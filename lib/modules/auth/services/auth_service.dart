import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../core/services/error_handler_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/enums/user_roles.dart';
import '../models/user_model.dart';
import 'user_service.dart';

/// Firebase Authentication Service
/// Handles all authentication operations including login, register, logout, etc.
class AuthService extends GetxService {
  static AuthService get instance => Get.find<AuthService>();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = Get.find<UserService>();
  
  // Reactive user state
  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  
  // Getters
  User? get firebaseUser => _firebaseUser.value;
  UserModel? get currentUser => _currentUser.value;
  bool get isLoggedIn => _firebaseUser.value != null;
  bool get isAuthenticated => _firebaseUser.value != null;
  bool get isEmailVerified => _firebaseUser.value?.emailVerified ?? false;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeAuthService();
  }
  
  /// Initialize authentication service
  Future<void> _initializeAuthService() async {
    try {
      // Set initial user state
      _firebaseUser.value = _auth.currentUser;
      
      // Listen to auth state changes
      _auth.authStateChanges().listen(_onAuthStateChanged);
      
      // Load current user if logged in
      if (_firebaseUser.value != null) {
        await _loadCurrentUser();
      }
      
      ErrorHandlerService.instance.logInfo('Auth service initialized successfully');
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Auth Service Initialization',
        severity: ErrorSeverity.critical,
      );
    }
  }
  
  /// Handle authentication state changes
  Future<void> _onAuthStateChanged(User? user) async {
    try {
      _firebaseUser.value = user;
      
      if (user != null) {
        // User signed in
        await _loadCurrentUser();
        await _updateLastLoginTime();
        ErrorHandlerService.instance.logInfo('User signed in: ${user.email}');
      } else {
        // User signed out
        _currentUser.value = null;
        await _clearUserData();
        ErrorHandlerService.instance.logInfo('User signed out');
      }
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Auth State Change',
        severity: ErrorSeverity.medium,
      );
    }
  }
  
  /// Load current user data from Firestore
  Future<void> _loadCurrentUser() async {
    try {
      if (_firebaseUser.value == null) return;
      
      final userModel = await _userService.getUserById(_firebaseUser.value!.uid);
      _currentUser.value = userModel;
      
      // Store user data locally
      if (userModel != null) {
        await StorageService.instance.setUserData(userModel.toJson());
      }
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Load Current User',
        severity: ErrorSeverity.medium,
      );
    }
  }
  
  /// Update last login time
  Future<void> _updateLastLoginTime() async {
    try {
      if (_firebaseUser.value == null) return;
      
      await _userService.updateUser(
        _firebaseUser.value!.uid,
        {'lastLoginAt': FieldValue.serverTimestamp()},
      );
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Update Last Login Time',
        severity: ErrorSeverity.low,
      );
    }
  }
  
  /// Clear user data from local storage
  Future<void> _clearUserData() async {
    try {
      await StorageService.instance.removeUserData();
      await StorageService.instance.removeUserToken();
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Clear User Data',
        severity: ErrorSeverity.low,
      );
    }
  }
  
  // ==================== AUTHENTICATION METHODS ====================
  
  /// Register new user with email and password
  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    UserRole role = UserRole.teamMember,
  }) async {
    try {
      // Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        throw Exception('Failed to create user account');
      }
      
      // Update display name
      await credential.user!.updateDisplayName('$firstName $lastName');
      
      // Create user model
      final userModel = UserModel.fromFirebaseUser(
        uid: credential.user!.uid,
        email: email,
        displayName: '$firstName $lastName',
        phoneNumber: phoneNumber,
        isEmailVerified: credential.user!.emailVerified,
        role: role,
      ).copyWith(
        firstName: firstName,
        lastName: lastName,
      );
      
      // Save user to Firestore
      await _userService.createUser(userModel);
      
      // Send email verification
      await sendEmailVerification();
      
      ErrorHandlerService.instance.logInfo('User registered successfully: $email');
      return userModel;
      
    } on FirebaseAuthException catch (e) {
      ErrorHandlerService.instance.handleError(
        AuthException(_getAuthErrorMessage(e.code)),
        context: 'Register User',
        severity: ErrorSeverity.medium,
        showToUser: true,
      );
      return null;
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Register User',
        severity: ErrorSeverity.medium,
        showToUser: true,
      );
      return null;
    }
  }
  
  /// Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        throw Exception('Failed to sign in');
      }
      
      // Get user token for API calls
      final token = await credential.user!.getIdToken();
      await StorageService.instance.setUserToken(token);
      
      ErrorHandlerService.instance.logInfo('User signed in successfully: $email');
      return _currentUser.value;
      
    } on FirebaseAuthException catch (e) {
      ErrorHandlerService.instance.handleError(
        AuthException(_getAuthErrorMessage(e.code)),
        context: 'Sign In User',
        severity: ErrorSeverity.medium,
        showToUser: true,
      );
      return null;
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Sign In User',
        severity: ErrorSeverity.medium,
        showToUser: true,
      );
      return null;
    }
  }
  
  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      ErrorHandlerService.instance.logInfo('User signed out successfully');
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Sign Out User',
        severity: ErrorSeverity.medium,
        showToUser: true,
      );
    }
  }
  
  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ErrorHandlerService.instance.logInfo('Password reset email sent to: $email');
      return true;
    } on FirebaseAuthException catch (e) {
      ErrorHandlerService.instance.handleError(
        AuthException(_getAuthErrorMessage(e.code)),
        context: 'Send Password Reset Email',
        severity: ErrorSeverity.medium,
        showToUser: true,
      );
      return false;
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Send Password Reset Email',
        severity: ErrorSeverity.medium,
        showToUser: true,
      );
      return false;
    }
  }
  
  /// Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      if (_firebaseUser.value == null) {
        throw Exception('No user signed in');
      }
      
      await _firebaseUser.value!.sendEmailVerification();
      ErrorHandlerService.instance.logInfo('Email verification sent');
      return true;
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Send Email Verification',
        severity: ErrorSeverity.medium,
        showToUser: true,
      );
      return false;
    }
  }
  
  /// Reload current user to check email verification status
  Future<void> reloadUser() async {
    try {
      if (_firebaseUser.value == null) return;
      
      await _firebaseUser.value!.reload();
      _firebaseUser.value = _auth.currentUser;
      
      // Update user model if email verification status changed
      if (_currentUser.value != null && 
          _currentUser.value!.isEmailVerified != isEmailVerified) {
        await _userService.updateUser(
          _currentUser.value!.id,
          {'isEmailVerified': isEmailVerified},
        );
        await _loadCurrentUser();
      }
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Reload User',
        severity: ErrorSeverity.low,
      );
    }
  }
  
  /// Change user password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (_firebaseUser.value == null) {
        throw Exception('No user signed in');
      }
      
      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: _firebaseUser.value!.email!,
        password: currentPassword,
      );
      
      await _firebaseUser.value!.reauthenticateWithCredential(credential);
      
      // Update password
      await _firebaseUser.value!.updatePassword(newPassword);
      
      ErrorHandlerService.instance.logInfo('Password changed successfully');
      return true;
      
    } on FirebaseAuthException catch (e) {
      ErrorHandlerService.instance.handleError(
        AuthException(_getAuthErrorMessage(e.code)),
        context: 'Change Password',
        severity: ErrorSeverity.medium,
        showToUser: true,
      );
      return false;
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Change Password',
        severity: ErrorSeverity.medium,
        showToUser: true,
      );
      return false;
    }
  }
  
  /// Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      if (_firebaseUser.value == null) {
        throw Exception('No user signed in');
      }
      
      await _firebaseUser.value!.updateDisplayName(displayName);
      await _firebaseUser.value!.updatePhotoURL(photoUrl);
      
      // Update user model in Firestore
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      updates['updatedAt'] = FieldValue.serverTimestamp();
      
      await _userService.updateUser(_firebaseUser.value!.uid, updates);
      await _loadCurrentUser();
      
      ErrorHandlerService.instance.logInfo('Profile updated successfully');
      return true;
      
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Update Profile',
        severity: ErrorSeverity.medium,
        showToUser: true,
      );
      return false;
    }
  }
  
  /// Delete user account
  Future<bool> deleteAccount(String password) async {
    try {
      if (_firebaseUser.value == null) {
        throw Exception('No user signed in');
      }
      
      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: _firebaseUser.value!.email!,
        password: password,
      );
      
      await _firebaseUser.value!.reauthenticateWithCredential(credential);
      
      // Delete user data from Firestore
      await _userService.deleteUser(_firebaseUser.value!.uid);
      
      // Delete Firebase Auth user
      await _firebaseUser.value!.delete();
      
      ErrorHandlerService.instance.logInfo('Account deleted successfully');
      return true;
      
    } on FirebaseAuthException catch (e) {
      ErrorHandlerService.instance.handleError(
        AuthException(_getAuthErrorMessage(e.code)),
        context: 'Delete Account',
        severity: ErrorSeverity.high,
        showToUser: true,
      );
      return false;
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Delete Account',
        severity: ErrorSeverity.high,
        showToUser: true,
      );
      return false;
    }
  }
  
  // ==================== HELPER METHODS ====================
  
  /// Get user-friendly error message from Firebase Auth error code
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      case 'credential-already-in-use':
        return 'This credential is already associated with another account.';
      case 'invalid-credential':
        return 'The provided credential is invalid.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      default:
        return 'An authentication error occurred. Please try again.';
    }
  }
  
  /// Check if user has specific permission
  bool hasPermission(String permission) {
    return _currentUser.value?.hasPermission(permission) ?? false;
  }
  
  /// Check if user has specific role
  bool hasRole(UserRole role) {
    return _currentUser.value?.role == role;
  }
  
  /// Check if user has minimum role level
  bool hasMinimumRole(UserRole minimumRole) {
    return _currentUser.value?.role.hasPermissionLevel(minimumRole) ?? false;
  }
  
  /// Get current user token
  Future<String?> getCurrentUserToken() async {
    try {
      if (_firebaseUser.value == null) return null;
      return await _firebaseUser.value!.getIdToken();
    } catch (e) {
      return null;
    }
  }
  
  /// Refresh current user token
  Future<String?> refreshUserToken() async {
    try {
      if (_firebaseUser.value == null) return null;
      final token = await _firebaseUser.value!.getIdToken(true);
      await StorageService.instance.setUserToken(token);
      return token;
    } catch (e) {
      return null;
    }
  }
}

/// Custom authentication exception
class AuthException implements Exception {
  final String message;
  
  const AuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}
