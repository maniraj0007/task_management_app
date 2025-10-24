import 'package:cloud_firestore/cloud_firestore.dart';

/// Task Dependency Model
/// Represents dependencies between tasks for project management
class TaskDependencyModel {
  final String id;
  final String dependentTaskId; // Task that depends on another
  final String dependsOnTaskId; // Task that must be completed first
  final String dependencyType; // finish_to_start, start_to_start, finish_to_finish, start_to_finish
  final int lagDays; // Lag time in days (can be negative for lead time)
  final String projectId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final Map<String, dynamic> metadata;

  TaskDependencyModel({
    required this.id,
    required this.dependentTaskId,
    required this.dependsOnTaskId,
    this.dependencyType = 'finish_to_start',
    this.lagDays = 0,
    required this.projectId,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.metadata = const {},
  });

  /// Create TaskDependencyModel from Firestore document
  factory TaskDependencyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TaskDependencyModel(
      id: doc.id,
      dependentTaskId: data['dependentTaskId'] ?? '',
      dependsOnTaskId: data['dependsOnTaskId'] ?? '',
      dependencyType: data['dependencyType'] ?? 'finish_to_start',
      lagDays: data['lagDays'] ?? 0,
      projectId: data['projectId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] ?? '',
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  /// Create TaskDependencyModel from JSON
  factory TaskDependencyModel.fromJson(Map<String, dynamic> json) {
    return TaskDependencyModel(
      id: json['id'] ?? '',
      dependentTaskId: json['dependentTaskId'] ?? '',
      dependsOnTaskId: json['dependsOnTaskId'] ?? '',
      dependencyType: json['dependencyType'] ?? 'finish_to_start',
      lagDays: json['lagDays'] ?? 0,
      projectId: json['projectId'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      createdBy: json['createdBy'] ?? '',
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dependentTaskId': dependentTaskId,
      'dependsOnTaskId': dependsOnTaskId,
      'dependencyType': dependencyType,
      'lagDays': lagDays,
      'projectId': projectId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'metadata': metadata,
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'dependentTaskId': dependentTaskId,
      'dependsOnTaskId': dependsOnTaskId,
      'dependencyType': dependencyType,
      'lagDays': lagDays,
      'projectId': projectId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  TaskDependencyModel copyWith({
    String? id,
    String? dependentTaskId,
    String? dependsOnTaskId,
    String? dependencyType,
    int? lagDays,
    String? projectId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    Map<String, dynamic>? metadata,
  }) {
    return TaskDependencyModel(
      id: id ?? this.id,
      dependentTaskId: dependentTaskId ?? this.dependentTaskId,
      dependsOnTaskId: dependsOnTaskId ?? this.dependsOnTaskId,
      dependencyType: dependencyType ?? this.dependencyType,
      lagDays: lagDays ?? this.lagDays,
      projectId: projectId ?? this.projectId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get dependency type display name
  String get dependencyTypeDisplayName {
    switch (dependencyType) {
      case 'finish_to_start':
        return 'Finish to Start';
      case 'start_to_start':
        return 'Start to Start';
      case 'finish_to_finish':
        return 'Finish to Finish';
      case 'start_to_finish':
        return 'Start to Finish';
      default:
        return 'Finish to Start';
    }
  }

  /// Get dependency type description
  String get dependencyTypeDescription {
    switch (dependencyType) {
      case 'finish_to_start':
        return 'Task must finish before dependent task can start';
      case 'start_to_start':
        return 'Tasks must start at the same time';
      case 'finish_to_finish':
        return 'Tasks must finish at the same time';
      case 'start_to_finish':
        return 'Task must start before dependent task can finish';
      default:
        return 'Task must finish before dependent task can start';
    }
  }

  /// Get lag/lead description
  String get lagDescription {
    if (lagDays == 0) {
      return 'No lag';
    } else if (lagDays > 0) {
      return '$lagDays day${lagDays == 1 ? '' : 's'} lag';
    } else {
      return '${lagDays.abs()} day${lagDays.abs() == 1 ? '' : 's'} lead';
    }
  }

  /// Check if this is a valid dependency (no circular references)
  bool isValidDependency(List<TaskDependencyModel> allDependencies) {
    // Simple circular dependency check
    final visited = <String>{};
    return !_hasCircularDependency(dependentTaskId, dependsOnTaskId, allDependencies, visited);
  }

  /// Helper method to check for circular dependencies
  bool _hasCircularDependency(
    String startTask,
    String currentTask,
    List<TaskDependencyModel> dependencies,
    Set<String> visited,
  ) {
    if (currentTask == startTask) {
      return true; // Circular dependency found
    }
    
    if (visited.contains(currentTask)) {
      return false; // Already visited, no circular dependency in this path
    }
    
    visited.add(currentTask);
    
    // Check all dependencies of the current task
    final taskDependencies = dependencies.where((dep) => dep.dependentTaskId == currentTask);
    for (final dep in taskDependencies) {
      if (_hasCircularDependency(startTask, dep.dependsOnTaskId, dependencies, visited)) {
        return true;
      }
    }
    
    visited.remove(currentTask);
    return false;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is TaskDependencyModel &&
        other.id == id &&
        other.dependentTaskId == dependentTaskId &&
        other.dependsOnTaskId == dependsOnTaskId &&
        other.dependencyType == dependencyType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        dependentTaskId.hashCode ^
        dependsOnTaskId.hashCode ^
        dependencyType.hashCode;
  }

  @override
  String toString() {
    return 'TaskDependencyModel(id: $id, dependentTaskId: $dependentTaskId, dependsOnTaskId: $dependsOnTaskId, dependencyType: $dependencyType)';
  }
}

/// Project Milestone Model
/// Represents project milestones for tracking progress
class ProjectMilestoneModel {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final String status; // pending, completed, overdue
  final List<String> associatedTasks;
  final int completionPercentage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final Map<String, dynamic> metadata;

  ProjectMilestoneModel({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    required this.dueDate,
    this.status = 'pending',
    this.associatedTasks = const [],
    this.completionPercentage = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.metadata = const {},
  });

  /// Create ProjectMilestoneModel from Firestore document
  factory ProjectMilestoneModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ProjectMilestoneModel(
      id: doc.id,
      projectId: data['projectId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'pending',
      associatedTasks: List<String>.from(data['associatedTasks'] ?? []),
      completionPercentage: data['completionPercentage'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] ?? '',
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status,
      'associatedTasks': associatedTasks,
      'completionPercentage': completionPercentage,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  ProjectMilestoneModel copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
    List<String>? associatedTasks,
    int? completionPercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    Map<String, dynamic>? metadata,
  }) {
    return ProjectMilestoneModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      associatedTasks: associatedTasks ?? this.associatedTasks,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if milestone is overdue
  bool get isOverdue {
    return status != 'completed' && dueDate.isBefore(DateTime.now());
  }

  /// Get formatted due date
  String get formattedDueDate {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.inDays == 0) {
      return 'Due today';
    } else if (difference.inDays == 1) {
      return 'Due tomorrow';
    } else if (difference.inDays > 0) {
      return 'Due in ${difference.inDays} days';
    } else {
      return 'Overdue by ${difference.inDays.abs()} days';
    }
  }

  @override
  String toString() {
    return 'ProjectMilestoneModel(id: $id, projectId: $projectId, title: $title, status: $status)';
  }
}
