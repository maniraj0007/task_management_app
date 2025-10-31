import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/search_controller.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/search_results_list.dart';
import '../widgets/search_suggestions_list.dart';
import '../widgets/search_filters_panel.dart';
import '../widgets/search_history_list.dart';

/// Global Search Screen
/// Comprehensive search interface with filtering, suggestions, and results
class GlobalSearchScreen extends GetView<SearchController> {
  const GlobalSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          // Filter toggle button
          Obx(() => IconButton(
            onPressed: controller.toggleFilters,
            icon: Icon(
              controller.showFilters ? Icons.filter_list : Icons.filter_list_off,
              color: controller.hasActiveFilters 
                  ? AppColors.primary 
                  : AppColors.textSecondary,
            ),
            tooltip: controller.showFilters ? 'Hide Filters' : 'Show Filters',
          )),
          
          // Clear all button
          Obx(() => controller.hasQuery || controller.hasActiveFilters
              ? IconButton(
                  onPressed: controller.clearAll,
                  icon: const Icon(Icons.clear_all),
                  tooltip: 'Clear All',
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const SearchBarWidget(),
          ),
          
          // Filters panel
          Obx(() => controller.showFilters
              ? const SearchFiltersPanel()
              : const SizedBox.shrink()),
          
          // Filter summary
          Obx(() => controller.hasActiveFilters
              ? _buildFilterSummary()
              : const SizedBox.shrink()),
          
          // Content area
          Expanded(
            child: Obx(() {
              if (controller.showSuggestions) {
                return _buildSuggestionsContent();
              } else if (controller.hasQuery) {
                return _buildSearchContent();
              } else {
                return _buildEmptyContent();
              }
            }),
          ),
        ],
      ),
    );
  }

  /// Build filter summary
  Widget _buildFilterSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              controller.filterSummary,
              style: Get.textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: controller.clearFilters,
            child: Text(
              'Clear',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build suggestions content
  Widget _buildSuggestionsContent() {
    return Column(
      children: [
        // Recent searches header
        if (controller.searchHistory.isNotEmpty) ...[
          _buildSectionHeader(
            'Recent Searches',
            Icons.history,
            onClear: controller.clearSearchHistory,
          ),
          const SearchHistoryList(),
        ],
        
        // Suggestions header
        _buildSectionHeader('Suggestions', Icons.lightbulb_outline),
        
        // Suggestions list
        const Expanded(child: SearchSuggestionsList()),
      ],
    );
  }

  /// Build search content
  Widget _buildSearchContent() {
    return Obx(() {
      if (controller.isSearching) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!controller.hasResults) {
        return _buildNoResultsState();
      }

      return Column(
        children: [
          // Results summary
          _buildResultsSummary(),
          
          // Results list
          const Expanded(child: SearchResultsList()),
        ],
      );
    });
  }

  /// Build empty content
  Widget _buildEmptyContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(
            'Search Everything',
            style: Get.textTheme.titleLarge?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            'Find tasks, teams, projects, users, and more...',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          
          // Quick search suggestions
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickSearchChip('urgent tasks', Icons.warning),
              _buildQuickSearchChip('my teams', Icons.group),
              _buildQuickSearchChip('active projects', Icons.folder_open),
              _buildQuickSearchChip('recent activity', Icons.schedule),
            ],
          ),
        ],
      ),
    );
  }

  /// Build no results state
  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(
            'No Results Found',
            style: Get.textTheme.titleLarge?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            controller.resultSummary,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          
          // Suggestions for better results
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            margin: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLarge,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Try these suggestions:',
                  style: Get.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSuggestionItem('Check your spelling'),
                _buildSuggestionItem('Use different keywords'),
                _buildSuggestionItem('Remove some filters'),
                _buildSuggestionItem('Try broader search terms'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build section header
  Widget _buildSectionHeader(
    String title,
    IconData icon, {
    VoidCallback? onClear,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Get.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          if (onClear != null)
            TextButton(
              onPressed: onClear,
              child: Text(
                'Clear',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build results summary
  Widget _buildResultsSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              controller.resultSummary,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Result type counts
          Obx(() {
            final counts = controller.resultCountsByType;
            if (counts.isEmpty) return const SizedBox.shrink();
            
            return Wrap(
              spacing: 8,
              children: counts.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${entry.key.displayName}: ${entry.value}',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  /// Build quick search chip
  Widget _buildQuickSearchChip(String text, IconData icon) {
    return ActionChip(
      onPressed: () {
        controller.searchTextController.text = text;
        controller.performSearch(text);
      },
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(text),
        ],
      ),
      backgroundColor: AppColors.primary.withOpacity(0.1),
      side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
    );
  }

  /// Build suggestion item
  Widget _buildSuggestionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 4,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Get.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
