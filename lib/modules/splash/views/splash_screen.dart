import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../controllers/splash_controller.dart';

/// Splash Screen
/// Initial screen shown when app starts
/// Handles app initialization and navigation
class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              _buildAppLogo(context),
              
              const SizedBox(height: AppDimensions.paddingXL),
              
              // App Name
              _buildAppName(context),
              
              const SizedBox(height: AppDimensions.paddingM),
              
              // App Tagline
              _buildAppTagline(context),
              
              const SizedBox(height: AppDimensions.paddingXXL * 2),
              
              // Loading Indicator
              _buildLoadingIndicator(context),
              
              const SizedBox(height: AppDimensions.paddingL),
              
              // Loading Text
              _buildLoadingText(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Build app logo with animation
  Widget _buildAppLogo(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        Icons.task_alt_rounded,
        size: 60,
        color: Theme.of(context).colorScheme.primary,
      ),
    ).animate().scale(
      duration: 800.ms,
      curve: Curves.elasticOut,
    ).fadeIn(
      duration: 600.ms,
    );
  }

  /// Build app name with animation
  Widget _buildAppName(BuildContext context) {
    return Text(
      AppConstants.appName,
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
      textAlign: TextAlign.center,
    ).animate().slideY(
      begin: 0.3,
      duration: 800.ms,
      curve: Curves.easeOutBack,
    ).fadeIn(
      duration: 600.ms,
      delay: 200.ms,
    );
  }

  /// Build app tagline with animation
  Widget _buildAppTagline(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXL),
      child: Text(
        'Organize • Collaborate • Achieve',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white.withOpacity(0.9),
          fontWeight: FontWeight.w300,
          letterSpacing: 0.8,
        ),
        textAlign: TextAlign.center,
      ),
    ).animate().slideY(
      begin: 0.3,
      duration: 800.ms,
      curve: Curves.easeOutBack,
    ).fadeIn(
      duration: 600.ms,
      delay: 400.ms,
    );
  }

  /// Build loading indicator with animation
  Widget _buildLoadingIndicator(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.white.withOpacity(0.8),
        ),
      ),
    ).animate().fadeIn(
      duration: 600.ms,
      delay: 800.ms,
    ).scale(
      begin: const Offset(0.8, 0.8),
      duration: 400.ms,
      delay: 800.ms,
    );
  }

  /// Build loading text with animation
  Widget _buildLoadingText(BuildContext context) {
    return Text(
      'Initializing...',
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Colors.white.withOpacity(0.7),
        fontWeight: FontWeight.w300,
      ),
    ).animate().fadeIn(
      duration: 600.ms,
      delay: 1000.ms,
    ).shimmer(
      duration: 2000.ms,
      delay: 1200.ms,
      color: Colors.white.withOpacity(0.3),
    );
  }
}
