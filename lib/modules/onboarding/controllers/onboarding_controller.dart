import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../core/services/storage_service.dart';

/// Onboarding Controller
/// Handles onboarding flow logic and navigation
class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final StorageService _storageService = Get.find<StorageService>();
  
  // Onboarding pages data
  final List<OnboardingPageData> pages = [
    OnboardingPageData(
      title: 'Welcome to TaskMaster',
      description: 'Organize your tasks efficiently with our powerful task management system.',
      image: 'assets/images/onboarding_1.png',
    ),
    OnboardingPageData(
      title: 'Team Collaboration',
      description: 'Work together with your team members and track progress in real-time.',
      image: 'assets/images/onboarding_2.png',
    ),
    OnboardingPageData(
      title: 'Stay Organized',
      description: 'Keep track of deadlines, priorities, and never miss an important task.',
      image: 'assets/images/onboarding_3.png',
    ),
  ];
  
  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
  
  /// Navigate to next page
  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }
  
  /// Navigate to previous page
  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  /// Skip onboarding
  void skipOnboarding() {
    _completeOnboarding();
  }
  
  /// Complete onboarding and navigate to login
  void _completeOnboarding() {
    _storageService.setOnboardingCompleted(true);
    Get.offAllNamed(AppRoutes.login);
  }
  
  /// Update current page index
  void updatePageIndex(int index) {
    currentPage.value = index;
  }
}

/// Onboarding page data model
class OnboardingPageData {
  final String title;
  final String description;
  final String image;
  
  OnboardingPageData({
    required this.title,
    required this.description,
    required this.image,
  });
}
