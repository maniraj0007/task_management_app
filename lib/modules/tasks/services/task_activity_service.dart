import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/performance_service.dart';
import '../models/task_activity_model.dart';

/// Task Activity Service
/// Handles task activity tracking and real-time activity feed
class TaskActivityService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();
  final PerformanceService _performanceService = Get.find<PerformanceService>();

  // Activity streams and subscriptions
  final Map<String, StreamSubscription> _activitySubscriptions = {};
  final Map<String, RxList<TaskActivityModel>> _taskActivities = {};
  final RxList<TaskActivityModel> _globalActivities = <TaskActivityModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  List<TaskActivityModel> get globalActivities => _globalActivities;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeActivityService();
  }

  /// Initialize activity service
  Future<void> _initializeActivityService() async {
    try {
      _isLoading.value = true;
      _error.value = '';
      
      // Start global activity stream
      _startGlobalActivityStream();
    } catch (e) {
      _error.value = 'Failed to initialize activity service: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  // ==================== ACTIVITY STREAMS ====================

  /// Get activities stream for a specific task
  RxList<TaskActivityModel> getTaskActivitiesStream(String taskId) {
    if (!_taskActivities.containsKey(taskId)) {
      _taskActivities[taskId] = <TaskActivityModel>[].obs;
      _startTaskActivityStream(taskId);
    }
    return _taskActivities[taskId]!;
  }

  /// Start global activity stream (for dashboard/feed)
  void _startGlobalActivityStream() {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    // Get activities for tasks the user is involved in
    final subscription = _firestore
        .collection('task_activities')
        .orderBy('createdAt', descending: true)
        .limit(50) // Limit to recent activities
        .snapshots()
        .listen(
          (snapshot) => _handleGlobalActivitiesSnapshot(snapshot),
          onError: (error) => _handleStreamError('Global activities stream error', error),
        );
    
    _activitySubscriptions['global'] = subscription;
  }

  /// Start activity stream for a specific task
  void _startTaskActivityStream(String taskId) {
    final subscription = _firestore
        .collection('task_activities')
        .where('taskId', isEqualTo: taskId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) => _handleTaskActivitiesSnapshot(taskId, snapshot),
          onError: (error) => _handleStreamError('Task activities stream error', error),
        );
    
    _activitySubscriptions[taskId] = subscription;
  }

  /// Handle global activities snapshot updates
  void _handleGlobalActivitiesSnapshot(QuerySnapshot snapshot) {
    try {
      final activities = snapshot.docs
          .map((doc) => TaskActivityModel.fromFirestore(doc))
          .toList();

      _globalActivities.value = activities;
      _error.value = '';
    } catch (e) {
      _handleStreamError('Failed to process global activities', e);
    }
  }

  /// Handle task activities snapshot updates
  void _handleTaskActivitiesSnapshot(String taskId, QuerySnapshot snapshot) {
    try {
      final activities = snapshot.docs
          .map((doc) => TaskActivityModel.fromFirestore(doc))
          .toList();

      _taskActivities[taskId]?.value = activities;
      _error.value = '';
    } catch (e) {
      _handleStreamError('Failed to process activities for task $taskId', e);
    }
  }

  /// Handle stream errors
  void _handleStreamError(String message, dynamic error) {
    print('TaskActivityService Error: $message - $error');
    _error.value = message;
  }

  /// Stop activity stream for a task
  void stopTaskActivityStream(String taskId) {
    _activitySubscriptions[taskId]?.cancel();
    _activitySubscriptions.remove(taskId);
    _taskActivities.remove(taskId);
  }

  // ==================== ACTIVITY LOGGING ====================

  /// Log a task activity
  Future<TaskActivityModel?> logActivity(TaskActivityModel activity) async {
    return await _performanceService.timeOperation('log_activity', () async {
      try {
        _isLoading.value = true;
        _error.value = '';

        // Save to Firestore
        final docRef = await _firestore
            .collection('task_activities')
            .add(activity.toFirestore());

        final savedActivity = activity.copyWith(id: docRef.id);
        return savedActivity;
      } catch (e) {
        _error.value = 'Failed to log activity: $e';
        return null;
      } finally {
        _isLoading.value = false;
      }
    });
  }

  /// Log task creation activity
  Future<void> logTaskCreated({
    required String taskId,
    required String taskTitle,
  }) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    final activity = TaskActivityModel.taskCreated(
      taskId: taskId,
      userId: currentUser.id,
      userName: '${currentUser.firstName} ${currentUser.lastName}',
      userAvatar: currentUser.profilePicture,
      taskTitle: taskTitle,
    );

    await logActivity(activity);
  }

  /// Log task update activity
  Future<void> logTaskUpdated({
    required String taskId,
    required String taskTitle,
    required List<String> changes,
  }) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    final activity = TaskActivityModel.taskUpdated(
      taskId: taskId,
      userId: currentUser.id,
      userName: '${currentUser.firstName} ${currentUser.lastName}',
      userAvatar: currentUser.profilePicture,
      taskTitle: taskTitle,
      changes: changes,
    );

    await logActivity(activity);
  }

  /// Log task comment activity
  Future<void> logTaskCommented({
    required String taskId,
    required String taskTitle,
    required String commentId,
  }) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    final activity = TaskActivityModel.taskCommented(
      taskId: taskId,
      userId: currentUser.id,
      userName: '${currentUser.firstName} ${currentUser.lastName}',
      userAvatar: currentUser.profilePicture,
      taskTitle: taskTitle,
      commentId: commentId,
    );

    await logActivity(activity);
  }

  /// Log task assignment activity
  Future<void> logTaskAssigned({
    required String taskId,
    required String taskTitle,
    required List<String> assignees,
  }) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    final activity = TaskActivityModel.taskAssigned(
      taskId: taskId,
      userId: currentUser.id,
      userName: '${currentUser.firstName} ${currentUser.lastName}',
      userAvatar: currentUser.profilePicture,
      taskTitle: taskTitle,
      assignees: assignees,
    );

    await logActivity(activity);
  }

  /// Log task completion activity
  Future<void> logTaskCompleted({
    required String taskId,
    required String taskTitle,
  }) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    final activity = TaskActivityModel.taskCompleted(
      taskId: taskId,
      userId: currentUser.id,
      userName: '${currentUser.firstName} ${currentUser.lastName}',
      userAvatar: currentUser.profilePicture,
      taskTitle: taskTitle,
    );

    await logActivity(activity);
  }

  /// Log status change activity
  Future<void> logStatusChanged({
    required String taskId,
    required String taskTitle,
    required String oldStatus,
    required String newStatus,
  }) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    final activity = TaskActivityModel.statusChanged(
      taskId: taskId,
      userId: currentUser.id,
      userName: '${currentUser.firstName} ${currentUser.lastName}',
      userAvatar: currentUser.profilePicture,
      taskTitle: taskTitle,
      oldStatus: oldStatus,
      newStatus: newStatus,
    );

    await logActivity(activity);
  }

  /// Log priority change activity
  Future<void> logPriorityChanged({
    required String taskId,
    required String taskTitle,
    required String oldPriority,
    required String newPriority,
  }) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    final activity = TaskActivityModel.priorityChanged(
      taskId: taskId,
      userId: currentUser.id,
      userName: '${currentUser.firstName} ${currentUser.lastName}',
      userAvatar: currentUser.profilePicture,
      taskTitle: taskTitle,
      oldPriority: oldPriority,
      newPriority: newPriority,
    );

    await logActivity(activity);
  }

  /// Log due date change activity
  Future<void> logDueDateChanged({
    required String taskId,
    required String taskTitle,
    DateTime? oldDueDate,
    DateTime? newDueDate,
  }) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    final activity = TaskActivityModel.dueDateChanged(
      taskId: taskId,
      userId: currentUser.id,
      userName: '${currentUser.firstName} ${currentUser.lastName}',
      userAvatar: currentUser.profilePicture,
      taskTitle: taskTitle,
      oldDueDate: oldDueDate,
      newDueDate: newDueDate,
    );

    await logActivity(activity);
  }

  // ==================== ACTIVITY QUERIES ====================

  /// Get activities for a task (one-time fetch)
  Future<List<TaskActivityModel>> getTaskActivities(String taskId) async {
    try {
      final snapshot = await _firestore
          .collection('task_activities')
          .where('taskId', isEqualTo: taskId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TaskActivityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      _error.value = 'Failed to get task activities: $e';
      return [];
    }
  }

  /// Get recent activities (one-time fetch)
  Future<List<TaskActivityModel>> getRecentActivities({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('task_activities')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => TaskActivityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      _error.value = 'Failed to get recent activities: $e';
      return [];
    }
  }

  /// Get activities by user (one-time fetch)
  Future<List<TaskActivityModel>> getUserActivities(String userId, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('task_activities')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => TaskActivityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      _error.value = 'Failed to get user activities: $e';
      return [];
    }
  }

  /// Get activities by type (one-time fetch)
  Future<List<TaskActivityModel>> getActivitiesByType(String activityType, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('task_activities')
          .where('activityType', isEqualTo: activityType)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => TaskActivityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      _error.value = 'Failed to get activities by type: $e';
      return [];
    }
  }

  /// Get activity count for a task
  Future<int> getTaskActivityCount(String taskId) async {
    try {
      final snapshot = await _firestore
          .collection('task_activities')
          .where('taskId', isEqualTo: taskId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      _error.value = 'Failed to get activity count: $e';
      return 0;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Group activities by date
  Map<String, List<TaskActivityModel>> groupActivitiesByDate(List<TaskActivityModel> activities) {
    final Map<String, List<TaskActivityModel>> grouped = {};
    
    for (final activity in activities) {
      final dateKey = _getDateKey(activity.createdAt);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(activity);
    }
    
    return grouped;
  }

  /// Get date key for grouping
  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final activityDate = DateTime(date.year, date.month, date.day);
    
    if (activityDate == today) {
      return 'Today';
    } else if (activityDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(activityDate).inDays < 7) {
      final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return weekdays[date.weekday - 1];
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Filter activities by date range
  List<TaskActivityModel> filterActivitiesByDateRange(
    List<TaskActivityModel> activities,
    DateTime startDate,
    DateTime endDate,
  ) {
    return activities.where((activity) =>
        activity.createdAt.isAfter(startDate) &&
        activity.createdAt.isBefore(endDate)).toList();
  }

  /// Get activity statistics
  Map<String, int> getActivityStatistics(List<TaskActivityModel> activities) {
    final Map<String, int> stats = {};
    
    for (final activity in activities) {
      stats[activity.activityType] = (stats[activity.activityType] ?? 0) + 1;
    }
    
    return stats;
  }

  @override
  void onClose() {
    // Cancel all subscriptions
    for (final subscription in _activitySubscriptions.values) {
      subscription.cancel();
    }
    _activitySubscriptions.clear();
    _taskActivities.clear();
    super.onClose();
  }
}
