import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/enums/team_enums.dart';

/// Project Filter Bar Widget
/// Provides filtering and search capabilities for projects
class ProjectFilterBar extends StatefulWidget {
  final ProjectStatus? selectedStatus;
  final ProjectPriority? selectedPriority;
  final String searchQuery;
  final Function(ProjectStatus?) onStatusChanged;
  final Function(ProjectPriority?) onPriorityChanged;
  final Function(String) onSearchChanged;
  final VoidCallback onClearFilters;

  const ProjectFilterBar({
    super.key,
    this.selectedStatus,
    this.selectedPriority,
    required this.searchQuery,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onSearchChanged,
    required this.onClearFilters,
  });

  @override
  State<ProjectFilterBar> createState() => _ProjectFilterBarState();
}

class _ProjectFilterBarState extends State<ProjectFilterBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    widget.onSearchChanged(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = widget.selectedStatus != null || 
                            widget.selectedPriority != null ||
                            widget.searchQuery.isNotEmpty;

    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          // Search bar and filter toggle
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search projects...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                widget.onSearchChanged('');
                              },
                              icon: const Icon(Icons.clear),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingMedium,
                        vertical: AppDimensions.paddingSmall,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: AppDimensions.paddingSmall),
                
                // Filter toggle button
                IconButton(
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  icon: Icon(
                    _isExpanded ? Icons.filter_list_off : Icons.filter_list,
                    color: hasActiveFilters ? AppColors.primary : AppColors.textSecondary,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: hasActiveFilters 
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.background,
                  ),
                ),
                
                // Clear filters button
                if (hasActiveFilters)
                  IconButton(
                    onPressed: () {
                      _searchController.clear();
                      widget.onClearFilters();
                    },
                    icon: const Icon(Icons.clear_all),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.error.withOpacity(0.1),
                    ),
                  ),
              ],
            ),
          ),
          
          // Expandable filter options
          if (_isExpanded) _buildFilterOptions(),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMedium,
        0,
        AppDimensions.paddingMedium,
        AppDimensions.paddingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status filter
          Text(
            'Status',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip(null, 'All'),
                const SizedBox(width: AppDimensions.paddingSmall),
                ...ProjectStatus.values.map((status) => Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.paddingSmall),
                  child: _buildStatusChip(status, status.displayName),
                )),
              ],
            ),
          ),
          
          const SizedBox(height: AppDimensions.paddingMedium),
          
          // Priority filter
          Text(
            'Priority',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPriorityChip(null, 'All'),
                const SizedBox(width: AppDimensions.paddingSmall),
                ...ProjectPriority.values.map((priority) => Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.paddingSmall),
                  child: _buildPriorityChip(priority, priority.displayName),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ProjectStatus? status, String label) {
    final isSelected = widget.selectedStatus == status;
    final color = status?.color ?? AppColors.primary;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => widget.onStatusChanged(status),
      backgroundColor: AppColors.background,
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: BorderSide(
          color: isSelected ? color : AppColors.outline,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildPriorityChip(ProjectPriority? priority, String label) {
    final isSelected = widget.selectedPriority == priority;
    final color = priority?.color ?? AppColors.primary;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (priority != null) ...[
            Icon(
              _getPriorityIcon(priority),
              size: 12,
              color: isSelected ? color : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => widget.onPriorityChanged(priority),
      backgroundColor: AppColors.background,
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: BorderSide(
          color: isSelected ? color : AppColors.outline,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  IconData _getPriorityIcon(ProjectPriority priority) {
    switch (priority) {
      case ProjectPriority.critical:
        return Icons.keyboard_double_arrow_up;
      case ProjectPriority.high:
        return Icons.keyboard_arrow_up;
      case ProjectPriority.medium:
        return Icons.remove;
      case ProjectPriority.low:
        return Icons.keyboard_arrow_down;
    }
  }
}

// Extension for project status colors
extension ProjectStatusColor on ProjectStatus {
  Color get color {
    switch (this) {
      case ProjectStatus.planning:
        return AppColors.warning;
      case ProjectStatus.active:
        return AppColors.success;
      case ProjectStatus.onHold:
        return AppColors.warning;
      case ProjectStatus.completed:
        return AppColors.primary;
      case ProjectStatus.cancelled:
        return AppColors.error;
      case ProjectStatus.archived:
        return AppColors.textSecondary;
    }
  }
}

// Extension for project priority colors
extension ProjectPriorityColor on ProjectPriority {
  Color get color {
    switch (this) {
      case ProjectPriority.low:
        return AppColors.success;
      case ProjectPriority.medium:
        return AppColors.primary;
      case ProjectPriority.high:
        return AppColors.warning;
      case ProjectPriority.critical:
        return AppColors.error;
    }
  }
}
