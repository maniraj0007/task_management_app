import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/enums/task_enums.dart';
import '../../../core/enums/user_roles.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../../auth/services/auth_service.dart';

/// Enhanced Task Controller
/// Comprehensive task management with reactive state and role-based operations
class EnhancedTaskController extends GetxController {
  static EnhancedTaskController get instance => Get.find<EnhancedTaskController>();
  
  final TaskService _taskService = Get.find<TaskService>();
  final AuthService _authService = Get.find<AuthService>();
  
  // Form controllers for task creation/editing
  final GlobalKey<FormState> taskFormKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  
  // Reactive state
  final RxBool _isLoading = false.obs;
  final RxBool _isInitialized = false.obs;
  final RxBool _isSyncing = false.obs;
  
  // Task collections
  final RxList<TaskModel> _allTasks = <TaskModel>[].obs;
  final RxList<TaskModel> _myTasks = <TaskModel>[].obs;
  final RxList<TaskModel> _assignedTasks = <TaskModel>[].obs;
  final RxList<TaskModel> _teamTasks = <TaskModel>[].obs;
  final RxList<TaskModel> _projectTasks = <TaskModel>[].obs;
  final RxList<TaskModel> _recentTasks = <TaskModel>[].obs;
  final RxList<TaskModel> _overdueTasks = <TaskModel>[].obs;
  final RxList<TaskModel> _todayTasks = <TaskModel>[].obs;
  final RxList<TaskModel> _upcomingTasks = <TaskModel>[].obs;
  
  // Task cache and metadata
  final RxMap<String, TaskModel> _taskCache = <String, TaskModel>{}.obs;
  final RxMap<String, List<TaskModel>> _tasksByCategory = <String, List<TaskModel>>{}.obs;
  final RxMap<String, List<TaskModel>> _tasksByStatus = <String, List<TaskModel>>{}.obs;
  final RxMap<String, List<TaskModel>> _tasksByPriority = <String, List<TaskModel>>{}.obs;
  
  // Statistics
  final RxInt _totalTasksCount = 0.obs;
  final RxInt _completedTasksCount = 0.obs;
  final RxInt _overdueTasksCount = 0.obs;
  final RxInt _inProgressTasksCount = 0.obs;
  final RxInt _todoTasksCount = 0.obs;
  final RxInt _reviewTasksCount = 0.obs;
  
  // Filter and sort state
  final Rx<TaskCategory?> _selectedCategory = Rx<TaskCategory?>(null);
  final Rx<TaskStatus?> _selectedStatus = Rx<TaskStatus?>(null);
  final Rx<TaskPriority?> _selectedPriority = Rx<TaskPriority?>(null);
  final RxString _searchQuery = ''.obs;
  final RxString _sortBy = 'dueDate'.obs;
  final RxBool _sortAscending = true.obs;
  
  // Form state
  final Rx<TaskCategory> _selectedFormCategory = TaskCategory.personal.obs;
  final Rx<TaskPriority> _selectedFormPriority = TaskPriority.medium.obs;
  final Rx<TaskVisibility> _selectedFormVisibility = TaskVisibility.private.obs;
  final Rx<DateTime?> _selectedDueDate = Rx<DateTime?>(null);
  final Rx<DateTime?> _selectedStartDate = Rx<DateTime?>(null);
  final RxList<String> _selectedTags = <String>[].obs;
  final RxString _selectedAssignee = ''.obs;
  
  // Getters
  bool get isLoading => _isLoading.value;
  bool get isInitialized => _isInitialized.value;
  bool get isSyncing => _isSyncing.value;
  
  // Task collections getters
  List<TaskModel> get allTasks => _allTasks;
  List<TaskModel> get myTasks => _myTasks;
  List<TaskModel> get assignedTasks => _assignedTasks;
  List<TaskModel> get teamTasks => _teamTasks;
  List<TaskModel> get projectTasks => _projectTasks;
  List<TaskModel> get recentTasks => _recentTasks;
  List<TaskModel> get overdueTasks => _overdueTasks;
  List<TaskModel> get todayTasks => _todayTasks;
  List<TaskModel> get upcomingTasks => _upcomingTasks;
  
  // Statistics getters
  int get totalTasksCount => _totalTasksCount.value;
  int get completedTasksCount => _completedTasksCount.value;
  int get overdueTasksCount => _overdueTasksCount.value;
  int get inProgressTasksCount => _inProgressTasksCount.value;
  int get todoTasksCount => _todoTasksCount.value;
  int get reviewTasksCount => _reviewTasksCount.value;
  
  // Filter getters
  TaskCategory? get selectedCategory => _selectedCategory.value;
  TaskStatus? get selectedStatus => _selectedStatus.value;
  TaskPriority? get selectedPriority => _selectedPriority.value;
  String get searchQuery => _searchQuery.value;
  String get sortBy => _sortBy.value;
  bool get sortAscending => _sortAscending.value;
  
  // Form getters
  TaskCategory get selectedFormCategory => _selectedFormCategory.value;
  TaskPriority get selectedFormPriority => _selectedFormPriority.value;
  TaskVisibility get selectedFormVisibility => _selectedFormVisibility.value;
  DateTime? get selectedDueDate => _selectedDueDate.value;
  DateTime? get selectedStartDate => _selectedStartDate.value;
  List<String> get selectedTags => _selectedTags;
  String get selectedAssignee => _selectedAssignee.value;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeController();
  }
  
  @override
  void onClose() {
    // Dispose controllers
    titleController.dispose();
    descriptionController.dispose();
    tagsController.dispose();
    super.onClose();
  }
  
  /// Initialize the enhanced task controller
  Future<void> _initializeController() async {
    try {
      _isLoading.value = true;
      
      // Load initial data based on user role
      await _loadInitialData();
      
      // Set up real-time listeners
      _setupRealtimeListeners();
      
      _isInitialized.value = true;
      
    } catch (e) {
      Get.snackbar(
        'Initialization Error',
        'Failed to initialize task management: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Load initial data based on user role and permissions
  Future<void> _loadInitialData() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;
    
    // Load different data sets based on user role
    switch (currentUser.role) {
      case UserRole.superAdmin:
      case UserRole.admin:
        await Future.wait([
          loadAllTasks(),
          loadMyTasks(),
          loadTeamTasks(),
          loadProjectTasks(),
        ]);
        break;
      case UserRole.teamMember:
        await Future.wait([
          loadMyTasks(),
          loadAssignedTasks(),
          loadTeamTasks(),
        ]);
        break;
      case UserRole.viewer:
        await Future.wait([
          loadMyTasks(),
          loadAssignedTasks(),
        ]);
        break;
    }
    
    // Update derived data
    _updateDerivedData();
  }
  
  /// Set up real-time listeners for task updates
  void _setupRealtimeListeners() {
    // This will be implemented with Firebase streams
    // For now, we'll use periodic refresh
    _startPeriodicRefresh();
  }
  
  /// Start periodic refresh for real-time updates
  void _startPeriodicRefresh() {
    // Refresh every 30 seconds
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isLoading.value) {
        refreshTasks();
      }
    });
  }
  
  // ==================== TASK LOADING METHODS ====================
  
  /// Load all tasks (admin/super admin only)
  Future<void> loadAllTasks() async {
    try {
      final tasks = await _taskService.getAllTasks();
      _allTasks.assignAll(tasks);
      _updateTaskCache(tasks);
    } catch (e) {
      _handleError('Failed to load all tasks', e);
    }
  }
  
  /// Load user's own tasks
  Future<void> loadMyTasks() async {
    try {
      final tasks = await _taskService.getMyTasks();
      _myTasks.assignAll(tasks);
      _updateTaskCache(tasks);
    } catch (e) {
      _handleError('Failed to load my tasks', e);
    }
  }
  
  /// Load tasks assigned to user
  Future<void> loadAssignedTasks() async {
    try {
      final tasks = await _taskService.getAssignedTasks();
      _assignedTasks.assignAll(tasks);
      _updateTaskCache(tasks);
    } catch (e) {
      _handleError('Failed to load assigned tasks', e);
    }
  }
  
  /// Load team tasks
  Future<void> loadTeamTasks() async {
    try {
      final tasks = await _taskService.getTeamTasks();
      _teamTasks.assignAll(tasks);
      _updateTaskCache(tasks);
    } catch (e) {
      _handleError('Failed to load team tasks', e);
    }
  }
  
  /// Load project tasks
  Future<void> loadProjectTasks() async {
    try {
      final tasks = await _taskService.getProjectTasks();
      _projectTasks.assignAll(tasks);
      _updateTaskCache(tasks);
    } catch (e) {
      _handleError('Failed to load project tasks', e);
    }
  }
  
  /// Refresh all tasks
  Future<void> refreshTasks() async {
    try {
      _isSyncing.value = true;
      await _loadInitialData();
    } finally {
      _isSyncing.value = false;
    }
  }
  
  // ==================== TASK OPERATIONS ====================
  
  /// Create a new task
  Future<bool> createTask() async {
    if (!taskFormKey.currentState!.validate()) return false;
    
    try {
      _isLoading.value = true;
      
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Create task model
      final task = TaskModel.create(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        createdBy: currentUser.id,
        category: selectedFormCategory,
        priority: selectedFormPriority,
        visibility: selectedFormVisibility,
        assignedTo: selectedAssignee.isEmpty ? null : selectedAssignee,
        dueDate: selectedDueDate,
        tags: selectedTags,
      );
      
      // Create task via service
      final createdTask = await _taskService.createTask(task);
      
      if (createdTask != null) {
        // Add to appropriate collections
        _addTaskToCollections(createdTask);
        
        // Clear form
        clearForm();
        
        Get.snackbar(
          'Success',
          'Task created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        return true;
      } else {
        throw Exception('Failed to create task');
      }
      
    } catch (e) {
      _handleError('Failed to create task', e);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Update task status
  Future<bool> updateTaskStatus(String taskId, TaskStatus newStatus) async {
    try {
      _isLoading.value = true;
      
      final updates = {
        'status': newStatus.value,
        'updatedAt': DateTime.now(),
      };
      
      // Add completion timestamp if completing
      if (newStatus == TaskStatus.completed) {
        updates['completedAt'] = DateTime.now();
      }
      
      final updatedTask = await _taskService.updateTask(taskId, updates);
      
      if (updatedTask != null) {
        _updateTaskInCollections(updatedTask);
        
        Get.snackbar(
          'Success',
          'Task status updated to ${newStatus.displayName}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        return true;
      } else {
        throw Exception('Failed to update task status');
      }
      
    } catch (e) {
      _handleError('Failed to update task status', e);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Update task priority
  Future<bool> updateTaskPriority(String taskId, TaskPriority newPriority) async {
    try {
      final updates = {
        'priority': newPriority.value,
        'updatedAt': DateTime.now(),
      };
      
      final updatedTask = await _taskService.updateTask(taskId, updates);
      
      if (updatedTask != null) {
        _updateTaskInCollections(updatedTask);
        return true;
      }
      
      return false;
    } catch (e) {
      _handleError('Failed to update task priority', e);
      return false;
    }
  }
  
  /// Delete task
  Future<bool> deleteTask(String taskId) async {
    try {
      _isLoading.value = true;
      
      final success = await _taskService.deleteTask(taskId);
      
      if (success) {
        _removeTaskFromCollections(taskId);
        
        Get.snackbar(
          'Success',
          'Task deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        return true;
      } else {
        throw Exception('Failed to delete task');
      }
      
    } catch (e) {
      _handleError('Failed to delete task', e);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  // ==================== FORM MANAGEMENT ====================
  
  /// Set form category
  void setFormCategory(TaskCategory category) {
    _selectedFormCategory.value = category;
  }
  
  /// Set form priority
  void setFormPriority(TaskPriority priority) {
    _selectedFormPriority.value = priority;
  }
  
  /// Set form visibility
  void setFormVisibility(TaskVisibility visibility) {
    _selectedFormVisibility.value = visibility;
  }
  
  /// Set due date
  void setDueDate(DateTime? date) {
    _selectedDueDate.value = date;
  }
  
  /// Set start date
  void setStartDate(DateTime? date) {
    _selectedStartDate.value = date;
  }
  
  /// Add tag
  void addTag(String tag) {
    if (tag.isNotEmpty && !_selectedTags.contains(tag)) {
      _selectedTags.add(tag);
    }
  }
  
  /// Remove tag
  void removeTag(String tag) {
    _selectedTags.remove(tag);
  }
  
  /// Set assignee
  void setAssignee(String userId) {
    _selectedAssignee.value = userId;
  }
  
  /// Clear form
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    tagsController.clear();
    _selectedFormCategory.value = TaskCategory.personal;
    _selectedFormPriority.value = TaskPriority.medium;
    _selectedFormVisibility.value = TaskVisibility.private;
    _selectedDueDate.value = null;
    _selectedStartDate.value = null;
    _selectedTags.clear();
    _selectedAssignee.value = '';
  }
  
  // ==================== VALIDATION ====================
  
  /// Validate task title
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
  
  /// Validate task description
  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    if (value.trim().length < 10) {
      return 'Description must be at least 10 characters';
    }
    if (value.trim().length > 1000) {
      return 'Description must be less than 1000 characters';
    }
    return null;
  }
  
  // ==================== FILTERING AND SORTING ====================
  
  /// Set category filter
  void setCategoryFilter(TaskCategory? category) {
    _selectedCategory.value = category;
    _applyFilters();
  }
  
  /// Set status filter
  void setStatusFilter(TaskStatus? status) {
    _selectedStatus.value = status;
    _applyFilters();
  }
  
  /// Set priority filter
  void setPriorityFilter(TaskPriority? priority) {
    _selectedPriority.value = priority;
    _applyFilters();
  }
  
  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery.value = query;
    _applyFilters();
  }
  
  /// Set sort criteria
  void setSortBy(String sortBy, {bool ascending = true}) {
    _sortBy.value = sortBy;
    _sortAscending.value = ascending;
    _applyFilters();
  }
  
  /// Clear all filters
  void clearFilters() {
    _selectedCategory.value = null;
    _selectedStatus.value = null;
    _selectedPriority.value = null;
    _searchQuery.value = '';
    _applyFilters();
  }
  
  /// Apply current filters and sorting
  void _applyFilters() {
    // This will be implemented to filter the task lists
    // based on current filter criteria
    _updateDerivedData();
  }
  
  // ==================== HELPER METHODS ====================
  
  /// Update task cache
  void _updateTaskCache(List<TaskModel> tasks) {
    for (final task in tasks) {
      _taskCache[task.id] = task;
    }
  }
  
  /// Add task to appropriate collections
  void _addTaskToCollections(TaskModel task) {
    _taskCache[task.id] = task;
    
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;
    
    // Add to my tasks if I created it
    if (task.createdBy == currentUser.id) {
      _myTasks.add(task);
    }
    
    // Add to assigned tasks if assigned to me
    if (task.isAssignedToUser(currentUser.id)) {
      _assignedTasks.add(task);
    }
    
    // Add to appropriate category collections
    switch (task.category) {
      case TaskCategory.teamCollaboration:
        _teamTasks.add(task);
        break;
      case TaskCategory.projectManagement:
        _projectTasks.add(task);
        break;
      case TaskCategory.personal:
        // Already in myTasks if created by user
        break;
    }
    
    _updateDerivedData();
  }
  
  /// Update task in collections
  void _updateTaskInCollections(TaskModel updatedTask) {
    _taskCache[updatedTask.id] = updatedTask;
    
    // Update in all collections
    _updateTaskInList(_myTasks, updatedTask);
    _updateTaskInList(_assignedTasks, updatedTask);
    _updateTaskInList(_teamTasks, updatedTask);
    _updateTaskInList(_projectTasks, updatedTask);
    _updateTaskInList(_allTasks, updatedTask);
    
    _updateDerivedData();
  }
  
  /// Update task in a specific list
  void _updateTaskInList(RxList<TaskModel> list, TaskModel updatedTask) {
    final index = list.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      list[index] = updatedTask;
    }
  }
  
  /// Remove task from collections
  void _removeTaskFromCollections(String taskId) {
    _taskCache.remove(taskId);
    _myTasks.removeWhere((task) => task.id == taskId);
    _assignedTasks.removeWhere((task) => task.id == taskId);
    _teamTasks.removeWhere((task) => task.id == taskId);
    _projectTasks.removeWhere((task) => task.id == taskId);
    _allTasks.removeWhere((task) => task.id == taskId);
    
    _updateDerivedData();
  }
  
  /// Update derived data (recent, overdue, today, upcoming tasks and statistics)
  void _updateDerivedData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));
    
    // Get all relevant tasks for current user
    final allRelevantTasks = <TaskModel>[];
    allRelevantTasks.addAll(_myTasks);
    allRelevantTasks.addAll(_assignedTasks);
    
    // Remove duplicates
    final uniqueTasks = <String, TaskModel>{};
    for (final task in allRelevantTasks) {
      uniqueTasks[task.id] = task;
    }
    final tasks = uniqueTasks.values.toList();
    
    // Update recent tasks (last 7 days)
    final recentCutoff = now.subtract(const Duration(days: 7));
    _recentTasks.assignAll(
      tasks.where((task) => task.updatedAt.isAfter(recentCutoff)).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)),
    );
    
    // Update overdue tasks
    _overdueTasks.assignAll(
      tasks.where((task) => task.isOverdue).toList()
        ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!)),
    );
    
    // Update today's tasks
    _todayTasks.assignAll(
      tasks.where((task) => task.isDueToday).toList()
        ..sort((a, b) => a.urgencyScore.compareTo(b.urgencyScore)),
    );
    
    // Update upcoming tasks (next 7 days)
    _upcomingTasks.assignAll(
      tasks.where((task) => 
        task.dueDate != null && 
        task.dueDate!.isAfter(tomorrow) && 
        task.dueDate!.isBefore(nextWeek)
      ).toList()
        ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!)),
    );
    
    // Update statistics
    _totalTasksCount.value = tasks.length;
    _completedTasksCount.value = tasks.where((task) => task.status.isCompleted).length;
    _overdueTasksCount.value = tasks.where((task) => task.isOverdue).length;
    _inProgressTasksCount.value = tasks.where((task) => task.status.isInProgress).length;
    _todoTasksCount.value = tasks.where((task) => task.status == TaskStatus.todo).length;
    _reviewTasksCount.value = tasks.where((task) => task.status == TaskStatus.review).length;
    
    // Update categorized tasks
    _updateCategorizedTasks(tasks);
  }
  
  /// Update categorized task collections
  void _updateCategorizedTasks(List<TaskModel> tasks) {
    // Group by category
    _tasksByCategory.clear();
    for (final category in TaskCategory.values) {
      _tasksByCategory[category.value] = 
        tasks.where((task) => task.category == category).toList();
    }
    
    // Group by status
    _tasksByStatus.clear();
    for (final status in TaskStatus.values) {
      _tasksByStatus[status.value] = 
        tasks.where((task) => task.status == status).toList();
    }
    
    // Group by priority
    _tasksByPriority.clear();
    for (final priority in TaskPriority.values) {
      _tasksByPriority[priority.value] = 
        tasks.where((task) => task.priority == priority).toList();
    }
  }
  
  /// Handle errors with user feedback
  void _handleError(String message, dynamic error) {
    Get.snackbar(
      'Error',
      '$message: ${error.toString()}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }
  
  // ==================== UTILITY METHODS ====================
  
  /// Get task by ID
  TaskModel? getTaskById(String taskId) {
    return _taskCache[taskId];
  }
  
  /// Get tasks by category
  List<TaskModel> getTasksByCategory(TaskCategory category) {
    return _tasksByCategory[category.value] ?? [];
  }
  
  /// Get tasks by status
  List<TaskModel> getTasksByStatus(TaskStatus status) {
    return _tasksByStatus[status.value] ?? [];
  }
  
  /// Get tasks by priority
  List<TaskModel> getTasksByPriority(TaskPriority priority) {
    return _tasksByPriority[priority.value] ?? [];
  }
  
  /// Get completion percentage
  double get completionPercentage {
    if (totalTasksCount == 0) return 0.0;
    return completedTasksCount / totalTasksCount;
  }
  
  /// Get productivity score (completed tasks in last 7 days)
  int get productivityScore {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _recentTasks
      .where((task) => task.status.isCompleted && task.completedAt != null && task.completedAt!.isAfter(weekAgo))
      .length;
  }
}
