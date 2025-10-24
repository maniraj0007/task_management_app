import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/enums/task_enums.dart';
import '../../controllers/enhanced_task_controller.dart';

/// Task Filter Bar Widget
/// Provides filtering and sorting options for task lists
class TaskFilterBar extends GetView<EnhancedTaskController> {
  const TaskFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Filter chips row
          _buildFilterChips(),
          
          // Sort and clear row
          if (_hasActiveFilters()) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            _buildSortAndClearRow(),
          ],
        ],
      ),
    );
  }

  /// Build filter chips
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Category filter
          _buildCategoryFilter(),
          
          const SizedBox(width: AppDimensions.paddingSmall),
          
          // Status filter
          _buildStatusFilter(),
          
          const SizedBox(width: AppDimensions.paddingSmall),
          
          // Priority filter
          _buildPriorityFilter(),
          
          const SizedBox(width: AppDimensions.paddingSmall),
          
          // Sort button
          _buildSortButton(),
        ],
      ),
    );
  }

  /// Build category filter
  Widget _buildCategoryFilter() {
    return Obx(() => PopupMenuButton<TaskCategory?>(
      child: Chip(
        avatar: Icon(
          Icons.category,
          size: 16,
          color: controller.selectedCategory != null 
            ? Colors.white 
            : AppColors.primary,
        ),
        label: Text(
          controller.selectedCategory?.displayName ?? 'Category',
          style: TextStyle(
            color: controller.selectedCategory != null 
              ? Colors.white 
              : AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: controller.selectedCategory != null 
          ? AppColors.primary 
          : AppColors.primary.withOpacity(0.1),
        side: BorderSide(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      onSelected: controller.setCategoryFilter,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: null,
          child: Text('All Categories'),
        ),
        ...TaskCategory.values.map((category) => PopupMenuItem(
          value: category,
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(category),
                size: 16,
                color: Color(int.parse(category.colorHex.substring(1), radix: 16) + 0xFF000000),
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              Text(category.displayName),
            ],
          ),
        )),
      ],
    ));
  }

  /// Build status filter
  Widget _buildStatusFilter() {
    return Obx(() => PopupMenuButton<TaskStatus?>(
      child: Chip(
        avatar: Icon(
          Icons.flag,
          size: 16,
          color: controller.selectedStatus != null 
            ? Colors.white 
            : AppColors.primary,
        ),
        label: Text(
          controller.selectedStatus?.displayName ?? 'Status',
          style: TextStyle(
            color: controller.selectedStatus != null 
              ? Colors.white 
              : AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: controller.selectedStatus != null 
          ? AppColors.primary 
          : AppColors.primary.withOpacity(0.1),
        side: BorderSide(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      onSelected: controller.setStatusFilter,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: null,
          child: Text('All Statuses'),
        ),
        ...TaskStatus.values.map((status) => PopupMenuItem(
          value: status,
          child: Row(
            children: [
              Icon(
                _getStatusIcon(status),
                size: 16,
                color: Color(int.parse(status.colorHex.substring(1), radix: 16) + 0xFF000000),
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              Text(status.displayName),
            ],
          ),
        )),
      ],
    ));
  }

  /// Build priority filter
  Widget _buildPriorityFilter() {
    return Obx(() => PopupMenuButton<TaskPriority?>(
      child: Chip(
        avatar: Icon(
          Icons.priority_high,
          size: 16,
          color: controller.selectedPriority != null 
            ? Colors.white 
            : AppColors.primary,
        ),
        label: Text(
          controller.selectedPriority?.displayName ?? 'Priority',
          style: TextStyle(
            color: controller.selectedPriority != null 
              ? Colors.white 
              : AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: controller.selectedPriority != null 
          ? AppColors.primary 
          : AppColors.primary.withOpacity(0.1),
        side: BorderSide(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      onSelected: controller.setPriorityFilter,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: null,
          child: Text('All Priorities'),
        ),
        ...TaskPriority.values.map((priority) => PopupMenuItem(
          value: priority,
          child: Row(
            children: [
              Icon(
                _getPriorityIcon(priority),
                size: 16,
                color: Color(int.parse(priority.colorHex.substring(1), radix: 16) + 0xFF000000),
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              Text(priority.displayName),
            ],
          ),
        )),
      ],
    ));
  }

  /// Build sort button
  Widget _buildSortButton() {
    return Obx(() => PopupMenuButton<String>(
      child: Chip(
        avatar: Icon(
          controller.sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
          size: 16,
          color: AppColors.primary,
        ),
        label: Text(
          'Sort: ${_getSortDisplayName()}',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppColors.primary.withOpacity(0.1),
        side: BorderSide(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      onSelected: (sortBy) => _handleSortSelection(sortBy),
      itemBuilder: (context) => [
        _buildSortMenuItem('dueDate', 'Due Date'),
        _buildSortMenuItem('priority', 'Priority'),
        _buildSortMenuItem('status', 'Status'),
        _buildSortMenuItem('title', 'Title'),
        _buildSortMenuItem('createdAt', 'Created Date'),
      ],
    ));
  }

  /// Build sort menu item
  PopupMenuItem<String> _buildSortMenuItem(String value, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            controller.sortBy == value 
              ? (controller.sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
              : Icons.sort,
            size: 16,
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          Text(label),
          if (controller.sortBy == value) ...[
            const Spacer(),
            Icon(
              Icons.check,
              size: 16,
              color: AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }

  /// Build sort and clear row
  Widget _buildSortAndClearRow() {
    return Row(
      children: [
        // Active filters count
        Obx(() => Text(
          '${_getActiveFiltersCount()} filter(s) active',
          style: Get.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        )),
        
        const Spacer(),
        
        // Clear filters button
        TextButton.icon(
          onPressed: controller.clearFilters,
          icon: const Icon(Icons.clear, size: 16),
          label: const Text('Clear All'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[600],
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingSmall,
            ),
          ),
        ),
      ],
    );
  }

  /// Check if there are active filters
  bool _hasActiveFilters() {
    return controller.selectedCategory != null ||
           controller.selectedStatus != null ||
           controller.selectedPriority != null ||
           controller.searchQuery.isNotEmpty;
  }

  /// Get active filters count
  int _getActiveFiltersCount() {
    int count = 0;
    if (controller.selectedCategory != null) count++;
    if (controller.selectedStatus != null) count++;
    if (controller.selectedPriority != null) count++;
    if (controller.searchQuery.isNotEmpty) count++;
    return count;
  }

  /// Get sort display name
  String _getSortDisplayName() {
    switch (controller.sortBy) {
      case 'title':
        return 'Title';
      case 'priority':
        return 'Priority';
      case 'status':
        return 'Status';
      case 'createdAt':
        return 'Created';
      case 'dueDate':
      default:
        return 'Due Date';
    }
  }

  /// Handle sort selection
  void _handleSortSelection(String sortBy) {
    if (controller.sortBy == sortBy) {
      // Toggle sort direction if same field
      controller.setSortBy(sortBy, ascending: !controller.sortAscending);
    } else {
      // Set new sort field with ascending order
      controller.setSortBy(sortBy, ascending: true);
    }
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

  /// Get status icon
  IconData _getStatusIcon(TaskStatus status) {
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
}

