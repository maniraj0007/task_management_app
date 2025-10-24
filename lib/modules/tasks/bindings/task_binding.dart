import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../controllers/enhanced_task_controller.dart';
import '../controllers/task_list_controller.dart';
import '../controllers/task_form_controller.dart';
import '../controllers/task_detail_controller.dart';
import '../controllers/create_task_controller.dart';
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
    Get.lazyPut<EnhancedTaskController>(() => EnhancedTaskController());
    Get.lazyPut<TaskListController>(() => TaskListController());
    Get.lazyPut<TaskFormController>(() => TaskFormController());
    Get.lazyPut<TaskDetailController>(() => TaskDetailController());
    Get.lazyPut<CreateTaskController>(() => CreateTaskController());
  }
}
