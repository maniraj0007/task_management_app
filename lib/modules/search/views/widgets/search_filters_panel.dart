import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/search_controller.dart';
import '../../models/search_models.dart';

/// Search Filters Panel Widget
/// Displays advanced search filters and options
class SearchFiltersPanel extends GetView<SearchController> {
  const SearchFiltersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Search Filters',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: controller.clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spacingMedium),
          
          // Type filters
          _buildTypeFilters(),
          
          const SizedBox(height: AppDimensions.spacingMedium),
          
          // Date range filter
          _buildDateRangeFilter(),
          
          const SizedBox(height: AppDimensions.spacingMedium),
          
          // Sort options
          _buildSortOptions(),
        ],
      ),
    );
  }

  /// Build type filters
  Widget _buildTypeFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Content Types',
          style: Get.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SearchResultType.values.map((type) {
            final isSelected = controller.filters.types.contains(type);
            return FilterChip(
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  controller.addTypeFilter(type);
                } else {
                  controller.removeTypeFilter(type);
                }
              },
              label: Text(type.displayName),
              avatar: Icon(
                _getTypeIcon(type),
                size: 16,
                color: isSelected ? Colors.white : _getTypeColor(type),
              ),
              selectedColor: _getTypeColor(type),
              checkmarkColor: Colors.white,
            );
          }).toList(),
        )),
      ],
    );
  }

  /// Build date range filter
  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: Get.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          child: Row(
            children: [
              Icon(
                Icons.date_range,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.filters.dateRange != null
                      ? '${_formatDate(controller.filters.dateRange!.start)} - ${_formatDate(controller.filters.dateRange!.end)}'
                      : 'Select date range',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: controller.filters.dateRange != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              if (controller.filters.dateRange != null)
                IconButton(
                  onPressed: () => controller.setDateRangeFilter(null),
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                ),
            ],
          ),
        )),
      ],
    );
  }

  /// Build sort options
  Widget _buildSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: Get.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<SearchSortOption>(
                value: controller.filters.sortBy,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                    vertical: AppDimensions.paddingSmall,
                  ),
                ),
                items: SearchSortOption.values.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(_getSortOptionName(option)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.setSortOption(value, controller.filters.sortAscending);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => controller.setSortOption(
                controller.filters.sortBy,
                !controller.filters.sortAscending,
              ),
              icon: Icon(
                controller.filters.sortAscending
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: AppColors.primary,
              ),
              tooltip: controller.filters.sortAscending ? 'Ascending' : 'Descending',
            ),
          ],
        )),
      ],
    );
  }

  /// Get type icon
  IconData _getTypeIcon(SearchResultType type) {
    switch (type) {
      case SearchResultType.task:
        return Icons.task_alt;
      case SearchResultType.team:
        return Icons.group;
      case SearchResultType.project:
        return Icons.folder;
      case SearchResultType.user:
        return Icons.person;
      case SearchResultType.notification:
        return Icons.notifications;
      case SearchResultType.comment:
        return Icons.comment;
      case SearchResultType.file:
        return Icons.insert_drive_file;
      case SearchResultType.other:
        return Icons.help_outline;
    }
  }

  /// Get type color
  Color _getTypeColor(SearchResultType type) {
    switch (type) {
      case SearchResultType.task:
        return Colors.blue;
      case SearchResultType.team:
        return Colors.purple;
      case SearchResultType.project:
        return Colors.orange;
      case SearchResultType.user:
        return Colors.green;
      case SearchResultType.notification:
        return Colors.red;
      case SearchResultType.comment:
        return Colors.teal;
      case SearchResultType.file:
        return Colors.indigo;
      case SearchResultType.other:
        return Colors.grey;
    }
  }

  /// Get sort option name
  String _getSortOptionName(SearchSortOption option) {
    switch (option) {
      case SearchSortOption.relevance:
        return 'Relevance';
      case SearchSortOption.date:
        return 'Date';
      case SearchSortOption.title:
        return 'Title';
      case SearchSortOption.type:
        return 'Type';
    }
  }

  /// Format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
