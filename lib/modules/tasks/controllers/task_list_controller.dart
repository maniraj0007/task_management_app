import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../core/enums/task_enums.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

/// Task List Controller
/// Manages task lists with filtering, sorting, and pagination
class TaskListController extends GetxController {
  final TaskService _taskService = Get.find<TaskService>();
  
  // Reactive state
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxBool _hasMoreTasks = true.obs;
  final RxList<TaskModel> _tasks = <TaskModel>[].obs;
  final RxString _searchQuery = ''.obs;
  final Rx<TaskStatus?> _selectedStatus = Rx<TaskStatus?>(null);
  final Rx<TaskPriority?> _selectedPriority = Rx<TaskPriority?>(null);
  final Rx<TaskCategory?> _selectedCategory = Rx<TaskCategory?>(null);
  final RxString _sortBy = 'updatedAt'.obs;
  final RxBool _sortDescending = true.obs;
  final RxInt _currentPage = 0.obs;
  
  // Pagination
  DocumentSnapshot? _lastDocument;
  static const int _pageSize = 20;
  
  // Getters
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get hasMoreTasks => _hasMoreTasks.value;
  List<TaskModel> get tasks => _tasks;
  String get searchQuery => _searchQuery.value;
  TaskStatus? get selectedStatus => _selectedStatus.value;
  TaskPriority? get selectedPriority => _selectedPriority.value;
  TaskCategory? get selectedCategory => _selectedCategory.value;
  String get sortBy => _sortBy.value;
  bool get sortDescending => _sortDescending.value;
  int get currentPage => _currentPage.value;
  bool get hasActiveFilters => 
      _selectedStatus.value != null || 
      _selectedPriority.value != null || 
      _selectedCategory.value != null ||
      _searchQuery.value.isNotEmpty;
  
  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }
  
  // ==================== TASK LOADING ====================
  
  /// Load tasks with current filters
  Future<void> loadTasks({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage.value = 0;
        _lastDocument = null;
        _hasMoreTasks.value = true;
        _tasks.clear();
      }
      
      _isLoading.value = true;
      
      List<TaskModel> newTasks;
      
      // Handle search separately
      if (_searchQuery.value.isNotEmpty) {
        newTasks = await _taskService.searchTasks(_searchQuery.value, limit: _pageSize);
        _hasMoreTasks.value = false; // Search doesn't support pagination yet
      } else {
        newTasks = await _taskService.getMyTasks(
          limit: _pageSize,
          startAfter: _lastDocument,
          status: _selectedStatus.value,
          priority: _selectedPriority.value,
          category: _selectedCategory.value,
        );
        
        // Update pagination state
        if (newTasks.length < _pageSize) {
          _hasMoreTasks.value = false;
        }
        
        if (newTasks.isNotEmpty) {
          // This would need to be implemented in the service to return DocumentSnapshot
          // For now, we'll use a simple approach
          _currentPage.value++;
        }
      }
      
      // Apply client-side sorting if needed
      newTasks = _applySorting(newTasks);
      
      if (refresh) {
        _tasks.assignAll(newTasks);
      } else {
        _tasks.addAll(newTasks);
      }
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load tasks: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Load more tasks (pagination)
  Future<void> loadMoreTasks() async {
    if (_isLoadingMore.value || !_hasMoreTasks.value) return;
    
    try {
      _isLoadingMore.value = true;
      
      final newTasks = await _taskService.getMyTasks(
        limit: _pageSize,
        startAfter: _lastDocument,
        status: _selectedStatus.value,
        priority: _selectedPriority.value,
        category: _selectedCategory.value,
      );
      
      if (newTasks.length < _pageSize) {
        _hasMoreTasks.value = false;
      }
      
      final sortedTasks = _applySorting(newTasks);
      _tasks.addAll(sortedTasks);
      
      if (newTasks.isNotEmpty) {
        _currentPage.value++;
      }
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load more tasks: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoadingMore.value = false;
    }
  }
  
  // ==================== FILTERING ====================
  
  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery.value = query.trim();
    _debounceSearch();
  }
  
  /// Clear search query
  void clearSearch() {
    _searchQuery.value = '';
    loadTasks(refresh: true);
  }
  
  /// Set status filter
  void setStatusFilter(TaskStatus? status) {
    _selectedStatus.value = status;
    loadTasks(refresh: true);
  }
  
  /// Set priority filter
  void setPriorityFilter(TaskPriority? priority) {
    _selectedPriority.value = priority;
    loadTasks(refresh: true);
  }
  
  /// Set category filter
  void setCategoryFilter(TaskCategory? category) {
    _selectedCategory.value = category;
    loadTasks(refresh: true);
  }
  
  /// Clear all filters
  void clearAllFilters() {
    _searchQuery.value = '';
    _selectedStatus.value = null;
    _selectedPriority.value = null;
    _selectedCategory.value = null;
    loadTasks(refresh: true);
  }
  
  /// Toggle status filter
  void toggleStatusFilter(TaskStatus status) {
    if (_selectedStatus.value == status) {
      _selectedStatus.value = null;
    } else {
      _selectedStatus.value = status;
    }
    loadTasks(refresh: true);
  }
  
  /// Toggle priority filter
  void togglePriorityFilter(TaskPriority priority) {
    if (_selectedPriority.value == priority) {
      _selectedPriority.value = null;
    } else {
      _selectedPriority.value = priority;
    }
    loadTasks(refresh: true);
  }
  
  /// Toggle category filter
  void toggleCategoryFilter(TaskCategory category) {
    if (_selectedCategory.value == category) {
      _selectedCategory.value = null;
    } else {
      _selectedCategory.value = category;
    }
    loadTasks(refresh: true);
  }
  
  // ==================== SORTING ====================
  
  /// Set sort criteria
  void setSortBy(String sortField, {bool? descending}) {
    _sortBy.value = sortField;
    if (descending != null) {
      _sortDescending.value = descending;
    }
    _applySortingToCurrentTasks();
  }
  
  /// Toggle sort direction
  void toggleSortDirection() {
    _sortDescending.value = !_sortDescending.value;
    _applySortingToCurrentTasks();
  }
  
  /// Apply sorting to current tasks
  void _applySortingToCurrentTasks() {
    final sortedTasks = _applySorting(_tasks.toList());
    _tasks.assignAll(sortedTasks);
  }
  
  /// Apply sorting to a list of tasks
  List<TaskModel> _applySorting(List<TaskModel> tasks) {
    final sortedTasks = List<TaskModel>.from(tasks);
    
    switch (_sortBy.value) {
      case 'title':
        sortedTasks.sort((a, b) => _sortDescending.value 
            ? b.title.compareTo(a.title)
            : a.title.compareTo(b.title));
        break;
      case 'priority':
        sortedTasks.sort((a, b) => _sortDescending.value 
            ? b.priority.level.compareTo(a.priority.level)
            : a.priority.level.compareTo(b.priority.level));
        break;
      case 'dueDate':
        sortedTasks.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return _sortDescending.value 
              ? b.dueDate!.compareTo(a.dueDate!)
              : a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case 'createdAt':
        sortedTasks.sort((a, b) => _sortDescending.value 
            ? b.createdAt.compareTo(a.createdAt)
            : a.createdAt.compareTo(b.createdAt));
        break;
      case 'status':
        sortedTasks.sort((a, b) => _sortDescending.value 
            ? b.status.order.compareTo(a.status.order)
            : a.status.order.compareTo(b.status.order));
        break;
      case 'urgency':
        sortedTasks.sort((a, b) => _sortDescending.value 
            ? b.urgencyScore.compareTo(a.urgencyScore)
            : a.urgencyScore.compareTo(b.urgencyScore));
        break;
      case 'updatedAt':
      default:
        sortedTasks.sort((a, b) => _sortDescending.value 
            ? b.updatedAt.compareTo(a.updatedAt)
            : a.updatedAt.compareTo(b.updatedAt));
        break;
    }
    
    return sortedTasks;
  }
  
  // ==================== SEARCH ====================
  
  /// Debounced search to avoid too many API calls
  void _debounceSearch() {
    // Cancel previous timer if exists
    _searchTimer?.cancel();
    
    // Start new timer
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      loadTasks(refresh: true);
    });
  }
  
  Timer? _searchTimer;
  
  @override
  void onClose() {
    _searchTimer?.cancel();
    super.onClose();
  }
  
  // ==================== QUICK FILTERS ====================
  
  /// Show only overdue tasks
  void showOverdueTasks() {
    clearAllFilters();
    // This would need custom logic since overdue is calculated, not stored
    final overdueTasks = _tasks.where((task) => task.isOverdue).toList();
    _tasks.assignAll(overdueTasks);
  }
  
  /// Show only tasks due today
  void showTasksDueToday() {
    clearAllFilters();
    final todayTasks = _tasks.where((task) => task.isDueToday).toList();
    _tasks.assignAll(todayTasks);
  }
  
  /// Show only tasks due this week
  void showTasksDueThisWeek() {
    clearAllFilters();
    final weekTasks = _tasks.where((task) => task.isDueThisWeek).toList();
    _tasks.assignAll(weekTasks);
  }
  
  /// Show only my created tasks
  void showMyCreatedTasks() {
    clearAllFilters();
    // This would need to be implemented in the service
    loadTasks(refresh: true);
  }
  
  /// Show only assigned to me tasks
  void showAssignedToMeTasks() {
    clearAllFilters();
    // This would need to be implemented in the service
    loadTasks(refresh: true);
  }
  
  // ==================== BULK OPERATIONS ====================
  
  /// Select/deselect task
  final RxSet<String> _selectedTaskIds = <String>{}.obs;
  Set<String> get selectedTaskIds => _selectedTaskIds;
  bool get hasSelectedTasks => _selectedTaskIds.isNotEmpty;
  int get selectedTasksCount => _selectedTaskIds.length;
  
  void toggleTaskSelection(String taskId) {
    if (_selectedTaskIds.contains(taskId)) {
      _selectedTaskIds.remove(taskId);
    } else {
      _selectedTaskIds.add(taskId);
    }
  }
  
  void selectAllTasks() {
    _selectedTaskIds.addAll(_tasks.map((task) => task.id));
  }
  
  void clearSelection() {
    _selectedTaskIds.clear();
  }
  
  bool isTaskSelected(String taskId) {
    return _selectedTaskIds.contains(taskId);
  }
  
  /// Bulk update selected tasks
  Future<void> bulkUpdateStatus(TaskStatus status) async {
    if (_selectedTaskIds.isEmpty) return;
    
    try {
      _isLoading.value = true;
      
      final futures = _selectedTaskIds.map((taskId) => 
          _taskService.updateTaskStatus(taskId, status));
      
      await Future.wait(futures);
      
      clearSelection();
      loadTasks(refresh: true);
      
      Get.snackbar(
        'Success',
        'Updated ${_selectedTaskIds.length} tasks',
        snackPosition: SnackPosition.TOP,
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update tasks: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Bulk delete selected tasks
  Future<void> bulkDeleteTasks() async {
    if (_selectedTaskIds.isEmpty) return;
    
    try {
      _isLoading.value = true;
      
      final futures = _selectedTaskIds.map((taskId) => 
          _taskService.deleteTask(taskId));
      
      await Future.wait(futures);
      
      clearSelection();
      loadTasks(refresh: true);
      
      Get.snackbar(
        'Success',
        'Deleted ${_selectedTaskIds.length} tasks',
        snackPosition: SnackPosition.TOP,
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete tasks: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  // ==================== UTILITY METHODS ====================
  
  /// Get filtered task count by status
  int getTaskCountByStatus(TaskStatus status) {
    return _tasks.where((task) => task.status == status).length;
  }
  
  /// Get filtered task count by priority
  int getTaskCountByPriority(TaskPriority priority) {
    return _tasks.where((task) => task.priority == priority).length;
  }
  
  /// Get filtered task count by category
  int getTaskCountByCategory(TaskCategory category) {
    return _tasks.where((task) => task.category == category).length;
  }
  
  /// Get current filter summary
  String getFilterSummary() {
    final filters = <String>[];
    
    if (_selectedStatus.value != null) {
      filters.add('Status: ${_selectedStatus.value!.displayName}');
    }
    if (_selectedPriority.value != null) {
      filters.add('Priority: ${_selectedPriority.value!.displayName}');
    }
    if (_selectedCategory.value != null) {
      filters.add('Category: ${_selectedCategory.value!.displayName}');
    }
    if (_searchQuery.value.isNotEmpty) {
      filters.add('Search: "${_searchQuery.value}"');
    }
    
    return filters.isEmpty ? 'All Tasks' : filters.join(', ');
  }
  
  /// Refresh tasks
  Future<void> refreshTasks() async {
    await loadTasks(refresh: true);
  }
  
  /// Reset to default state
  void resetToDefault() {
    clearAllFilters();
    _sortBy.value = 'updatedAt';
    _sortDescending.value = true;
    clearSelection();
    loadTasks(refresh: true);
  }
}
