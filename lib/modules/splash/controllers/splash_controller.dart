import 'package:get/get.dart';
import '../../auth/services/auth_service.dart';
import '../../../routes/app_routes.dart';

/// Splash Controller
/// Handles splash screen logic and navigation
class SplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }
  
  /// Initialize app and navigate to appropriate screen
  Future<void> _initializeApp() async {
    // Show splash for minimum duration
    await Future.delayed(const Duration(seconds: 2));
    
    // Check authentication status
    if (_authService.isLoggedIn) {
      // User is authenticated, go to main navigation
      Get.offAllNamed(AppRoutes.mainNavigation);
    } else {
      // User is not authenticated, go to login
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
