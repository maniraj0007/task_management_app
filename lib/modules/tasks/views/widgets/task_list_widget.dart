import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/models/task_model.dart';
import '../../controllers/task_controller.dart';
import 'task_card_widget.dart';
import 'task_filter_widget.dart';

/// Task List Widget
/// Advanced task list with filtering, sorting, and selection capabilities
class TaskListWidget extends StatefulWidget {
  final String? teamId;
  final String? projectId;
  final bool showFilters;
  final bool allowSelection;
  final bool showCompleted;
  final VoidCallback? onTaskTap;
  final Function(TaskModel)? onTaskEdit;
  final Function(TaskModel)? onTaskDelete;

  const TaskListWidget({
    Key? key,
    this.teamId,
    this.projectId,
    this.showFilters = true,
    this.allowSelection = false,
    this.showCompleted = true,
    this.onTaskTap,
    this.onTaskEdit,
    this.onTaskDelete,
  }) : super(key: key);

  @override
  State<TaskListWidget> createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  final TaskController _taskController = Get.find<TaskController>();
  final ScrollController _scrollController = ScrollController();
  
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    _taskController.loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with search and filters
        if (widget.showFilters) _buildHeader(),
        
        // Filter panel
        if (widget.showFilters && _isFilterExpanded) _buildFilterPanel(),
        
        // Task list
        Expanded(child: _buildTaskList()),
        
        // Selection actions
        if (widget.allowSelection) _buildSelectionActions(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: _taskController.setSearchQuery,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isFilterExpanded = !_isFilterExpanded;
                  });
                },
                icon: Icon(
                  _isFilterExpanded ? Icons.filter_list_off : Icons.filter_list,
                  color: _isFilterExpanded ? Theme.of(context).primaryColor : null,
                ),
                tooltip: 'Filters',
              ),
              if (widget.allowSelection)
                IconButton(
                  onPressed: _toggleSelectionMode,
                  icon: const Icon(Icons.checklist),
                  tooltip: 'Select tasks',
                ),
            ],
          ),
          
          // Quick stats
          const SizedBox(height: 12),
          Obx(() => _buildQuickStats()),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _buildStatChip(
          'Total',
          _taskController.totalTasks.toString(),
          Colors.blue,
          Icons.task_alt,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          'Pending',
          _taskController.pendingTasks.toString(),
          Colors.orange,
          Icons.pending_actions,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          'Completed',
          _taskController.completedTasks.toString(),
          Colors.green,
          Icons.check_circle,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          'Overdue',
          _taskController.overdueTasks.toString(),
          Colors.red,
          Icons.warning,
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPanel() {
    return TaskFilterWidget(
      onFiltersChanged: () {
        // Filters are automatically applied through reactive programming
      },
    );
  }

  Widget _buildTaskList() {
    return Obx(() {
      if (_taskController.isLoading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (_taskController.error.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading tasks',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _taskController.error,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadTasks,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      final tasks = _getFilteredTasks();

      if (tasks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.task_alt,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'No tasks found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first task to get started',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => _loadTasks(),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TaskCardWidget(
                task: task,
                isSelected: widget.allowSelection && _taskController.selectedTasks.contains(task),
                showSelection: widget.allowSelection,
                onTap: () => _handleTaskTap(task),
                onSelectionChanged: widget.allowSelection ? (selected) => _handleTaskSelection(task, selected) : null,
                onEdit: widget.onTaskEdit != null ? () => widget.onTaskEdit!(task) : null,
                onDelete: widget.onTaskDelete != null ? () => widget.onTaskDelete!(task) : null,
                onStatusChanged: (status) => _handleStatusChange(task, status),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildSelectionActions() {
    return Obx(() {
      final selectedCount = _taskController.selectedTasks.length;
      
      if (selectedCount == 0) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          border: Border(
            top: BorderSide(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              '$selectedCount selected',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _taskController.clearTaskSelection,
              icon: const Icon(Icons.clear),
              label: const Text('Clear'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _taskController.deleteSelectedTasks,
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    });
  }

  List<TaskModel> _getFilteredTasks() {
    var tasks = _taskController.filteredTasks;
    
    // Filter by team/project if specified
    if (widget.teamId != null) {
      tasks = tasks.where((task) => task.teamId == widget.teamId).toList();
    }
    
    if (widget.projectId != null) {
      tasks = tasks.where((task) => task.projectId == widget.projectId).toList();
    }
    
    // Filter completed tasks if not showing them
    if (!widget.showCompleted) {
      tasks = tasks.where((task) => task.status != 'completed').toList();
    }
    
    return tasks;
  }

  void _handleTaskTap(TaskModel task) {
    if (widget.allowSelection) {
      _handleTaskSelection(task, !_taskController.selectedTasks.contains(task));
    } else {
      widget.onTaskTap?.call();
      // Navigate to task details or show task details modal
      _showTaskDetails(task);
    }
  }

  void _handleTaskSelection(TaskModel task, bool selected) {
    _taskController.toggleTaskSelection(task);
  }

  void _handleStatusChange(TaskModel task, String newStatus) {
    _taskController.toggleTaskCompletion(task.id);
  }

  void _toggleSelectionMode() {
    if (_taskController.selectedTasks.isNotEmpty) {
      _taskController.clearTaskSelection();
    } else {
      // Enter selection mode - could show instructions or select first task
    }
  }

  void _showTaskDetails(TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: TaskDetailsWidget(
            task: task,
            scrollController: scrollController,
            onEdit: widget.onTaskEdit,
            onDelete: widget.onTaskDelete,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

/// Task Details Widget
/// Shows detailed task information in a modal
class TaskDetailsWidget extends StatelessWidget {
  final TaskModel task;
  final ScrollController scrollController;
  final Function(TaskModel)? onEdit;
  final Function(TaskModel)? onDelete;

  const TaskDetailsWidget({
    Key? key,
    required this.task,
    required this.scrollController,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        // Handle bar
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Header
        Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit?.call(task);
                    Navigator.of(context).pop();
                    break;
                  case 'delete':
                    onDelete?.call(task);
                    Navigator.of(context).pop();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Status and priority
        Row(
          children: [
            _buildStatusChip(context, task.status),
            const SizedBox(width: 8),
            _buildPriorityChip(context, task.priority),
          ],
        ),
        const SizedBox(height: 16),

        // Description
        if (task.description?.isNotEmpty == true) ...[
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            task.description!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
        ],

        // Due date
        if (task.dueDate != null) ...[
          _buildInfoRow(
            context,
            'Due Date',
            '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
            Icons.calendar_today,
          ),
          const SizedBox(height: 12),
        ],

        // Assignees
        if (task.assignees.isNotEmpty) ...[
          _buildInfoRow(
            context,
            'Assignees',
            '${task.assignees.length} assigned',
            Icons.people,
          ),
          const SizedBox(height: 12),
        ],

        // Tags
        if (task.tags.isNotEmpty) ...[
          Text(
            'Tags',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: task.tags.map((tag) => Chip(
              label: Text(tag),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            )).toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Timestamps
        _buildInfoRow(
          context,
          'Created',
          '${task.createdAt.day}/${task.createdAt.month}/${task.createdAt.year}',
          Icons.access_time,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          'Updated',
          '${task.updatedAt.day}/${task.updatedAt.month}/${task.updatedAt.year}',
          Icons.update,
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'completed':
        color = Colors.green;
        label = 'Completed';
        break;
      case 'in_progress':
        color = Colors.blue;
        label = 'In Progress';
        break;
      case 'review':
        color = Colors.orange;
        label = 'Review';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        label = 'To Do';
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPriorityChip(BuildContext context, String priority) {
    Color color;
    String label;
    
    switch (priority) {
      case 'urgent':
        color = Colors.red;
        label = 'Urgent';
        break;
      case 'high':
        color = Colors.orange;
        label = 'High';
        break;
      case 'low':
        color = Colors.green;
        label = 'Low';
        break;
      default:
        color = Colors.blue;
        label = 'Medium';
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
