import 'package:cloud_firestore/cloud_firestore.dart';

/// Notification Model
/// Represents a notification for users in the task management system
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? actionUrl;
  final String? imageUrl;
  final Map<String, dynamic> metadata;
  final String? relatedResourceId;
  final String? relatedResourceType; // task, team, project, user, etc.

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.actionUrl,
    this.imageUrl,
    this.metadata = const {},
    this.relatedResourceId,
    this.relatedResourceType,
  });

  /// Create NotificationModel from Firestore document
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: NotificationType.fromString(data['type'] ?? 'info'),
      priority: NotificationPriority.fromString(data['priority'] ?? 'medium'),
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
      actionUrl: data['actionUrl'],
      imageUrl: data['imageUrl'],
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      relatedResourceId: data['relatedResourceId'],
      relatedResourceType: data['relatedResourceType'],
    );
  }

  /// Create NotificationModel from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: NotificationType.fromString(json['type'] ?? 'info'),
      priority: NotificationPriority.fromString(json['priority'] ?? 'medium'),
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      readAt: json['readAt'] != null 
          ? DateTime.parse(json['readAt'])
          : null,
      actionUrl: json['actionUrl'],
      imageUrl: json['imageUrl'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      relatedResourceId: json['relatedResourceId'],
      relatedResourceType: json['relatedResourceType'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.value,
      'priority': priority.value,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'actionUrl': actionUrl,
      'imageUrl': imageUrl,
      'metadata': metadata,
      'relatedResourceId': relatedResourceId,
      'relatedResourceType': relatedResourceType,
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.value,
      'priority': priority.value,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'actionUrl': actionUrl,
      'imageUrl': imageUrl,
      'metadata': metadata,
      'relatedResourceId': relatedResourceId,
      'relatedResourceType': relatedResourceType,
    };
  }

  /// Create a copy with updated fields
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    String? actionUrl,
    String? imageUrl,
    Map<String, dynamic>? metadata,
    String? relatedResourceId,
    String? relatedResourceType,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      actionUrl: actionUrl ?? this.actionUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
      relatedResourceId: relatedResourceId ?? this.relatedResourceId,
      relatedResourceType: relatedResourceType ?? this.relatedResourceType,
    );
  }

  /// Mark notification as read
  NotificationModel markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  /// Check if notification is recent (within last 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  /// Get formatted time ago string
  String get timeAgo {
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
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is NotificationModel &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.message == message &&
        other.type == type &&
        other.priority == priority &&
        other.isRead == isRead &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      title,
      message,
      type,
      priority,
      isRead,
      createdAt,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, userId: $userId, title: $title, message: $message, type: $type, priority: $priority, isRead: $isRead, createdAt: $createdAt)';
  }

  /// Static factory methods for common notification types

  /// Task assignment notification
  static NotificationModel taskAssigned({
    required String userId,
    required String taskId,
    required String taskTitle,
    required String assignedBy,
  }) {
    return NotificationModel(
      id: '',
      userId: userId,
      title: 'New Task Assigned',
      message: 'You have been assigned to "$taskTitle" by $assignedBy',
      type: NotificationType.taskAssignment,
      priority: NotificationPriority.high,
      isRead: false,
      createdAt: DateTime.now(),
      actionUrl: '/tasks/$taskId',
      relatedResourceId: taskId,
      relatedResourceType: 'task',
      metadata: {
        'taskTitle': taskTitle,
        'assignedBy': assignedBy,
      },
    );
  }

  /// Task status change notification
  static NotificationModel taskStatusChanged({
    required String userId,
    required String taskId,
    required String taskTitle,
    required String oldStatus,
    required String newStatus,
    required String changedBy,
  }) {
    return NotificationModel(
      id: '',
      userId: userId,
      title: 'Task Status Updated',
      message: '"$taskTitle" status changed from $oldStatus to $newStatus by $changedBy',
      type: NotificationType.taskUpdate,
      priority: NotificationPriority.medium,
      isRead: false,
      createdAt: DateTime.now(),
      actionUrl: '/tasks/$taskId',
      relatedResourceId: taskId,
      relatedResourceType: 'task',
      metadata: {
        'taskTitle': taskTitle,
        'oldStatus': oldStatus,
        'newStatus': newStatus,
        'changedBy': changedBy,
      },
    );
  }

  /// Team invitation notification
  static NotificationModel teamInvitation({
    required String userId,
    required String teamId,
    required String teamName,
    required String invitedBy,
  }) {
    return NotificationModel(
      id: '',
      userId: userId,
      title: 'Team Invitation',
      message: 'You have been invited to join "$teamName" by $invitedBy',
      type: NotificationType.teamInvitation,
      priority: NotificationPriority.high,
      isRead: false,
      createdAt: DateTime.now(),
      actionUrl: '/teams/$teamId/join',
      relatedResourceId: teamId,
      relatedResourceType: 'team',
      metadata: {
        'teamName': teamName,
        'invitedBy': invitedBy,
      },
    );
  }

  /// Comment notification
  static NotificationModel newComment({
    required String userId,
    required String taskId,
    required String taskTitle,
    required String commenterName,
    required String commentPreview,
  }) {
    return NotificationModel(
      id: '',
      userId: userId,
      title: 'New Comment',
      message: '$commenterName commented on "$taskTitle": $commentPreview',
      type: NotificationType.comment,
      priority: NotificationPriority.medium,
      isRead: false,
      createdAt: DateTime.now(),
      actionUrl: '/tasks/$taskId#comments',
      relatedResourceId: taskId,
      relatedResourceType: 'task',
      metadata: {
        'taskTitle': taskTitle,
        'commenterName': commenterName,
        'commentPreview': commentPreview,
      },
    );
  }

  /// Due date reminder notification
  static NotificationModel dueDateReminder({
    required String userId,
    required String taskId,
    required String taskTitle,
    required DateTime dueDate,
  }) {
    final hoursUntilDue = dueDate.difference(DateTime.now()).inHours;
    final timeText = hoursUntilDue < 24 
        ? '${hoursUntilDue}h' 
        : '${(hoursUntilDue / 24).ceil()}d';

    return NotificationModel(
      id: '',
      userId: userId,
      title: 'Task Due Soon',
      message: '"$taskTitle" is due in $timeText',
      type: NotificationType.reminder,
      priority: NotificationPriority.high,
      isRead: false,
      createdAt: DateTime.now(),
      actionUrl: '/tasks/$taskId',
      relatedResourceId: taskId,
      relatedResourceType: 'task',
      metadata: {
        'taskTitle': taskTitle,
        'dueDate': dueDate.toIso8601String(),
        'hoursUntilDue': hoursUntilDue,
      },
    );
  }

  /// System announcement notification
  static NotificationModel systemAnnouncement({
    required String userId,
    required String title,
    required String message,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: '',
      userId: userId,
      title: title,
      message: message,
      type: NotificationType.system,
      priority: NotificationPriority.medium,
      isRead: false,
      createdAt: DateTime.now(),
      actionUrl: actionUrl,
      relatedResourceType: 'system',
    );
  }
}

/// Notification Type Enum
enum NotificationType {
  taskAssignment('task_assignment', 'Task Assignment'),
  taskUpdate('task_update', 'Task Update'),
  taskCompletion('task_completion', 'Task Completion'),
  teamInvitation('team_invitation', 'Team Invitation'),
  comment('comment', 'Comment'),
  mention('mention', 'Mention'),
  reminder('reminder', 'Reminder'),
  system('system', 'System'),
  info('info', 'Info'),
  warning('warning', 'Warning'),
  error('error', 'Error');

  const NotificationType(this.value, this.displayName);

  final String value;
  final String displayName;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.info,
    );
  }
}

/// Notification Priority Enum
enum NotificationPriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High'),
  urgent('urgent', 'Urgent');

  const NotificationPriority(this.value, this.displayName);

  final String value;
  final String displayName;

  static NotificationPriority fromString(String value) {
    return NotificationPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => NotificationPriority.medium,
    );
  }
}
