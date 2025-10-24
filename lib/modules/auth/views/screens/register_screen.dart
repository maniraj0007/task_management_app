import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/social_login_buttons.dart';

/// Register Screen
/// Provides user registration interface with form validation
class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(),
              
              const SizedBox(height: AppDimensions.paddingXLarge),
              
              // Registration Form
              _buildRegistrationForm(),
              
              const SizedBox(height: AppDimensions.paddingLarge),
              
              // Social Login Options
              _buildSocialLogin(),
              
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
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: AppDimensions.paddingSmall),
        
        Text(
          'Join ${AppConstants.appName} and start managing your tasks',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: controller.registerFormKey,
      child: Column(
        children: [
          // First Name and Last Name Row
          Row(
            children: [
              Expanded(
                child: AuthFormField(
                  controller: controller.firstNameController,
                  label: 'First Name',
                  hintText: 'Enter your first name',
                  prefixIcon: Icons.person_outlined,
                  validator: controller.validateFirstName,
                ),
              ),
              
              const SizedBox(width: AppDimensions.paddingMedium),
              
              Expanded(
                child: AuthFormField(
                  controller: controller.lastNameController,
                  label: 'Last Name',
                  hintText: 'Enter your last name',
                  prefixIcon: Icons.person_outlined,
                  validator: controller.validateLastName,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingMedium),
          
          // Email Field
          AuthFormField(
            controller: controller.emailController,
            label: 'Email',
            hintText: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: controller.validateEmail,
          ),
          
          const SizedBox(height: AppDimensions.paddingMedium),
          
          // Password Field
          Obx(() => AuthFormField(
            controller: controller.passwordController,
            label: 'Password',
            hintText: 'Create a strong password',
            obscureText: controller.isPasswordHidden.value,
            prefixIcon: Icons.lock_outlined,
            suffixIcon: IconButton(
              icon: Icon(
                controller.isPasswordHidden.value
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
            validator: controller.validatePassword,
          )),
          
          const SizedBox(height: AppDimensions.paddingMedium),
          
          // Confirm Password Field
          Obx(() => AuthFormField(
            controller: controller.confirmPasswordController,
            label: 'Confirm Password',
            hintText: 'Confirm your password',
            obscureText: controller.isConfirmPasswordHidden.value,
            prefixIcon: Icons.lock_outlined,
            suffixIcon: IconButton(
              icon: Icon(
                controller.isConfirmPasswordHidden.value
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: controller.toggleConfirmPasswordVisibility,
            ),
            validator: controller.validateConfirmPassword,
          )),
          
          const SizedBox(height: AppDimensions.paddingMedium),
          
          // Terms and Conditions Checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Checkbox(
                value: controller.acceptTerms.value,
                onChanged: (value) => controller.acceptTerms.value = value ?? false,
                activeColor: AppColors.primary,
              )),
              
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.acceptTerms.value = !controller.acceptTerms.value,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Register Button
          Obx(() => AuthButton(
            text: 'Create Account',
            onPressed: controller.isLoading.value ? null : controller.register,
            isLoading: controller.isLoading.value,
          )),
        ],
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        // Divider with "OR"
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppColors.outline.withOpacity(0.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
              child: Text(
                'OR',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppColors.outline.withOpacity(0.5),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppDimensions.paddingLarge),
        
        // Social Login Buttons
        const SocialLoginButtons(),
      ],
    );
  }

  Widget _buildNavigationLinks() {
    return Column(
      children: [
        // Sign In Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
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
      ],
    );
  }
}
