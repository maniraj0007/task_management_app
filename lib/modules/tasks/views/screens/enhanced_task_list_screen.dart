import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/enums/task_enums.dart';
import '../../controllers/enhanced_task_controller.dart';
import '../../models/task_model.dart';
import '../widgets/task_card.dart';
import '../widgets/task_filter_bar.dart';
import '../widgets/task_stats_card.dart';

/// Enhanced Task List Screen
/// Comprehensive task management interface with filtering, sorting, and statistics
class EnhancedTaskListScreen extends GetView<EnhancedTaskController> {
  const EnhancedTaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (!controller.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return RefreshIndicator(
          onRefresh: controller.refreshTasks,
          child: Column(
            children: [
              // Statistics overview
              _buildStatsOverview(),
              
              // Filter bar
              const TaskFilterBar(),
              
              // Task list
              Expanded(
                child: _buildTaskList(),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Build app bar with search and actions
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Tasks'),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        // Search button
        IconButton(
          onPressed: _showSearchDialog,
          icon: const Icon(Icons.search),
          tooltip: 'Search Tasks',
        ),
        
        // Refresh button
        Obx(() => IconButton(
          onPressed: controller.isSyncing ? null : controller.refreshTasks,
          icon: controller.isSyncing 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.refresh),
          tooltip: 'Refresh',
        )),
        
        // More options
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view_mode',
              child: ListTile(
                leading: Icon(Icons.view_list),
                title: Text('View Mode'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('Export'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build statistics overview
  Widget _buildStatsOverview() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: TaskStatsCard(
              title: 'Total',
              count: controller.totalTasksCount,
              color: AppColors.primary,
              icon: Icons.task_alt,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          Expanded(
            child: TaskStatsCard(
              title: 'Completed',
              count: controller.completedTasksCount,
              color: Colors.green,
              icon: Icons.check_circle,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          Expanded(
            child: TaskStatsCard(
              title: 'In Progress',
              count: controller.inProgressTasksCount,
              color: Colors.blue,
              icon: Icons.play_circle,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          Expanded(
            child: TaskStatsCard(
              title: 'Overdue',
              count: controller.overdueTasksCount,
              color: Colors.red,
              icon: Icons.warning,
            ),
          ),
        ],
      )),
    );
  }

  /// Build task list based on current filters
  Widget _buildTaskList() {
    return Obx(() {
      final tasks = _getFilteredTasks();
      
      if (tasks.isEmpty) {
        return _buildEmptyState();
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
            child: TaskCard(
              task: task,
              onTap: () => _navigateToTaskDetail(task),
              onStatusChanged: (newStatus) => _updateTaskStatus(task, newStatus),
              onPriorityChanged: (newPriority) => _updateTaskPriority(task, newPriority),
              onDelete: () => _deleteTask(task),
            ),
          );
        },
      );
    });
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            'No tasks found',
            style: Get.textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            'Create your first task to get started',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          ElevatedButton.icon(
            onPressed: _navigateToCreateTask,
            icon: const Icon(Icons.add),
            label: const Text('Create Task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingLarge,
                vertical: AppDimensions.paddingMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build floating action button
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _navigateToCreateTask,
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  /// Get filtered tasks based on current filters
  List<TaskModel> _getFilteredTasks() {
    List<TaskModel> tasks = controller.myTasks;
    
    // Apply category filter
    if (controller.selectedCategory != null) {
      tasks = tasks.where((task) => task.category == controller.selectedCategory).toList();
    }
    
    // Apply status filter
    if (controller.selectedStatus != null) {
      tasks = tasks.where((task) => task.status == controller.selectedStatus).toList();
    }
    
    // Apply priority filter
    if (controller.selectedPriority != null) {
      tasks = tasks.where((task) => task.priority == controller.selectedPriority).toList();
    }
    
    // Apply search filter
    if (controller.searchQuery.isNotEmpty) {
      final query = controller.searchQuery.toLowerCase();
      tasks = tasks.where((task) => 
        task.title.toLowerCase().contains(query) ||
        task.description.toLowerCase().contains(query) ||
        task.tags.any((tag) => tag.toLowerCase().contains(query))
      ).toList();
    }
    
    // Apply sorting
    tasks.sort((a, b) {
      switch (controller.sortBy) {
        case 'title':
          return controller.sortAscending 
            ? a.title.compareTo(b.title)
            : b.title.compareTo(a.title);
        case 'priority':
          return controller.sortAscending 
            ? a.priority.level.compareTo(b.priority.level)
            : b.priority.level.compareTo(a.priority.level);
        case 'status':
          return controller.sortAscending 
            ? a.status.order.compareTo(b.status.order)
            : b.status.order.compareTo(a.status.order);
        case 'createdAt':
          return controller.sortAscending 
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt);
        case 'dueDate':
        default:
          // Handle null due dates
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return controller.sortAscending 
            ? a.dueDate!.compareTo(b.dueDate!)
            : b.dueDate!.compareTo(a.dueDate!);
      }
    });
    
    return tasks;
  }

  /// Show search dialog
  void _showSearchDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Search Tasks'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter search terms...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: controller.setSearchQuery,
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.setSearchQuery('');
              Get.back();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Handle menu actions
  void _handleMenuAction(String action) {
    switch (action) {
      case 'view_mode':
        _showViewModeDialog();
        break;
      case 'export':
        _exportTasks();
        break;
      case 'settings':
        _navigateToSettings();
        break;
    }
  }

  /// Show view mode dialog
  void _showViewModeDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('View Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.view_list),
              title: const Text('List View'),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: const Icon(Icons.view_module),
              title: const Text('Grid View'),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: const Icon(Icons.view_kanban),
              title: const Text('Kanban View'),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  /// Export tasks
  void _exportTasks() {
    Get.snackbar(
      'Export',
      'Task export functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Navigate to settings
  void _navigateToSettings() {
    Get.toNamed('/settings');
  }

  /// Navigate to task detail
  void _navigateToTaskDetail(TaskModel task) {
    Get.toNamed('/task-detail', arguments: task);
  }

  /// Navigate to create task
  void _navigateToCreateTask() {
    Get.toNamed('/create-task');
  }

  /// Update task status
  void _updateTaskStatus(TaskModel task, TaskStatus newStatus) {
    controller.updateTaskStatus(task.id, newStatus);
  }

  /// Update task priority
  void _updateTaskPriority(TaskModel task, TaskPriority newPriority) {
    controller.updateTaskPriority(task.id, newPriority);
  }

  /// Delete task
  void _deleteTask(TaskModel task) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteTask(task.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

