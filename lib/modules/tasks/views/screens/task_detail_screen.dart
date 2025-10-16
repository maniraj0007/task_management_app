import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/task_detail_controller.dart';
import '../../models/task_model.dart';

/// Screen for viewing task details
class TaskDetailScreen extends GetView<TaskDetailController> {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
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
      
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.task == null) {
          return const Center(
            child: Text('Task not found'),
          );
        }
        
        return RefreshIndicator(
          onRefresh: controller.refreshTask,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task header
                _buildTaskHeader(),
                
                const SizedBox(height: 24),
                
                // Task details
                _buildTaskDetails(),
                
                const SizedBox(height: 24),
                
                // Status actions
                _buildStatusActions(),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Build task header with title and priority
  Widget _buildTaskHeader() {
    final task = controller.task!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      decoration: task.status == TaskStatus.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _buildPriorityChip(),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Status and due date
            Row(
              children: [
                _buildStatusChip(),
                const Spacer(),
                if (task.dueDate != null) _buildDueDateInfo(),
              ],
            ),
            
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build task details section
  Widget _buildTaskDetails() {
    final task = controller.task!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Category
            if (task.category != null)
              _buildDetailRow(
                icon: Icons.folder_outlined,
                label: 'Category',
                value: task.category.toString().split('.').last,
              ),
            
            // Created date
            _buildDetailRow(
              icon: Icons.add_circle_outline,
              label: 'Created',
              value: controller.getRelativeTime(task.createdAt),
            ),
            
            // Updated date
            _buildDetailRow(
              icon: Icons.update,
              label: 'Last Updated',
              value: controller.getRelativeTime(task.updatedAt),
            ),
            
            // Completed date
            if (task.completedAt != null)
              _buildDetailRow(
                icon: Icons.check_circle_outline,
                label: 'Completed',
                value: controller.getRelativeTime(task.completedAt!),
                valueColor: Colors.green,
              ),
            
            // Assigned users
            if (task.assignedUsers.isNotEmpty)
              _buildDetailRow(
                icon: Icons.people_outline,
                label: 'Assigned To',
                value: '${task.assignedUsers.length} user(s)',
              ),
          ],
        ),
      ),
    );
  }

  /// Build status action buttons
  Widget _buildStatusActions() {
    final task = controller.task!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Status change buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskStatus.values.map((status) {
                final isCurrentStatus = task.status == status;
                return FilterChip(
                  selected: isCurrentStatus,
                  label: Text(_getStatusText(status)),
                  avatar: Icon(
                    _getStatusIcon(status),
                    size: 18,
                    color: isCurrentStatus 
                        ? Colors.white 
                        : _getStatusColor(status),
                  ),
                  onSelected: isCurrentStatus 
                      ? null 
                      : (selected) => controller.updateTaskStatus(status),
                  backgroundColor: _getStatusColor(status).withOpacity(0.1),
                  selectedColor: _getStatusColor(status),
                  checkmarkColor: Colors.white,
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.editTask,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Task'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: task.status == TaskStatus.completed
                        ? null
                        : () => controller.updateTaskStatus(TaskStatus.completed),
                    icon: const Icon(Icons.check),
                    label: Text(
                      task.status == TaskStatus.completed 
                          ? 'Completed' 
                          : 'Mark Complete',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: task.status == TaskStatus.completed
                          ? Colors.green
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build priority chip
  Widget _buildPriorityChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: controller.getPriorityColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: controller.getPriorityColor().withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flag,
            size: 16,
            color: controller.getPriorityColor(),
          ),
          const SizedBox(width: 4),
          Text(
            controller.getPriorityText(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: controller.getPriorityColor(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build status chip
  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: controller.getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: controller.getStatusColor().withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(controller.task!.status),
            size: 16,
            color: controller.getStatusColor(),
          ),
          const SizedBox(width: 6),
          Text(
            controller.getStatusText(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: controller.getStatusColor(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build due date information
  Widget _buildDueDateInfo() {
    final task = controller.task!;
    final isOverdue = controller.isOverdue;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOverdue 
            ? Colors.red.withOpacity(0.1)
            : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
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
            size: 16,
            color: isOverdue ? Colors.red : Colors.blue,
          ),
          const SizedBox(width: 6),
          Text(
            isOverdue 
                ? 'Overdue'
                : controller.formatDueDate(task.dueDate!),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isOverdue ? Colors.red : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  /// Build detail row
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /// Handle menu actions
  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        controller.editTask();
        break;
      case 'delete':
        controller.deleteTask();
        break;
    }
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
}

