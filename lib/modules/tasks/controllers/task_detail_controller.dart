import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

/// Controller for task detail screen
class TaskDetailController extends GetxController {
  final TaskService _taskService = Get.find<TaskService>();
  
  // Observable state
  final Rx<TaskModel?> _task = Rx<TaskModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _taskId = ''.obs;
  
  // Getters
  TaskModel? get task => _task.value;
  bool get isLoading => _isLoading.value;
  String get taskId => _taskId.value;
  
  @override
  void onInit() {
    super.onInit();
    _loadTaskId();
    if (_taskId.value.isNotEmpty) {
      _loadTask();
    }
  }
  
  /// Load task ID from route parameters
  void _loadTaskId() {
    final id = Get.parameters['taskId'];
    if (id != null && id.isNotEmpty) {
      _taskId.value = id;
    } else {
      Get.snackbar(
        'Error',
        'Task ID not found',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
    }
  }
  
  /// Load task details
  Future<void> _loadTask() async {
    try {
      _isLoading.value = true;
      final task = await _taskService.getTaskById(_taskId.value);
      
      if (task != null) {
        _task.value = task;
      } else {
        Get.snackbar(
          'Error',
          'Task not found',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.back();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load task: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Refresh task data
  Future<void> refreshTask() async {
    await _loadTask();
  }
  
  /// Navigate to edit task screen
  void editTask() {
    Get.toNamed('/tasks/edit/${_taskId.value}');
  }
  
  /// Update task status
  Future<void> updateTaskStatus(TaskStatus status) async {
    if (_task.value == null) return;
    
    try {
      await _taskService.updateTaskStatus(_taskId.value, status);
      
      // Update local task
      _task.value = _task.value!.copyWith(
        status: status,
        updatedAt: DateTime.now(),
        completedAt: status == TaskStatus.completed ? DateTime.now() : null,
      );
      
      Get.snackbar(
        'Success',
        'Task status updated',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update task status: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  /// Delete task with confirmation
  Future<void> deleteTask() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Task'),
        content: const Text(
          'Are you sure you want to delete this task? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await _taskService.deleteTask(_taskId.value);
        Get.snackbar(
          'Success',
          'Task deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.back(); // Go back to task list
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete task: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
  
  /// Get priority color
  Color getPriorityColor() {
    if (_task.value == null) return Colors.grey;
    
    switch (_task.value!.priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }
  
  /// Get status color
  Color getStatusColor() {
    if (_task.value == null) return Colors.grey;
    
    switch (_task.value!.status) {
      case TaskStatus.pending:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
    }
  }
  
  /// Get priority text
  String getPriorityText() {
    if (_task.value == null) return '';
    
    switch (_task.value!.priority) {
      case TaskPriority.high:
        return 'High Priority';
      case TaskPriority.medium:
        return 'Medium Priority';
      case TaskPriority.low:
        return 'Low Priority';
    }
  }
  
  /// Get status text
  String getStatusText() {
    if (_task.value == null) return '';
    
    switch (_task.value!.status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }
  
  /// Check if task is overdue
  bool get isOverdue {
    if (_task.value?.dueDate == null) return false;
    return _task.value!.dueDate!.isBefore(DateTime.now()) && 
           _task.value!.status != TaskStatus.completed;
  }
  
  /// Get relative time string
  String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) return 'now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
  
  /// Format due date
  String formatDueDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dateStr;
    if (taskDate == today) {
      dateStr = 'Today';
    } else if (taskDate == tomorrow) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    
    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    
    return '$dateStr at $timeStr';
  }
}
