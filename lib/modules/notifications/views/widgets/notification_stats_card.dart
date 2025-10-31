import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

/// Notification Stats Card Widget
/// Displays notification statistics in a visually appealing card
class NotificationStatsCard extends StatelessWidget {
  final Map<String, int> stats;

  const NotificationStatsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Notification Overview',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spacingMedium),
          
          // Stats grid
          Row(
            children: [
              // Total notifications
              Expanded(
                child: _buildStatItem(
                  'Total',
                  stats['total'] ?? 0,
                  Icons.notifications,
                  AppColors.primary,
                ),
              ),
              
              // Unread notifications
              Expanded(
                child: _buildStatItem(
                  'Unread',
                  stats['unread'] ?? 0,
                  Icons.mark_email_unread,
                  AppColors.warning,
                ),
              ),
              
              // Recent notifications
              Expanded(
                child: _buildStatItem(
                  'Recent',
                  stats['recent'] ?? 0,
                  Icons.schedule,
                  AppColors.info,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spacingMedium),
          
          // Category breakdown
          Row(
            children: [
              // Tasks
              Expanded(
                child: _buildCategoryItem(
                  'Tasks',
                  stats['tasks'] ?? 0,
                  Icons.task_alt,
                  Colors.blue,
                ),
              ),
              
              // Teams
              Expanded(
                child: _buildCategoryItem(
                  'Teams',
                  stats['teams'] ?? 0,
                  Icons.group,
                  Colors.purple,
                ),
              ),
              
              // Comments
              Expanded(
                child: _buildCategoryItem(
                  'Comments',
                  stats['comments'] ?? 0,
                  Icons.comment,
                  Colors.teal,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spacingSmall),
          
          Row(
            children: [
              // Reminders
              Expanded(
                child: _buildCategoryItem(
                  'Reminders',
                  stats['reminders'] ?? 0,
                  Icons.alarm,
                  Colors.amber,
                ),
              ),
              
              // System
              Expanded(
                child: _buildCategoryItem(
                  'System',
                  stats['system'] ?? 0,
                  Icons.settings,
                  Colors.grey,
                ),
              ),
              
              // Empty space for alignment
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  /// Build stat item
  Widget _buildStatItem(
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build category item
  Widget _buildCategoryItem(
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
        vertical: 6,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
