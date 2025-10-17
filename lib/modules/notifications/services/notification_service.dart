import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../core/services/error_handler_service.dart';
import '../../auth/services/auth_service.dart';
import '../models/notification_model.dart';

/// Notification Service
/// Handles all notification-related operations including CRUD, real-time updates, and push notifications
class NotificationService extends GetxService {
  static NotificationService get instance => Get.find<NotificationService>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  // Collections
  late final CollectionReference _notificationsCollection;

  // Reactive state
  final RxList<NotificationModel> _notifications = <NotificationModel>[].obs;
  final RxInt _unreadCount = 0.obs;
  final RxBool _isLoading = false.obs;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _initializeCollections();
    _setupNotificationListener();
  }

  /// Initialize Firestore collections
  void _initializeCollections() {
    _notificationsCollection = _firestore.collection('notifications');
  }

  /// Setup real-time notification listener
  void _setupNotificationListener() {
    final currentUser = _authService.currentUser.value;
    if (currentUser != null) {
      _listenToUserNotifications(currentUser.id);
    }

    // Listen to auth state changes
    _authService.currentUser.listen((user) {
      if (user != null) {
        _listenToUserNotifications(user.id);
      } else {
        _notifications.clear();
        _unreadCount.value = 0;
      }
    });
  }

  /// Listen to user notifications in real-time
  void _listenToUserNotifications(String userId) {
    _notificationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen(
      (snapshot) {
        final notifications = snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList();
        
        _notifications.value = notifications;
        _updateUnreadCount();
      },
      onError: (error) {
        ErrorHandlerService.instance.handleError(
          error,
          context: 'Listen to User Notifications',
          severity: ErrorSeverity.medium,
        );
      },
    );
  }

  /// Update unread count
  void _updateUnreadCount() {
    _unreadCount.value = _notifications.where((n) => !n.isRead).length;
  }

  // ==================== NOTIFICATION CRUD OPERATIONS ====================

  /// Create a new notification
  Future<NotificationModel?> createNotification(NotificationModel notification) async {
    try {
      _isLoading.value = true;

      final docRef = await _notificationsCollection.add(notification.toFirestore());
      
      final createdNotification = notification.copyWith(id: docRef.id);
      
      // Send push notification if enabled
      await _sendPushNotification(createdNotification);
      
      return createdNotification;
      
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Create Notification',
        severity: ErrorSeverity.medium,
      );
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get notification by ID
  Future<NotificationModel?> getNotificationById(String notificationId) async {
    try {
      final doc = await _notificationsCollection.doc(notificationId).get();
      
      if (doc.exists) {
        return NotificationModel.fromFirestore(doc);
      }
      
      return null;
      
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Get Notification By ID',
        severity: ErrorSeverity.low,
      );
      return null;
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
      
      return true;
      
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Mark Notification as Read',
        severity: ErrorSeverity.low,
      );
      return false;
    }
  }

  /// Mark all notifications as read for current user
  Future<bool> markAllAsRead() async {
    try {
      final currentUser = _authService.currentUser.value;
      if (currentUser == null) return false;

      final batch = _firestore.batch();
      final unreadNotifications = _notifications.where((n) => !n.isRead);
      
      for (final notification in unreadNotifications) {
        batch.update(
          _notificationsCollection.doc(notification.id),
          {
            'isRead': true,
            'readAt': FieldValue.serverTimestamp(),
          },
        );
      }
      
      await batch.commit();
      return true;
      
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Mark All Notifications as Read',
        severity: ErrorSeverity.medium,
      );
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).delete();
      return true;
      
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Delete Notification',
        severity: ErrorSeverity.low,
      );
      return false;
    }
  }

  /// Clear all notifications for current user
  Future<bool> clearAllNotifications() async {
    try {
      final currentUser = _authService.currentUser.value;
      if (currentUser == null) return false;

      final batch = _firestore.batch();
      
      for (final notification in _notifications) {
        batch.delete(_notificationsCollection.doc(notification.id));
      }
      
      await batch.commit();
      return true;
      
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Clear All Notifications',
        severity: ErrorSeverity.medium,
      );
      return false;
    }
  }

  // ==================== NOTIFICATION FILTERING ====================

  /// Get notifications by type
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Get unread notifications
  List<NotificationModel> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  /// Get notifications by priority
  List<NotificationModel> getNotificationsByPriority(NotificationPriority priority) {
    return _notifications.where((n) => n.priority == priority).toList();
  }

  /// Get recent notifications (last 24 hours)
  List<NotificationModel> getRecentNotifications() {
    return _notifications.where((n) => n.isRecent).toList();
  }

  // ==================== BULK NOTIFICATION OPERATIONS ====================

  /// Send notification to multiple users
  Future<bool> sendBulkNotification({
    required List<String> userIds,
    required String title,
    required String message,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.medium,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final batch = _firestore.batch();
      
      for (final userId in userIds) {
        final notification = NotificationModel(
          id: '',
          userId: userId,
          title: title,
          message: message,
          type: type,
          priority: priority,
          isRead: false,
          createdAt: DateTime.now(),
          actionUrl: actionUrl,
          metadata: metadata ?? {},
        );
        
        final docRef = _notificationsCollection.doc();
        batch.set(docRef, notification.toFirestore());
      }
      
      await batch.commit();
      return true;
      
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Send Bulk Notification',
        severity: ErrorSeverity.medium,
      );
      return false;
    }
  }

  /// Send notification to all team members
  Future<bool> sendTeamNotification({
    required String teamId,
    required String title,
    required String message,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.medium,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Get team members
      final teamDoc = await _firestore.collection('teams').doc(teamId).get();
      if (!teamDoc.exists) return false;
      
      final teamData = teamDoc.data() as Map<String, dynamic>;
      final members = List<Map<String, dynamic>>.from(teamData['members'] ?? []);
      final userIds = members.map((m) => m['userId'] as String).toList();
      
      return await sendBulkNotification(
        userIds: userIds,
        title: title,
        message: message,
        type: type,
        priority: priority,
        actionUrl: actionUrl,
        metadata: metadata,
      );
      
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Send Team Notification',
        severity: ErrorSeverity.medium,
      );
      return false;
    }
  }

  // ==================== PUSH NOTIFICATION INTEGRATION ====================

  /// Send push notification (placeholder for future implementation)
  Future<void> _sendPushNotification(NotificationModel notification) async {
    // TODO: Implement push notification logic
    // This would integrate with Firebase Cloud Messaging (FCM)
    // or other push notification services
    
    // For now, we'll just log the notification
    print('Push notification would be sent: ${notification.title}');
  }

  // ==================== NOTIFICATION TEMPLATES ====================

  /// Create task assignment notification
  Future<NotificationModel?> createTaskAssignmentNotification({
    required String userId,
    required String taskId,
    required String taskTitle,
    required String assignedBy,
  }) async {
    final notification = NotificationModel.taskAssigned(
      userId: userId,
      taskId: taskId,
      taskTitle: taskTitle,
      assignedBy: assignedBy,
    );
    
    return await createNotification(notification);
  }

  /// Create task status change notification
  Future<NotificationModel?> createTaskStatusNotification({
    required String userId,
    required String taskId,
    required String taskTitle,
    required String oldStatus,
    required String newStatus,
    required String changedBy,
  }) async {
    final notification = NotificationModel.taskStatusChanged(
      userId: userId,
      taskId: taskId,
      taskTitle: taskTitle,
      oldStatus: oldStatus,
      newStatus: newStatus,
      changedBy: changedBy,
    );
    
    return await createNotification(notification);
  }

  /// Create team invitation notification
  Future<NotificationModel?> createTeamInvitationNotification({
    required String userId,
    required String teamId,
    required String teamName,
    required String invitedBy,
  }) async {
    final notification = NotificationModel.teamInvitation(
      userId: userId,
      teamId: teamId,
      teamName: teamName,
      invitedBy: invitedBy,
    );
    
    return await createNotification(notification);
  }

  /// Create comment notification
  Future<NotificationModel?> createCommentNotification({
    required String userId,
    required String taskId,
    required String taskTitle,
    required String commenterName,
    required String commentPreview,
  }) async {
    final notification = NotificationModel.newComment(
      userId: userId,
      taskId: taskId,
      taskTitle: taskTitle,
      commenterName: commenterName,
      commentPreview: commentPreview,
    );
    
    return await createNotification(notification);
  }

  /// Create due date reminder notification
  Future<NotificationModel?> createDueDateReminderNotification({
    required String userId,
    required String taskId,
    required String taskTitle,
    required DateTime dueDate,
  }) async {
    final notification = NotificationModel.dueDateReminder(
      userId: userId,
      taskId: taskId,
      taskTitle: taskTitle,
      dueDate: dueDate,
    );
    
    return await createNotification(notification);
  }

  /// Create system announcement notification
  Future<NotificationModel?> createSystemAnnouncementNotification({
    required String userId,
    required String title,
    required String message,
    String? actionUrl,
  }) async {
    final notification = NotificationModel.systemAnnouncement(
      userId: userId,
      title: title,
      message: message,
      actionUrl: actionUrl,
    );
    
    return await createNotification(notification);
  }

  // ==================== NOTIFICATION PREFERENCES ====================

  /// Get user notification preferences (placeholder)
  Future<Map<String, bool>> getUserNotificationPreferences(String userId) async {
    // TODO: Implement user notification preferences
    // This would fetch user preferences from Firestore
    return {
      'taskAssignments': true,
      'taskUpdates': true,
      'teamInvitations': true,
      'comments': true,
      'reminders': true,
      'systemAnnouncements': true,
    };
  }

  /// Update user notification preferences (placeholder)
  Future<bool> updateUserNotificationPreferences(
    String userId,
    Map<String, bool> preferences,
  ) async {
    // TODO: Implement user notification preferences update
    return true;
  }

  // ==================== CLEANUP OPERATIONS ====================

  /// Clean up old notifications (older than 30 days)
  Future<void> cleanupOldNotifications() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      final oldNotifications = await _notificationsCollection
          .where('createdAt', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();
      
      final batch = _firestore.batch();
      
      for (final doc in oldNotifications.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Cleanup Old Notifications',
        severity: ErrorSeverity.low,
      );
    }
  }
}
