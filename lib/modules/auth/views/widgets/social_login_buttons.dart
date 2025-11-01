import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/auth_controller.dart';

/// Social Login Buttons Widget
/// Provides social authentication options (Google, Apple, etc.)
class SocialLoginButtons extends GetView<AuthController> {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Google Sign In
        _buildSocialButton(
          text: 'Continue with Google',
          icon: Icons.g_mobiledata, // Using built-in icon, replace with custom if needed
          onPressed: controller.signInWithGoogle,
          backgroundColor: Colors.white,
          textColor: Colors.black87,
          borderColor: AppColors.outline.withOpacity(0.3),
        ),
        
        const SizedBox(height: AppDimensions.paddingMedium),
        
        // Apple Sign In (iOS only, but we'll show it for demo)
        _buildSocialButton(
          text: 'Continue with Apple',
          icon: Icons.apple,
          onPressed: controller.signInWithApple,
          backgroundColor: Colors.black,
          textColor: Colors.white,
        ),
        
        const SizedBox(height: AppDimensions.paddingMedium),
        
        // Facebook Sign In
        _buildSocialButton(
          text: 'Continue with Facebook',
          icon: Icons.facebook,
          onPressed: controller.signInWithFacebook,
          backgroundColor: const Color(0xFF1877F2),
          textColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: controller.isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 1,
          shadowColor: AppColors.shadow.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            side: borderColor != null 
                ? BorderSide(color: borderColor)
                : BorderSide.none,
          ),
          disabledBackgroundColor: backgroundColor.withOpacity(0.6),
          disabledForegroundColor: textColor.withOpacity(0.6),
        ),
        child: controller.isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: textColor,
                  ),
                  const SizedBox(width: AppDimensions.paddingMedium),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    ));
  }
}
