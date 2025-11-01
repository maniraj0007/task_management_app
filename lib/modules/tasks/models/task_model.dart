import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/enums/task_enums.dart';

/// Task model for the multi-admin task management system
/// Represents a task with all its properties, relationships, and metadata
class TaskModel {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final TaskCategory category;
  final TaskAssignmentType assignmentType;
  final TaskRecurrence recurrence;
  final TaskVisibility visibility;
  
  // User relationships
  final String createdBy;
  final String? assignedTo;
  final List<String> assignedUsers;
  final List<String> watchers;
  
  // Team and project relationships
  final String? teamId;
  final String? projectId;
  final String? parentTaskId;
  final List<String> subtaskIds;
  final List<String> dependencyIds;
  final List<String> blockedByIds;
  
  // Dates and timing
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startDate;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final int? estimatedHours;
  final int? actualHours;
  
  // Recurrence settings
  final Map<String, dynamic>? recurrenceSettings;
  final DateTime? nextRecurrenceDate;
  
  // Task metadata
  final List<String> tags;
  final Map<String, dynamic> customFields;
  final int commentsCount;
  final int attachmentsCount;
  final double? progress;
  
  // Collaboration and tracking
  final List<String> collaborators;
  final DateTime? lastActivityAt;
  final String? lastActivityBy;
  final Map<String, dynamic> activitySummary;
  
  // Location and context
  final String? location;
  final Map<String, dynamic>? coordinates;
  
  // Archival and deletion
  final bool isArchived;
  final bool isDeleted;
  final DateTime? archivedAt;
  final DateTime? deletedAt;
  final String? archivedBy;
  final String? deletedBy;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.category,
    required this.assignmentType,
    required this.recurrence,
    required this.visibility,
    required this.createdBy,
    this.assignedTo,
    this.assignedUsers = const [],
    this.watchers = const [],
    this.teamId,
    this.projectId,
    this.parentTaskId,
    this.subtaskIds = const [],
    this.dependencyIds = const [],
    this.blockedByIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.startDate,
    this.dueDate,
    this.completedAt,
    this.estimatedHours,
    this.actualHours,
    this.recurrenceSettings,
    this.nextRecurrenceDate,
    this.tags = const [],
    this.customFields = const {},
    this.commentsCount = 0,
    this.attachmentsCount = 0,
    this.progress,
    this.collaborators = const [],
    this.lastActivityAt,
    this.lastActivityBy,
    this.activitySummary = const {},
    this.location,
    this.coordinates,
    this.isArchived = false,
    this.isDeleted = false,
    this.archivedAt,
    this.deletedAt,
    this.archivedBy,
    this.deletedBy,
  });

  /// Check if task is overdue
  bool get isOverdue {
    if (dueDate == null || status.isCompleted || status.isCancelled) {
      return false;
    }
    return DateTime.now().isAfter(dueDate!);
  }

  /// Check if task is due today
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final due = dueDate!;
    return now.year == due.year && now.month == due.month && now.day == due.day;
  }

  /// Check if task is due this week
  bool get isDueThisWeek {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return dueDate!.isAfter(startOfWeek) && dueDate!.isBefore(endOfWeek);
  }

  /// Check if task has subtasks
  bool get hasSubtasks => subtaskIds.isNotEmpty;

  /// Check if task has dependencies
  bool get hasDependencies => dependencyIds.isNotEmpty;

  /// Check if task is blocked
  bool get isBlocked => blockedByIds.isNotEmpty;

  /// Check if task is assigned to multiple users
  bool get isMultiAssigned => assignedUsers.length > 1;

  /// Check if task is being watched
  bool get isWatched => watchers.isNotEmpty;

  /// Check if task has attachments
  bool get hasAttachments => attachmentsCount > 0;

  /// Check if task has comments
  bool get hasComments => commentsCount > 0;

  /// Check if task is recurring
  bool get isRecurring => recurrence.isRecurring;

  /// Check if task is collaborative
  bool get isCollaborative => category.allowsCollaboration;

  /// Get task age in days
  int get ageInDays {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Get days until due date
  int? get daysUntilDue {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  /// Get completion percentage
  double get completionPercentage {
    if (progress != null) return progress!;
    
    // Calculate based on status
    switch (status) {
      case TaskStatus.todo:
        return 0.0;
      case TaskStatus.inProgress:
        return 0.5;
      case TaskStatus.review:
        return 0.8;
      case TaskStatus.completed:
        return 1.0;
      case TaskStatus.cancelled:
        return 0.0;
    }
  }

  /// Get all assigned user IDs (including single assignment)
  List<String> get allAssignedUserIds {
    final allAssigned = <String>[];
    if (assignedTo != null) allAssigned.add(assignedTo!);
    allAssigned.addAll(assignedUsers);
    return allAssigned.toSet().toList(); // Remove duplicates
  }

  /// Check if user is assigned to this task
  bool isAssignedToUser(String userId) {
    return allAssignedUserIds.contains(userId);
  }

  /// Check if user is watching this task
  bool isWatchedByUser(String userId) {
    return watchers.contains(userId);
  }

  /// Check if user is collaborating on this task
  bool isCollaboratedByUser(String userId) {
    return collaborators.contains(userId);
  }

  /// Check if user can edit this task
  bool canBeEditedByUser(String userId) {
    return createdBy == userId || 
           isAssignedToUser(userId) || 
           isCollaboratedByUser(userId);
  }

  /// Get task urgency score (for sorting)
  double get urgencyScore {
    double score = priority.level.toDouble();
    
    // Add urgency based on due date
    if (dueDate != null) {
      final daysUntilDue = this.daysUntilDue ?? 0;
      if (daysUntilDue < 0) {
        score += 10; // Overdue tasks get highest priority
      } else if (daysUntilDue == 0) {
        score += 5; // Due today
      } else if (daysUntilDue <= 3) {
        score += 3; // Due within 3 days
      } else if (daysUntilDue <= 7) {
        score += 1; // Due within a week
      }
    }
    
    return score;
  }

  /// Create a copy with updated fields
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    TaskCategory? category,
    TaskAssignmentType? assignmentType,
    TaskRecurrence? recurrence,
    TaskVisibility? visibility,
    String? createdBy,
    String? assignedTo,
    List<String>? assignedUsers,
    List<String>? watchers,
    String? teamId,
    String? projectId,
    String? parentTaskId,
    List<String>? subtaskIds,
    List<String>? dependencyIds,
    List<String>? blockedByIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? completedAt,
    int? estimatedHours,
    int? actualHours,
    Map<String, dynamic>? recurrenceSettings,
    DateTime? nextRecurrenceDate,
    List<String>? tags,
    Map<String, dynamic>? customFields,
    int? commentsCount,
    int? attachmentsCount,
    double? progress,
    List<String>? collaborators,
    DateTime? lastActivityAt,
    String? lastActivityBy,
    Map<String, dynamic>? activitySummary,
    String? location,
    Map<String, dynamic>? coordinates,
    bool? isArchived,
    bool? isDeleted,
    DateTime? archivedAt,
    DateTime? deletedAt,
    String? archivedBy,
    String? deletedBy,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      assignmentType: assignmentType ?? this.assignmentType,
      recurrence: recurrence ?? this.recurrence,
      visibility: visibility ?? this.visibility,
      createdBy: createdBy ?? this.createdBy,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedUsers: assignedUsers ?? this.assignedUsers,
      watchers: watchers ?? this.watchers,
      teamId: teamId ?? this.teamId,
      projectId: projectId ?? this.projectId,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      subtaskIds: subtaskIds ?? this.subtaskIds,
      dependencyIds: dependencyIds ?? this.dependencyIds,
      blockedByIds: blockedByIds ?? this.blockedByIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actualHours: actualHours ?? this.actualHours,
      recurrenceSettings: recurrenceSettings ?? this.recurrenceSettings,
      nextRecurrenceDate: nextRecurrenceDate ?? this.nextRecurrenceDate,
      tags: tags ?? this.tags,
      customFields: customFields ?? this.customFields,
      commentsCount: commentsCount ?? this.commentsCount,
      attachmentsCount: attachmentsCount ?? this.attachmentsCount,
      progress: progress ?? this.progress,
      collaborators: collaborators ?? this.collaborators,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      lastActivityBy: lastActivityBy ?? this.lastActivityBy,
      activitySummary: activitySummary ?? this.activitySummary,
      location: location ?? this.location,
      coordinates: coordinates ?? this.coordinates,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      archivedBy: archivedBy ?? this.archivedBy,
      deletedBy: deletedBy ?? this.deletedBy,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.value,
      'priority': priority.value,
      'category': category.value,
      'assignmentType': assignmentType.value,
      'recurrence': recurrence.value,
      'visibility': visibility.value,
      'createdBy': createdBy,
      'assignedTo': assignedTo,
      'assignedUsers': assignedUsers,
      'watchers': watchers,
      'teamId': teamId,
      'projectId': projectId,
      'parentTaskId': parentTaskId,
      'subtaskIds': subtaskIds,
      'dependencyIds': dependencyIds,
      'blockedByIds': blockedByIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'estimatedHours': estimatedHours,
      'actualHours': actualHours,
      'recurrenceSettings': recurrenceSettings,
      'nextRecurrenceDate': nextRecurrenceDate != null ? Timestamp.fromDate(nextRecurrenceDate!) : null,
      'tags': tags,
      'customFields': customFields,
      'commentsCount': commentsCount,
      'attachmentsCount': attachmentsCount,
      'progress': progress,
      'collaborators': collaborators,
      'lastActivityAt': lastActivityAt != null ? Timestamp.fromDate(lastActivityAt!) : null,
      'lastActivityBy': lastActivityBy,
      'activitySummary': activitySummary,
      'location': location,
      'coordinates': coordinates,
      'isArchived': isArchived,
      'isDeleted': isDeleted,
      'archivedAt': archivedAt != null ? Timestamp.fromDate(archivedAt!) : null,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
      'archivedBy': archivedBy,
      'deletedBy': deletedBy,
    };
  }

  /// Create from Firestore document
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }
    return TaskModel.fromJson({...data, 'id': doc.id});
  }

  /// Create from JSON (Firestore document)
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: TaskStatus.fromString(json['status'] ?? 'todo'),
      priority: TaskPriority.fromString(json['priority'] ?? 'medium'),
      category: TaskCategory.fromString(json['category'] ?? 'personal'),
      assignmentType: TaskAssignmentType.fromString(json['assignmentType'] ?? 'unassigned'),
      recurrence: TaskRecurrence.fromString(json['recurrence'] ?? 'none'),
      visibility: TaskVisibility.fromString(json['visibility'] ?? 'private'),
      createdBy: json['createdBy'] ?? '',
      assignedTo: json['assignedTo'],
      assignedUsers: (json['assignedUsers'] as List<dynamic>?)?.cast<String>() ?? [],
      watchers: (json['watchers'] as List<dynamic>?)?.cast<String>() ?? [],
      teamId: json['teamId'],
      projectId: json['projectId'],
      parentTaskId: json['parentTaskId'],
      subtaskIds: (json['subtaskIds'] as List<dynamic>?)?.cast<String>() ?? [],
      dependencyIds: (json['dependencyIds'] as List<dynamic>?)?.cast<String>() ?? [],
      blockedByIds: (json['blockedByIds'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startDate: (json['startDate'] as Timestamp?)?.toDate(),
      dueDate: (json['dueDate'] as Timestamp?)?.toDate(),
      completedAt: (json['completedAt'] as Timestamp?)?.toDate(),
      estimatedHours: json['estimatedHours'],
      actualHours: json['actualHours'],
      recurrenceSettings: json['recurrenceSettings']?.cast<String, dynamic>(),
      nextRecurrenceDate: (json['nextRecurrenceDate'] as Timestamp?)?.toDate(),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      customFields: json['customFields']?.cast<String, dynamic>() ?? {},
      commentsCount: json['commentsCount'] ?? 0,
      attachmentsCount: json['attachmentsCount'] ?? 0,
      progress: json['progress']?.toDouble(),
      collaborators: (json['collaborators'] as List<dynamic>?)?.cast<String>() ?? [],
      lastActivityAt: (json['lastActivityAt'] as Timestamp?)?.toDate(),
      lastActivityBy: json['lastActivityBy'],
      activitySummary: json['activitySummary']?.cast<String, dynamic>() ?? {},
      location: json['location'],
      coordinates: json['coordinates']?.cast<String, dynamic>(),
      isArchived: json['isArchived'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      archivedAt: (json['archivedAt'] as Timestamp?)?.toDate(),
      deletedAt: (json['deletedAt'] as Timestamp?)?.toDate(),
      archivedBy: json['archivedBy'],
      deletedBy: json['deletedBy'],
    );
  }

  /// Create a new task with minimal required fields
  factory TaskModel.create({
    required String title,
    required String description,
    required String createdBy,
    TaskCategory category = TaskCategory.personal,
    TaskPriority priority = TaskPriority.medium,
    TaskVisibility visibility = TaskVisibility.private,
    String? assignedTo,
    DateTime? dueDate,
    List<String>? tags,
  }) {
    final now = DateTime.now();
    return TaskModel(
      id: '', // Will be set by Firestore
      title: title,
      description: description,
      status: TaskStatus.todo,
      priority: priority,
      category: category,
      assignmentType: assignedTo != null ? TaskAssignmentType.managerAssigned : TaskAssignmentType.selfAssigned,
      recurrence: TaskRecurrence.none,
      visibility: visibility,
      createdBy: createdBy,
      assignedTo: assignedTo,
      createdAt: now,
      updatedAt: now,
      dueDate: dueDate,
      tags: tags ?? [],
      lastActivityAt: now,
      lastActivityBy: createdBy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, status: ${status.displayName}, priority: ${priority.displayName})';
  }
}
