import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/validators.dart';
import '../services/auth_service.dart';

/// Login Controller
/// Manages login form state and authentication logic
class LoginController extends GetxController {
  static LoginController get instance => Get.find<LoginController>();
  
  final AuthService _authService = Get.find<AuthService>();
  
  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  // Reactive state
  final RxBool _isLoading = false.obs;
  final RxBool _isPasswordVisible = false.obs;
  final RxBool _rememberMe = false.obs;
  
  // Getters
  bool get isLoading => _isLoading.value;
  bool get isPasswordVisible => _isPasswordVisible.value;
  bool get rememberMe => _rememberMe.value;
  
  @override
  void onInit() {
    super.onInit();
    _loadSavedCredentials();
  }
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
  
  /// Load saved credentials if remember me was enabled
  void _loadSavedCredentials() {
    // TODO: Implement loading saved credentials from storage
    // This will be implemented when storage service is integrated
  }
  
  /// Toggle password visibility
  void togglePasswordVisibility() {
    _isPasswordVisible.value = !_isPasswordVisible.value;
  }
  
  /// Toggle remember me
  void toggleRememberMe(bool? value) {
    _rememberMe.value = value ?? false;
  }
  
  /// Validate email field
  String? validateEmail(String? value) {
    return Validators.validateEmail(value);
  }
  
  /// Validate password field
  String? validatePassword(String? value) {
    return Validators.validatePassword(value);
  }
  
  /// Sign in with email and password
  Future<void> signInWithEmailAndPassword() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    try {
      _isLoading.value = true;
      
      final user = await _authService.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      
      if (user != null) {
        // Save credentials if remember me is enabled
        if (_rememberMe.value) {
          await _saveCredentials();
        }
        
        // Show success message
        Get.snackbar(
          'Success',
          'Welcome back, ${user.firstName}!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          duration: const Duration(seconds: 2),
        );
        
        // Navigate based on user role
        _navigateBasedOnRole(user);
      } else {
        // Error is handled by the auth service
        _clearPasswordField();
      }
    } catch (e) {
      Get.snackbar(
        'Login Failed',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      _clearPasswordField();
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Navigate to forgot password screen
  void navigateToForgotPassword() {
    Get.toNamed('/forgot-password', arguments: {
      'email': emailController.text.trim(),
    });
  }
  
  /// Navigate to register screen
  void navigateToRegister() {
    Get.toNamed('/register');
  }
  
  /// Navigate based on user role
  void _navigateBasedOnRole(dynamic user) {
    // This will be handled by the main AuthController
    // For now, just navigate to dashboard
    Get.offAllNamed('/dashboard');
  }
  
  /// Save credentials for remember me functionality
  Future<void> _saveCredentials() async {
    // TODO: Implement saving credentials to secure storage
    // This will be implemented when storage service is integrated
  }
  
  /// Clear password field for security
  void _clearPasswordField() {
    passwordController.clear();
  }
  
  /// Clear all form fields
  void clearForm() {
    emailController.clear();
    passwordController.clear();
    _isPasswordVisible.value = false;
    _rememberMe.value = false;
  }
  
  /// Auto-fill demo credentials for testing
  void fillDemoCredentials() {
    emailController.text = 'admin@taskmaster.com';
    passwordController.text = 'Admin123!';
  }
  
  /// Check if form is valid
  bool get isFormValid {
    return emailController.text.trim().isNotEmpty &&
           passwordController.text.isNotEmpty &&
           Validators.validateEmail(emailController.text.trim()) == null &&
           Validators.validatePassword(passwordController.text) == null;
  }
  
  /// Handle Google Sign In (placeholder for future implementation)
  Future<void> signInWithGoogle() async {
    try {
      _isLoading.value = true;
      
      // TODO: Implement Google Sign In
      Get.snackbar(
        'Coming Soon',
        'Google Sign In will be available in a future update',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Handle Apple Sign In (placeholder for future implementation)
  Future<void> signInWithApple() async {
    try {
      _isLoading.value = true;
      
      // TODO: Implement Apple Sign In
      Get.snackbar(
        'Coming Soon',
        'Apple Sign In will be available in a future update',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Handle biometric authentication (placeholder for future implementation)
  Future<void> signInWithBiometrics() async {
    try {
      _isLoading.value = true;
      
      // TODO: Implement biometric authentication
      Get.snackbar(
        'Coming Soon',
        'Biometric authentication will be available in a future update',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
