import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

/// Notification Controller
/// Manages notification state and user interactions
class NotificationController extends GetxController {
  final NotificationService _notificationService = Get.find<NotificationService>();

  // Reactive state
  final RxList<NotificationModel> _filteredNotifications = <NotificationModel>[].obs;
  final RxString _selectedFilter = 'all'.obs;
  final RxBool _showOnlyUnread = false.obs;
  final RxBool _isLoading = false.obs;

  // Getters
  List<NotificationModel> get notifications => _filteredNotifications;
  List<NotificationModel> get allNotifications => _notificationService.notifications;
  int get unreadCount => _notificationService.unreadCount;
  bool get isLoading => _isLoading.value || _notificationService.isLoading;
  String get selectedFilter => _selectedFilter.value;
  bool get showOnlyUnread => _showOnlyUnread.value;

  @override
  void onInit() {
    super.onInit();
    _setupNotificationListener();
    _applyFilters();
  }

  /// Setup notification listener
  void _setupNotificationListener() {
    // Listen to changes in the notification service
    ever(_notificationService._notifications, (_) => _applyFilters());
  }

  // ==================== FILTER OPERATIONS ====================

  /// Apply current filters to notifications
  void _applyFilters() {
    var notifications = List<NotificationModel>.from(allNotifications);

    // Apply unread filter
    if (_showOnlyUnread.value) {
      notifications = notifications.where((n) => !n.isRead).toList();
    }

    // Apply type filter
    switch (_selectedFilter.value) {
      case 'tasks':
        notifications = notifications.where((n) => 
          n.type == NotificationType.taskAssignment ||
          n.type == NotificationType.taskUpdate ||
          n.type == NotificationType.taskCompletion
        ).toList();
        break;
      case 'teams':
        notifications = notifications.where((n) => 
          n.type == NotificationType.teamInvitation
        ).toList();
        break;
      case 'comments':
        notifications = notifications.where((n) => 
          n.type == NotificationType.comment ||
          n.type == NotificationType.mention
        ).toList();
        break;
      case 'reminders':
        notifications = notifications.where((n) => 
          n.type == NotificationType.reminder
        ).toList();
        break;
      case 'system':
        notifications = notifications.where((n) => 
          n.type == NotificationType.system ||
          n.type == NotificationType.info ||
          n.type == NotificationType.warning ||
          n.type == NotificationType.error
        ).toList();
        break;
      case 'all':
      default:
        // No additional filtering needed
        break;
    }

    _filteredNotifications.value = notifications;
  }

  /// Set notification filter
  void setFilter(String filter) {
    _selectedFilter.value = filter;
    _applyFilters();
  }

  /// Toggle unread filter
  void toggleUnreadFilter() {
    _showOnlyUnread.value = !_showOnlyUnread.value;
    _applyFilters();
  }

  /// Clear all filters
  void clearFilters() {
    _selectedFilter.value = 'all';
    _showOnlyUnread.value = false;
    _applyFilters();
  }

  // ==================== NOTIFICATION ACTIONS ====================

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    _isLoading.value = true;
    try {
      await _notificationService.markAsRead(notificationId);
    } finally {
      _isLoading.value = false;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    _isLoading.value = true;
    try {
      await _notificationService.markAllAsRead();
      Get.snackbar(
        'Success',
        'All notifications marked as read',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark all notifications as read',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    _isLoading.value = true;
    try {
      final success = await _notificationService.deleteNotification(notificationId);
      if (success) {
        Get.snackbar(
          'Success',
          'Notification deleted',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete notification',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      _isLoading.value = false;
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
          'Are you sure you want to clear all notifications? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _isLoading.value = true;
      try {
        final success = await _notificationService.clearAllNotifications();
        if (success) {
          Get.snackbar(
            'Success',
            'All notifications cleared',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            'Error',
            'Failed to clear notifications',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } finally {
        _isLoading.value = false;
      }
    }
  }

  /// Handle notification tap
  void onNotificationTap(NotificationModel notification) {
    // Mark as read if not already read
    if (!notification.isRead) {
      markAsRead(notification.id);
    }

    // Navigate to action URL if available
    if (notification.actionUrl != null) {
      Get.toNamed(notification.actionUrl!);
    }
  }

  // ==================== NOTIFICATION STATISTICS ====================

  /// Get notification count by type
  int getNotificationCountByType(NotificationType type) {
    return allNotifications.where((n) => n.type == type).length;
  }

  /// Get unread notification count by type
  int getUnreadCountByType(NotificationType type) {
    return allNotifications.where((n) => n.type == type && !n.isRead).length;
  }

  /// Get notification count by priority
  int getNotificationCountByPriority(NotificationPriority priority) {
    return allNotifications.where((n) => n.priority == priority).length;
  }

  /// Get recent notification count (last 24 hours)
  int get recentNotificationCount {
    return allNotifications.where((n) => n.isRecent).length;
  }

  /// Get notification statistics
  Map<String, int> get notificationStats {
    return {
      'total': allNotifications.length,
      'unread': unreadCount,
      'recent': recentNotificationCount,
      'tasks': getNotificationCountByType(NotificationType.taskAssignment) +
               getNotificationCountByType(NotificationType.taskUpdate) +
               getNotificationCountByType(NotificationType.taskCompletion),
      'teams': getNotificationCountByType(NotificationType.teamInvitation),
      'comments': getNotificationCountByType(NotificationType.comment) +
                  getNotificationCountByType(NotificationType.mention),
      'reminders': getNotificationCountByType(NotificationType.reminder),
      'system': getNotificationCountByType(NotificationType.system) +
                getNotificationCountByType(NotificationType.info) +
                getNotificationCountByType(NotificationType.warning) +
                getNotificationCountByType(NotificationType.error),
    };
  }

  // ==================== NOTIFICATION GROUPING ====================

  /// Group notifications by date
  Map<String, List<NotificationModel>> get notificationsByDate {
    final Map<String, List<NotificationModel>> grouped = {};
    
    for (final notification in _filteredNotifications) {
      final dateKey = _getDateKey(notification.createdAt);
      
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      
      grouped[dateKey]!.add(notification);
    }
    
    return grouped;
  }

  /// Get date key for grouping
  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(date.year, date.month, date.day);
    
    if (notificationDate == today) {
      return 'Today';
    } else if (notificationDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return '${now.difference(date).inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // ==================== NOTIFICATION PREFERENCES ====================

  /// Get notification preferences
  Future<Map<String, bool>> getNotificationPreferences() async {
    // This would typically fetch from user preferences
    return {
      'taskAssignments': true,
      'taskUpdates': true,
      'teamInvitations': true,
      'comments': true,
      'reminders': true,
      'systemAnnouncements': true,
      'pushNotifications': true,
      'emailNotifications': false,
    };
  }

  /// Update notification preferences
  Future<void> updateNotificationPreferences(Map<String, bool> preferences) async {
    _isLoading.value = true;
    try {
      // TODO: Implement preference update logic
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
      
      Get.snackbar(
        'Success',
        'Notification preferences updated',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update preferences',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    _isLoading.value = true;
    try {
      // The service automatically updates via real-time listeners
      // This method can be used to force a refresh if needed
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get notification icon
  IconData getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.taskAssignment:
        return Icons.assignment_ind;
      case NotificationType.taskUpdate:
        return Icons.update;
      case NotificationType.taskCompletion:
        return Icons.task_alt;
      case NotificationType.teamInvitation:
        return Icons.group_add;
      case NotificationType.comment:
        return Icons.comment;
      case NotificationType.mention:
        return Icons.alternate_email;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.info:
        return Icons.info;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.error:
        return Icons.error;
    }
  }

  /// Get notification color
  Color getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.taskAssignment:
        return Colors.blue;
      case NotificationType.taskUpdate:
        return Colors.orange;
      case NotificationType.taskCompletion:
        return Colors.green;
      case NotificationType.teamInvitation:
        return Colors.purple;
      case NotificationType.comment:
        return Colors.teal;
      case NotificationType.mention:
        return Colors.indigo;
      case NotificationType.reminder:
        return Colors.amber;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.info:
        return Colors.blue;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.error:
        return Colors.red;
    }
  }

  /// Get priority color
  Color getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.green;
      case NotificationPriority.medium:
        return Colors.orange;
      case NotificationPriority.high:
        return Colors.red;
      case NotificationPriority.urgent:
        return Colors.red.shade800;
    }
  }
}
