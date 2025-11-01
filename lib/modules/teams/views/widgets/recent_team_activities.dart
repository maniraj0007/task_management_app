import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

/// Recent Team Activities Widget
/// Displays a list of recent team activities and updates
class RecentTeamActivities extends StatelessWidget {
  final List<Map<String, dynamic>> activities;
  final int maxItems;

  const RecentTeamActivities({
    super.key,
    required this.activities,
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context) {
    final displayActivities = activities.take(maxItems).toList();
    
    return Card(
      elevation: AppDimensions.elevation2,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activities',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            if (displayActivities.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Text(
                    'No recent activities',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              ...displayActivities.map((activity) => _buildActivityItem(context, activity)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, Map<String, dynamic> activity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] ?? 'Activity',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (activity['description'] != null)
                  Text(
                    activity['description'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            activity['time'] ?? '',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
