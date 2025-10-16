import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/task_model.dart';
import '../services/task_service.dart';

/// Controller for creating and editing tasks
class CreateTaskController extends GetxController {
  final TaskService _taskService = Get.find<TaskService>();
  
  // Form controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  
  // Observable state
  final RxBool _isLoading = false.obs;
  final RxBool _isEditMode = false.obs;
  final Rx<TaskPriority> _selectedPriority = TaskPriority.medium.obs;
  final Rx<TaskStatus> _selectedStatus = TaskStatus.pending.obs;
  final Rx<DateTime?> _selectedDueDate = Rx<DateTime?>(null);
  final RxString _selectedCategory = ''.obs;
  final RxList<String> _assignedUsers = <String>[].obs;
  final RxString _taskId = ''.obs;
  
  // Form key for validation
  final formKey = GlobalKey<FormState>();
  
  // Getters
  bool get isLoading => _isLoading.value;
  bool get isEditMode => _isEditMode.value;
  TaskPriority get selectedPriority => _selectedPriority.value;
  TaskStatus get selectedStatus => _selectedStatus.value;
  DateTime? get selectedDueDate => _selectedDueDate.value;
  String get selectedCategory => _selectedCategory.value;
  List<String> get assignedUsers => _assignedUsers;
  String get taskId => _taskId.value;
  
  // Available options
  final List<String> categories = [
    'Personal',
    'Work',
    'Shopping',
    'Health',
    'Education',
    'Finance',
    'Travel',
    'Home',
    'Other',
  ];
  
  @override
  void onInit() {
    super.onInit();
    _checkEditMode();
  }
  
  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
  
  /// Check if we're in edit mode and load task data
  void _checkEditMode() {
    final taskId = Get.parameters['taskId'];
    if (taskId != null && taskId.isNotEmpty) {
      _isEditMode.value = true;
      _taskId.value = taskId;
      _loadTaskForEditing(taskId);
    }
  }
  
  /// Load task data for editing
  Future<void> _loadTaskForEditing(String taskId) async {
    try {
      _isLoading.value = true;
      final task = await _taskService.getTaskById(taskId);
      
      if (task != null) {
        titleController.text = task.title;
        descriptionController.text = task.description;
        _selectedPriority.value = task.priority;
        _selectedStatus.value = task.status;
        _selectedDueDate.value = task.dueDate;
        _selectedCategory.value = task.category;
        _assignedUsers.assignAll(task.assignedTo);
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
  
  /// Update selected priority
  void updatePriority(TaskPriority priority) {
    _selectedPriority.value = priority;
  }
  
  /// Update selected status
  void updateStatus(TaskStatus status) {
    _selectedStatus.value = status;
  }
  
  /// Update selected due date
  void updateDueDate(DateTime? date) {
    _selectedDueDate.value = date;
  }
  
  /// Update selected category
  void updateCategory(String category) {
    _selectedCategory.value = category;
  }
  
  /// Select due date using date picker
  Future<void> selectDueDate() async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: _selectedDueDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: Get.context!,
        initialTime: TimeOfDay.fromDateTime(
          _selectedDueDate.value ?? DateTime.now(),
        ),
      );
      
      if (time != null) {
        _selectedDueDate.value = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      } else {
        _selectedDueDate.value = date;
      }
    }
  }
  
  /// Clear due date
  void clearDueDate() {
    _selectedDueDate.value = null;
  }
  
  /// Add user to assigned list
  void addAssignedUser(String userId) {
    if (!_assignedUsers.contains(userId)) {
      _assignedUsers.add(userId);
    }
  }
  
  /// Remove user from assigned list
  void removeAssignedUser(String userId) {
    _assignedUsers.remove(userId);
  }
  
  /// Validate form
  bool _validateForm() {
    if (!formKey.currentState!.validate()) {
      return false;
    }
    
    if (titleController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Task title is required',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    
    return true;
  }
  
  /// Save task (create or update)
  Future<void> saveTask() async {
    if (!_validateForm()) return;
    
    try {
      _isLoading.value = true;
      
      final taskData = TaskModel(
        id: _isEditMode.value ? _taskId.value : '',
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        priority: _selectedPriority.value,
        status: _selectedStatus.value,
        dueDate: _selectedDueDate.value,
        category: _selectedCategory.value,
        assignedTo: List.from(_assignedUsers),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: '', // Will be set by service
        tags: [],
        attachments: [],
        comments: [],
        subtasks: [],
        dependencies: [],
        estimatedHours: null,
        actualHours: null,
        completedAt: null,
      );
      
      if (_isEditMode.value) {
        await _taskService.updateTask(_taskId.value, taskData);
        Get.snackbar(
          'Success',
          'Task updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        await _taskService.createTask(taskData);
        Get.snackbar(
          'Success',
          'Task created successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      
      // Navigate back to task list
      Get.back();
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save task: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Cancel and go back
  void cancel() {
    Get.back();
  }
  
  /// Reset form
  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    _selectedPriority.value = TaskPriority.medium;
    _selectedStatus.value = TaskStatus.pending;
    _selectedDueDate.value = null;
    _selectedCategory.value = '';
    _assignedUsers.clear();
  }
  
  /// Get priority display name
  String getPriorityDisplayName(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'High Priority';
      case TaskPriority.medium:
        return 'Medium Priority';
      case TaskPriority.low:
        return 'Low Priority';
    }
  }
  
  /// Get status display name
  String getStatusDisplayName(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }
  
  /// Get priority color
  Color getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }
  
  /// Get status color
  Color getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
    }
  }
}

