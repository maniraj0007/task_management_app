import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/social_login_buttons.dart';

/// Login Screen
/// Provides user authentication interface with email/password and social login options
class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.paddingXLarge),
              
              // App Logo and Title
              _buildHeader(),
              
              const SizedBox(height: AppDimensions.paddingXLarge),
              
              // Login Form
              _buildLoginForm(),
              
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
        // App Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.task_alt,
            size: 50,
            color: AppColors.onPrimary,
          ),
        ),
        
        const SizedBox(height: AppDimensions.paddingLarge),
        
        // App Title
        Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: AppDimensions.paddingSmall),
        
        Text(
          'Welcome back! Sign in to continue',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: controller.loginFormKey,
      child: Column(
        children: [
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
            hintText: 'Enter your password',
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
          
          // Remember Me and Forgot Password
          Row(
            children: [
              Obx(() => Checkbox(
                value: controller.rememberMe.value,
                onChanged: (value) => controller.rememberMe.value = value ?? false,
                activeColor: AppColors.primary,
              )),
              
              Text(
                'Remember me',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              
              const Spacer(),
              
              TextButton(
                onPressed: () => Get.toNamed('/forgot-password'),
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Login Button
          Obx(() => AuthButton(
            text: 'Sign In',
            onPressed: controller.isLoading.value ? null : controller.login,
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
        // Sign Up Link
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
        
        // Terms and Privacy
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
          child: Text(
            'By signing in, you agree to our Terms of Service and Privacy Policy',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}
