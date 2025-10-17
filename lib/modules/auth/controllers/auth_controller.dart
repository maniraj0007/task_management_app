import 'package:get/get.dart';
import '../../../core/enums/user_roles.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Main Authentication Controller
/// Manages authentication state and provides reactive access to user data
class AuthController extends GetxController {
  static AuthController get instance => Get.find<AuthController>();
  
  final AuthService _authService = Get.find<AuthService>();
  
  // Reactive state
  final RxBool _isLoading = false.obs;
  final RxBool _isInitialized = false.obs;
  
  // Getters
  bool get isLoading => _isLoading.value;
  bool get isInitialized => _isInitialized.value;
  bool get isLoggedIn => _authService.isLoggedIn;
  bool get isEmailVerified => _authService.isEmailVerified;
  UserModel? get currentUser => _authService.currentUser;
  
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
  
  // ==================== AUTHENTICATION METHODS ====================
  
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
}
