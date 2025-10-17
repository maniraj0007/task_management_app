import 'package:get/get.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../../../core/enums/task_enums.dart';

/// Controller for managing task list screen state and operations
class TaskListController extends GetxController {
  final TaskService _taskService = Get.find<TaskService>();
  
  // Observable state
  final RxList<TaskModel> _tasks = <TaskModel>[].obs;
  final RxList<TaskModel> _filteredTasks = <TaskModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _selectedFilter = 'all'.obs;
  final RxString _selectedSort = 'dueDate'.obs;
  final RxBool _isAscending = true.obs;
  final Rx<TaskStatus?> _selectedStatusFilter = Rx<TaskStatus?>(null);
  final Rx<TaskPriority?> _selectedPriorityFilter = Rx<TaskPriority?>(null);
  final RxBool _showOverdueOnly = false.obs;
  
  // Getters
  List<TaskModel> get tasks => _tasks;
  List<TaskModel> get filteredTasks => _filteredTasks;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;
  String get selectedFilter => _selectedFilter.value;
  String get selectedSort => _selectedSort.value;
  bool get isAscending => _isAscending.value;
  TaskStatus? get selectedStatusFilter => _selectedStatusFilter.value;
  TaskPriority? get selectedPriorityFilter => _selectedPriorityFilter.value;
  bool get showOverdueOnly => _showOverdueOnly.value;
  
  // Statistics getters
  int get totalTasks => _tasks.length;
  int get pendingTasks => _tasks.where((task) => task.status == TaskStatus.todo).length;
  int get inProgressTasks => _tasks.where((task) => task.status == TaskStatus.inProgress).length;
  int get completedTasks => _tasks.where((task) => task.status == TaskStatus.completed).length;
  
  // Filter options
  final List<String> filterOptions = [
    'all',
    'pending',
    'in_progress',
    'completed',
    'overdue',
    'high_priority',
    'medium_priority',
    'low_priority',
  ];
  
  // Sort options
  final List<String> sortOptions = [
    'dueDate',
    'priority',
    'status',
    'title',
    'createdAt',
    'updatedAt',
  ];
  
  @override
  void onInit() {
    super.onInit();
    _loadTasks();
    _setupTaskStream();
  }
  
  /// Load tasks from service
  Future<void> _loadTasks() async {
    try {
      _isLoading.value = true;
      final tasks = await _taskService.getUserTasks();
      _tasks.assignAll(tasks);
      _applyFiltersAndSort();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load tasks: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Setup real-time task updates
  void _setupTaskStream() {
    _taskService.getTasksStream().listen(
      (tasks) {
        _tasks.assignAll(tasks);
        _applyFiltersAndSort();
      },
      onError: (error) {
        Get.snackbar(
          'Error',
          'Failed to sync tasks: $error',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }
  
  /// Refresh tasks (pull-to-refresh)
  Future<void> refreshTasks() async {
    await _loadTasks();
  }
  
  /// Update search query and apply filters
  void updateSearchQuery(String query) {
    _searchQuery.value = query;
    _applyFiltersAndSort();
  }
  
  /// Update selected filter and apply
  void updateFilter(String filter) {
    _selectedFilter.value = filter;
    _applyFiltersAndSort();
  }
  
  /// Update sort option and apply
  void updateSort(String sort) {
    _selectedSort.value = sort;
    _applyFiltersAndSort();
  }
  
  /// Toggle sort order
  void toggleSortOrder() {
    _isAscending.value = !_isAscending.value;
    _applyFiltersAndSort();
  }
  
  /// Apply current filters and sorting
  void _applyFiltersAndSort() {
    List<TaskModel> filtered = List.from(_tasks);
    
    // Apply search filter
    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered.where((task) {
        return task.title.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
               task.description.toLowerCase().contains(_searchQuery.value.toLowerCase());
      }).toList();
    }
    
    // Apply status/priority filters
    switch (_selectedFilter.value) {
      case 'pending':
        filtered = filtered.where((task) => task.status == TaskStatus.todo).toList();
        break;
      case 'in_progress':
        filtered = filtered.where((task) => task.status == TaskStatus.inProgress).toList();
        break;
      case 'completed':
        filtered = filtered.where((task) => task.status == TaskStatus.completed).toList();
        break;
      case 'overdue':
        filtered = filtered.where((task) => 
          task.dueDate != null && 
          task.dueDate!.isBefore(DateTime.now()) && 
          task.status != TaskStatus.completed
        ).toList();
        break;
      case 'high_priority':
        filtered = filtered.where((task) => task.priority == TaskPriority.high).toList();
        break;
      case 'medium_priority':
        filtered = filtered.where((task) => task.priority == TaskPriority.medium).toList();
        break;
      case 'low_priority':
        filtered = filtered.where((task) => task.priority == TaskPriority.low).toList();
        break;
      case 'all':
      default:
        // No additional filtering
        break;
    }
    
    // Apply additional filters
    if (_selectedStatusFilter.value != null) {
      filtered = filtered.where((task) => task.status == _selectedStatusFilter.value).toList();
    }
    
    if (_selectedPriorityFilter.value != null) {
      filtered = filtered.where((task) => task.priority == _selectedPriorityFilter.value).toList();
    }
    
    if (_showOverdueOnly.value) {
      filtered = filtered.where((task) => 
        task.dueDate != null && 
        task.dueDate!.isBefore(DateTime.now()) && 
        task.status != TaskStatus.completed
      ).toList();
    }
    
    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;
      
      switch (_selectedSort.value) {
        case 'dueDate':
          if (a.dueDate == null && b.dueDate == null) {
            comparison = 0;
          } else if (a.dueDate == null) {
            comparison = 1;
          } else if (b.dueDate == null) {
            comparison = -1;
          } else {
            comparison = a.dueDate!.compareTo(b.dueDate!);
          }
          break;
        case 'priority':
          comparison = _comparePriority(a.priority, b.priority);
          break;
        case 'status':
          comparison = a.status.index.compareTo(b.status.index);
          break;
        case 'title':
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case 'createdAt':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'updatedAt':
          comparison = a.updatedAt.compareTo(b.updatedAt);
          break;
      }
      
      return _isAscending.value ? comparison : -comparison;
    });
    
    _filteredTasks.assignAll(filtered);
  }
  
  /// Compare task priorities (high > medium > low)
  int _comparePriority(TaskPriority a, TaskPriority b) {
    const priorityOrder = {
      TaskPriority.high: 3,
      TaskPriority.medium: 2,
      TaskPriority.low: 1,
    };
    
    return priorityOrder[a]!.compareTo(priorityOrder[b]!);
  }
  
  /// Navigate to task details
  void viewTaskDetails(String taskId) {
    Get.toNamed('/tasks/details/$taskId');
  }
  
  /// Navigate to create task screen
  void createNewTask() {
    Get.toNamed('/tasks/create');
  }
  
  /// Navigate to edit task screen
  void editTask(String taskId) {
    Get.toNamed('/tasks/edit/$taskId');
  }
  
  /// Quick update task status
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      await _taskService.updateTaskStatus(taskId, status);
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
  Future<void> deleteTask(String taskId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await _taskService.deleteTask(taskId);
        Get.snackbar(
          'Success',
          'Task deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete task: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
  
  /// Get task count by status
  int getTaskCountByStatus(TaskStatus status) {
    return _tasks.where((task) => task.status == status).length;
  }
  
  /// Get overdue task count
  int getOverdueTaskCount() {
    return _tasks.where((task) => 
      task.dueDate != null && 
      task.dueDate!.isBefore(DateTime.now()) && 
      task.status != TaskStatus.completed
    ).length;
  }
  
  /// Set status filter
  void setStatusFilter(TaskStatus? status) {
    _selectedStatusFilter.value = status;
    _applyFiltersAndSort();
  }
  
  /// Set priority filter
  void setPriorityFilter(TaskPriority? priority) {
    _selectedPriorityFilter.value = priority;
    _applyFiltersAndSort();
  }
  
  /// Toggle overdue filter
  void toggleOverdueFilter() {
    _showOverdueOnly.value = !_showOverdueOnly.value;
    _applyFiltersAndSort();
  }
  
  /// Clear all filters
  void clearFilters() {
    _searchQuery.value = '';
    _selectedFilter.value = 'all';
    _selectedSort.value = 'dueDate';
    _isAscending.value = true;
    _selectedStatusFilter.value = null;
    _selectedPriorityFilter.value = null;
    _showOverdueOnly.value = false;
    _applyFiltersAndSort();
  }
}
