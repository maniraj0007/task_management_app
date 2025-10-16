import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/task_list_controller.dart';
import '../../models/task_model.dart';

/// Screen for displaying and managing task list
class TaskListScreen extends GetView<TaskListController> {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: controller.refreshTasks,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'filter',
                child: ListTile(
                  leading: Icon(Icons.filter_list),
                  title: Text('Filter'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'sort',
                child: ListTile(
                  leading: Icon(Icons.sort),
                  title: Text('Sort'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),
          
          // Filter chips
          _buildFilterChips(),
          
          // Task statistics
          _buildTaskStatistics(),
          
          // Task list
          Expanded(
            child: Obx(() {
              if (controller.isLoading && controller.filteredTasks.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredTasks.isEmpty) {
                return _buildEmptyState();
              }
              
              return RefreshIndicator(
                onRefresh: controller.refreshTasks,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = controller.filteredTasks[index];
                    return _buildTaskCard(task);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/tasks/create'),
        child: const Icon(Icons.add),
        tooltip: 'Create Task',
      ),
    );
  }

  /// Build search bar
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: controller.updateSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: controller.clearSearch,
                  icon: const Icon(Icons.clear),
                )
              : const SizedBox.shrink()),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  /// Build filter chips
  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() => ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Status filters
          ...TaskStatus.values.map((status) {
            final isSelected = controller.selectedStatusFilter == status;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Text(_getStatusText(status)),
                onSelected: (selected) => controller.updateStatusFilter(
                  selected ? status : null,
                ),
                avatar: Icon(
                  _getStatusIcon(status),
                  size: 16,
                  color: isSelected ? Colors.white : _getStatusColor(status),
                ),
              ),
            );
          }).toList(),
          
          const SizedBox(width: 8),
          
          // Priority filters
          ...TaskPriority.values.map((priority) {
            final isSelected = controller.selectedPriorityFilter == priority;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Text(_getPriorityText(priority)),
                onSelected: (selected) => controller.updatePriorityFilter(
                  selected ? priority : null,
                ),
                avatar: Icon(
                  Icons.flag,
                  size: 16,
                  color: isSelected ? Colors.white : _getPriorityColor(priority),
                ),
              ),
            );
          }).toList(),
          
          const SizedBox(width: 8),
          
          // Overdue filter
          FilterChip(
            selected: controller.showOverdueOnly,
            label: const Text('Overdue'),
            onSelected: controller.toggleOverdueFilter,
            avatar: Icon(
              Icons.warning,
              size: 16,
              color: controller.showOverdueOnly ? Colors.white : Colors.red,
            ),
          ),
        ],
      )),
    );
  }

  /// Build task statistics
  Widget _buildTaskStatistics() {
    return Obx(() => Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total',
            controller.totalTasks.toString(),
            Icons.list_alt,
            Colors.blue,
          ),
          _buildStatItem(
            'Pending',
            controller.pendingTasks.toString(),
            Icons.schedule,
            Colors.orange,
          ),
          _buildStatItem(
            'In Progress',
            controller.inProgressTasks.toString(),
            Icons.play_circle_outline,
            Colors.blue,
          ),
          _buildStatItem(
            'Completed',
            controller.completedTasks.toString(),
            Icons.check_circle_outline,
            Colors.green,
          ),
        ],
      ),
    ));
  }

  /// Build stat item
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Build task card
  Widget _buildTaskCard(TaskModel task) {
    final isOverdue = task.dueDate != null && 
                     task.dueDate!.isBefore(DateTime.now()) && 
                     task.status != TaskStatus.completed;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Get.toNamed('/tasks/details/${task.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getPriorityColor(task.priority).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and priority
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: task.status == TaskStatus.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildPriorityChip(task.priority),
                  ],
                ),
                
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                const SizedBox(height: 12),
                
                // Status, due date, and actions
                Row(
                  children: [
                    _buildStatusChip(task.status),
                    const SizedBox(width: 8),
                    if (task.dueDate != null) _buildDueDateChip(task.dueDate!, isOverdue),
                    const Spacer(),
                    _buildTaskActions(task),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build priority chip
  Widget _buildPriorityChip(TaskPriority priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getPriorityColor(priority).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flag,
            size: 12,
            color: _getPriorityColor(priority),
          ),
          const SizedBox(width: 4),
          Text(
            _getPriorityText(priority),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _getPriorityColor(priority),
            ),
          ),
        ],
      ),
    );
  }

  /// Build status chip
  Widget _buildStatusChip(TaskStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: 12,
            color: _getStatusColor(status),
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusText(status),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(status),
            ),
          ),
        ],
      ),
    );
  }

  /// Build due date chip
  Widget _buildDueDateChip(DateTime dueDate, bool isOverdue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOverdue 
            ? Colors.red.withOpacity(0.1)
            : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue 
              ? Colors.red.withOpacity(0.3)
              : Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue ? Icons.warning : Icons.schedule,
            size: 12,
            color: isOverdue ? Colors.red : Colors.blue,
          ),
          const SizedBox(width: 4),
          Text(
            _formatDueDate(dueDate),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isOverdue ? Colors.red : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  /// Build task actions
  Widget _buildTaskActions(TaskModel task) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (task.status != TaskStatus.completed)
          IconButton(
            onPressed: () => controller.updateTaskStatus(task.id, TaskStatus.completed),
            icon: const Icon(Icons.check_circle_outline),
            iconSize: 20,
            tooltip: 'Mark Complete',
          ),
        PopupMenuButton<String>(
          onSelected: (action) => _handleTaskAction(action, task),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit, size: 20),
                title: Text('Edit'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red, size: 20),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
          child: const Icon(Icons.more_vert, size: 20),
        ),
      ],
    );
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
          const SizedBox(height: 16),
          Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first task to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/tasks/create'),
            icon: const Icon(Icons.add),
            label: const Text('Create Task'),
          ),
        ],
      ),
    );
  }

  /// Handle menu actions
  void _handleMenuAction(String action) {
    switch (action) {
      case 'filter':
        _showFilterDialog();
        break;
      case 'sort':
        _showSortDialog();
        break;
    }
  }

  /// Handle task actions
  void _handleTaskAction(String action, TaskModel task) {
    switch (action) {
      case 'edit':
        Get.toNamed('/tasks/edit/${task.id}');
        break;
      case 'delete':
        controller.deleteTask(task.id);
        break;
    }
  }

  /// Show filter dialog
  void _showFilterDialog() {
    // TODO: Implement filter dialog
    Get.snackbar('Info', 'Filter dialog coming soon');
  }

  /// Show sort dialog
  void _showSortDialog() {
    // TODO: Implement sort dialog
    Get.snackbar('Info', 'Sort dialog coming soon');
  }

  /// Get status icon
  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Icons.schedule;
      case TaskStatus.inProgress:
        return Icons.play_circle_outline;
      case TaskStatus.completed:
        return Icons.check_circle_outline;
    }
  }

  /// Get status color
  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
    }
  }

  /// Get status text
  String _getStatusText(TaskStatus status) {
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
  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  /// Get priority text
  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  /// Format due date
  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${dueDate.day}/${dueDate.month}';
    }
  }
}

