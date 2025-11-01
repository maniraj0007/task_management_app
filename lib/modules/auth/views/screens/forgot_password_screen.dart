import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_button.dart';

/// Forgot Password Screen
/// Allows users to reset their password via email
class ForgotPasswordScreen extends GetView<AuthController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.paddingXLarge),
              
              // Header
              _buildHeader(),
              
              const SizedBox(height: AppDimensions.paddingXLarge),
              
              // Reset Form
              _buildResetForm(formKey, emailController),
              
              const SizedBox(height: AppDimensions.paddingLarge),
              
              // Navigation Links
              _buildNavigationLinks(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          ),
          child: Icon(
            Icons.lock_reset,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        
        const SizedBox(height: AppDimensions.paddingLarge),
        
        // Title
        Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: AppDimensions.paddingSmall),
        
        Text(
          'No worries! Enter your email address and we\'ll send you a link to reset your password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildResetForm(GlobalKey<FormState> formKey, TextEditingController emailController) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Email Field
          AuthFormField(
            controller: emailController,
            label: 'Email Address',
            hintText: 'Enter your registered email address',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: controller.validateEmail,
          ),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Send Reset Link Button
          Obx(() => AuthButton(
            text: 'Send Reset Link',
            onPressed: controller.isLoading 
                ? null 
                : () => _handlePasswordReset(formKey, emailController),
            isLoading: controller.isLoading,
          )),
          
          const SizedBox(height: AppDimensions.paddingMedium),
          
          // Instructions
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                Expanded(
                  child: Text(
                    'Check your email inbox and spam folder for the reset link.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationLinks() {
    return Column(
      children: [
        // Back to Login Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Remember your password? ',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Sign In',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppDimensions.paddingMedium),
        
        // Create Account Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/register'),
              child: Text(
                'Sign Up',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handlePasswordReset(GlobalKey<FormState> formKey, TextEditingController emailController) {
    if (formKey.currentState!.validate()) {
      controller.sendPasswordResetEmail(emailController.text.trim());
    }
  }
}
