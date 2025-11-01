import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/enums/team_enums.dart';

/// Project model for the multi-admin task management system
/// Represents a project within a team with tasks, milestones, and collaboration features
class ProjectModel {
  final String id;
  final String name;
  final String description;
  final String? coverImageUrl;
  final ProjectStatus status;
  final ProjectPriority priority;
  final ProjectType type;
  final String teamId;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final DateTime? archivedAt;
  final String? archivedBy;
  
  // Project timeline
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? actualStartDate;
  final DateTime? actualEndDate;
  final int? estimatedHours;
  final int? actualHours;
  
  // Project settings
  final Map<String, dynamic> settings;
  final List<String> tags;
  final String? repository;
  final String? website;
  final Map<String, String> externalLinks;
  
  // Member management
  final List<String> memberIds;
  final Map<String, String> memberRoles; // userId -> role
  final String? projectManager;
  final List<String> stakeholders;
  
  // Statistics
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int overdueTasks;
  final int totalMilestones;
  final int completedMilestones;
  final DateTime? lastActivityAt;
  final String? lastActivityBy;
  
  // Collaboration features
  final Map<String, dynamic> collaborationSettings;
  final List<String> milestoneIds;
  final Map<String, dynamic> customFields;
  final Map<String, dynamic> integrations;
  final List<String> attachmentIds;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    this.coverImageUrl,
    required this.status,
    required this.priority,
    required this.type,
    required this.teamId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
    this.archivedAt,
    this.archivedBy,
    this.startDate,
    this.endDate,
    this.actualStartDate,
    this.actualEndDate,
    this.estimatedHours,
    this.actualHours,
    this.settings = const {},
    this.tags = const [],
    this.repository,
    this.website,
    this.externalLinks = const {},
    this.memberIds = const [],
    this.memberRoles = const {},
    this.projectManager,
    this.stakeholders = const [],
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.inProgressTasks = 0,
    this.overdueTasks = 0,
    this.totalMilestones = 0,
    this.completedMilestones = 0,
    this.lastActivityAt,
    this.lastActivityBy,
    this.collaborationSettings = const {},
    this.milestoneIds = const [],
    this.customFields = const {},
    this.integrations = const {},
    this.attachmentIds = const [],
  });

  /// Check if project is active
  bool get isActive => status.isActive;

  /// Check if project is completed
  bool get isCompleted => status.isCompleted;

  /// Check if project is cancelled
  bool get isCancelled => status.isCancelled;

  /// Check if project can be worked on
  bool get canWork => status.canWork && !isArchived;

  /// Check if user is a member of this project
  bool isMember(String userId) {
    return memberIds.contains(userId);
  }

  /// Check if user is the project manager
  bool isProjectManager(String userId) {
    return projectManager == userId;
  }

  /// Check if user is a stakeholder
  bool isStakeholder(String userId) {
    return stakeholders.contains(userId);
  }

  /// Get project completion percentage
  double get completionPercentage {
    if (totalTasks == 0) return 0.0;
    return completedTasks / totalTasks;
  }

  /// Get milestone completion percentage
  double get milestoneCompletionPercentage {
    if (totalMilestones == 0) return 0.0;
    return completedMilestones / totalMilestones;
  }

  /// Get project progress (0.0 to 1.0)
  double get progress {
    // Combine task and milestone completion
    final taskProgress = completionPercentage;
    final milestoneProgress = milestoneCompletionPercentage;
    
    if (totalTasks > 0 && totalMilestones > 0) {
      return (taskProgress + milestoneProgress) / 2;
    } else if (totalTasks > 0) {
      return taskProgress;
    } else if (totalMilestones > 0) {
      return milestoneProgress;
    }
    
    return 0.0;
  }

  /// Check if project is overdue
  bool get isOverdue {
    if (endDate == null || isCompleted) return false;
    return DateTime.now().isAfter(endDate!);
  }

  /// Check if project is due soon (within 7 days)
  bool get isDueSoon {
    if (endDate == null || isCompleted) return false;
    final daysUntilDue = endDate!.difference(DateTime.now()).inDays;
    return daysUntilDue <= 7 && daysUntilDue >= 0;
  }

  /// Get days until due date
  int? get daysUntilDue {
    if (endDate == null) return null;
    return endDate!.difference(DateTime.now()).inDays;
  }

  /// Get project duration in days
  int? get durationInDays {
    if (startDate == null || endDate == null) return null;
    return endDate!.difference(startDate!).inDays;
  }

  /// Get actual duration in days
  int? get actualDurationInDays {
    if (actualStartDate == null) return null;
    final endDateToUse = actualEndDate ?? DateTime.now();
    return endDateToUse.difference(actualStartDate!).inDays;
  }

  /// Get project health score (0-100)
  int get healthScore {
    int score = 0;
    
    // Progress score (40 points)
    final progressScore = (progress * 40).round();
    score += progressScore;
    
    // Timeline score (30 points)
    if (endDate != null) {
      if (isCompleted) {
        // Completed projects get full timeline score
        score += 30;
      } else if (isOverdue) {
        // Overdue projects lose points
        score += 5;
      } else if (isDueSoon) {
        // Projects due soon get partial score
        score += 20;
      } else {
        // Projects on track get full score
        score += 30;
      }
    } else {
      // Projects without end date get partial score
      score += 15;
    }
    
    // Activity score (20 points)
    if (lastActivityAt != null) {
      final daysSinceActivity = DateTime.now().difference(lastActivityAt!).inDays;
      if (daysSinceActivity == 0) score += 20;
      else if (daysSinceActivity <= 3) score += 15;
      else if (daysSinceActivity <= 7) score += 10;
      else if (daysSinceActivity <= 30) score += 5;
    }
    
    // Task management score (10 points)
    if (totalTasks > 0) {
      if (overdueTasks == 0) score += 10;
      else if (overdueTasks <= totalTasks * 0.1) score += 7;
      else if (overdueTasks <= totalTasks * 0.2) score += 5;
      else score += 2;
    } else {
      score += 5; // Partial score for projects without tasks yet
    }
    
    return score.clamp(0, 100);
  }

  /// Get project status color
  String get statusColor => status.colorHex;

  /// Get project priority color
  String get priorityColor => priority.colorHex;

  /// Get project type color
  String get typeColor => type.colorHex;

  /// Get project activity level
  String get activityLevel {
    if (lastActivityAt == null) return 'Inactive';
    
    final daysSinceActivity = DateTime.now().difference(lastActivityAt!).inDays;
    
    if (daysSinceActivity == 0) return 'Very Active';
    if (daysSinceActivity <= 3) return 'Active';
    if (daysSinceActivity <= 7) return 'Moderate';
    if (daysSinceActivity <= 30) return 'Low';
    return 'Inactive';
  }

  /// Get project age in days
  int get ageInDays {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Check if project is new (less than 7 days old)
  bool get isNew => ageInDays < 7;

  /// Get estimated vs actual hours variance
  double? get hoursVariance {
    if (estimatedHours == null || actualHours == null) return null;
    return (actualHours! - estimatedHours!) / estimatedHours!;
  }

  /// Check if project is over budget (time-wise)
  bool get isOverBudget {
    final variance = hoursVariance;
    return variance != null && variance > 0.1; // 10% over estimate
  }

  /// Get next possible statuses
  List<ProjectStatus> get nextStatuses => status.nextStatuses;

  /// Create a copy with updated fields
  ProjectModel copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImageUrl,
    ProjectStatus? status,
    ProjectPriority? priority,
    ProjectType? type,
    String? teamId,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    DateTime? archivedAt,
    String? archivedBy,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? actualStartDate,
    DateTime? actualEndDate,
    int? estimatedHours,
    int? actualHours,
    Map<String, dynamic>? settings,
    List<String>? tags,
    String? repository,
    String? website,
    Map<String, String>? externalLinks,
    List<String>? memberIds,
    Map<String, String>? memberRoles,
    String? projectManager,
    List<String>? stakeholders,
    int? totalTasks,
    int? completedTasks,
    int? inProgressTasks,
    int? overdueTasks,
    int? totalMilestones,
    int? completedMilestones,
    DateTime? lastActivityAt,
    String? lastActivityBy,
    Map<String, dynamic>? collaborationSettings,
    List<String>? milestoneIds,
    Map<String, dynamic>? customFields,
    Map<String, dynamic>? integrations,
    List<String>? attachmentIds,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      type: type ?? this.type,
      teamId: teamId ?? this.teamId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      archivedAt: archivedAt ?? this.archivedAt,
      archivedBy: archivedBy ?? this.archivedBy,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      actualStartDate: actualStartDate ?? this.actualStartDate,
      actualEndDate: actualEndDate ?? this.actualEndDate,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actualHours: actualHours ?? this.actualHours,
      settings: settings ?? this.settings,
      tags: tags ?? this.tags,
      repository: repository ?? this.repository,
      website: website ?? this.website,
      externalLinks: externalLinks ?? this.externalLinks,
      memberIds: memberIds ?? this.memberIds,
      memberRoles: memberRoles ?? this.memberRoles,
      projectManager: projectManager ?? this.projectManager,
      stakeholders: stakeholders ?? this.stakeholders,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      inProgressTasks: inProgressTasks ?? this.inProgressTasks,
      overdueTasks: overdueTasks ?? this.overdueTasks,
      totalMilestones: totalMilestones ?? this.totalMilestones,
      completedMilestones: completedMilestones ?? this.completedMilestones,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      lastActivityBy: lastActivityBy ?? this.lastActivityBy,
      collaborationSettings: collaborationSettings ?? this.collaborationSettings,
      milestoneIds: milestoneIds ?? this.milestoneIds,
      customFields: customFields ?? this.customFields,
      integrations: integrations ?? this.integrations,
      attachmentIds: attachmentIds ?? this.attachmentIds,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'status': status.value,
      'priority': priority.value,
      'type': type.value,
      'teamId': teamId,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isArchived': isArchived,
      'archivedAt': archivedAt != null ? Timestamp.fromDate(archivedAt!) : null,
      'archivedBy': archivedBy,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'actualStartDate': actualStartDate != null ? Timestamp.fromDate(actualStartDate!) : null,
      'actualEndDate': actualEndDate != null ? Timestamp.fromDate(actualEndDate!) : null,
      'estimatedHours': estimatedHours,
      'actualHours': actualHours,
      'settings': settings,
      'tags': tags,
      'repository': repository,
      'website': website,
      'externalLinks': externalLinks,
      'memberIds': memberIds,
      'memberRoles': memberRoles,
      'projectManager': projectManager,
      'stakeholders': stakeholders,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'inProgressTasks': inProgressTasks,
      'overdueTasks': overdueTasks,
      'totalMilestones': totalMilestones,
      'completedMilestones': completedMilestones,
      'lastActivityAt': lastActivityAt != null ? Timestamp.fromDate(lastActivityAt!) : null,
      'lastActivityBy': lastActivityBy,
      'collaborationSettings': collaborationSettings,
      'milestoneIds': milestoneIds,
      'customFields': customFields,
      'integrations': integrations,
      'attachmentIds': attachmentIds,
    };
  }

  /// Create from Firestore document
  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }
    return ProjectModel.fromJson({...data, 'id': doc.id});
  }

  /// Create from JSON (Firestore document)
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      coverImageUrl: json['coverImageUrl'],
      status: ProjectStatus.fromString(json['status'] ?? 'planning'),
      priority: ProjectPriority.fromString(json['priority'] ?? 'medium'),
      type: ProjectType.fromString(json['type'] ?? 'general'),
      teamId: json['teamId'] ?? '',
      createdBy: json['createdBy'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isArchived: json['isArchived'] ?? false,
      archivedAt: (json['archivedAt'] as Timestamp?)?.toDate(),
      archivedBy: json['archivedBy'],
      startDate: (json['startDate'] as Timestamp?)?.toDate(),
      endDate: (json['endDate'] as Timestamp?)?.toDate(),
      actualStartDate: (json['actualStartDate'] as Timestamp?)?.toDate(),
      actualEndDate: (json['actualEndDate'] as Timestamp?)?.toDate(),
      estimatedHours: json['estimatedHours'],
      actualHours: json['actualHours'],
      settings: json['settings']?.cast<String, dynamic>() ?? {},
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      repository: json['repository'],
      website: json['website'],
      externalLinks: json['externalLinks']?.cast<String, String>() ?? {},
      memberIds: (json['memberIds'] as List<dynamic>?)?.cast<String>() ?? [],
      memberRoles: json['memberRoles']?.cast<String, String>() ?? {},
      projectManager: json['projectManager'],
      stakeholders: (json['stakeholders'] as List<dynamic>?)?.cast<String>() ?? [],
      totalTasks: json['totalTasks'] ?? 0,
      completedTasks: json['completedTasks'] ?? 0,
      inProgressTasks: json['inProgressTasks'] ?? 0,
      overdueTasks: json['overdueTasks'] ?? 0,
      totalMilestones: json['totalMilestones'] ?? 0,
      completedMilestones: json['completedMilestones'] ?? 0,
      lastActivityAt: (json['lastActivityAt'] as Timestamp?)?.toDate(),
      lastActivityBy: json['lastActivityBy'],
      collaborationSettings: json['collaborationSettings']?.cast<String, dynamic>() ?? {},
      milestoneIds: (json['milestoneIds'] as List<dynamic>?)?.cast<String>() ?? [],
      customFields: json['customFields']?.cast<String, dynamic>() ?? {},
      integrations: json['integrations']?.cast<String, dynamic>() ?? {},
      attachmentIds: (json['attachmentIds'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  /// Create a new project with minimal required fields
  factory ProjectModel.create({
    required String name,
    required String description,
    required String teamId,
    required String createdBy,
    ProjectStatus status = ProjectStatus.planning,
    ProjectPriority priority = ProjectPriority.medium,
    ProjectType type = ProjectType.general,
    DateTime? startDate,
    DateTime? endDate,
    int? estimatedHours,
    List<String>? tags,
    String? projectManager,
  }) {
    final now = DateTime.now();
    return ProjectModel(
      id: '', // Will be set by Firestore
      name: name,
      description: description,
      status: status,
      priority: priority,
      type: type,
      teamId: teamId,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
      startDate: startDate,
      endDate: endDate,
      estimatedHours: estimatedHours,
      tags: tags ?? [],
      projectManager: projectManager ?? createdBy,
      memberIds: [createdBy], // Creator is automatically a member
      lastActivityAt: now,
      lastActivityBy: createdBy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProjectModel(id: $id, name: $name, status: ${status.displayName}, progress: ${(progress * 100).toStringAsFixed(1)}%)';
  }
}
