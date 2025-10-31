import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/enums/task_enums.dart';
import '../../../core/utils/validators.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../../auth/services/auth_service.dart';

/// Task Form Controller
/// Manages task creation and editing forms with validation
class TaskFormController extends GetxController {
  final TaskService _taskService = Get.find<TaskService>();
  final AuthService _authService = Get.find<AuthService>();
  
  // Form controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  // Reactive state
  final RxBool _isLoading = false.obs;
  final RxBool _isEditMode = false.obs;
  final Rx<TaskModel?> _editingTask = Rx<TaskModel?>(null);
  final Rx<TaskCategory> _selectedCategory = TaskCategory.personal.obs;
  final Rx<TaskPriority> _selectedPriority = TaskPriority.medium.obs;
  final Rx<TaskVisibility> _selectedVisibility = TaskVisibility.private.obs;
  final Rx<TaskRecurrence> _selectedRecurrence = TaskRecurrence.none.obs;
  final Rx<DateTime?> _selectedDueDate = Rx<DateTime?>(null);
  final Rx<DateTime?> _selectedStartDate = Rx<DateTime?>(null);
  final RxString _selectedAssignedTo = ''.obs;
  final RxList<String> _selectedTags = <String>[].obs;
  final RxInt _estimatedHours = 0.obs;
  final RxString _location = ''.obs;
  final RxMap<String, dynamic> _customFields = <String, dynamic>{}.obs;
  
  // Tag input
  final tagController = TextEditingController();
  
  // Getters
  bool get isLoading => _isLoading.value;
  bool get isEditMode => _isEditMode.value;
  TaskModel? get editingTask => _editingTask.value;
  TaskCategory get selectedCategory => _selectedCategory.value;
  TaskPriority get selectedPriority => _selectedPriority.value;
  TaskVisibility get selectedVisibility => _selectedVisibility.value;
  TaskRecurrence get selectedRecurrence => _selectedRecurrence.value;
  DateTime? get selectedDueDate => _selectedDueDate.value;
  DateTime? get selectedStartDate => _selectedStartDate.value;
  String get selectedAssignedTo => _selectedAssignedTo.value;
  List<String> get selectedTags => _selectedTags;
  int get estimatedHours => _estimatedHours.value;
  String get location => _location.value;
  Map<String, dynamic> get customFields => _customFields;
  
  @override
  void onInit() {
    super.onInit();
    _initializeForm();
  }
  
  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    tagController.dispose();
    super.onClose();
  }
  
  /// Initialize form with arguments if provided
  void _initializeForm() {
    final args = Get.arguments as Map<String, dynamic>?;
    
    if (args != null) {
      // Check if editing existing task
      if (args.containsKey('task')) {
        final task = args['task'] as TaskModel;
        _loadTaskForEditing(task);
      }
      
      // Pre-fill category if provided
      if (args.containsKey('category')) {
        _selectedCategory.value = args['category'] as TaskCategory;
      }
      
      // Pre-fill assigned user if provided
      if (args.containsKey('assignedTo')) {
        _selectedAssignedTo.value = args['assignedTo'] as String;
      }
    }
  }
  
  /// Load task data for editing
  void _loadTaskForEditing(TaskModel task) {
    _isEditMode.value = true;
    _editingTask.value = task;
    
    // Fill form fields
    titleController.text = task.title;
    descriptionController.text = task.description;
    _selectedCategory.value = task.category;
    _selectedPriority.value = task.priority;
    _selectedVisibility.value = task.visibility;
    _selectedRecurrence.value = task.recurrence;
    _selectedDueDate.value = task.dueDate;
    _selectedStartDate.value = task.startDate;
    _selectedAssignedTo.value = task.assignedTo ?? '';
    _selectedTags.assignAll(task.tags);
    _estimatedHours.value = task.estimatedHours ?? 0;
    _location.value = task.location ?? '';
    _customFields.assignAll(task.customFields);
  }
  
  // ==================== FORM VALIDATION ====================
  
  /// Validate title field
  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    if (value.trim().length < 3) {
      return 'Title must be at least 3 characters';
    }
    if (value.trim().length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }
  
  /// Validate description field
  String? validateDescription(String? value) {
    if (value != null && value.length > 1000) {
      return 'Description must be less than 1000 characters';
    }
    return null;
  }
  
  /// Validate estimated hours
  String? validateEstimatedHours(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final hours = int.tryParse(value);
    if (hours == null) {
      return 'Please enter a valid number';
    }
    if (hours < 0) {
      return 'Hours cannot be negative';
    }
    if (hours > 1000) {
      return 'Hours cannot exceed 1000';
    }
    return null;
  }
  
  /// Check if form is valid
  bool get isFormValid {
    return titleController.text.trim().isNotEmpty &&
           titleController.text.trim().length >= 3 &&
           titleController.text.trim().length <= 100 &&
           (descriptionController.text.isEmpty || descriptionController.text.length <= 1000);
  }
  
  // ==================== FORM FIELD SETTERS ====================
  
  /// Set task category
  void setCategory(TaskCategory category) {
    _selectedCategory.value = category;
    
    // Auto-adjust visibility based on category
    if (category == TaskCategory.personal) {
      _selectedVisibility.value = TaskVisibility.private;
    } else if (category == TaskCategory.teamCollaboration) {
      _selectedVisibility.value = TaskVisibility.team;
    } else if (category == TaskCategory.projectManagement) {
      _selectedVisibility.value = TaskVisibility.project;
    }
  }
  
  /// Set task priority
  void setPriority(TaskPriority priority) {
    _selectedPriority.value = priority;
  }
  
  /// Set task visibility
  void setVisibility(TaskVisibility visibility) {
    _selectedVisibility.value = visibility;
  }
  
  /// Set task recurrence
  void setRecurrence(TaskRecurrence recurrence) {
    _selectedRecurrence.value = recurrence;
  }
  
  /// Set due date
  void setDueDate(DateTime? date) {
    _selectedDueDate.value = date;
    
    // Ensure start date is not after due date
    if (date != null && _selectedStartDate.value != null) {
      if (_selectedStartDate.value!.isAfter(date)) {
        _selectedStartDate.value = date;
      }
    }
  }
  
  /// Set start date
  void setStartDate(DateTime? date) {
    _selectedStartDate.value = date;
    
    // Ensure due date is not before start date
    if (date != null && _selectedDueDate.value != null) {
      if (_selectedDueDate.value!.isBefore(date)) {
        _selectedDueDate.value = date;
      }
    }
  }
  
  /// Set assigned user
  void setAssignedTo(String userId) {
    _selectedAssignedTo.value = userId;
  }
  
  /// Clear assigned user
  void clearAssignedTo() {
    _selectedAssignedTo.value = '';
  }
  
  /// Set estimated hours
  void setEstimatedHours(int hours) {
    _estimatedHours.value = hours.clamp(0, 1000);
  }
  
  /// Set location
  void setLocation(String location) {
    _location.value = location;
  }
  
  // ==================== TAG MANAGEMENT ====================
  
  /// Add tag
  void addTag(String tag) {
    final trimmedTag = tag.trim().toLowerCase();
    if (trimmedTag.isNotEmpty && !_selectedTags.contains(trimmedTag)) {
      _selectedTags.add(trimmedTag);
      tagController.clear();
    }
  }
  
  /// Remove tag
  void removeTag(String tag) {
    _selectedTags.remove(tag);
  }
  
  /// Add tag from controller
  void addTagFromController() {
    if (tagController.text.trim().isNotEmpty) {
      addTag(tagController.text);
    }
  }
  
  /// Clear all tags
  void clearAllTags() {
    _selectedTags.clear();
  }
  
  // ==================== CUSTOM FIELDS ====================
  
  /// Add custom field
  void addCustomField(String key, dynamic value) {
    if (key.trim().isNotEmpty) {
      _customFields[key.trim()] = value;
    }
  }
  
  /// Remove custom field
  void removeCustomField(String key) {
    _customFields.remove(key);
  }
  
  /// Update custom field
  void updateCustomField(String key, dynamic value) {
    if (_customFields.containsKey(key)) {
      _customFields[key] = value;
    }
  }
  
  // ==================== FORM ACTIONS ====================
  
  /// Save task (create or update)
  Future<TaskModel?> saveTask() async {
    if (!formKey.currentState!.validate()) {
      return null;
    }
    
    try {
      _isLoading.value = true;
      
      TaskModel? result;
      
      if (_isEditMode.value && _editingTask.value != null) {
        // Update existing task
        result = await _updateTask();
      } else {
        // Create new task
        result = await _createTask();
      }
      
      if (result != null) {
        Get.snackbar(
          'Success',
          _isEditMode.value ? 'Task updated successfully' : 'Task created successfully',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        
        // Navigate back or to task detail
        Get.back(result: result);
      }
      
      return result;
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Create new task
  Future<TaskModel?> _createTask() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    final task = TaskModel.create(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      createdBy: currentUser.id,
      category: _selectedCategory.value,
      priority: _selectedPriority.value,
      visibility: _selectedVisibility.value,
      assignedTo: _selectedAssignedTo.value.isNotEmpty ? _selectedAssignedTo.value : null,
      dueDate: _selectedDueDate.value,
      tags: _selectedTags.toList(),
    );
    
    // Add additional fields
    final taskWithExtras = task.copyWith(
      recurrence: _selectedRecurrence.value,
      startDate: _selectedStartDate.value,
      estimatedHours: _estimatedHours.value > 0 ? _estimatedHours.value : null,
      location: _location.value.isNotEmpty ? _location.value : null,
      customFields: _customFields.isNotEmpty ? Map.from(_customFields) : {},
    );
    
    return await _taskService.createTask(taskWithExtras);
  }
  
  /// Update existing task
  Future<TaskModel?> _updateTask() async {
    final task = _editingTask.value!;
    
    final updates = <String, dynamic>{
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'category': _selectedCategory.value.value,
      'priority': _selectedPriority.value.value,
      'visibility': _selectedVisibility.value.value,
      'recurrence': _selectedRecurrence.value.value,
      'dueDate': _selectedDueDate.value,
      'startDate': _selectedStartDate.value,
      'assignedTo': _selectedAssignedTo.value.isNotEmpty ? _selectedAssignedTo.value : null,
      'tags': _selectedTags.toList(),
      'estimatedHours': _estimatedHours.value > 0 ? _estimatedHours.value : null,
      'location': _location.value.isNotEmpty ? _location.value : null,
      'customFields': Map.from(_customFields),
    };
    
    return await _taskService.updateTask(task.id, updates);
  }
  
  /// Save as draft
  Future<void> saveAsDraft() async {
    // TODO: Implement draft saving to local storage
    Get.snackbar(
      'Draft Saved',
      'Task saved as draft',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }
  
  /// Clear form
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    tagController.clear();
    _selectedCategory.value = TaskCategory.personal;
    _selectedPriority.value = TaskPriority.medium;
    _selectedVisibility.value = TaskVisibility.private;
    _selectedRecurrence.value = TaskRecurrence.none;
    _selectedDueDate.value = null;
    _selectedStartDate.value = null;
    _selectedAssignedTo.value = '';
    _selectedTags.clear();
    _estimatedHours.value = 0;
    _location.value = '';
    _customFields.clear();
    _isEditMode.value = false;
    _editingTask.value = null;
  }
  
  /// Reset form to initial state
  void resetForm() {
    if (_isEditMode.value && _editingTask.value != null) {
      _loadTaskForEditing(_editingTask.value!);
    } else {
      clearForm();
    }
  }
  
  // ==================== UTILITY METHODS ====================
  
  /// Check if form has unsaved changes
  bool get hasUnsavedChanges {
    if (!_isEditMode.value) {
      return titleController.text.trim().isNotEmpty ||
             descriptionController.text.trim().isNotEmpty ||
             _selectedTags.isNotEmpty ||
             _selectedDueDate.value != null ||
             _selectedStartDate.value != null ||
             _selectedAssignedTo.value.isNotEmpty ||
             _estimatedHours.value > 0 ||
             _location.value.isNotEmpty ||
             _customFields.isNotEmpty;
    }
    
    final task = _editingTask.value!;
    return titleController.text.trim() != task.title ||
           descriptionController.text.trim() != task.description ||
           _selectedCategory.value != task.category ||
           _selectedPriority.value != task.priority ||
           _selectedVisibility.value != task.visibility ||
           _selectedRecurrence.value != task.recurrence ||
           _selectedDueDate.value != task.dueDate ||
           _selectedStartDate.value != task.startDate ||
           _selectedAssignedTo.value != (task.assignedTo ?? '') ||
           !_listEquals(_selectedTags, task.tags) ||
           _estimatedHours.value != (task.estimatedHours ?? 0) ||
           _location.value != (task.location ?? '') ||
           !_mapEquals(_customFields, task.customFields);
  }
  
  /// Helper method to compare lists
  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
  
  /// Helper method to compare maps
  bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
  
  /// Get available categories based on user permissions
  List<TaskCategory> get availableCategories {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return [TaskCategory.personal];
    
    final categories = <TaskCategory>[TaskCategory.personal];
    
    if (currentUser.role.canManageTeams) {
      categories.add(TaskCategory.teamCollaboration);
    }
    
    if (currentUser.role.canManageProjects) {
      categories.add(TaskCategory.projectManagement);
    }
    
    return categories;
  }
  
  /// Get available visibility options based on category
  List<TaskVisibility> get availableVisibilityOptions {
    switch (_selectedCategory.value) {
      case TaskCategory.personal:
        return [TaskVisibility.private, TaskVisibility.public];
      case TaskCategory.teamCollaboration:
        return [TaskVisibility.team, TaskVisibility.project, TaskVisibility.public];
      case TaskCategory.projectManagement:
        return [TaskVisibility.project, TaskVisibility.public];
    }
  }
  
  /// Auto-fill demo data for testing
  void fillDemoData() {
    titleController.text = 'Sample Task';
    descriptionController.text = 'This is a sample task description for testing purposes.';
    _selectedPriority.value = TaskPriority.high;
    _selectedDueDate.value = DateTime.now().add(const Duration(days: 7));
    _selectedTags.addAll(['demo', 'testing', 'sample']);
    _estimatedHours.value = 4;
  }
}
