import 'package:get/get.dart';
import '../controllers/task_detail_controller.dart';
import '../services/task_service.dart';

/// Task Detail Binding
/// Handles dependency injection for task detail functionality
class TaskDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<TaskService>(() => TaskService());
    
    // Controllers
    Get.lazyPut<TaskDetailController>(() => TaskDetailController());
  }
}
