import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/enums/task_enums.dart';
import '../../controllers/enhanced_task_controller.dart';
import '../widgets/task_form_field.dart';

/// Create Task Screen
/// Allows users to create new tasks with comprehensive options
class CreateTaskScreen extends GetView<EnhancedTaskController> {
  const CreateTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Create Task'),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        TextButton(
          onPressed: controller.clearForm,
          child: const Text(
            'Clear',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  /// Build body
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Form(
        key: controller.taskFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title field
            TaskFormField(
              controller: controller.titleController,
              label: 'Task Title',
              hint: 'Enter task title',
              validator: controller.validateTitle,
              required: true,
            ),
            
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // Description field
            TaskFormField(
              controller: controller.descriptionController,
              label: 'Description',
              hint: 'Enter task description',
              validator: controller.validateDescription,
              maxLines: 4,
              required: true,
            ),
            
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // Category selection
            _buildCategorySelection(),
            
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // Priority selection
            _buildPrioritySelection(),
            
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // Visibility selection
            _buildVisibilitySelection(),
            
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // Date selection
            _buildDateSelection(),
            
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // Tags input
            _buildTagsInput(),
            
            const SizedBox(height: AppDimensions.paddingLarge * 2),
          ],
        ),
      ),
    );
  }

  /// Build category selection
  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Obx(() => Wrap(
          spacing: AppDimensions.paddingSmall,
          children: TaskCategory.values.map((category) => ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(category),
                  size: 16,
                  color: controller.selectedFormCategory == category 
                    ? Colors.white 
                    : Color(int.parse(category.colorHex.substring(1), radix: 16) + 0xFF000000),
                ),
                const SizedBox(width: AppDimensions.paddingSmall / 2),
                Text(category.displayName),
              ],
            ),
            selected: controller.selectedFormCategory == category,
            onSelected: (selected) {
              if (selected) controller.setFormCategory(category);
            },
            selectedColor: Color(int.parse(category.colorHex.substring(1), radix: 16) + 0xFF000000),
            backgroundColor: Color(int.parse(category.colorHex.substring(1), radix: 16) + 0xFF000000).withOpacity(0.1),
          )).toList(),
        )),
        const SizedBox(height: AppDimensions.paddingSmall),
        Obx(() => Text(
          controller.selectedFormCategory.description,
          style: Get.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        )),
      ],
    );
  }

  /// Build priority selection
  Widget _buildPrioritySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Obx(() => Wrap(
          spacing: AppDimensions.paddingSmall,
          children: TaskPriority.values.map((priority) => ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getPriorityIcon(priority),
                  size: 16,
                  color: controller.selectedFormPriority == priority 
                    ? Colors.white 
                    : Color(int.parse(priority.colorHex.substring(1), radix: 16) + 0xFF000000),
                ),
                const SizedBox(width: AppDimensions.paddingSmall / 2),
                Text(priority.displayName),
              ],
            ),
            selected: controller.selectedFormPriority == priority,
            onSelected: (selected) {
              if (selected) controller.setFormPriority(priority);
            },
            selectedColor: Color(int.parse(priority.colorHex.substring(1), radix: 16) + 0xFF000000),
            backgroundColor: Color(int.parse(priority.colorHex.substring(1), radix: 16) + 0xFF000000).withOpacity(0.1),
          )).toList(),
        )),
        const SizedBox(height: AppDimensions.paddingSmall),
        Obx(() => Text(
          controller.selectedFormPriority.description,
          style: Get.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        )),
      ],
    );
  }

  /// Build visibility selection
  Widget _buildVisibilitySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visibility',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Obx(() => Column(
          children: TaskVisibility.values.map((visibility) => RadioListTile<TaskVisibility>(
            title: Row(
              children: [
                Icon(
                  _getVisibilityIcon(visibility),
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                Text(visibility.displayName),
              ],
            ),
            subtitle: Text(_getVisibilityDescription(visibility)),
            value: visibility,
            groupValue: controller.selectedFormVisibility,
            onChanged: (value) {
              if (value != null) controller.setFormVisibility(value);
            },
            contentPadding: EdgeInsets.zero,
          )).toList(),
        )),
      ],
    );
  }

  /// Build date selection
  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dates',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Row(
          children: [
            // Start date
            Expanded(
              child: Obx(() => InkWell(
                onTap: _selectStartDate,
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Date',
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: AppDimensions.paddingSmall / 2),
                          Text(
                            controller.selectedStartDate != null
                              ? _formatDate(controller.selectedStartDate!)
                              : 'Select date',
                            style: Get.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
            ),
            
            const SizedBox(width: AppDimensions.paddingMedium),
            
            // Due date
            Expanded(
              child: Obx(() => InkWell(
                onTap: _selectDueDate,
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due Date',
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: AppDimensions.paddingSmall / 2),
                          Text(
                            controller.selectedDueDate != null
                              ? _formatDate(controller.selectedDueDate!)
                              : 'Select date',
                            style: Get.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
            ),
          ],
        ),
      ],
    );
  }

  /// Build tags input
  Widget _buildTagsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        
        // Tags input field
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.tagsController,
                decoration: const InputDecoration(
                  hintText: 'Add a tag and press Enter',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    controller.addTag(value.trim());
                    controller.tagsController.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            IconButton(
              onPressed: () {
                final value = controller.tagsController.text.trim();
                if (value.isNotEmpty) {
                  controller.addTag(value);
                  controller.tagsController.clear();
                }
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        
        const SizedBox(height: AppDimensions.paddingSmall),
        
        // Selected tags
        Obx(() => controller.selectedTags.isEmpty
          ? Text(
              'No tags added',
              style: Get.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            )
          : Wrap(
              spacing: AppDimensions.paddingSmall / 2,
              runSpacing: AppDimensions.paddingSmall / 2,
              children: controller.selectedTags.map((tag) => Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => controller.removeTag(tag),
                backgroundColor: AppColors.primary.withOpacity(0.1),
                side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
              )).toList(),
            ),
        ),
      ],
    );
  }

  /// Build bottom bar with actions
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cancel button
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingMedium),
              ),
              child: const Text('Cancel'),
            ),
          ),
          
          const SizedBox(width: AppDimensions.paddingMedium),
          
          // Create button
          Expanded(
            flex: 2,
            child: Obx(() => ElevatedButton(
              onPressed: controller.isLoading ? null : _createTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingMedium),
              ),
              child: controller.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Create Task'),
            )),
          ),
        ],
      ),
    );
  }

  /// Create task
  Future<void> _createTask() async {
    final success = await controller.createTask();
    if (success) {
      Get.back();
      Get.snackbar(
        'Success',
        'Task created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  /// Select start date
  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: controller.selectedStartDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      controller.setStartDate(date);
    }
  }

  /// Select due date
  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: controller.selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      controller.setDueDate(date);
    }
  }

  /// Format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Get category icon
  IconData _getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.personal:
        return Icons.person;
      case TaskCategory.teamCollaboration:
        return Icons.group;
      case TaskCategory.projectManagement:
        return Icons.folder_open;
    }
  }

  /// Get priority icon
  IconData _getPriorityIcon(TaskPriority priority) {
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

  /// Get visibility icon
  IconData _getVisibilityIcon(TaskVisibility visibility) {
    switch (visibility) {
      case TaskVisibility.private:
        return Icons.lock;
      case TaskVisibility.team:
        return Icons.group;
      case TaskVisibility.project:
        return Icons.folder_shared;
      case TaskVisibility.public:
        return Icons.public;
    }
  }

  /// Get visibility description
  String _getVisibilityDescription(TaskVisibility visibility) {
    switch (visibility) {
      case TaskVisibility.private:
        return 'Only you can see this task';
      case TaskVisibility.team:
        return 'Team members can see this task';
      case TaskVisibility.project:
        return 'Project members can see this task';
      case TaskVisibility.public:
        return 'Everyone in the organization can see this task';
    }
  }
}

