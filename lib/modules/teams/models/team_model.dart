import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/enums/team_enums.dart';

/// Team model for the multi-admin task management system
/// Represents a team with members, settings, and collaboration features
class TeamModel {
  final String id;
  final String name;
  final String description;
  final String? logoUrl;
  final TeamVisibility visibility;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isArchived;
  final DateTime? archivedAt;
  final String? archivedBy;
  
  // Team settings
  final Map<String, dynamic> settings;
  final List<String> tags;
  final String? website;
  final String? location;
  final Map<String, String> socialLinks;
  
  // Member management
  final List<String> memberIds;
  final Map<String, String> memberRoles; // userId -> role
  final int maxMembers;
  final bool allowJoinRequests;
  final bool requireApprovalForJoin;
  
  // Statistics
  final int totalMembers;
  final int totalProjects;
  final int totalTasks;
  final int completedTasks;
  final DateTime? lastActivityAt;
  final String? lastActivityBy;
  
  // Collaboration features
  final Map<String, dynamic> collaborationSettings;
  final List<String> defaultProjectTags;
  final Map<String, dynamic> notificationSettings;
  final Map<String, dynamic> integrations;

  const TeamModel({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    required this.visibility,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isArchived = false,
    this.archivedAt,
    this.archivedBy,
    this.settings = const {},
    this.tags = const [],
    this.website,
    this.location,
    this.socialLinks = const {},
    this.memberIds = const [],
    this.memberRoles = const {},
    this.maxMembers = 50,
    this.allowJoinRequests = false,
    this.requireApprovalForJoin = true,
    this.totalMembers = 0,
    this.totalProjects = 0,
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.lastActivityAt,
    this.lastActivityBy,
    this.collaborationSettings = const {},
    this.defaultProjectTags = const [],
    this.notificationSettings = const {},
    this.integrations = const {},
  });

  /// Check if team is private
  bool get isPrivate => visibility.isPrivate;

  /// Check if team is public
  bool get isPublic => visibility.isPublic;

  /// Check if team allows new members
  bool get canAcceptNewMembers => 
      isActive && !isArchived && totalMembers < maxMembers;

  /// Check if user is a member of this team
  bool isMember(String userId) {
    return memberIds.contains(userId);
  }

  /// Get user's role in this team
  TeamRole? getUserRole(String userId) {
    if (!isMember(userId)) return null;
    final roleString = memberRoles[userId];
    return roleString != null ? TeamRole.fromString(roleString) : null;
  }

  /// Check if user has specific role or higher
  bool hasRoleOrHigher(String userId, TeamRole requiredRole) {
    final userRole = getUserRole(userId);
    if (userRole == null) return false;
    return userRole.level >= requiredRole.level;
  }

  /// Check if user can manage this team
  bool canUserManageTeam(String userId) {
    final role = getUserRole(userId);
    return role?.canManageTeam ?? false;
  }

  /// Check if user can manage team members
  bool canUserManageMembers(String userId) {
    final role = getUserRole(userId);
    return role?.canManageMembers ?? false;
  }

  /// Check if user can create projects
  bool canUserCreateProjects(String userId) {
    final role = getUserRole(userId);
    return role?.canCreateProjects ?? false;
  }

  /// Check if user can view team analytics
  bool canUserViewAnalytics(String userId) {
    final role = getUserRole(userId);
    return role?.canViewAnalytics ?? false;
  }

  /// Get team completion percentage
  double get completionPercentage {
    if (totalTasks == 0) return 0.0;
    return completedTasks / totalTasks;
  }

  /// Get team activity level
  String get activityLevel {
    if (lastActivityAt == null) return 'Inactive';
    
    final daysSinceActivity = DateTime.now().difference(lastActivityAt!).inDays;
    
    if (daysSinceActivity == 0) return 'Very Active';
    if (daysSinceActivity <= 3) return 'Active';
    if (daysSinceActivity <= 7) return 'Moderate';
    if (daysSinceActivity <= 30) return 'Low';
    return 'Inactive';
  }

  /// Get members by role
  List<String> getMembersByRole(TeamRole role) {
    return memberIds.where((memberId) {
      final memberRole = memberRoles[memberId];
      return memberRole == role.value;
    }).toList();
  }

  /// Get team owners
  List<String> get owners => getMembersByRole(TeamRole.owner);

  /// Get team admins
  List<String> get admins => getMembersByRole(TeamRole.admin);

  /// Get team managers
  List<String> get managers => getMembersByRole(TeamRole.manager);

  /// Get regular members
  List<String> get members => getMembersByRole(TeamRole.member);

  /// Get guests
  List<String> get guests => getMembersByRole(TeamRole.guest);

  /// Check if team has any owners
  bool get hasOwners => owners.isNotEmpty;

  /// Check if team has any admins
  bool get hasAdmins => admins.isNotEmpty;

  /// Get team age in days
  int get ageInDays {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Check if team is new (less than 7 days old)
  bool get isNew => ageInDays < 7;

  /// Get team health score (0-100)
  int get healthScore {
    int score = 0;
    
    // Activity score (30 points)
    if (lastActivityAt != null) {
      final daysSinceActivity = DateTime.now().difference(lastActivityAt!).inDays;
      if (daysSinceActivity == 0) score += 30;
      else if (daysSinceActivity <= 3) score += 25;
      else if (daysSinceActivity <= 7) score += 20;
      else if (daysSinceActivity <= 30) score += 10;
    }
    
    // Member engagement (25 points)
    if (totalMembers > 0) {
      if (totalMembers >= 5) score += 25;
      else if (totalMembers >= 3) score += 20;
      else if (totalMembers >= 2) score += 15;
      else score += 10;
    }
    
    // Project activity (25 points)
    if (totalProjects > 0) {
      if (totalProjects >= 3) score += 25;
      else if (totalProjects >= 2) score += 20;
      else score += 15;
    }
    
    // Task completion (20 points)
    if (totalTasks > 0) {
      final completionRate = completionPercentage;
      if (completionRate >= 0.8) score += 20;
      else if (completionRate >= 0.6) score += 15;
      else if (completionRate >= 0.4) score += 10;
      else score += 5;
    }
    
    return score.clamp(0, 100);
  }

  /// Create a copy with updated fields
  TeamModel copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    TeamVisibility? visibility,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isArchived,
    DateTime? archivedAt,
    String? archivedBy,
    Map<String, dynamic>? settings,
    List<String>? tags,
    String? website,
    String? location,
    Map<String, String>? socialLinks,
    List<String>? memberIds,
    Map<String, String>? memberRoles,
    int? maxMembers,
    bool? allowJoinRequests,
    bool? requireApprovalForJoin,
    int? totalMembers,
    int? totalProjects,
    int? totalTasks,
    int? completedTasks,
    DateTime? lastActivityAt,
    String? lastActivityBy,
    Map<String, dynamic>? collaborationSettings,
    List<String>? defaultProjectTags,
    Map<String, dynamic>? notificationSettings,
    Map<String, dynamic>? integrations,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      visibility: visibility ?? this.visibility,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      archivedAt: archivedAt ?? this.archivedAt,
      archivedBy: archivedBy ?? this.archivedBy,
      settings: settings ?? this.settings,
      tags: tags ?? this.tags,
      website: website ?? this.website,
      location: location ?? this.location,
      socialLinks: socialLinks ?? this.socialLinks,
      memberIds: memberIds ?? this.memberIds,
      memberRoles: memberRoles ?? this.memberRoles,
      maxMembers: maxMembers ?? this.maxMembers,
      allowJoinRequests: allowJoinRequests ?? this.allowJoinRequests,
      requireApprovalForJoin: requireApprovalForJoin ?? this.requireApprovalForJoin,
      totalMembers: totalMembers ?? this.totalMembers,
      totalProjects: totalProjects ?? this.totalProjects,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      lastActivityBy: lastActivityBy ?? this.lastActivityBy,
      collaborationSettings: collaborationSettings ?? this.collaborationSettings,
      defaultProjectTags: defaultProjectTags ?? this.defaultProjectTags,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      integrations: integrations ?? this.integrations,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'visibility': visibility.value,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'isArchived': isArchived,
      'archivedAt': archivedAt != null ? Timestamp.fromDate(archivedAt!) : null,
      'archivedBy': archivedBy,
      'settings': settings,
      'tags': tags,
      'website': website,
      'location': location,
      'socialLinks': socialLinks,
      'memberIds': memberIds,
      'memberRoles': memberRoles,
      'maxMembers': maxMembers,
      'allowJoinRequests': allowJoinRequests,
      'requireApprovalForJoin': requireApprovalForJoin,
      'totalMembers': totalMembers,
      'totalProjects': totalProjects,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'lastActivityAt': lastActivityAt != null ? Timestamp.fromDate(lastActivityAt!) : null,
      'lastActivityBy': lastActivityBy,
      'collaborationSettings': collaborationSettings,
      'defaultProjectTags': defaultProjectTags,
      'notificationSettings': notificationSettings,
      'integrations': integrations,
    };
  }

  /// Create from JSON (Firestore document)
  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      logoUrl: json['logoUrl'],
      visibility: TeamVisibility.fromString(json['visibility'] ?? 'private'),
      createdBy: json['createdBy'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: json['isActive'] ?? true,
      isArchived: json['isArchived'] ?? false,
      archivedAt: (json['archivedAt'] as Timestamp?)?.toDate(),
      archivedBy: json['archivedBy'],
      settings: json['settings']?.cast<String, dynamic>() ?? {},
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      website: json['website'],
      location: json['location'],
      socialLinks: json['socialLinks']?.cast<String, String>() ?? {},
      memberIds: (json['memberIds'] as List<dynamic>?)?.cast<String>() ?? [],
      memberRoles: json['memberRoles']?.cast<String, String>() ?? {},
      maxMembers: json['maxMembers'] ?? 50,
      allowJoinRequests: json['allowJoinRequests'] ?? false,
      requireApprovalForJoin: json['requireApprovalForJoin'] ?? true,
      totalMembers: json['totalMembers'] ?? 0,
      totalProjects: json['totalProjects'] ?? 0,
      totalTasks: json['totalTasks'] ?? 0,
      completedTasks: json['completedTasks'] ?? 0,
      lastActivityAt: (json['lastActivityAt'] as Timestamp?)?.toDate(),
      lastActivityBy: json['lastActivityBy'],
      collaborationSettings: json['collaborationSettings']?.cast<String, dynamic>() ?? {},
      defaultProjectTags: (json['defaultProjectTags'] as List<dynamic>?)?.cast<String>() ?? [],
      notificationSettings: json['notificationSettings']?.cast<String, dynamic>() ?? {},
      integrations: json['integrations']?.cast<String, dynamic>() ?? {},
    );
  }

  /// Create a new team with minimal required fields
  factory TeamModel.create({
    required String name,
    required String description,
    required String createdBy,
    TeamVisibility visibility = TeamVisibility.private,
    List<String>? tags,
    String? website,
    String? location,
    int maxMembers = 50,
  }) {
    final now = DateTime.now();
    return TeamModel(
      id: '', // Will be set by Firestore
      name: name,
      description: description,
      visibility: visibility,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
      tags: tags ?? [],
      website: website,
      location: location,
      maxMembers: maxMembers,
      memberIds: [createdBy], // Creator is automatically a member
      memberRoles: {createdBy: TeamRole.owner.value}, // Creator is the owner
      totalMembers: 1,
      lastActivityAt: now,
      lastActivityBy: createdBy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TeamModel(id: $id, name: $name, members: $totalMembers, projects: $totalProjects)';
  }
}
