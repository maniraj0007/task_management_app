import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/enums/task_enums.dart';
import '../../models/task_model.dart';

/// Task Card Widget
/// Displays task information in a card format with actions
class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final Function(TaskStatus)? onStatusChanged;
  final Function(TaskPriority)? onPriorityChanged;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool compact;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onStatusChanged,
    this.onPriorityChanged,
    this.onDelete,
    this.showActions = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: BorderSide(
          color: _getStatusColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: EdgeInsets.all(
            compact ? AppDimensions.paddingSmall : AppDimensions.paddingMedium,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title and priority
              _buildHeader(),
              
              if (!compact) ...[
                const SizedBox(height: AppDimensions.paddingSmall),
                
                // Description
                if (task.description.isNotEmpty) _buildDescription(),
                
                const SizedBox(height: AppDimensions.paddingSmall),
                
                // Tags
                if (task.tags.isNotEmpty) _buildTags(),
                
                const SizedBox(height: AppDimensions.paddingSmall),
              ],
              
              // Footer with metadata and actions
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header with title and priority
  Widget _buildHeader() {
    return Row(
      children: [
        // Status indicator
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: _getStatusColor(),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        
        const SizedBox(width: AppDimensions.paddingSmall),
        
        // Title
        Expanded(
          child: Text(
            task.title,
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              decoration: task.status.isCompleted 
                ? TextDecoration.lineThrough 
                : null,
            ),
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        // Priority indicator
        _buildPriorityChip(),
      ],
    );
  }

  /// Build description
  Widget _buildDescription() {
    return Text(
      task.description,
      style: Get.textTheme.bodyMedium?.copyWith(
        color: Colors.grey[600],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build tags
  Widget _buildTags() {
    return Wrap(
      spacing: AppDimensions.paddingSmall,
      runSpacing: AppDimensions.paddingSmall / 2,
      children: task.tags.take(3).map((tag) => Chip(
        label: Text(
          tag,
          style: Get.textTheme.bodySmall,
        ),
        backgroundColor: AppColors.primary.withOpacity(0.1),
        side: BorderSide.none,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      )).toList(),
    );
  }

  /// Build footer with metadata and actions
  Widget _buildFooter() {
    return Row(
      children: [
        // Category icon
        Icon(
          _getCategoryIcon(),
          size: 16,
          color: Colors.grey[600],
        ),
        
        const SizedBox(width: AppDimensions.paddingSmall),
        
        // Due date
        if (task.dueDate != null) ...[
          Icon(
            Icons.schedule,
            size: 16,
            color: task.isOverdue ? Colors.red : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            _formatDueDate(),
            style: Get.textTheme.bodySmall?.copyWith(
              color: task.isOverdue ? Colors.red : Colors.grey[600],
              fontWeight: task.isOverdue ? FontWeight.w600 : null,
            ),
          ),
        ],
        
        const Spacer(),
        
        // Actions
        if (showActions) _buildActions(),
      ],
    );
  }

  /// Build priority chip
  Widget _buildPriorityChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _getPriorityColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(
          color: _getPriorityColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPriorityIcon(),
            size: 12,
            color: _getPriorityColor(),
          ),
          const SizedBox(width: 2),
          Text(
            task.priority.displayName,
            style: Get.textTheme.bodySmall?.copyWith(
              color: _getPriorityColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build actions
  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status action
        if (onStatusChanged != null)
          PopupMenuButton<TaskStatus>(
            icon: Icon(
              _getStatusIcon(),
              size: 20,
              color: _getStatusColor(),
            ),
            tooltip: 'Change Status',
            onSelected: onStatusChanged,
            itemBuilder: (context) => task.status.nextStatuses
              .map((status) => PopupMenuItem(
                value: status,
                child: Row(
                  children: [
                    Icon(
                      _getStatusIconForStatus(status),
                      size: 16,
                      color: _getStatusColorForStatus(status),
                    ),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Text(status.displayName),
                  ],
                ),
              ))
              .toList(),
          ),
        
        // More actions
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            size: 20,
            color: Colors.grey[600],
          ),
          tooltip: 'More Actions',
          onSelected: _handleMoreAction,
          itemBuilder: (context) => [
            if (onPriorityChanged != null)
              const PopupMenuItem(
                value: 'priority',
                child: Row(
                  children: [
                    Icon(Icons.priority_high, size: 16),
                    SizedBox(width: AppDimensions.paddingSmall),
                    Text('Change Priority'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: AppDimensions.paddingSmall),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'duplicate',
              child: Row(
                children: [
                  Icon(Icons.copy, size: 16),
                  SizedBox(width: AppDimensions.paddingSmall),
                  Text('Duplicate'),
                ],
              ),
            ),
            if (onDelete != null)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Colors.red),
                    SizedBox(width: AppDimensions.paddingSmall),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Handle more actions
  void _handleMoreAction(String action) {
    switch (action) {
      case 'priority':
        _showPriorityDialog();
        break;
      case 'edit':
        Get.toNamed('/edit-task', arguments: task);
        break;
      case 'duplicate':
        _duplicateTask();
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }

  /// Show priority change dialog
  void _showPriorityDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Change Priority'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TaskPriority.values.map((priority) => ListTile(
            leading: Icon(
              _getPriorityIconForPriority(priority),
              color: _getPriorityColorForPriority(priority),
            ),
            title: Text(priority.displayName),
            subtitle: Text(priority.description),
            selected: task.priority == priority,
            onTap: () {
              Get.back();
              onPriorityChanged?.call(priority);
            },
          )).toList(),
        ),
      ),
    );
  }

  /// Duplicate task
  void _duplicateTask() {
    Get.snackbar(
      'Duplicate',
      'Task duplication functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Get status color
  Color _getStatusColor() {
    return _getStatusColorForStatus(task.status);
  }

  /// Get status color for specific status
  Color _getStatusColorForStatus(TaskStatus status) {
    return Color(int.parse(status.colorHex.substring(1), radix: 16) + 0xFF000000);
  }

  /// Get status icon
  IconData _getStatusIcon() {
    return _getStatusIconForStatus(task.status);
  }

  /// Get status icon for specific status
  IconData _getStatusIconForStatus(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.play_circle_outline;
      case TaskStatus.review:
        return Icons.rate_review;
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.cancelled:
        return Icons.cancel;
    }
  }

  /// Get priority color
  Color _getPriorityColor() {
    return _getPriorityColorForPriority(task.priority);
  }

  /// Get priority color for specific priority
  Color _getPriorityColorForPriority(TaskPriority priority) {
    return Color(int.parse(priority.colorHex.substring(1), radix: 16) + 0xFF000000);
  }

  /// Get priority icon
  IconData _getPriorityIcon() {
    return _getPriorityIconForPriority(task.priority);
  }

  /// Get priority icon for specific priority
  IconData _getPriorityIconForPriority(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.keyboard_arrow_down;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.keyboard_arrow_up;
      case TaskPriority.urgent:
        return Icons.priority_high;
    }
  }

  /// Get category icon
  IconData _getCategoryIcon() {
    switch (task.category) {
      case TaskCategory.personal:
        return Icons.person;
      case TaskCategory.teamCollaboration:
        return Icons.group;
      case TaskCategory.projectManagement:
        return Icons.folder_open;
    }
  }

  /// Format due date
  String _formatDueDate() {
    if (task.dueDate == null) return '';
    
    final now = DateTime.now();
    final dueDate = task.dueDate!;
    final difference = dueDate.difference(now).inDays;
    
    if (difference < 0) {
      return '${difference.abs()} days overdue';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else if (difference <= 7) {
      return 'Due in $difference days';
    } else {
      return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
    }
  }
}

