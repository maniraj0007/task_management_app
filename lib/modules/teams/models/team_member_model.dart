import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/enums/team_enums.dart';

/// Team member model for the multi-admin task management system
/// Represents a user's membership in a team with role and activity tracking
class TeamMemberModel {
  final String id;
  final String userId;
  final String teamId;
  final TeamRole role;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final bool isActive;
  final String addedBy;
  final String? removedBy;
  final String? removalReason;
  
  // Member profile in team context
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final String? title;
  final String? department;
  final Map<String, dynamic> customFields;
  
  // Activity tracking
  final DateTime? lastActiveAt;
  final int totalTasksAssigned;
  final int totalTasksCompleted;
  final int totalProjectsAssigned;
  final double averageTaskCompletionTime; // in hours
  final Map<String, dynamic> activityStats;
  
  // Permissions and settings
  final Map<String, bool> permissions;
  final Map<String, dynamic> preferences;
  final List<String> specializations;
  final Map<String, dynamic> availability;
  
  // Collaboration metrics
  final int collaborationScore; // 0-100
  final DateTime? lastCollaborationAt;
  final List<String> frequentCollaborators;
  final Map<String, int> skillRatings; // skill -> rating (1-5)

  const TeamMemberModel({
    required this.id,
    required this.userId,
    required this.teamId,
    required this.role,
    required this.joinedAt,
    this.leftAt,
    this.isActive = true,
    required this.addedBy,
    this.removedBy,
    this.removalReason,
    this.displayName,
    this.email,
    this.photoUrl,
    this.title,
    this.department,
    this.customFields = const {},
    this.lastActiveAt,
    this.totalTasksAssigned = 0,
    this.totalTasksCompleted = 0,
    this.totalProjectsAssigned = 0,
    this.averageTaskCompletionTime = 0.0,
    this.activityStats = const {},
    this.permissions = const {},
    this.preferences = const {},
    this.specializations = const [],
    this.availability = const {},
    this.collaborationScore = 0,
    this.lastCollaborationAt,
    this.frequentCollaborators = const [],
    this.skillRatings = const {},
  });

  /// Check if member is currently active in the team
  bool get isCurrentlyActive => isActive && leftAt == null;

  /// Get member's tenure in the team (days)
  int get tenureInDays {
    final endDate = leftAt ?? DateTime.now();
    return endDate.difference(joinedAt).inDays;
  }

  /// Check if member is new (joined within last 30 days)
  bool get isNewMember => tenureInDays <= 30;

  /// Get task completion rate
  double get taskCompletionRate {
    if (totalTasksAssigned == 0) return 0.0;
    return totalTasksCompleted / totalTasksAssigned;
  }

  /// Get member's activity level
  String get activityLevel {
    if (lastActiveAt == null) return 'Never Active';
    
    final daysSinceActive = DateTime.now().difference(lastActiveAt!).inDays;
    
    if (daysSinceActive == 0) return 'Very Active';
    if (daysSinceActive <= 3) return 'Active';
    if (daysSinceActive <= 7) return 'Moderate';
    if (daysSinceActive <= 30) return 'Low';
    return 'Inactive';
  }

  /// Get member's performance score (0-100)
  int get performanceScore {
    int score = 0;
    
    // Task completion rate (40 points)
    score += (taskCompletionRate * 40).round();
    
    // Activity level (30 points)
    if (lastActiveAt != null) {
      final daysSinceActive = DateTime.now().difference(lastActiveAt!).inDays;
      if (daysSinceActive == 0) score += 30;
      else if (daysSinceActive <= 3) score += 25;
      else if (daysSinceActive <= 7) score += 20;
      else if (daysSinceActive <= 30) score += 10;
    }
    
    // Collaboration score (20 points)
    score += (collaborationScore * 0.2).round();
    
    // Tenure bonus (10 points)
    if (tenureInDays >= 365) score += 10; // 1+ years
    else if (tenureInDays >= 180) score += 7; // 6+ months
    else if (tenureInDays >= 90) score += 5; // 3+ months
    else if (tenureInDays >= 30) score += 3; // 1+ month
    
    return score.clamp(0, 100);
  }

  /// Check if member has specific permission
  bool hasPermission(String permission) {
    return permissions[permission] ?? false;
  }

  /// Get member's skill level for a specific skill
  int getSkillRating(String skill) {
    return skillRatings[skill] ?? 0;
  }

  /// Check if member has high skill rating (4-5) in any area
  bool get hasHighSkills {
    return skillRatings.values.any((rating) => rating >= 4);
  }

  /// Get member's top skills (rating 4-5)
  List<String> get topSkills {
    return skillRatings.entries
        .where((entry) => entry.value >= 4)
        .map((entry) => entry.key)
        .toList();
  }

  /// Check if member is available for new assignments
  bool get isAvailableForAssignments {
    if (!isCurrentlyActive) return false;
    
    // Check availability settings
    final isAvailable = availability['isAvailable'] as bool? ?? true;
    final maxConcurrentTasks = availability['maxConcurrentTasks'] as int? ?? 10;
    
    return isAvailable && totalTasksAssigned < maxConcurrentTasks;
  }

  /// Get member's workload level
  String get workloadLevel {
    final maxTasks = availability['maxConcurrentTasks'] as int? ?? 10;
    final currentLoad = totalTasksAssigned / maxTasks;
    
    if (currentLoad >= 1.0) return 'Overloaded';
    if (currentLoad >= 0.8) return 'High';
    if (currentLoad >= 0.6) return 'Medium';
    if (currentLoad >= 0.3) return 'Light';
    return 'Available';
  }

  /// Check if member can perform specific role actions
  bool canPerformRoleAction(String action) {
    switch (action) {
      case 'manage_team':
        return role.canManageTeam;
      case 'manage_members':
        return role.canManageMembers;
      case 'create_projects':
        return role.canCreateProjects;
      case 'assign_tasks':
        return role.canAssignTasks;
      case 'view_analytics':
        return role.canViewAnalytics;
      default:
        return false;
    }
  }

  /// Get member's role color
  String get roleColor => role.colorHex;

  /// Get member's role icon
  String get roleIcon => role.iconName;

  /// Get member's role description
  String get roleDescription => role.description;

  /// Check if member is a team leader (owner or admin)
  bool get isTeamLeader => role == TeamRole.owner || role == TeamRole.admin;

  /// Check if member can manage other member
  bool canManageMember(TeamMemberModel otherMember) {
    if (!role.canManageMembers) return false;
    return role.level > otherMember.role.level;
  }

  /// Get days since last activity
  int? get daysSinceLastActivity {
    if (lastActiveAt == null) return null;
    return DateTime.now().difference(lastActiveAt!).inDays;
  }

  /// Check if member needs attention (inactive for too long)
  bool get needsAttention {
    final days = daysSinceLastActivity;
    return days != null && days > 14; // Inactive for more than 2 weeks
  }

  /// Create a copy with updated fields
  TeamMemberModel copyWith({
    String? id,
    String? userId,
    String? teamId,
    TeamRole? role,
    DateTime? joinedAt,
    DateTime? leftAt,
    bool? isActive,
    String? addedBy,
    String? removedBy,
    String? removalReason,
    String? displayName,
    String? email,
    String? photoUrl,
    String? title,
    String? department,
    Map<String, dynamic>? customFields,
    DateTime? lastActiveAt,
    int? totalTasksAssigned,
    int? totalTasksCompleted,
    int? totalProjectsAssigned,
    double? averageTaskCompletionTime,
    Map<String, dynamic>? activityStats,
    Map<String, bool>? permissions,
    Map<String, dynamic>? preferences,
    List<String>? specializations,
    Map<String, dynamic>? availability,
    int? collaborationScore,
    DateTime? lastCollaborationAt,
    List<String>? frequentCollaborators,
    Map<String, int>? skillRatings,
  }) {
    return TeamMemberModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      teamId: teamId ?? this.teamId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      leftAt: leftAt ?? this.leftAt,
      isActive: isActive ?? this.isActive,
      addedBy: addedBy ?? this.addedBy,
      removedBy: removedBy ?? this.removedBy,
      removalReason: removalReason ?? this.removalReason,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      title: title ?? this.title,
      department: department ?? this.department,
      customFields: customFields ?? this.customFields,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      totalTasksAssigned: totalTasksAssigned ?? this.totalTasksAssigned,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      totalProjectsAssigned: totalProjectsAssigned ?? this.totalProjectsAssigned,
      averageTaskCompletionTime: averageTaskCompletionTime ?? this.averageTaskCompletionTime,
      activityStats: activityStats ?? this.activityStats,
      permissions: permissions ?? this.permissions,
      preferences: preferences ?? this.preferences,
      specializations: specializations ?? this.specializations,
      availability: availability ?? this.availability,
      collaborationScore: collaborationScore ?? this.collaborationScore,
      lastCollaborationAt: lastCollaborationAt ?? this.lastCollaborationAt,
      frequentCollaborators: frequentCollaborators ?? this.frequentCollaborators,
      skillRatings: skillRatings ?? this.skillRatings,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'teamId': teamId,
      'role': role.value,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'leftAt': leftAt != null ? Timestamp.fromDate(leftAt!) : null,
      'isActive': isActive,
      'addedBy': addedBy,
      'removedBy': removedBy,
      'removalReason': removalReason,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'title': title,
      'department': department,
      'customFields': customFields,
      'lastActiveAt': lastActiveAt != null ? Timestamp.fromDate(lastActiveAt!) : null,
      'totalTasksAssigned': totalTasksAssigned,
      'totalTasksCompleted': totalTasksCompleted,
      'totalProjectsAssigned': totalProjectsAssigned,
      'averageTaskCompletionTime': averageTaskCompletionTime,
      'activityStats': activityStats,
      'permissions': permissions,
      'preferences': preferences,
      'specializations': specializations,
      'availability': availability,
      'collaborationScore': collaborationScore,
      'lastCollaborationAt': lastCollaborationAt != null ? Timestamp.fromDate(lastCollaborationAt!) : null,
      'frequentCollaborators': frequentCollaborators,
      'skillRatings': skillRatings,
    };
  }

  /// Create from JSON (Firestore document)
  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      teamId: json['teamId'] ?? '',
      role: TeamRole.fromString(json['role'] ?? 'member'),
      joinedAt: (json['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      leftAt: (json['leftAt'] as Timestamp?)?.toDate(),
      isActive: json['isActive'] ?? true,
      addedBy: json['addedBy'] ?? '',
      removedBy: json['removedBy'],
      removalReason: json['removalReason'],
      displayName: json['displayName'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      title: json['title'],
      department: json['department'],
      customFields: json['customFields']?.cast<String, dynamic>() ?? {},
      lastActiveAt: (json['lastActiveAt'] as Timestamp?)?.toDate(),
      totalTasksAssigned: json['totalTasksAssigned'] ?? 0,
      totalTasksCompleted: json['totalTasksCompleted'] ?? 0,
      totalProjectsAssigned: json['totalProjectsAssigned'] ?? 0,
      averageTaskCompletionTime: (json['averageTaskCompletionTime'] ?? 0.0).toDouble(),
      activityStats: json['activityStats']?.cast<String, dynamic>() ?? {},
      permissions: json['permissions']?.cast<String, bool>() ?? {},
      preferences: json['preferences']?.cast<String, dynamic>() ?? {},
      specializations: (json['specializations'] as List<dynamic>?)?.cast<String>() ?? [],
      availability: json['availability']?.cast<String, dynamic>() ?? {},
      collaborationScore: json['collaborationScore'] ?? 0,
      lastCollaborationAt: (json['lastCollaborationAt'] as Timestamp?)?.toDate(),
      frequentCollaborators: (json['frequentCollaborators'] as List<dynamic>?)?.cast<String>() ?? [],
      skillRatings: json['skillRatings']?.cast<String, int>() ?? {},
    );
  }

  /// Create a new team member with minimal required fields
  factory TeamMemberModel.create({
    required String userId,
    required String teamId,
    required String addedBy,
    TeamRole role = TeamRole.member,
    String? displayName,
    String? email,
    String? photoUrl,
    String? title,
    String? department,
    List<String>? specializations,
  }) {
    final now = DateTime.now();
    return TeamMemberModel(
      id: '', // Will be set by Firestore
      userId: userId,
      teamId: teamId,
      role: role,
      joinedAt: now,
      addedBy: addedBy,
      displayName: displayName,
      email: email,
      photoUrl: photoUrl,
      title: title,
      department: department,
      specializations: specializations ?? [],
      lastActiveAt: now,
      availability: {
        'isAvailable': true,
        'maxConcurrentTasks': 10,
        'workingHours': {
          'start': '09:00',
          'end': '17:00',
          'timezone': 'UTC',
        },
        'workingDays': ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
      },
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamMemberModel && 
           other.userId == userId && 
           other.teamId == teamId;
  }

  @override
  int get hashCode => Object.hash(userId, teamId);

  @override
  String toString() {
    return 'TeamMemberModel(userId: $userId, teamId: $teamId, role: ${role.displayName}, active: $isActive)';
  }
}
