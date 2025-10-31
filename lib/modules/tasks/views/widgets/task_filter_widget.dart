import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/task_controller.dart';

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
  final TaskController _taskController = Get.find<TaskController>();

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

          // Assignee filter
          _buildFilterSection(
            'Assignee',
            Icons.person,
            _buildAssigneeFilter(),
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
          _taskController.statusFilter == 'all',
          () => _taskController.setStatusFilter('all'),
        ),
        _buildFilterChip(
          'To Do',
          _taskController.statusFilter == 'todo',
          () => _taskController.setStatusFilter('todo'),
        ),
        _buildFilterChip(
          'In Progress',
          _taskController.statusFilter == 'in_progress',
          () => _taskController.setStatusFilter('in_progress'),
        ),
        _buildFilterChip(
          'Review',
          _taskController.statusFilter == 'review',
          () => _taskController.setStatusFilter('review'),
        ),
        _buildFilterChip(
          'Completed',
          _taskController.statusFilter == 'completed',
          () => _taskController.setStatusFilter('completed'),
        ),
        _buildFilterChip(
          'Cancelled',
          _taskController.statusFilter == 'cancelled',
          () => _taskController.setStatusFilter('cancelled'),
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
          _taskController.priorityFilter == 'all',
          () => _taskController.setPriorityFilter('all'),
        ),
        _buildPriorityChip(
          'Low',
          Colors.green,
          _taskController.priorityFilter == 'low',
          () => _taskController.setPriorityFilter('low'),
        ),
        _buildPriorityChip(
          'Medium',
          Colors.blue,
          _taskController.priorityFilter == 'medium',
          () => _taskController.setPriorityFilter('medium'),
        ),
        _buildPriorityChip(
          'High',
          Colors.orange,
          _taskController.priorityFilter == 'high',
          () => _taskController.setPriorityFilter('high'),
        ),
        _buildPriorityChip(
          'Urgent',
          Colors.red,
          _taskController.priorityFilter == 'urgent',
          () => _taskController.setPriorityFilter('urgent'),
        ),
      ],
    ));
  }

  Widget _buildAssigneeFilter() {
    return Obx(() => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFilterChip(
          'All',
          _taskController.assigneeFilter == 'all',
          () => _taskController.setAssigneeFilter('all'),
        ),
        _buildFilterChip(
          'Assigned to Me',
          _taskController.assigneeFilter == 'me',
          () => _taskController.setAssigneeFilter('me'),
        ),
        _buildFilterChip(
          'Unassigned',
          _taskController.assigneeFilter == 'unassigned',
          () => _taskController.setAssigneeFilter('unassigned'),
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
              _taskController.sortBy == 'created_date',
              () => _taskController.setSortBy('created_date'),
            ),
            _buildFilterChip(
              'Due Date',
              _taskController.sortBy == 'due_date',
              () => _taskController.setSortBy('due_date'),
            ),
            _buildFilterChip(
              'Title',
              _taskController.sortBy == 'title',
              () => _taskController.setSortBy('title'),
            ),
            _buildFilterChip(
              'Priority',
              _taskController.sortBy == 'priority',
              () => _taskController.setSortBy('priority'),
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
              selected: _taskController.sortAscending,
              onSelected: (selected) {
                if (selected) {
                  _taskController.setSortBy(_taskController.sortBy, ascending: true);
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
              selected: !_taskController.sortAscending,
              onSelected: (selected) {
                if (selected) {
                  _taskController.setSortBy(_taskController.sortBy, ascending: false);
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
    _taskController.setStatusFilter('all');
    _taskController.setPriorityFilter('all');
    _taskController.setAssigneeFilter('all');
    _taskController.setSortBy('created_date', ascending: false);
    _taskController.setSearchQuery('');
    
    widget.onFiltersChanged?.call();
  }
}
