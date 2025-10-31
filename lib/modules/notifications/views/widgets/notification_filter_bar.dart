import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/notification_controller.dart';

/// Notification Filter Bar Widget
/// Provides filtering options for notifications
class NotificationFilterBar extends GetView<NotificationController> {
  const NotificationFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'All', Icons.notifications),
                const SizedBox(width: 8),
                _buildFilterChip('tasks', 'Tasks', Icons.task_alt),
                const SizedBox(width: 8),
                _buildFilterChip('teams', 'Teams', Icons.group),
                const SizedBox(width: 8),
                _buildFilterChip('comments', 'Comments', Icons.comment),
                const SizedBox(width: 8),
                _buildFilterChip('reminders', 'Reminders', Icons.alarm),
                const SizedBox(width: 8),
                _buildFilterChip('system', 'System', Icons.settings),
              ],
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacingSmall),
          
          // Additional filters
          Row(
            children: [
              // Unread filter toggle
              Obx(() => FilterChip(
                label: Text('Unread only'),
                selected: controller.showOnlyUnread,
                onSelected: (_) => controller.toggleUnreadFilter(),
                avatar: Icon(
                  Icons.mark_email_unread,
                  size: 16,
                  color: controller.showOnlyUnread 
                      ? Colors.white 
                      : AppColors.primary,
                ),
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: controller.showOnlyUnread 
                      ? Colors.white 
                      : AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              )),
              
              const Spacer(),
              
              // Clear filters button
              Obx(() {
                final hasFilters = controller.selectedFilter != 'all' || 
                                 controller.showOnlyUnread;
                
                if (!hasFilters) return const SizedBox.shrink();
                
                return TextButton.icon(
                  onPressed: controller.clearFilters,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  /// Build filter chip
  Widget _buildFilterChip(String value, String label, IconData icon) {
    return Obx(() => FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: controller.selectedFilter == value 
                ? Colors.white 
                : AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(label),
          const SizedBox(width: 4),
          _buildFilterCount(value),
        ],
      ),
      selected: controller.selectedFilter == value,
      onSelected: (_) => controller.setFilter(value),
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: controller.selectedFilter == value 
            ? Colors.white 
            : AppColors.primary,
        fontWeight: FontWeight.w500,
      ),
    ));
  }

  /// Build filter count badge
  Widget _buildFilterCount(String filter) {
    return Obx(() {
      final stats = controller.notificationStats;
      int count = 0;
      
      switch (filter) {
        case 'all':
          count = stats['total'] ?? 0;
          break;
        case 'tasks':
          count = stats['tasks'] ?? 0;
          break;
        case 'teams':
          count = stats['teams'] ?? 0;
          break;
        case 'comments':
          count = stats['comments'] ?? 0;
          break;
        case 'reminders':
          count = stats['reminders'] ?? 0;
          break;
        case 'system':
          count = stats['system'] ?? 0;
          break;
      }
      
      if (count == 0) return const SizedBox.shrink();
      
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: controller.selectedFilter == filter 
              ? Colors.white.withOpacity(0.3)
              : AppColors.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: controller.selectedFilter == filter 
                ? Colors.white 
                : AppColors.primary,
          ),
        ),
      );
    });
  }
}
