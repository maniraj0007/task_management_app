import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/search_controller.dart';

/// Search Suggestions List Widget
/// Displays search suggestions and popular searches
class SearchSuggestionsList extends GetView<SearchController> {
  const SearchSuggestionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.suggestions.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        itemCount: controller.suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = controller.suggestions[index];
          return _buildSuggestionItem(suggestion);
        },
      );
    });
  }

  /// Build suggestion item
  Widget _buildSuggestionItem(dynamic suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingSmall),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(
          Icons.search,
          color: AppColors.textSecondary,
          size: 20,
        ),
        title: Text(
          suggestion.text ?? suggestion.toString(),
          style: Get.textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: suggestion.category != null
            ? Text(
                suggestion.category,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        trailing: Icon(
          Icons.north_west,
          color: AppColors.textSecondary,
          size: 16,
        ),
        onTap: () => controller.selectSuggestion(suggestion),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Suggestions Available',
            style: Get.textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start typing to see search suggestions',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
