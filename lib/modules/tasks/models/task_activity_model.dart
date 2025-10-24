import 'package:cloud_firestore/cloud_firestore.dart';

/// Task Activity Model
/// Represents an activity/event on a task for activity feed
class TaskActivityModel {
  final String id;
  final String taskId;
  final String activityType; // created, updated, commented, assigned, completed, etc.
  final String userId;
  final String userName;
  final String? userAvatar;
  final String description;
  final Map<String, dynamic> metadata; // Additional data specific to activity type
  final DateTime createdAt;

  TaskActivityModel({
    required this.id,
    required this.taskId,
    required this.activityType,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.description,
    this.metadata = const {},
    required this.createdAt,
  });

  /// Create TaskActivityModel from Firestore document
  factory TaskActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TaskActivityModel(
      id: doc.id,
      taskId: data['taskId'] ?? '',
      activityType: data['activityType'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userAvatar: data['userAvatar'],
      description: data['description'] ?? '',
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create TaskActivityModel from JSON
  factory TaskActivityModel.fromJson(Map<String, dynamic> json) {
    return TaskActivityModel(
      id: json['id'] ?? '',
      taskId: json['taskId'] ?? '',
      activityType: json['activityType'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'],
      description: json['description'] ?? '',
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'activityType': activityType,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'description': description,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'taskId': taskId,
      'activityType': activityType,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'description': description,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy with updated fields
  TaskActivityModel copyWith({
    String? id,
    String? taskId,
    String? activityType,
    String? userId,
    String? userName,
    String? userAvatar,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return TaskActivityModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      activityType: activityType ?? this.activityType,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get activity icon based on type
  String get activityIcon {
    switch (activityType) {
      case 'created':
        return '➕';
      case 'updated':
        return '✏️';
      case 'commented':
        return '💬';
      case 'assigned':
        return '👤';
      case 'completed':
        return '✅';
      case 'reopened':
        return '🔄';
      case 'priority_changed':
        return '🚩';
      case 'due_date_changed':
        return '📅';
      case 'status_changed':
        return '🔄';
      case 'attachment_added':
        return '📎';
      case 'tag_added':
        return '🏷️';
      case 'tag_removed':
        return '🏷️';
      default:
        return '📝';
    }
  }

  /// Get formatted creation time
  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  /// Factory methods for common activity types
  static TaskActivityModel taskCreated({
    required String taskId,
    required String userId,
    required String userName,
    String? userAvatar,
    required String taskTitle,
  }) {
    return TaskActivityModel(
      id: '',
      taskId: taskId,
      activityType: 'created',
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      description: 'created task "$taskTitle"',
      metadata: {'taskTitle': taskTitle},
      createdAt: DateTime.now(),
    );
  }

  static TaskActivityModel taskUpdated({
    required String taskId,
    required String userId,
    required String userName,
    String? userAvatar,
    required String taskTitle,
    required List<String> changes,
  }) {
    return TaskActivityModel(
      id: '',
      taskId: taskId,
      activityType: 'updated',
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      description: 'updated task "$taskTitle"',
      metadata: {
        'taskTitle': taskTitle,
        'changes': changes,
      },
      createdAt: DateTime.now(),
    );
  }

  static TaskActivityModel taskCommented({
    required String taskId,
    required String userId,
    required String userName,
    String? userAvatar,
    required String taskTitle,
    required String commentId,
  }) {
    return TaskActivityModel(
      id: '',
      taskId: taskId,
      activityType: 'commented',
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      description: 'commented on task "$taskTitle"',
      metadata: {
        'taskTitle': taskTitle,
        'commentId': commentId,
      },
      createdAt: DateTime.now(),
    );
  }

  static TaskActivityModel taskAssigned({
    required String taskId,
    required String userId,
    required String userName,
    String? userAvatar,
    required String taskTitle,
    required List<String> assignees,
  }) {
    return TaskActivityModel(
      id: '',
      taskId: taskId,
      activityType: 'assigned',
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      description: 'assigned task "$taskTitle"',
      metadata: {
        'taskTitle': taskTitle,
        'assignees': assignees,
      },
      createdAt: DateTime.now(),
    );
  }

  static TaskActivityModel taskCompleted({
    required String taskId,
    required String userId,
    required String userName,
    String? userAvatar,
    required String taskTitle,
  }) {
    return TaskActivityModel(
      id: '',
      taskId: taskId,
      activityType: 'completed',
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      description: 'completed task "$taskTitle"',
      metadata: {'taskTitle': taskTitle},
      createdAt: DateTime.now(),
    );
  }

  static TaskActivityModel statusChanged({
    required String taskId,
    required String userId,
    required String userName,
    String? userAvatar,
    required String taskTitle,
    required String oldStatus,
    required String newStatus,
  }) {
    return TaskActivityModel(
      id: '',
      taskId: taskId,
      activityType: 'status_changed',
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      description: 'changed status of "$taskTitle" from $oldStatus to $newStatus',
      metadata: {
        'taskTitle': taskTitle,
        'oldStatus': oldStatus,
        'newStatus': newStatus,
      },
      createdAt: DateTime.now(),
    );
  }

  static TaskActivityModel priorityChanged({
    required String taskId,
    required String userId,
    required String userName,
    String? userAvatar,
    required String taskTitle,
    required String oldPriority,
    required String newPriority,
  }) {
    return TaskActivityModel(
      id: '',
      taskId: taskId,
      activityType: 'priority_changed',
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      description: 'changed priority of "$taskTitle" from $oldPriority to $newPriority',
      metadata: {
        'taskTitle': taskTitle,
        'oldPriority': oldPriority,
        'newPriority': newPriority,
      },
      createdAt: DateTime.now(),
    );
  }

  static TaskActivityModel dueDateChanged({
    required String taskId,
    required String userId,
    required String userName,
    String? userAvatar,
    required String taskTitle,
    DateTime? oldDueDate,
    DateTime? newDueDate,
  }) {
    String description;
    if (oldDueDate == null && newDueDate != null) {
      description = 'set due date for "$taskTitle"';
    } else if (oldDueDate != null && newDueDate == null) {
      description = 'removed due date from "$taskTitle"';
    } else {
      description = 'changed due date for "$taskTitle"';
    }

    return TaskActivityModel(
      id: '',
      taskId: taskId,
      activityType: 'due_date_changed',
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      description: description,
      metadata: {
        'taskTitle': taskTitle,
        'oldDueDate': oldDueDate?.toIso8601String(),
        'newDueDate': newDueDate?.toIso8601String(),
      },
      createdAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is TaskActivityModel &&
        other.id == id &&
        other.taskId == taskId &&
        other.activityType == activityType &&
        other.userId == userId &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        taskId.hashCode ^
        activityType.hashCode ^
        userId.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'TaskActivityModel(id: $id, taskId: $taskId, activityType: $activityType, userId: $userId, description: $description)';
  }
}
