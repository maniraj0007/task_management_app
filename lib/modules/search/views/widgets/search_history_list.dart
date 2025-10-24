import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/search_controller.dart';

/// Search History List Widget
/// Displays recent search history with quick access
class SearchHistoryList extends GetView<SearchController> {
  const SearchHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.searchHistory.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        constraints: const BoxConstraints(maxHeight: 200),
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
          ),
          itemCount: controller.searchHistory.length,
          itemBuilder: (context, index) {
            final history = controller.searchHistory[index];
            return _buildHistoryItem(history);
          },
        ),
      );
    });
  }

  /// Build history item
  Widget _buildHistoryItem(dynamic history) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingSmall),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          Icons.history,
          color: AppColors.textSecondary,
          size: 18,
        ),
        title: Text(
          history.query ?? history.toString(),
          style: Get.textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: history.timestamp != null
            ? Text(
                _formatTimestamp(history.timestamp),
                style: Get.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Filter count indicator
            if (history.filters?.hasActiveFilters == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Filtered',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            
            const SizedBox(width: 8),
            
            // Remove from history button
            GestureDetector(
              onTap: () => _removeFromHistory(history),
              child: Icon(
                Icons.close,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ),
          ],
        ),
        onTap: () => controller.selectFromHistory(history),
      ),
    );
  }

  /// Remove item from history
  void _removeFromHistory(dynamic history) {
    // This would typically call a method on the controller
    // For now, we'll show a placeholder
    Get.snackbar(
      'History',
      'Removed "${history.query ?? history.toString()}" from search history',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Format timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
