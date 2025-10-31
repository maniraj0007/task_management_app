import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/search_controller.dart';

/// Search Bar Widget
/// Interactive search input with suggestions and voice search
class SearchBarWidget extends GetView<SearchController> {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search icon
          Padding(
            padding: const EdgeInsets.only(left: AppDimensions.paddingMedium),
            child: Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          
          // Search input
          Expanded(
            child: TextField(
              controller: controller.searchTextController,
              onTap: controller.focusSearchField,
              onTapOutside: (_) => controller.unfocusSearchField(),
              decoration: InputDecoration(
                hintText: controller.searchPlaceholder,
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingMedium,
                ),
              ),
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: controller.performSearch,
            ),
          ),
          
          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Clear button
              Obx(() => controller.hasQuery
                  ? IconButton(
                      onPressed: () {
                        controller.searchTextController.clear();
                        controller.clearAll();
                      },
                      icon: Icon(
                        Icons.clear,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      tooltip: 'Clear search',
                    )
                  : const SizedBox.shrink()),
              
              // Voice search button (placeholder)
              IconButton(
                onPressed: _showVoiceSearchDialog,
                icon: Icon(
                  Icons.mic,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                tooltip: 'Voice search',
              ),
              
              // Search button
              Container(
                margin: const EdgeInsets.only(right: 4),
                child: IconButton(
                  onPressed: () => controller.performSearch(
                    controller.searchTextController.text,
                  ),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  tooltip: 'Search',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Show voice search dialog (placeholder)
  void _showVoiceSearchDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.mic, color: Colors.red),
            SizedBox(width: 8),
            Text('Voice Search'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mic,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Voice search is not implemented yet.\nThis is a placeholder for future functionality.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
