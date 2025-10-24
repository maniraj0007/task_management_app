import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import '../../analytics/controllers/analytics_controller.dart';
import '../../search/controllers/search_controller.dart';
import '../../notifications/controllers/notification_controller.dart';

/// Navigation Binding
/// Initializes navigation controller and related dependencies
class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    // Core navigation controller
    Get.lazyPut<NavigationController>(
      () => NavigationController(),
      fenix: true,
    );

    // Analytics controller for analytics screen
    Get.lazyPut<AnalyticsController>(
      () => AnalyticsController(),
      fenix: true,
    );

    // Search controller for search screen
    Get.lazyPut<SearchController>(
      () => SearchController(),
      fenix: true,
    );

    // Notification controller for notifications screen
    Get.lazyPut<NotificationController>(
      () => NotificationController(),
      fenix: true,
    );
  }
}
