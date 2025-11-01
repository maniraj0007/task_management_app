import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/enums/user_roles.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Main Authentication Controller
/// Manages authentication state and provides reactive access to user data
class AuthController extends GetxController {
  static AuthController get instance => Get.find<AuthController>();
  
  final AuthService _authService = Get.find<AuthService>();
  
  // Form controllers
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  
  // Reactive state
  final RxBool _isLoading = false.obs;
  final RxBool _isInitialized = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxBool isConfirmPasswordHidden = true.obs;
  final RxBool rememberMe = false.obs;
  
  // Getters
  bool get isLoading => _isLoading.value;
  bool get isInitialized => _isInitialized.value;
  bool get isLoggedIn => _authService.isLoggedIn;
  bool get isEmailVerified => _authService.isEmailVerified;
  UserModel? get currentUser => _authService.currentUser;
  
  // Form validation getters
  String? get validateFirstName {
    final firstName = firstNameController.text.trim();
    if (firstName.isEmpty) {
      return 'First name is required';
    }
    if (firstName.length < 2) {
      return 'First name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(firstName)) {
      return 'First name can only contain letters and spaces';
    }
    return null;
  }
  
  String? get validateLastName {
    final lastName = lastNameController.text.trim();
    if (lastName.isEmpty) {
      return 'Last name is required';
    }
    if (lastName.length < 2) {
      return 'Last name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(lastName)) {
      return 'Last name can only contain letters and spaces';
    }
    return null;
  }
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeController();
  }
  
  /// Initialize the authentication controller
  Future<void> _initializeController() async {
    try {
      _isLoading.value = true;
      
      // Wait for auth service to be ready
      await Future.delayed(const Duration(milliseconds: 100));
      
      _isInitialized.value = true;
      _isLoading.value = false;
      
      // Listen to auth state changes
      // Note: We'll implement proper reactive listeners when the auth service exposes them
      // For now, we'll use periodic checks or implement proper reactive streams
      
    } catch (e) {
      _isLoading.value = false;
      Get.snackbar(
        'Initialization Error',
        'Failed to initialize authentication',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  /// Handle authentication state changes
  void _onAuthStateChanged(dynamic user) {
    if (user != null) {
      // User signed in - navigate to appropriate screen based on role
      _navigateBasedOnRole();
    } else {
      // User signed out - navigate to login
      Get.offAllNamed('/login');
    }
  }
  
  /// Handle user data changes
  void _onUserDataChanged(UserModel? user) {
    if (user != null) {
      // Update UI based on user role or preferences
      _updateUIBasedOnUser(user);
    }
  }
  
  /// Navigate based on user role
  void _navigateBasedOnRole() {
    if (currentUser == null) return;
    
    switch (currentUser!.role) {
      case UserRole.superAdmin:
        Get.offAllNamed('/admin/dashboard');
        break;
      case UserRole.admin:
        Get.offAllNamed('/admin/dashboard');
        break;
      case UserRole.teamMember:
        Get.offAllNamed('/dashboard');
        break;
      case UserRole.viewer:
        Get.offAllNamed('/dashboard');
        break;
    }
  }
  
  /// Update UI based on user preferences
  void _updateUIBasedOnUser(UserModel user) {
    // Update theme based on user preferences
    if (user.preferences.theme != 'system') {
      // Update theme controller
      // This will be implemented when theme controller is integrated
    }
  }
  
  // ==================== FORM METHODS ====================
  
  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }
  
  /// Validate email field
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
  
  /// Validate password field
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
  
  /// Validate name field
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }
  
  /// Clear form fields
  void clearFormFields() {
    emailController.clear();
    passwordController.clear();
    firstNameController.clear();
    lastNameController.clear();
    phoneController.clear();
    isPasswordHidden.value = true;
    rememberMe.value = false;
  }
  
  // ==================== AUTHENTICATION METHODS ====================
  
  /// Login with email and password
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;
    
    try {
      _isLoading.value = true;
      
      final user = await _authService.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      
      if (user != null) {
        Get.snackbar(
          'Success',
          'Signed in successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Navigate based on user role
        _navigateBasedOnRole();
        
        // Clear form if not remembering
        if (!rememberMe.value) {
          clearFormFields();
        }
      } else {
        Get.snackbar(
          'Login Failed',
          'Invalid email or password',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Register new user
  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;
    
    try {
      _isLoading.value = true;
      
      final user = await _authService.registerWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phoneNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
      );
      
      if (user != null) {
        Get.snackbar(
          'Success',
          'Registration successful! Please verify your email.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Navigate to email verification screen or main app
        Get.offAllNamed('/main-navigation');
        clearFormFields();
      } else {
        Get.snackbar(
          'Registration Failed',
          'Failed to create account. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    Get.snackbar(
      'Coming Soon',
      'Google Sign In will be available in a future update',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }
  
  /// Sign in with Apple (placeholder)
  Future<void> signInWithApple() async {
    Get.snackbar(
      'Coming Soon',
      'Apple Sign In will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  /// Sign in with Facebook (placeholder)
  Future<void> signInWithFacebook() async {
    Get.snackbar(
      'Coming Soon',
      'Facebook Sign In will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _isLoading.value = true;
      
      final success = await _authService.sendPasswordResetEmail(email);
      
      if (success) {
        Get.snackbar(
          'Success',
          'Password reset email sent successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to send password reset email',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send password reset email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Sign out current user
  Future<void> signOut() async {
    try {
      _isLoading.value = true;
      await _authService.signOut();
      
      Get.snackbar(
        'Success',
        'Signed out successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Navigate to login screen
      Get.offAllNamed('/login');
      clearFormFields();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign out',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Reload current user data
  Future<void> reloadUser() async {
    try {
      await _authService.reloadUser();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reload user data',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      _isLoading.value = true;
      final success = await _authService.sendEmailVerification();
      
      if (success) {
        Get.snackbar(
          'Success',
          'Verification email sent successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to send verification email',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      _isLoading.value = false;
    }
  }
  
  // ==================== PERMISSION METHODS ====================
  
  /// Check if current user has specific permission
  bool hasPermission(String permission) {
    return _authService.hasPermission(permission);
  }
  
  /// Check if current user has specific role
  bool hasRole(UserRole role) {
    return _authService.hasRole(role);
  }
  
  /// Check if current user has minimum role level
  bool hasMinimumRole(UserRole minimumRole) {
    return _authService.hasMinimumRole(minimumRole);
  }
  
  /// Check if current user can access admin features
  bool get canAccessAdmin => hasPermission('access_admin');
  
  /// Check if current user can access super admin features
  bool get canAccessSuperAdmin => hasPermission('access_super_admin');
  
  /// Check if current user can create tasks
  bool get canCreateTasks => hasPermission('create_tasks');
  
  /// Check if current user can edit tasks
  bool get canEditTasks => hasPermission('edit_tasks');
  
  /// Check if current user can delete tasks
  bool get canDeleteTasks => hasPermission('delete_tasks');
  
  /// Check if current user can manage teams
  bool get canManageTeams => hasPermission('manage_teams');
  
  /// Check if current user can manage projects
  bool get canManageProjects => hasPermission('manage_projects');
  
  /// Check if current user can view analytics
  bool get canViewAnalytics => hasPermission('view_analytics');
  
  // ==================== UTILITY METHODS ====================
  
  /// Get current user token
  Future<String?> getCurrentUserToken() async {
    return await _authService.getCurrentUserToken();
  }
  
  /// Refresh current user token
  Future<String?> refreshUserToken() async {
    return await _authService.refreshUserToken();
  }
  
  /// Get user display name
  String get userDisplayName {
    if (currentUser == null) return 'Guest';
    return currentUser!.name;
  }
  
  /// Get user initials for avatar
  String get userInitials {
    if (currentUser == null) return 'G';
    return currentUser!.initials;
  }
  
  /// Get user role display name
  String get userRoleDisplayName {
    if (currentUser == null) return 'Guest';
    return currentUser!.role.displayName;
  }
  
  /// Get user role color
  String get userRoleColor {
    if (currentUser == null) return '#9E9E9E';
    return currentUser!.role.colorHex;
  }
  
  /// Check if user profile is complete
  bool get isProfileComplete {
    if (currentUser == null) return false;
    
    return currentUser!.firstName.isNotEmpty &&
           currentUser!.lastName.isNotEmpty &&
           currentUser!.email.isNotEmpty;
  }
  
  /// Check if user needs to verify email
  bool get needsEmailVerification {
    return isLoggedIn && !isEmailVerified;
  }
  
  /// Get user completion percentage
  double get profileCompletionPercentage {
    if (currentUser == null) return 0.0;
    
    int completedFields = 0;
    int totalFields = 6;
    
    if (currentUser!.firstName.isNotEmpty) completedFields++;
    if (currentUser!.lastName.isNotEmpty) completedFields++;
    if (currentUser!.email.isNotEmpty) completedFields++;
    if (currentUser!.phoneNumber?.isNotEmpty == true) completedFields++;
    if (currentUser!.photoUrl?.isNotEmpty == true) completedFields++;
    if (isEmailVerified) completedFields++;
    
    return completedFields / totalFields;
  }
  
  /// Show role-based welcome message
  void showWelcomeMessage() {
    if (currentUser == null) return;
    
    String message;
    switch (currentUser!.role) {
      case UserRole.superAdmin:
        message = 'Welcome back, Super Admin! You have full system control.';
        break;
      case UserRole.admin:
        message = 'Welcome back, Admin! Ready to manage your teams?';
        break;
      case UserRole.teamMember:
        message = 'Welcome back! Let\'s get productive today.';
        break;
      case UserRole.viewer:
        message = 'Welcome back! Check out the latest updates.';
        break;
    }
    
    Get.snackbar(
      'Welcome, ${currentUser!.firstName}!',
      message,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }
  
  /// Handle app lifecycle changes
  void handleAppLifecycleChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App resumed - refresh user token if needed
        refreshUserToken();
        break;
      case AppLifecycleState.paused:
        // App paused - save any pending data
        break;
      case AppLifecycleState.detached:
        // App detached - cleanup if needed
        break;
      case AppLifecycleState.inactive:
        // App inactive - pause operations
        break;
      case AppLifecycleState.hidden:
        // App hidden - pause operations
        break;
    }
  }
  
  @override
  void onClose() {
    // Dispose of text controllers
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
