import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/analytics_controller.dart';

/// Analytics Time Range Selector Widget
/// Allows users to select different time ranges for analytics
class AnalyticsTimeRangeSelector extends GetView<AnalyticsController> {
  const AnalyticsTimeRangeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => PopupMenuButton<String>(
      onSelected: controller.setTimeRange,
      itemBuilder: (context) => [
        _buildMenuItem('1d', 'Last 24 Hours'),
        _buildMenuItem('7d', 'Last 7 Days'),
        _buildMenuItem('30d', 'Last 30 Days'),
        _buildMenuItem('90d', 'Last 90 Days'),
        _buildMenuItem('1y', 'Last Year'),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSmall,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.date_range,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              controller.getTimeRangeDisplayText(controller.selectedTimeRange),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    ));
  }

  /// Build menu item
  PopupMenuItem<String> _buildMenuItem(String value, String label) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          if (controller.selectedTimeRange == value)
            Icon(
              Icons.check,
              size: 16,
              color: AppColors.primary,
            )
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
