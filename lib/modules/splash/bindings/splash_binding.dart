import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

/// Splash Binding
/// Manages dependency injection for splash screen
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
