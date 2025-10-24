import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/analytics_controller.dart';

/// Analytics Metric Type Selector Widget
/// Allows users to filter analytics by different metric types
class AnalyticsMetricTypeSelector extends GetView<AnalyticsController> {
  const AnalyticsMetricTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTypeChip('overview', 'Overview', Icons.dashboard),
            const SizedBox(width: 8),
            _buildTypeChip('tasks', 'Tasks', Icons.task_alt),
            const SizedBox(width: 8),
            _buildTypeChip('users', 'Users', Icons.people),
            const SizedBox(width: 8),
            _buildTypeChip('teams', 'Teams', Icons.group),
            const SizedBox(width: 8),
            _buildTypeChip('projects', 'Projects', Icons.folder),
            const SizedBox(width: 8),
            _buildTypeChip('system', 'System', Icons.settings),
          ],
        ),
      ),
    );
  }

  /// Build type chip
  Widget _buildTypeChip(String type, String label, IconData icon) {
    return Obx(() {
      final isSelected = controller.selectedMetricType == type;
      final hasData = controller.hasDataForMetricType(type);
      
      return FilterChip(
        selected: isSelected,
        onSelected: hasData ? (_) => controller.setMetricType(type) : null,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected 
                  ? Colors.white 
                  : hasData 
                      ? AppColors.primary 
                      : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected 
                    ? Colors.white 
                    : hasData 
                        ? AppColors.primary 
                        : AppColors.textSecondary,
              ),
            ),
            if (!hasData) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.info_outline,
                size: 12,
                color: AppColors.textSecondary,
              ),
            ],
          ],
        ),
        selectedColor: AppColors.primary,
        backgroundColor: hasData 
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.textSecondary.withOpacity(0.1),
        disabledColor: AppColors.textSecondary.withOpacity(0.1),
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected 
              ? AppColors.primary 
              : hasData 
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.textSecondary.withOpacity(0.3),
          width: 1,
        ),
        tooltip: hasData 
            ? 'View ${label.toLowerCase()} analytics'
            : 'No ${label.toLowerCase()} data available',
      );
    });
  }
}
