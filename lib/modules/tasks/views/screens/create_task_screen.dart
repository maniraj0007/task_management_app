import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/create_task_controller.dart';
import '../../models/task_model.dart';

/// Screen for creating and editing tasks
class CreateTaskScreen extends GetView<CreateTaskController> {
  const CreateTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.isEditMode ? 'Edit Task' : 'Create Task',
        )),
        elevation: 0,
        actions: [
          Obx(() => controller.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: controller.saveTask,
                  child: Text(
                    controller.isEditMode ? 'Update' : 'Create',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
          ),
        ],
      ),
      
      body: Obx(() {
        if (controller.isLoading && controller.isEditMode) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title field
                _buildSectionTitle('Task Details'),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: controller.titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title *',
                    hintText: 'Enter task title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Task title is required';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                
                const SizedBox(height: 16),
                
                // Description field
                TextFormField(
                  controller: controller.descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter task description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                ),
                
                const SizedBox(height: 24),
                
                // Priority and Status
                _buildSectionTitle('Priority & Status'),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(child: _buildPrioritySelector()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatusSelector()),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Due Date and Category
                _buildSectionTitle('Schedule & Category'),
                const SizedBox(height: 16),
                
                _buildDueDateSelector(),
                const SizedBox(height: 16),
                _buildCategorySelector(),
                
                const SizedBox(height: 32),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.cancel,
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.isLoading ? null : controller.saveTask,
                        child: controller.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(controller.isEditMode ? 'Update Task' : 'Create Task'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Build section title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Build priority selector
  Widget _buildPrioritySelector() {
    return Obx(() => Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Priority',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          ...TaskPriority.values.map((priority) {
            final isSelected = controller.selectedPriority == priority;
            return ListTile(
              dense: true,
              leading: Icon(
                Icons.flag,
                color: controller.getPriorityColor(priority),
                size: 20,
              ),
              title: Text(
                controller.getPriorityDisplayName(priority),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onTap: () => controller.updatePriority(priority),
            );
          }).toList(),
        ],
      ),
    ));
  }

  /// Build status selector
  Widget _buildStatusSelector() {
    return Obx(() => Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Status',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          ...TaskStatus.values.map((status) {
            final isSelected = controller.selectedStatus == status;
            return ListTile(
              dense: true,
              leading: Icon(
                _getStatusIcon(status),
                color: controller.getStatusColor(status),
                size: 20,
              ),
              title: Text(
                controller.getStatusDisplayName(status),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onTap: () => controller.updateStatus(status),
            );
          }).toList(),
        ],
      ),
    ));
  }

  /// Build due date selector
  Widget _buildDueDateSelector() {
    return Obx(() => InkWell(
      onTap: controller.selectDueDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.schedule, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Due Date',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.selectedDueDate != null
                        ? _formatDateTime(controller.selectedDueDate!)
                        : 'No due date set',
                    style: TextStyle(
                      fontSize: 16,
                      color: controller.selectedDueDate != null
                          ? Colors.black87
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (controller.selectedDueDate != null)
              IconButton(
                onPressed: controller.clearDueDate,
                icon: const Icon(Icons.clear, size: 20),
                tooltip: 'Clear due date',
              ),
          ],
        ),
      ),
    ));
  }

  /// Build category selector
  Widget _buildCategorySelector() {
    return Obx(() => DropdownButtonFormField<String>(
      value: controller.selectedCategory.isEmpty ? null : controller.selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.folder),
      ),
      hint: const Text('Select category'),
      items: controller.categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) => controller.updateCategory(value ?? ''),
    ));
  }

  /// Get status icon
  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.play_circle_outline;
      case TaskStatus.completed:
        return Icons.check_circle_outline;
      case TaskStatus.review:
        return Icons.rate_review;
      case TaskStatus.cancelled:
        return Icons.cancel;
    }
  }

  /// Format date time for display
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dateStr;
    if (taskDate == today) {
      dateStr = 'Today';
    } else if (taskDate == tomorrow) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    
    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    
    return '$dateStr at $timeStr';
  }
}
