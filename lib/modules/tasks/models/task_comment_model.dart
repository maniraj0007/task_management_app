import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/enums/task_enums.dart';

/// Task comment model for the multi-admin task management system
/// Represents a comment or activity on a task
class TaskCommentModel {
  final String id;
  final String taskId;
  final String content;
  final TaskCommentType type;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? editedAt;
  final String? editedBy;
  final bool isEdited;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String? deletedBy;
  final List<String> mentions;
  final List<String> attachmentIds;
  final Map<String, dynamic> metadata;
  final String? parentCommentId;
  final List<String> replyIds;
  final Map<String, dynamic> reactions;
  final bool isPinned;
  final DateTime? pinnedAt;
  final String? pinnedBy;

  const TaskCommentModel({
    required this.id,
    required this.taskId,
    required this.content,
    required this.type,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.createdAt,
    this.updatedAt,
    this.editedAt,
    this.editedBy,
    this.isEdited = false,
    this.isDeleted = false,
    this.deletedAt,
    this.deletedBy,
    this.mentions = const [],
    this.attachmentIds = const [],
    this.metadata = const {},
    this.parentCommentId,
    this.replyIds = const [],
    this.reactions = const {},
    this.isPinned = false,
    this.pinnedAt,
    this.pinnedBy,
  });

  /// Check if comment is a reply
  bool get isReply => parentCommentId != null;

  /// Check if comment has replies
  bool get hasReplies => replyIds.isNotEmpty;

  /// Check if comment has attachments
  bool get hasAttachments => attachmentIds.isNotEmpty;

  /// Check if comment has mentions
  bool get hasMentions => mentions.isNotEmpty;

  /// Check if comment has reactions
  bool get hasReactions => reactions.isNotEmpty;

  /// Check if comment is system generated
  bool get isSystemGenerated => type.isSystemGenerated;

  /// Get total reaction count
  int get totalReactions {
    return reactions.values.fold(0, (sum, count) => sum + (count as int));
  }

  /// Get comment age in minutes
  int get ageInMinutes {
    return DateTime.now().difference(createdAt).inMinutes;
  }

  /// Get comment age in hours
  int get ageInHours {
    return DateTime.now().difference(createdAt).inHours;
  }

  /// Get comment age in days
  int get ageInDays {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Check if comment can be edited by user
  bool canBeEditedByUser(String userId) {
    return authorId == userId && !isSystemGenerated && !isDeleted;
  }

  /// Check if comment can be deleted by user
  bool canBeDeletedByUser(String userId) {
    return authorId == userId && !isDeleted;
  }

  /// Check if user has reacted with specific emoji
  bool hasUserReacted(String userId, String emoji) {
    final reactionData = reactions[emoji] as Map<String, dynamic>?;
    if (reactionData == null) return false;
    final users = reactionData['users'] as List<dynamic>?;
    return users?.contains(userId) ?? false;
  }

  /// Get reaction count for specific emoji
  int getReactionCount(String emoji) {
    final reactionData = reactions[emoji] as Map<String, dynamic>?;
    return reactionData?['count'] as int? ?? 0;
  }

  /// Create a copy with updated fields
  TaskCommentModel copyWith({
    String? id,
    String? taskId,
    String? content,
    TaskCommentType? type,
    String? authorId,
    String? authorName,
    String? authorPhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? editedAt,
    String? editedBy,
    bool? isEdited,
    bool? isDeleted,
    DateTime? deletedAt,
    String? deletedBy,
    List<String>? mentions,
    List<String>? attachmentIds,
    Map<String, dynamic>? metadata,
    String? parentCommentId,
    List<String>? replyIds,
    Map<String, dynamic>? reactions,
    bool? isPinned,
    DateTime? pinnedAt,
    String? pinnedBy,
  }) {
    return TaskCommentModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      content: content ?? this.content,
      type: type ?? this.type,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      editedAt: editedAt ?? this.editedAt,
      editedBy: editedBy ?? this.editedBy,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      mentions: mentions ?? this.mentions,
      attachmentIds: attachmentIds ?? this.attachmentIds,
      metadata: metadata ?? this.metadata,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      replyIds: replyIds ?? this.replyIds,
      reactions: reactions ?? this.reactions,
      isPinned: isPinned ?? this.isPinned,
      pinnedAt: pinnedAt ?? this.pinnedAt,
      pinnedBy: pinnedBy ?? this.pinnedBy,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'content': content,
      'type': type.value,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'editedBy': editedBy,
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
      'deletedBy': deletedBy,
      'mentions': mentions,
      'attachmentIds': attachmentIds,
      'metadata': metadata,
      'parentCommentId': parentCommentId,
      'replyIds': replyIds,
      'reactions': reactions,
      'isPinned': isPinned,
      'pinnedAt': pinnedAt != null ? Timestamp.fromDate(pinnedAt!) : null,
      'pinnedBy': pinnedBy,
    };
  }

  /// Create from JSON (Firestore document)
  factory TaskCommentModel.fromJson(Map<String, dynamic> json) {
    return TaskCommentModel(
      id: json['id'] ?? '',
      taskId: json['taskId'] ?? '',
      content: json['content'] ?? '',
      type: TaskCommentType.fromString(json['type'] ?? 'comment'),
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      authorPhotoUrl: json['authorPhotoUrl'],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
      editedAt: (json['editedAt'] as Timestamp?)?.toDate(),
      editedBy: json['editedBy'],
      isEdited: json['isEdited'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      deletedAt: (json['deletedAt'] as Timestamp?)?.toDate(),
      deletedBy: json['deletedBy'],
      mentions: (json['mentions'] as List<dynamic>?)?.cast<String>() ?? [],
      attachmentIds: (json['attachmentIds'] as List<dynamic>?)?.cast<String>() ?? [],
      metadata: json['metadata']?.cast<String, dynamic>() ?? {},
      parentCommentId: json['parentCommentId'],
      replyIds: (json['replyIds'] as List<dynamic>?)?.cast<String>() ?? [],
      reactions: json['reactions']?.cast<String, dynamic>() ?? {},
      isPinned: json['isPinned'] ?? false,
      pinnedAt: (json['pinnedAt'] as Timestamp?)?.toDate(),
      pinnedBy: json['pinnedBy'],
    );
  }

  /// Create a new comment
  factory TaskCommentModel.create({
    required String taskId,
    required String content,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    TaskCommentType type = TaskCommentType.comment,
    List<String>? mentions,
    List<String>? attachmentIds,
    String? parentCommentId,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return TaskCommentModel(
      id: '', // Will be set by Firestore
      taskId: taskId,
      content: content,
      type: type,
      authorId: authorId,
      authorName: authorName,
      authorPhotoUrl: authorPhotoUrl,
      createdAt: now,
      updatedAt: now,
      mentions: mentions ?? [],
      attachmentIds: attachmentIds ?? [],
      parentCommentId: parentCommentId,
      metadata: metadata ?? {},
    );
  }

  /// Create a system comment for status updates
  factory TaskCommentModel.systemComment({
    required String taskId,
    required String content,
    required TaskCommentType type,
    required String authorId,
    required String authorName,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return TaskCommentModel(
      id: '', // Will be set by Firestore
      taskId: taskId,
      content: content,
      type: type,
      authorId: authorId,
      authorName: authorName,
      createdAt: now,
      updatedAt: now,
      metadata: metadata ?? {},
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskCommentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TaskCommentModel(id: $id, taskId: $taskId, type: ${type.displayName}, author: $authorName)';
  }
}
