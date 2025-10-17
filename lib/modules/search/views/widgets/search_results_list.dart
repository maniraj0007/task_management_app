import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/search_controller.dart';
import '../../models/search_models.dart';
import 'search_result_card.dart';

/// Search Results List Widget
/// Displays search results with grouping and filtering options
class SearchResultsList extends GetView<SearchController> {
  const SearchResultsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.searchResults.isEmpty) {
        return const SizedBox.shrink();
      }

      return RefreshIndicator(
        onRefresh: () => controller.performSearch(controller.query),
        child: ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          itemCount: _getItemCount(),
          itemBuilder: (context, index) => _buildItem(index),
        ),
      );
    });
  }

  /// Get total item count including headers
  int _getItemCount() {
    final groupedResults = _getGroupedResults();
    int count = 0;
    
    for (final entry in groupedResults.entries) {
      count += 1; // Header
      count += entry.value.length; // Results
    }
    
    return count;
  }

  /// Build item at index
  Widget _buildItem(int index) {
    final groupedResults = _getGroupedResults();
    int currentIndex = 0;
    
    for (final entry in groupedResults.entries) {
      // Check if this is the header
      if (currentIndex == index) {
        return _buildTypeHeader(entry.key, entry.value.length);
      }
      currentIndex++;
      
      // Check if this is one of the results
      for (int i = 0; i < entry.value.length; i++) {
        if (currentIndex == index) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppDimensions.spacingSmall),
            child: SearchResultCard(
              result: entry.value[i],
              onTap: () => controller.onResultTap(entry.value[i]),
            ),
          );
        }
        currentIndex++;
      }
    }
    
    return const SizedBox.shrink();
  }

  /// Group results by type
  Map<SearchResultType, List<SearchResultModel>> _getGroupedResults() {
    final grouped = <SearchResultType, List<SearchResultModel>>{};
    
    for (final result in controller.searchResults) {
      if (!grouped.containsKey(result.type)) {
        grouped[result.type] = [];
      }
      grouped[result.type]!.add(result);
    }
    
    // Sort groups by priority
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => _getTypePriority(a.key).compareTo(_getTypePriority(b.key)));
    
    return Map.fromEntries(sortedEntries);
  }

  /// Get type priority for sorting
  int _getTypePriority(SearchResultType type) {
    switch (type) {
      case SearchResultType.task:
        return 1;
      case SearchResultType.project:
        return 2;
      case SearchResultType.team:
        return 3;
      case SearchResultType.user:
        return 4;
      case SearchResultType.notification:
        return 5;
      case SearchResultType.comment:
        return 6;
      case SearchResultType.file:
        return 7;
      case SearchResultType.other:
        return 8;
    }
  }

  /// Build type header
  Widget _buildTypeHeader(SearchResultType type, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacingSmall,
        top: AppDimensions.spacingMedium,
      ),
      decoration: BoxDecoration(
        color: _getTypeColor(type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(
          color: _getTypeColor(type).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getTypeIcon(type),
            color: _getTypeColor(type),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            type.displayName,
            style: Get.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: _getTypeColor(type),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getTypeColor(type).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getTypeColor(type),
              ),
            ),
          ),
        ],
      ),
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
}
