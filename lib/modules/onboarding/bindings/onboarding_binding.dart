import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';

/// Onboarding Binding
/// Manages dependency injection for onboarding screens
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}
