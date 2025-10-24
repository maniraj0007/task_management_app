import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

/// Auth Binding
/// Manages dependency injection for authentication screens
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
