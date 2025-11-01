import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/task_list_controller.dart';
import '../../../../core/enums/task_enums.dart';

/// Task Filter Widget
/// Advanced filtering and sorting options for tasks
class TaskFilterWidget extends StatefulWidget {
  final VoidCallback? onFiltersChanged;

  const TaskFilterWidget({
    Key? key,
    this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<TaskFilterWidget> createState() => _TaskFilterWidgetState();
}

class _TaskFilterWidgetState extends State<TaskFilterWidget> {
  final TaskListController _taskController = Get.find<TaskListController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter header
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Filters & Sorting',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearAllFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status filter
          _buildFilterSection(
            'Status',
            Icons.radio_button_checked,
            _buildStatusFilter(),
          ),
          const SizedBox(height: 16),

          // Priority filter
          _buildFilterSection(
            'Priority',
            Icons.flag,
            _buildPriorityFilter(),
          ),
          const SizedBox(height: 16),

          // Sort options
          _buildFilterSection(
            'Sort By',
            Icons.sort,
            _buildSortOptions(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Obx(() => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFilterChip(
          'All',
          _taskController.selectedStatusFilter == null,
          () => _taskController.setStatusFilter(null),
        ),
        _buildFilterChip(
          'To Do',
          _taskController.selectedStatusFilter == TaskStatus.todo,
          () => _taskController.setStatusFilter(TaskStatus.todo),
        ),
        _buildFilterChip(
          'In Progress',
          _taskController.selectedStatusFilter == TaskStatus.inProgress,
          () => _taskController.setStatusFilter(TaskStatus.inProgress),
        ),
        _buildFilterChip(
          'Review',
          _taskController.selectedStatusFilter == TaskStatus.review,
          () => _taskController.setStatusFilter(TaskStatus.review),
        ),
        _buildFilterChip(
          'Completed',
          _taskController.selectedStatusFilter == TaskStatus.completed,
          () => _taskController.setStatusFilter(TaskStatus.completed),
        ),
        _buildFilterChip(
          'Cancelled',
          _taskController.selectedStatusFilter == TaskStatus.cancelled,
          () => _taskController.setStatusFilter(TaskStatus.cancelled),
        ),
      ],
    ));
  }

  Widget _buildPriorityFilter() {
    return Obx(() => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFilterChip(
          'All',
          _taskController.selectedPriorityFilter == null,
          () => _taskController.setPriorityFilter(null),
        ),
        _buildPriorityChip(
          'Low',
          Colors.green,
          _taskController.selectedPriorityFilter == TaskPriority.low,
          () => _taskController.setPriorityFilter(TaskPriority.low),
        ),
        _buildPriorityChip(
          'Medium',
          Colors.blue,
          _taskController.selectedPriorityFilter == TaskPriority.medium,
          () => _taskController.setPriorityFilter(TaskPriority.medium),
        ),
        _buildPriorityChip(
          'High',
          Colors.orange,
          _taskController.selectedPriorityFilter == TaskPriority.high,
          () => _taskController.setPriorityFilter(TaskPriority.high),
        ),
        _buildPriorityChip(
          'Urgent',
          Colors.red,
          _taskController.selectedPriorityFilter == TaskPriority.urgent,
          () => _taskController.setPriorityFilter(TaskPriority.urgent),
        ),
      ],
    ));
  }



  Widget _buildSortOptions() {
    return Obx(() => Column(
      children: [
        // Sort by options
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip(
              'Created Date',
              _taskController.selectedSort == 'createdAt',
              () => _taskController.updateSort('createdAt'),
            ),
            _buildFilterChip(
              'Due Date',
              _taskController.selectedSort == 'dueDate',
              () => _taskController.updateSort('dueDate'),
            ),
            _buildFilterChip(
              'Title',
              _taskController.selectedSort == 'title',
              () => _taskController.updateSort('title'),
            ),
            _buildFilterChip(
              'Priority',
              _taskController.selectedSort == 'priority',
              () => _taskController.updateSort('priority'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Sort order
        Row(
          children: [
            const Text('Order: '),
            const SizedBox(width: 8),
            ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.arrow_upward, size: 16),
                  SizedBox(width: 4),
                  Text('Ascending'),
                ],
              ),
              selected: _taskController.isAscending,
              onSelected: (selected) {
                if (selected && !_taskController.isAscending) {
                  _taskController.toggleSortOrder();
                }
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.arrow_downward, size: 16),
                  SizedBox(width: 4),
                  Text('Descending'),
                ],
              ),
              selected: !_taskController.isAscending,
              onSelected: (selected) {
                if (selected && _taskController.isAscending) {
                  _taskController.toggleSortOrder();
                }
              },
            ),
          ],
        ),
      ],
    ));
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      backgroundColor: Colors.grey.shade100,
      side: BorderSide(
        color: isSelected 
            ? Theme.of(context).primaryColor 
            : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildPriorityChip(String label, Color color, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      backgroundColor: Colors.grey.shade100,
      side: BorderSide(
        color: isSelected ? color : Colors.grey.shade300,
      ),
    );
  }

  void _clearAllFilters() {
    _taskController.clearFilters();
    widget.onFiltersChanged?.call();
  }
}
