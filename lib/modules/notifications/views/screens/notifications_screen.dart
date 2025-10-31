import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/notification_controller.dart';
import '../../models/notification_model.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_filter_bar.dart';
import '../widgets/notification_stats_card.dart';

/// Notifications Screen
/// Displays user notifications with filtering and management capabilities
class NotificationsScreen extends GetView<NotificationController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          // Mark all as read button
          Obx(() => IconButton(
            onPressed: controller.unreadCount > 0 
                ? controller.markAllAsRead 
                : null,
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
          )),
          
          // More options menu
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'preferences',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Notification Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: ListTile(
                  leading: Icon(Icons.clear_all, color: Colors.red),
                  title: Text('Clear All'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Section
          _buildStatsSection(),
          
          // Filter Bar
          const NotificationFilterBar(),
          
          // Notifications List
          Expanded(
            child: Obx(() {
              if (controller.isLoading && controller.notifications.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.notifications.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.refreshNotifications,
                child: _buildNotificationsList(),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Build statistics section
  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Obx(() {
        final stats = controller.notificationStats;
        return NotificationStatsCard(stats: stats);
      }),
    );
  }

  /// Build notifications list
  Widget _buildNotificationsList() {
    return Obx(() {
      final groupedNotifications = controller.notificationsByDate;
      
      return ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
        ),
        itemCount: groupedNotifications.length,
        itemBuilder: (context, index) {
          final dateKey = groupedNotifications.keys.elementAt(index);
          final notifications = groupedNotifications[dateKey]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              _buildDateHeader(dateKey),
              
              // Notifications for this date
              ...notifications.map((notification) {
                return Container(
                  margin: const EdgeInsets.only(
                    bottom: AppDimensions.spacingSmall,
                  ),
                  child: NotificationCard(
                    notification: notification,
                    onTap: () => controller.onNotificationTap(notification),
                    onMarkAsRead: () => controller.markAsRead(notification.id),
                    onDelete: () => controller.deleteNotification(notification.id),
                  ),
                );
              }).toList(),
              
              const SizedBox(height: AppDimensions.spacingMedium),
            ],
          );
        },
      );
    });
  }

  /// Build date header
  Widget _buildDateHeader(String dateKey) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.paddingSmall,
        horizontal: AppDimensions.paddingMedium,
      ),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingSmall),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            dateKey,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
        ],
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
            controller.showOnlyUnread 
                ? Icons.mark_email_read 
                : Icons.notifications_none,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(
            controller.showOnlyUnread 
                ? 'No unread notifications'
                : 'No notifications yet',
            style: Get.textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            controller.showOnlyUnread
                ? 'All caught up! You have no unread notifications.'
                : 'When you receive notifications, they\'ll appear here.',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (controller.showOnlyUnread) ...[
            const SizedBox(height: AppDimensions.spacingLarge),
            ElevatedButton(
              onPressed: () => controller.toggleUnreadFilter(),
              child: const Text('Show All Notifications'),
            ),
          ],
        ],
      ),
    );
  }

  /// Handle menu actions
  void _handleMenuAction(String action) {
    switch (action) {
      case 'preferences':
        _showNotificationPreferences();
        break;
      case 'clear_all':
        controller.clearAllNotifications();
        break;
    }
  }

  /// Show notification preferences dialog
  void _showNotificationPreferences() {
    Get.dialog(
      AlertDialog(
        title: const Text('Notification Settings'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<Map<String, bool>>(
            future: controller.getNotificationPreferences(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Text('Failed to load preferences');
              }

              final preferences = snapshot.data!;
              
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: preferences.entries.map((entry) {
                  return SwitchListTile(
                    title: Text(_getPreferenceTitle(entry.key)),
                    subtitle: Text(_getPreferenceSubtitle(entry.key)),
                    value: entry.value,
                    onChanged: (value) {
                      preferences[entry.key] = value;
                      // Update preferences immediately
                      controller.updateNotificationPreferences(preferences);
                    },
                  );
                }).toList(),
              );
            },
          ),
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

  /// Get preference title
  String _getPreferenceTitle(String key) {
    switch (key) {
      case 'taskAssignments':
        return 'Task Assignments';
      case 'taskUpdates':
        return 'Task Updates';
      case 'teamInvitations':
        return 'Team Invitations';
      case 'comments':
        return 'Comments & Mentions';
      case 'reminders':
        return 'Due Date Reminders';
      case 'systemAnnouncements':
        return 'System Announcements';
      case 'pushNotifications':
        return 'Push Notifications';
      case 'emailNotifications':
        return 'Email Notifications';
      default:
        return key;
    }
  }

  /// Get preference subtitle
  String _getPreferenceSubtitle(String key) {
    switch (key) {
      case 'taskAssignments':
        return 'When you\'re assigned to a task';
      case 'taskUpdates':
        return 'When task status changes';
      case 'teamInvitations':
        return 'When you\'re invited to a team';
      case 'comments':
        return 'When someone comments or mentions you';
      case 'reminders':
        return 'Before tasks are due';
      case 'systemAnnouncements':
        return 'Important system updates';
      case 'pushNotifications':
        return 'Show notifications on your device';
      case 'emailNotifications':
        return 'Send notifications to your email';
      default:
        return '';
    }
  }
}
