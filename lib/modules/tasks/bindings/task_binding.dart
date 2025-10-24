import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../controllers/task_list_controller.dart';
import '../services/task_service.dart';

/// Task Binding
/// Handles dependency injection for task-related controllers and services
class TaskBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<TaskService>(() => TaskService());
    
    // Controllers
    Get.lazyPut<TaskController>(() => TaskController());
    Get.lazyPut<TaskListController>(() => TaskListController());
  }
}
