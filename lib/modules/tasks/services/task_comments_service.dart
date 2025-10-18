import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/performance_service.dart';
import '../models/task_comment_model.dart';
import '../../notifications/services/notification_service.dart';

/// Task Comments Service
/// Handles all comment-related operations including CRUD, threading, and real-time updates
class TaskCommentsService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();
  final PerformanceService _performanceService = Get.find<PerformanceService>();
  
  // Lazy load notification service to avoid circular dependency
  NotificationService? _notificationService;
  NotificationService get notificationService {
    _notificationService ??= Get.find<NotificationService>();
    return _notificationService!;
  }

  // Comment streams and subscriptions
  final Map<String, StreamSubscription> _commentSubscriptions = {};
  final Map<String, RxList<TaskCommentModel>> _taskComments = {};
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeCommentsService();
  }

  /// Initialize comments service
  Future<void> _initializeCommentsService() async {
    try {
      _isLoading.value = true;
      _error.value = '';
      
      // Service is ready
    } catch (e) {
      _error.value = 'Failed to initialize comments service: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  // ==================== COMMENT STREAMS ====================

  /// Get comments stream for a task
  RxList<TaskCommentModel> getTaskCommentsStream(String taskId) {
    if (!_taskComments.containsKey(taskId)) {
      _taskComments[taskId] = <TaskCommentModel>[].obs;
      _startCommentsStream(taskId);
    }
    return _taskComments[taskId]!;
  }

  /// Start comments stream for a task
  void _startCommentsStream(String taskId) {
    final subscription = _firestore
        .collection('task_comments')
        .where('taskId', isEqualTo: taskId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen(
          (snapshot) => _handleCommentsSnapshot(taskId, snapshot),
          onError: (error) => _handleStreamError('Comments stream error', error),
        );
    
    _commentSubscriptions[taskId] = subscription;
  }

  /// Handle comments snapshot updates
  void _handleCommentsSnapshot(String taskId, QuerySnapshot snapshot) {
    try {
      final comments = snapshot.docs
          .map((doc) => TaskCommentModel.fromFirestore(doc))
          .toList();

      _taskComments[taskId]?.value = comments;
      _error.value = '';
    } catch (e) {
      _handleStreamError('Failed to process comments for task $taskId', e);
    }
  }

  /// Handle stream errors
  void _handleStreamError(String message, dynamic error) {
    print('TaskCommentsService Error: $message - $error');
    _error.value = message;
  }

  /// Stop comments stream for a task
  void stopCommentsStream(String taskId) {
    _commentSubscriptions[taskId]?.cancel();
    _commentSubscriptions.remove(taskId);
    _taskComments.remove(taskId);
  }

  // ==================== COMMENT CRUD OPERATIONS ====================

  /// Create a new comment
  Future<TaskCommentModel?> createComment({
    required String taskId,
    required String content,
    String? parentCommentId,
    List<String>? attachments,
  }) async {
    return await _performanceService.timeOperation('create_comment', () async {
      try {
        _isLoading.value = true;
        _error.value = '';

        final currentUser = _authService.currentUser;
        if (currentUser == null) {
          throw Exception('User not authenticated');
        }

        // Validate content
        if (content.trim().isEmpty) {
          throw Exception('Comment content cannot be empty');
        }

        if (content.length > 2000) {
          throw Exception('Comment content must be less than 2000 characters');
        }

        // Extract mentions from content
        final mentions = _extractMentions(content);

        // Create comment model
        final comment = TaskCommentModel(
          id: '', // Will be set by Firestore
          taskId: taskId,
          content: content.trim(),
          authorId: currentUser.id,
          authorName: '${currentUser.firstName} ${currentUser.lastName}',
          authorAvatar: currentUser.profilePicture,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          parentCommentId: parentCommentId,
          mentions: mentions,
          attachments: attachments ?? [],
        );

        // Save to Firestore
        final docRef = await _firestore
            .collection('task_comments')
            .add(comment.toFirestore());

        final savedComment = comment.copyWith(id: docRef.id);

        // Send notifications for mentions
        if (mentions.isNotEmpty) {
          await _sendMentionNotifications(savedComment, mentions);
        }

        // Send notification to task assignees (if not a reply)
        if (parentCommentId == null) {
          await _sendCommentNotification(savedComment);
        }

        return savedComment;
      } catch (e) {
        _error.value = 'Failed to create comment: $e';
        return null;
      } finally {
        _isLoading.value = false;
      }
    });
  }

  /// Update an existing comment
  Future<TaskCommentModel?> updateComment({
    required String commentId,
    required String content,
  }) async {
    return await _performanceService.timeOperation('update_comment', () async {
      try {
        _isLoading.value = true;
        _error.value = '';

        final currentUser = _authService.currentUser;
        if (currentUser == null) {
          throw Exception('User not authenticated');
        }

        // Validate content
        if (content.trim().isEmpty) {
          throw Exception('Comment content cannot be empty');
        }

        if (content.length > 2000) {
          throw Exception('Comment content must be less than 2000 characters');
        }

        // Get existing comment
        final commentDoc = await _firestore
            .collection('task_comments')
            .doc(commentId)
            .get();

        if (!commentDoc.exists) {
          throw Exception('Comment not found');
        }

        final existingComment = TaskCommentModel.fromFirestore(commentDoc);

        // Check permissions
        if (existingComment.authorId != currentUser.id) {
          throw Exception('You can only edit your own comments');
        }

        // Extract mentions from updated content
        final mentions = _extractMentions(content);

        // Update comment
        final updatedData = {
          'content': content.trim(),
          'mentions': mentions,
          'isEdited': true,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        };

        await _firestore
            .collection('task_comments')
            .doc(commentId)
            .update(updatedData);

        final updatedComment = existingComment.copyWith(
          content: content.trim(),
          mentions: mentions,
          isEdited: true,
          updatedAt: DateTime.now(),
        );

        // Send notifications for new mentions
        final newMentions = mentions.where((mention) => 
            !existingComment.mentions.contains(mention)).toList();
        if (newMentions.isNotEmpty) {
          await _sendMentionNotifications(updatedComment, newMentions);
        }

        return updatedComment;
      } catch (e) {
        _error.value = 'Failed to update comment: $e';
        return null;
      } finally {
        _isLoading.value = false;
      }
    });
  }

  /// Delete a comment
  Future<bool> deleteComment(String commentId) async {
    return await _performanceService.timeOperation('delete_comment', () async {
      try {
        _isLoading.value = true;
        _error.value = '';

        final currentUser = _authService.currentUser;
        if (currentUser == null) {
          throw Exception('User not authenticated');
        }

        // Get existing comment
        final commentDoc = await _firestore
            .collection('task_comments')
            .doc(commentId)
            .get();

        if (!commentDoc.exists) {
          throw Exception('Comment not found');
        }

        final existingComment = TaskCommentModel.fromFirestore(commentDoc);

        // Check permissions
        if (existingComment.authorId != currentUser.id) {
          throw Exception('You can only delete your own comments');
        }

        // Soft delete the comment
        await _firestore
            .collection('task_comments')
            .doc(commentId)
            .update({
              'isDeleted': true,
              'updatedAt': Timestamp.fromDate(DateTime.now()),
            });

        return true;
      } catch (e) {
        _error.value = 'Failed to delete comment: $e';
        return false;
      } finally {
        _isLoading.value = false;
      }
    });
  }

  // ==================== COMMENT QUERIES ====================

  /// Get comments for a task (one-time fetch)
  Future<List<TaskCommentModel>> getTaskComments(String taskId) async {
    try {
      final snapshot = await _firestore
          .collection('task_comments')
          .where('taskId', isEqualTo: taskId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => TaskCommentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      _error.value = 'Failed to get comments: $e';
      return [];
    }
  }

  /// Get comment by ID
  Future<TaskCommentModel?> getCommentById(String commentId) async {
    try {
      final doc = await _firestore
          .collection('task_comments')
          .doc(commentId)
          .get();

      if (doc.exists) {
        return TaskCommentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _error.value = 'Failed to get comment: $e';
      return null;
    }
  }

  /// Get replies to a comment
  Future<List<TaskCommentModel>> getCommentReplies(String parentCommentId) async {
    try {
      final snapshot = await _firestore
          .collection('task_comments')
          .where('parentCommentId', isEqualTo: parentCommentId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => TaskCommentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      _error.value = 'Failed to get replies: $e';
      return [];
    }
  }

  /// Get comment count for a task
  Future<int> getCommentCount(String taskId) async {
    try {
      final snapshot = await _firestore
          .collection('task_comments')
          .where('taskId', isEqualTo: taskId)
          .where('isDeleted', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      _error.value = 'Failed to get comment count: $e';
      return 0;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Extract mentions from comment content
  List<String> _extractMentions(String content) {
    final mentionRegex = RegExp(r'@(\w+)');
    final matches = mentionRegex.allMatches(content);
    return matches.map((match) => match.group(1)!).toSet().toList();
  }

  /// Send mention notifications
  Future<void> _sendMentionNotifications(
    TaskCommentModel comment,
    List<String> mentions,
  ) async {
    try {
      for (final mention in mentions) {
        await notificationService.createNotification(
          userId: mention,
          title: 'You were mentioned',
          message: '${comment.authorName} mentioned you in a comment',
          type: 'mention',
          data: {
            'taskId': comment.taskId,
            'commentId': comment.id,
            'authorId': comment.authorId,
            'authorName': comment.authorName,
          },
        );
      }
    } catch (e) {
      print('Error sending mention notifications: $e');
    }
  }

  /// Send comment notification to task assignees
  Future<void> _sendCommentNotification(TaskCommentModel comment) async {
    try {
      // Get task assignees
      final taskDoc = await _firestore
          .collection('tasks')
          .doc(comment.taskId)
          .get();

      if (taskDoc.exists) {
        final taskData = taskDoc.data() as Map<String, dynamic>;
        final assignees = List<String>.from(taskData['assignees'] ?? []);
        
        // Send notification to assignees (except comment author)
        for (final assigneeId in assignees) {
          if (assigneeId != comment.authorId) {
            await notificationService.createNotification(
              userId: assigneeId,
              title: 'New comment',
              message: '${comment.authorName} commented on a task',
              type: 'comment',
              data: {
                'taskId': comment.taskId,
                'commentId': comment.id,
                'authorId': comment.authorId,
                'authorName': comment.authorName,
              },
            );
          }
        }
      }
    } catch (e) {
      print('Error sending comment notification: $e');
    }
  }

  /// Get threaded comments (organized by parent-child relationship)
  List<TaskCommentModel> getThreadedComments(List<TaskCommentModel> comments) {
    final Map<String?, List<TaskCommentModel>> commentMap = {};
    
    // Group comments by parent
    for (final comment in comments) {
      final parentId = comment.parentCommentId;
      if (!commentMap.containsKey(parentId)) {
        commentMap[parentId] = [];
      }
      commentMap[parentId]!.add(comment);
    }
    
    // Build threaded structure
    final List<TaskCommentModel> threaded = [];
    
    // Add root comments first
    final rootComments = commentMap[null] ?? [];
    for (final rootComment in rootComments) {
      threaded.add(rootComment);
      
      // Add replies
      final replies = commentMap[rootComment.id] ?? [];
      threaded.addAll(replies);
    }
    
    return threaded;
  }

  @override
  void onClose() {
    // Cancel all subscriptions
    for (final subscription in _commentSubscriptions.values) {
      subscription.cancel();
    }
    _commentSubscriptions.clear();
    _taskComments.clear();
    super.onClose();
  }
}
