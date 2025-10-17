import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/validators.dart';
import '../../../core/enums/user_roles.dart';
import '../services/auth_service.dart';

/// Register Controller
/// Manages registration form state and user creation logic
class RegisterController extends GetxController {
  static RegisterController get instance => Get.find<RegisterController>();
  
  final AuthService _authService = Get.find<AuthService>();
  
  // Form controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  // Reactive state
  final RxBool _isLoading = false.obs;
  final RxBool _isPasswordVisible = false.obs;
  final RxBool _isConfirmPasswordVisible = false.obs;
  final RxBool _acceptTerms = false.obs;
  final RxBool _acceptPrivacy = false.obs;
  final Rx<UserRole> _selectedRole = UserRole.teamMember.obs;
  
  // Getters
  bool get isLoading => _isLoading.value;
  bool get isPasswordVisible => _isPasswordVisible.value;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible.value;
  bool get acceptTerms => _acceptTerms.value;
  bool get acceptPrivacy => _acceptPrivacy.value;
  UserRole get selectedRole => _selectedRole.value;
  
  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }
  
  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
  
  /// Initialize controller with default values
  void _initializeController() {
    // Pre-fill email if passed from login screen
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['email'] != null) {
      emailController.text = args['email'];
    }
  }
  
  /// Toggle password visibility
  void togglePasswordVisibility() {
    _isPasswordVisible.value = !_isPasswordVisible.value;
  }
  
  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible.value = !_isConfirmPasswordVisible.value;
  }
  
  /// Toggle terms acceptance
  void toggleAcceptTerms(bool? value) {
    _acceptTerms.value = value ?? false;
  }
  
  /// Toggle privacy policy acceptance
  void toggleAcceptPrivacy(bool? value) {
    _acceptPrivacy.value = value ?? false;
  }
  
  /// Set selected role
  void setSelectedRole(UserRole role) {
    _selectedRole.value = role;
  }
  
  /// Validate first name
  String? validateFirstName(String? value) {
    return Validators.validateName(value, 'First name');
  }
  
  /// Validate last name
  String? validateLastName(String? value) {
    return Validators.validateName(value, 'Last name');
  }
  
  /// Validate email
  String? validateEmail(String? value) {
    return Validators.validateEmail(value);
  }
  
  /// Validate phone number
  String? validatePhone(String? value) {
    return Validators.validatePhoneNumber(value);
  }
  
  /// Validate password
  String? validatePassword(String? value) {
    return Validators.validatePassword(value);
  }
  
  /// Validate confirm password
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
  
  /// Register new user
  Future<void> registerUser() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    if (!_acceptTerms.value || !_acceptPrivacy.value) {
      Get.snackbar(
        'Terms Required',
        'Please accept the Terms of Service and Privacy Policy to continue',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange,
      );
      return;
    }
    
    try {
      _isLoading.value = true;
      
      final user = await _authService.registerWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phoneNumber: phoneController.text.trim().isNotEmpty 
            ? phoneController.text.trim() 
            : null,
        role: _selectedRole.value,
      );
      
      if (user != null) {
        // Show success message
        Get.snackbar(
          'Registration Successful',
          'Welcome to TaskMaster Pro, ${user.firstName}! Please verify your email.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          duration: const Duration(seconds: 4),
        );
        
        // Navigate to email verification screen
        Get.offAllNamed('/email-verification');
      } else {
        // Error is handled by the auth service
        _clearPasswordFields();
      }
    } catch (e) {
      Get.snackbar(
        'Registration Failed',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      _clearPasswordFields();
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Navigate to login screen
  void navigateToLogin() {
    Get.offNamed('/login');
  }
  
  /// Navigate to terms of service
  void navigateToTerms() {
    Get.toNamed('/terms-of-service');
  }
  
  /// Navigate to privacy policy
  void navigateToPrivacy() {
    Get.toNamed('/privacy-policy');
  }
  
  /// Clear password fields for security
  void _clearPasswordFields() {
    passwordController.clear();
    confirmPasswordController.clear();
  }
  
  /// Clear all form fields
  void clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    _isPasswordVisible.value = false;
    _isConfirmPasswordVisible.value = false;
    _acceptTerms.value = false;
    _acceptPrivacy.value = false;
    _selectedRole.value = UserRole.teamMember;
  }
  
  /// Check if form is valid
  bool get isFormValid {
    return firstNameController.text.trim().isNotEmpty &&
           lastNameController.text.trim().isNotEmpty &&
           emailController.text.trim().isNotEmpty &&
           passwordController.text.isNotEmpty &&
           confirmPasswordController.text.isNotEmpty &&
           passwordController.text == confirmPasswordController.text &&
           _acceptTerms.value &&
           _acceptPrivacy.value &&
           Validators.validateName(firstNameController.text.trim(), 'First name') == null &&
           Validators.validateName(lastNameController.text.trim(), 'Last name') == null &&
           Validators.validateEmail(emailController.text.trim()) == null &&
           Validators.validatePassword(passwordController.text) == null;
  }
  
  /// Get available roles for selection
  List<UserRole> get availableRoles {
    // For now, allow users to select Team Member or Viewer
    // Admin roles should be assigned by existing admins
    return [UserRole.teamMember, UserRole.viewer];
  }
  
  /// Get role description for UI
  String getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.teamMember:
        return 'Can create and manage personal tasks, collaborate on team projects';
      case UserRole.viewer:
        return 'Read-only access to assigned tasks and projects';
      case UserRole.admin:
        return 'Can manage teams, assign tasks, and moderate content';
      case UserRole.superAdmin:
        return 'Full system control with all administrative privileges';
    }
  }
  
  /// Auto-fill demo data for testing
  void fillDemoData() {
    firstNameController.text = 'John';
    lastNameController.text = 'Doe';
    emailController.text = 'john.doe@example.com';
    phoneController.text = '+1234567890';
    passwordController.text = 'Demo123!';
    confirmPasswordController.text = 'Demo123!';
    _acceptTerms.value = true;
    _acceptPrivacy.value = true;
  }
  
  /// Validate password strength and show feedback
  String getPasswordStrengthText() {
    final password = passwordController.text;
    if (password.isEmpty) return '';
    
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    switch (strength) {
      case 0:
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Fair';
      case 4:
        return 'Good';
      case 5:
        return 'Strong';
      default:
        return '';
    }
  }
  
  /// Get password strength color
  Color getPasswordStrengthColor() {
    final password = passwordController.text;
    if (password.isEmpty) return Colors.grey;
    
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    switch (strength) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
