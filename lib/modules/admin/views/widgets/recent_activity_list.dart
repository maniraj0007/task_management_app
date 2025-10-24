import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

/// Recent Activity List Widget
/// Displays a list of recent administrative activities
class RecentActivityList extends StatelessWidget {
  final List<Map<String, dynamic>> activities;
  final int maxItems;

  const RecentActivityList({
    super.key,
    required this.activities,
    this.maxItems = 10,
  });

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return _buildEmptyState();
    }

    final displayActivities = activities.take(maxItems).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayActivities.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: AppColors.outline.withOpacity(0.1),
        ),
        itemBuilder: (context, index) {
          final activity = displayActivities[index];
          return _buildActivityItem(activity);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            'No Recent Activity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            'Administrative activities will appear here',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final actionIcon = _getActionIcon(activity['actionIcon'] ?? 'info');
    final actionColor = _getActionColor(activity['actionColor'] ?? '#9E9E9E');
    
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        children: [
          // Action icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: actionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Icon(
              actionIcon,
              color: actionColor,
              size: 20,
            ),
          ),
          
          const SizedBox(width: AppDimensions.paddingMedium),
          
          // Activity details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['formattedAction'] ?? activity['action'] ?? 'Unknown Action',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: AppDimensions.paddingSmall),
                
                if (activity['details'] != null && activity['details'].isNotEmpty)
                  Text(
                    _formatActivityDetails(activity['details']),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          
          // Timestamp
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                activity['formattedTime'] ?? 'Unknown',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              
              if (activity['adminUserId'] != null)
                const SizedBox(height: AppDimensions.paddingSmall),
              
              if (activity['adminUserId'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingSmall,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Text(
                    'Admin',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getActionIcon(String iconName) {
    switch (iconName) {
      case 'admin_panel_settings':
        return Icons.admin_panel_settings;
      case 'person_add':
        return Icons.person_add;
      case 'person_remove':
        return Icons.person_remove;
      case 'delete':
        return Icons.delete;
      case 'settings':
        return Icons.settings;
      case 'group':
        return Icons.group;
      case 'group_add':
        return Icons.group_add;
      case 'group_remove':
        return Icons.group_remove;
      default:
        return Icons.info;
    }
  }

  Color _getActionColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.textSecondary;
    }
  }

  String _formatActivityDetails(Map<String, dynamic> details) {
    final buffer = StringBuffer();
    
    if (details['newRole'] != null) {
      buffer.write('Role: ${details['newRole']}');
    }
    
    if (details['isActive'] != null) {
      if (buffer.isNotEmpty) buffer.write(' • ');
      buffer.write('Status: ${details['isActive'] ? 'Active' : 'Inactive'}');
    }
    
    if (details['count'] != null) {
      if (buffer.isNotEmpty) buffer.write(' • ');
      buffer.write('Count: ${details['count']}');
    }
    
    if (details['targetUserId'] != null) {
      if (buffer.isNotEmpty) buffer.write(' • ');
      buffer.write('User ID: ${details['targetUserId'].toString().substring(0, 8)}...');
    }
    
    return buffer.toString();
  }
}
