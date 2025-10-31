import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/services/auth_service.dart';
import '../../../core/services/performance_service.dart';

/// Push Notification Service
/// Handles Firebase Cloud Messaging and local notifications
class PushNotificationService extends GetxService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final AuthService _authService = Get.find<AuthService>();
  final PerformanceService _performanceService = Get.find<PerformanceService>();

  // Notification state
  final RxBool _isInitialized = false.obs;
  final RxString _fcmToken = ''.obs;
  final RxList<RemoteMessage> _notifications = <RemoteMessage>[].obs;
  final RxString _error = ''.obs;

  // Getters
  bool get isInitialized => _isInitialized.value;
  String get fcmToken => _fcmToken.value;
  List<RemoteMessage> get notifications => _notifications;
  String get error => _error.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializePushNotifications();
  }

  /// Initialize push notification service
  Future<void> _initializePushNotifications() async {
    try {
      // Request permission
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
        return;
      }

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        _fcmToken.value = token;
        await _saveFCMToken(token);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((token) {
        _fcmToken.value = token;
        _saveFCMToken(token);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // Handle terminated app messages
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleBackgroundMessage(initialMessage);
      }

      _isInitialized.value = true;
    } catch (e) {
      _error.value = 'Failed to initialize push notifications: $e';
      print('Push notification initialization error: $e');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationTap,
    );
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Received foreground message: ${message.messageId}');
    _notifications.add(message);
    _showLocalNotification(message);
  }

  /// Handle background messages
  void _handleBackgroundMessage(RemoteMessage message) {
    print('Received background message: ${message.messageId}');
    _notifications.add(message);
    _handleNotificationAction(message);
  }

  /// Handle local notification tap
  void _handleLocalNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      _navigateToNotificationTarget(data);
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'task_management_channel',
      'Task Management',
      channelDescription: 'Task management notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Task Management',
      message.notification?.body ?? 'You have a new notification',
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  /// Handle notification action
  void _handleNotificationAction(RemoteMessage message) {
    _navigateToNotificationTarget(message.data);
  }

  /// Navigate to notification target
  void _navigateToNotificationTarget(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final taskId = data['taskId'] as String?;
    final projectId = data['projectId'] as String?;

    switch (type) {
      case 'task_assigned':
      case 'task_updated':
      case 'task_completed':
        if (taskId != null) {
          Get.toNamed('/task-details', arguments: {'taskId': taskId});
        }
        break;
      case 'comment':
      case 'mention':
        if (taskId != null) {
          Get.toNamed('/task-details', arguments: {'taskId': taskId, 'showComments': true});
        }
        break;
      case 'project_update':
        if (projectId != null) {
          Get.toNamed('/project-details', arguments: {'projectId': projectId});
        }
        break;
      default:
        Get.toNamed('/dashboard');
    }
  }

  /// Save FCM token to user profile
  Future<void> _saveFCMToken(String token) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        // Save token to user profile in Firestore
        // This would typically be done through a user service
        print('Saving FCM token for user: ${currentUser.id}');
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  // ==================== NOTIFICATION SENDING ====================

  /// Send push notification to specific user
  Future<bool> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    return await _performanceService.timeOperation('send_push_notification', () async {
      try {
        // Get user's FCM token from Firestore
        final userToken = await _getUserFCMToken(userId);
        if (userToken == null) {
          print('No FCM token found for user: $userId');
          return false;
        }

        return await _sendFCMMessage(
          token: userToken,
          title: title,
          body: body,
          data: data ?? {},
        );
      } catch (e) {
        _error.value = 'Failed to send notification: $e';
        return false;
      }
    });
  }

  /// Send push notification to multiple users
  Future<bool> sendNotificationToUsers({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    return await _performanceService.timeOperation('send_bulk_notifications', () async {
      try {
        final tokens = <String>[];
        
        // Get FCM tokens for all users
        for (final userId in userIds) {
          final token = await _getUserFCMToken(userId);
          if (token != null) {
            tokens.add(token);
          }
        }

        if (tokens.isEmpty) {
          print('No FCM tokens found for users');
          return false;
        }

        return await _sendFCMMulticast(
          tokens: tokens,
          title: title,
          body: body,
          data: data ?? {},
        );
      } catch (e) {
        _error.value = 'Failed to send bulk notifications: $e';
        return false;
      }
    });
  }

  /// Send task assignment notification
  Future<void> sendTaskAssignmentNotification({
    required String assigneeId,
    required String taskTitle,
    required String taskId,
    required String assignerName,
  }) async {
    await sendNotificationToUser(
      userId: assigneeId,
      title: 'New Task Assigned',
      body: '$assignerName assigned you to "$taskTitle"',
      data: {
        'type': 'task_assigned',
        'taskId': taskId,
        'assignerName': assignerName,
      },
    );
  }

  /// Send task completion notification
  Future<void> sendTaskCompletionNotification({
    required List<String> userIds,
    required String taskTitle,
    required String taskId,
    required String completerName,
  }) async {
    await sendNotificationToUsers(
      userIds: userIds,
      title: 'Task Completed',
      body: '$completerName completed "$taskTitle"',
      data: {
        'type': 'task_completed',
        'taskId': taskId,
        'completerName': completerName,
      },
    );
  }

  /// Send comment notification
  Future<void> sendCommentNotification({
    required List<String> userIds,
    required String taskTitle,
    required String taskId,
    required String commenterName,
  }) async {
    await sendNotificationToUsers(
      userIds: userIds,
      title: 'New Comment',
      body: '$commenterName commented on "$taskTitle"',
      data: {
        'type': 'comment',
        'taskId': taskId,
        'commenterName': commenterName,
      },
    );
  }

  /// Send mention notification
  Future<void> sendMentionNotification({
    required String userId,
    required String taskTitle,
    required String taskId,
    required String mentionerName,
  }) async {
    await sendNotificationToUser(
      userId: userId,
      title: 'You were mentioned',
      body: '$mentionerName mentioned you in "$taskTitle"',
      data: {
        'type': 'mention',
        'taskId': taskId,
        'mentionerName': mentionerName,
      },
    );
  }

  /// Send due date reminder notification
  Future<void> sendDueDateReminderNotification({
    required List<String> userIds,
    required String taskTitle,
    required String taskId,
    required String timeFrame,
  }) async {
    await sendNotificationToUsers(
      userIds: userIds,
      title: 'Task Due Soon',
      body: '"$taskTitle" is due $timeFrame',
      data: {
        'type': 'due_date_reminder',
        'taskId': taskId,
        'timeFrame': timeFrame,
      },
    );
  }

  // ==================== HELPER METHODS ====================

  /// Get user's FCM token from Firestore
  Future<String?> _getUserFCMToken(String userId) async {
    try {
      // This would typically query Firestore for the user's FCM token
      // For now, return a placeholder
      return 'user_fcm_token_$userId';
    } catch (e) {
      print('Error getting user FCM token: $e');
      return null;
    }
  }

  /// Send FCM message to single token
  Future<bool> _sendFCMMessage({
    required String token,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      // This would typically use Firebase Admin SDK or HTTP API
      // For now, simulate successful sending
      print('Sending FCM message to token: $token');
      print('Title: $title');
      print('Body: $body');
      print('Data: $data');
      
      return true;
    } catch (e) {
      print('Error sending FCM message: $e');
      return false;
    }
  }

  /// Send FCM multicast message
  Future<bool> _sendFCMMulticast({
    required List<String> tokens,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      // This would typically use Firebase Admin SDK for multicast
      // For now, simulate successful sending
      print('Sending FCM multicast to ${tokens.length} tokens');
      print('Title: $title');
      print('Body: $body');
      print('Data: $data');
      
      return true;
    } catch (e) {
      print('Error sending FCM multicast: $e');
      return false;
    }
  }

  /// Clear all notifications
  void clearAllNotifications() {
    _notifications.clear();
    _localNotifications.cancelAll();
  }

  /// Clear specific notification
  void clearNotification(int id) {
    _localNotifications.cancel(id);
  }

  /// Get notification count
  int get notificationCount => _notifications.length;

  /// Mark notification as read
  void markNotificationAsRead(String messageId) {
    _notifications.removeWhere((notification) => notification.messageId == messageId);
  }

  @override
  void onClose() {
    // Clean up resources
    super.onClose();
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
  // Handle background message processing here
}
