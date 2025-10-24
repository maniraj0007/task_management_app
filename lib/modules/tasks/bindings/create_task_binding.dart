import 'package:get/get.dart';
import '../controllers/create_task_controller.dart';
import '../controllers/task_form_controller.dart';
import '../services/task_service.dart';

/// Create Task Binding
/// Handles dependency injection for task creation functionality
class CreateTaskBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<TaskService>(() => TaskService());
    
    // Controllers
    Get.lazyPut<CreateTaskController>(() => CreateTaskController());
    Get.lazyPut<TaskFormController>(() => TaskFormController());
  }
}
