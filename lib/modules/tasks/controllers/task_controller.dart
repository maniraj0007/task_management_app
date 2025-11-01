import 'package:get/get.dart';
import '../../../core/enums/task_enums.dart';
import '../../../core/enums/user_roles.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../../auth/services/auth_service.dart';

/// Main Task Controller
/// Manages overall task state and provides reactive access to task operations
class TaskController extends GetxController {
  static TaskController get instance => Get.find<TaskController>();
  
  final TaskService _taskService = Get.find<TaskService>();
  final AuthService _authService = Get.find<AuthService>();
  
  // Reactive state
  final RxBool _isLoading = false.obs;
  final RxBool _isInitialized = false.obs;
  final RxList<TaskModel> _myTasks = <TaskModel>[].obs;
  final RxList<TaskModel> _recentTasks = <TaskModel>[].obs;
  final RxList<TaskModel> _overdueTasks = <TaskModel>[].obs;
  final RxMap<String, TaskModel> _taskCache = <String, TaskModel>{}.obs;
  final RxInt _totalTasksCount = 0.obs;
  final RxInt _completedTasksCount = 0.obs;
  final RxInt _overdueTasksCount = 0.obs;
  final RxInt _inProgressTasksCount = 0.obs;
  
  // Additional reactive state for UI components
  final RxString _error = ''.obs;
  final RxString _searchQuery = ''.obs;
  final RxList<String> _selectedTasks = <String>[].obs;
  final RxList<TaskModel> _pendingTasks = <TaskModel>[].obs;
  final RxList<TaskModel> _completedTasks = <TaskModel>[].obs;
  
  // Getters
  bool get isLoading => _isLoading.value;
  bool get isInitialized => _isInitialized.value;
  List<TaskModel> get myTasks => _myTasks;
  List<TaskModel> get recentTasks => _recentTasks;
  List<TaskModel> get overdueTasks => _overdueTasks;
  Map<String, TaskModel> get taskCache => _taskCache;
  int get totalTasksCount => _totalTasksCount.value;
  int get completedTasksCount => _completedTasksCount.value;
  int get overdueTasksCount => _overdueTasksCount.value;
  int get inProgressTasksCount => _inProgressTasksCount.value;
  
  // Additional getters for UI components
  String get error => _error.value;
  int get totalTasks => _totalTasksCount.value; // Alias for backward compatibility
  List<TaskModel> get pendingTasks => _pendingTasks;
  List<TaskModel> get completedTasks => _completedTasks;
  List<String> get selectedTasks => _selectedTasks;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeController();
  }
  
  @override
  void onClose() {
    // Clean up any subscriptions
    super.onClose();
  }
  
  /// Initialize the task controller
  Future<void> _initializeController() async {
    try {
      _isLoading.value = true;
      
      // Load initial data
      await Future.wait([
        loadMyTasks(),
        loadOverdueTasks(),
        _updateTaskStatistics(),
      ]);
      
      // Set up real-time listeners
      _setupRealtimeListeners();
      
      _isInitialized.value = true;
      
    } catch (e) {
      Get.snackbar(
        'Initialization Error',
        'Failed to initialize task management',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Set up real-time listeners for task updates
  void _setupRealtimeListeners() {
    // Listen to user's tasks
    _taskService.listenToMyTasks().listen(
      (tasks) {
        _myTasks.assignAll(tasks);
        _updateRecentTasks();
        _updateTaskStatistics();
      },
      onError: (error) {
        Get.snackbar(
          'Sync Error',
          'Failed to sync tasks',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }
  
  // ==================== TASK OPERATIONS ====================
  
  /// Create a new task
  Future<TaskModel?> createTask({
    required String title,
    required String description,
    TaskCategory category = TaskCategory.personal,
    TaskPriority priority = TaskPriority.medium,
    TaskVisibility visibility = TaskVisibility.private,
    String? assignedTo,
    DateTime? dueDate,
    List<String>? tags,
  }) async {
    try {
      _isLoading.value = true;
      
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      final task = TaskModel.create(
        title: title,
        description: description,
        createdBy: currentUser.id,
        category: category,
        priority: priority,
        visibility: visibility,
        assignedTo: assignedTo,
        dueDate: dueDate,
        tags: tags,
      );
      
      final createdTask = await _taskService.createTask(task);
      
      if (createdTask != null) {
        // Add to cache and lists
        _taskCache[createdTask.id] = createdTask;
        _myTasks.insert(0, createdTask);
        _updateRecentTasks();
        _updateTaskStatistics();
        
        Get.snackbar(
          'Success',
          'Task created successfully',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      }
      
      return createdTask;
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Update an existing task
  Future<TaskModel?> updateTask(String taskId, Map<String, dynamic> updates) async {
    try {
      _isLoading.value = true;
      
      final updatedTask = await _taskService.updateTask(taskId, updates);
      
      if (updatedTask != null) {
        // Update cache and lists
        _taskCache[taskId] = updatedTask;
        _updateTaskInLists(updatedTask);
        _updateTaskStatistics();
        
        Get.snackbar(
          'Success',
          'Task updated successfully',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      }
      
      return updatedTask;
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Delete a task
  Future<bool> deleteTask(String taskId) async {
    try {
      _isLoading.value = true;
      
      final success = await _taskService.deleteTask(taskId);
      
      if (success) {
        // Remove from cache and lists
        _taskCache.remove(taskId);
        _myTasks.removeWhere((task) => task.id == taskId);
        _recentTasks.removeWhere((task) => task.id == taskId);
        _overdueTasks.removeWhere((task) => task.id == taskId);
        _updateTaskStatistics();
        
        Get.snackbar(
          'Success',
          'Task deleted successfully',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      }
      
      return success;
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Archive a task
  Future<bool> archiveTask(String taskId) async {
    try {
      _isLoading.value = true;
      
      final success = await _taskService.archiveTask(taskId);
      
      if (success) {
        // Remove from active lists but keep in cache
        _myTasks.removeWhere((task) => task.id == taskId);
        _recentTasks.removeWhere((task) => task.id == taskId);
        _overdueTasks.removeWhere((task) => task.id == taskId);
        _updateTaskStatistics();
        
        Get.snackbar(
          'Success',
          'Task archived successfully',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      }
      
      return success;
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to archive task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  // ==================== TASK STATUS OPERATIONS ====================
  
  /// Update task status
  Future<TaskModel?> updateTaskStatus(String taskId, TaskStatus newStatus) async {
    try {
      final updatedTask = await _taskService.updateTaskStatus(taskId, newStatus);
      
      if (updatedTask != null) {
        // Update cache and lists
        _taskCache[taskId] = updatedTask;
        _updateTaskInLists(updatedTask);
        _updateTaskStatistics();
        
        Get.snackbar(
          'Success',
          'Task status updated to ${newStatus.displayName}',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      }
      
      return updatedTask;
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update task status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }
  
  /// Mark task as completed
  Future<TaskModel?> completeTask(String taskId) async {
    return await updateTaskStatus(taskId, TaskStatus.completed);
  }
  
  /// Start working on a task
  Future<TaskModel?> startTask(String taskId) async {
    return await updateTaskStatus(taskId, TaskStatus.inProgress);
  }
  
  /// Move task to review
  Future<TaskModel?> reviewTask(String taskId) async {
    return await updateTaskStatus(taskId, TaskStatus.review);
  }
  
  /// Cancel a task
  Future<TaskModel?> cancelTask(String taskId) async {
    return await updateTaskStatus(taskId, TaskStatus.cancelled);
  }
  
  // ==================== TASK ASSIGNMENT ====================
  
  /// Assign task to user
  Future<TaskModel?> assignTask(String taskId, String userId) async {
    try {
      final updatedTask = await _taskService.assignTask(taskId, userId);
      
      if (updatedTask != null) {
        // Update cache and lists
        _taskCache[taskId] = updatedTask;
        _updateTaskInLists(updatedTask);
        
        Get.snackbar(
          'Success',
          'Task assigned successfully',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      }
      
      return updatedTask;
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to assign task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }
  
  /// Unassign task
  Future<TaskModel?> unassignTask(String taskId) async {
    return await updateTask(taskId, {
      'assignedTo': null,
      'assignmentType': TaskAssignmentType.unassigned.value,
    });
  }
  
  // ==================== DATA LOADING ====================
  
  /// Load user's tasks
  Future<void> loadMyTasks({bool refresh = false}) async {
    try {
      if (!refresh && _myTasks.isNotEmpty) return;
      
      final tasks = await _taskService.getMyTasks(limit: 50);
      _myTasks.assignAll(tasks);
      
      // Update cache
      for (final task in tasks) {
        _taskCache[task.id] = task;
      }
      
      _updateRecentTasks();
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load tasks',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  /// Load overdue tasks
  Future<void> loadOverdueTasks() async {
    try {
      final tasks = await _taskService.getOverdueTasks(limit: 20);
      _overdueTasks.assignAll(tasks);
      
      // Update cache
      for (final task in tasks) {
        _taskCache[task.id] = task;
      }
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load overdue tasks',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  /// Get task by ID (with caching)
  Future<TaskModel?> getTask(String taskId) async {
    try {
      // Check cache first
      if (_taskCache.containsKey(taskId)) {
        return _taskCache[taskId];
      }
      
      // Fetch from service
      final task = await _taskService.getTaskById(taskId);
      if (task != null) {
        _taskCache[taskId] = task;
      }
      
      return task;
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load task',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }
  
  /// Search tasks
  Future<List<TaskModel>> searchTasks(String searchTerm) async {
    try {
      if (searchTerm.trim().isEmpty) return [];
      
      final tasks = await _taskService.searchTasks(searchTerm, limit: 30);
      
      // Update cache
      for (final task in tasks) {
        _taskCache[task.id] = task;
      }
      
      return tasks;
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to search tasks',
        snackPosition: SnackPosition.BOTTOM,
      );
      return [];
    }
  }
  
  // ==================== UTILITY METHODS ====================
  
  /// Update recent tasks list
  void _updateRecentTasks() {
    final recent = _myTasks
        .where((task) => !task.isArchived && !task.isDeleted)
        .take(10)
        .toList();
    _recentTasks.assignAll(recent);
  }
  
  /// Update task in all lists
  void _updateTaskInLists(TaskModel updatedTask) {
    // Update in my tasks
    final myTaskIndex = _myTasks.indexWhere((task) => task.id == updatedTask.id);
    if (myTaskIndex != -1) {
      _myTasks[myTaskIndex] = updatedTask;
    }
    
    // Update in recent tasks
    final recentTaskIndex = _recentTasks.indexWhere((task) => task.id == updatedTask.id);
    if (recentTaskIndex != -1) {
      _recentTasks[recentTaskIndex] = updatedTask;
    }
    
    // Update in overdue tasks
    final overdueTaskIndex = _overdueTasks.indexWhere((task) => task.id == updatedTask.id);
    if (overdueTaskIndex != -1) {
      if (updatedTask.isOverdue) {
        _overdueTasks[overdueTaskIndex] = updatedTask;
      } else {
        _overdueTasks.removeAt(overdueTaskIndex);
      }
    } else if (updatedTask.isOverdue) {
      _overdueTasks.add(updatedTask);
    }
  }
  
  /// Update task statistics
  void _updateTaskStatistics() {
    _totalTasksCount.value = _myTasks.length;
    _completedTasksCount.value = _myTasks.where((task) => task.status.isCompleted).length;
    _overdueTasksCount.value = _myTasks.where((task) => task.isOverdue).length;
    _inProgressTasksCount.value = _myTasks.where((task) => task.status.isInProgress).length;
  }
  
  /// Get tasks by category
  List<TaskModel> getTasksByCategory(TaskCategory category) {
    return _myTasks.where((task) => task.category == category).toList();
  }
  
  /// Get tasks by status
  List<TaskModel> getTasksByStatus(TaskStatus status) {
    return _myTasks.where((task) => task.status == status).toList();
  }
  
  /// Get tasks by priority
  List<TaskModel> getTasksByPriority(TaskPriority priority) {
    return _myTasks.where((task) => task.priority == priority).toList();
  }
  
  /// Get tasks due today
  List<TaskModel> getTasksDueToday() {
    return _myTasks.where((task) => task.isDueToday).toList();
  }
  
  /// Get tasks due this week
  List<TaskModel> getTasksDueThisWeek() {
    return _myTasks.where((task) => task.isDueThisWeek).toList();
  }
  
  /// Get completion percentage for current user
  double get completionPercentage {
    if (_totalTasksCount.value == 0) return 0.0;
    return _completedTasksCount.value / _totalTasksCount.value;
  }
  
  /// Get productivity score (completed tasks in last 7 days)
  int get productivityScore {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return _myTasks
        .where((task) => 
            task.status.isCompleted && 
            task.completedAt != null && 
            task.completedAt!.isAfter(sevenDaysAgo))
        .length;
  }
  
  /// Check if user can perform action on task
  bool canPerformAction(String taskId, String action) {
    final task = _taskCache[taskId];
    if (task == null) return false;
    
    final currentUser = _authService.currentUser;
    if (currentUser == null) return false;
    
    switch (action) {
      case 'edit':
        return task.canBeEditedByUser(currentUser.id) || currentUser.role.canAccessAdmin;
      case 'delete':
        return task.createdBy == currentUser.id || currentUser.role.canDeleteTasks;
      case 'assign':
        return currentUser.role.canManageTeams || task.createdBy == currentUser.id;
      case 'complete':
        return task.isAssignedToUser(currentUser.id) || task.createdBy == currentUser.id;
      default:
        return false;
    }
  }
  
  /// Refresh all task data
  Future<void> refreshTasks() async {
    await Future.wait([
      loadMyTasks(refresh: true),
      loadOverdueTasks(),
    ]);
    _updateTaskStatistics();
  }
  
  /// Set search query for task filtering
  void setSearchQuery(String query) {
    _searchQuery.value = query;
    // Implement search logic here if needed
  }
  
  /// Clear task selection
  void clearTaskSelection() {
    _selectedTasks.clear();
  }
  
  /// Delete selected tasks
  Future<void> deleteSelectedTasks() async {
    try {
      for (final taskId in _selectedTasks) {
        await deleteTask(taskId);
      }
      _selectedTasks.clear();
    } catch (e) {
      _error.value = 'Failed to delete selected tasks: $e';
    }
  }
}
