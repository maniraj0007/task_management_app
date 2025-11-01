import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/enums/user_roles.dart';

/// User model for the multi-admin task management system
/// Represents a user with role-based permissions and profile information
class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final UserRole role;
  final bool isActive;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? customClaims;
  final List<String> teamIds;
  final List<String> projectIds;
  final UserPreferences preferences;
  final UserStats stats;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    required this.role,
    this.isActive = true,
    this.isEmailVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.customClaims,
    this.teamIds = const [],
    this.projectIds = const [],
    required this.preferences,
    required this.stats,
  });

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Get display name or full name
  String get name => displayName?.isNotEmpty == true ? displayName! : fullName;

  /// Get initials for avatar
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  /// Check if user has a specific permission
  bool hasPermission(String permission) {
    switch (permission) {
      case 'create_tasks':
        return role.canCreateTasks;
      case 'edit_tasks':
        return role.canEditTasks;
      case 'delete_tasks':
        return role.canDeleteTasks;
      case 'manage_teams':
        return role.canManageTeams;
      case 'manage_projects':
        return role.canManageProjects;
      case 'access_admin':
        return role.canAccessAdmin;
      case 'access_super_admin':
        return role.canAccessSuperAdmin;
      case 'view_analytics':
        return role.canViewAnalytics;
      case 'access_audit_logs':
        return role.canAccessAuditLogs;
      case 'modify_system_settings':
        return role.canModifySystemSettings;
      default:
        return false;
    }
  }

  /// Check if user can manage another user
  bool canManageUser(UserModel otherUser) {
    return role.canManage(otherUser.role);
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    UserRole? role,
    bool? isActive,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? customClaims,
    List<String>? teamIds,
    List<String>? projectIds,
    UserPreferences? preferences,
    UserStats? stats,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      customClaims: customClaims ?? this.customClaims,
      teamIds: teamIds ?? this.teamIds,
      projectIds: projectIds ?? this.projectIds,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'role': role.value,
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'customClaims': customClaims,
      'teamIds': teamIds,
      'projectIds': projectIds,
      'preferences': preferences.toJson(),
      'stats': stats.toJson(),
    };
  }

  /// Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }
    return UserModel.fromJson({...data, 'id': doc.id});
  }

  /// Create from JSON (Firestore document)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      phoneNumber: json['phoneNumber'],
      role: UserRole.fromString(json['role'] ?? 'viewer'),
      isActive: json['isActive'] ?? true,
      isEmailVerified: json['isEmailVerified'] ?? false,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (json['lastLoginAt'] as Timestamp?)?.toDate(),
      customClaims: json['customClaims']?.cast<String, dynamic>(),
      teamIds: (json['teamIds'] as List<dynamic>?)?.cast<String>() ?? [],
      projectIds: (json['projectIds'] as List<dynamic>?)?.cast<String>() ?? [],
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      stats: UserStats.fromJson(json['stats'] ?? {}),
    );
  }

  /// Create from Map with document ID (for Firestore queries)
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel.fromJson({...data, 'id': documentId});
  }

  /// Create from Firebase Auth User
  factory UserModel.fromFirebaseUser({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    bool isEmailVerified = false,
    UserRole role = UserRole.teamMember,
  }) {
    final names = _parseDisplayName(displayName ?? '');
    final now = DateTime.now();
    
    return UserModel(
      id: uid,
      email: email,
      firstName: names['firstName'] ?? '',
      lastName: names['lastName'] ?? '',
      displayName: displayName,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
      role: role,
      isActive: true,
      isEmailVerified: isEmailVerified,
      createdAt: now,
      updatedAt: now,
      lastLoginAt: now,
      preferences: UserPreferences.defaultPreferences(),
      stats: UserStats.empty(),
    );
  }

  /// Parse display name into first and last name
  static Map<String, String> _parseDisplayName(String displayName) {
    if (displayName.isEmpty) {
      return {'firstName': '', 'lastName': ''};
    }
    
    final parts = displayName.trim().split(' ');
    if (parts.length == 1) {
      return {'firstName': parts[0], 'lastName': ''};
    }
    
    return {
      'firstName': parts.first,
      'lastName': parts.skip(1).join(' '),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, role: ${role.displayName})';
  }
}

/// User preferences for personalization
class UserPreferences {
  final String theme; // 'light', 'dark', 'system'
  final String language; // 'en', 'es', etc.
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final String dateFormat;
  final String timeFormat;
  final String timezone;
  final Map<String, dynamic> dashboardLayout;

  const UserPreferences({
    this.theme = 'system',
    this.language = 'en',
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.dateFormat = 'dd/MM/yyyy',
    this.timeFormat = 'HH:mm',
    this.timezone = 'UTC',
    this.dashboardLayout = const {},
  });

  /// Default preferences for new users
  factory UserPreferences.defaultPreferences() {
    return const UserPreferences();
  }

  /// Create copy with updated fields
  UserPreferences copyWith({
    String? theme,
    String? language,
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    String? dateFormat,
    String? timeFormat,
    String? timezone,
    Map<String, dynamic>? dashboardLayout,
  }) {
    return UserPreferences(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      timezone: timezone ?? this.timezone,
      dashboardLayout: dashboardLayout ?? this.dashboardLayout,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'dateFormat': dateFormat,
      'timeFormat': timeFormat,
      'timezone': timezone,
      'dashboardLayout': dashboardLayout,
    };
  }

  /// Create from JSON
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      theme: json['theme'] ?? 'system',
      language: json['language'] ?? 'en',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      emailNotifications: json['emailNotifications'] ?? true,
      pushNotifications: json['pushNotifications'] ?? true,
      dateFormat: json['dateFormat'] ?? 'dd/MM/yyyy',
      timeFormat: json['timeFormat'] ?? 'HH:mm',
      timezone: json['timezone'] ?? 'UTC',
      dashboardLayout: json['dashboardLayout']?.cast<String, dynamic>() ?? {},
    );
  }
}

/// User statistics for analytics and gamification
class UserStats {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int overdueTasks;
  final int teamsJoined;
  final int projectsJoined;
  final double completionRate;
  final int streakDays;
  final DateTime? lastActivityAt;
  final Map<String, int> tasksByCategory;
  final Map<String, int> tasksByPriority;

  const UserStats({
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.pendingTasks = 0,
    this.overdueTasks = 0,
    this.teamsJoined = 0,
    this.projectsJoined = 0,
    this.completionRate = 0.0,
    this.streakDays = 0,
    this.lastActivityAt,
    this.tasksByCategory = const {},
    this.tasksByPriority = const {},
  });

  /// Empty stats for new users
  factory UserStats.empty() {
    return const UserStats();
  }

  /// Create copy with updated fields
  UserStats copyWith({
    int? totalTasks,
    int? completedTasks,
    int? pendingTasks,
    int? overdueTasks,
    int? teamsJoined,
    int? projectsJoined,
    double? completionRate,
    int? streakDays,
    DateTime? lastActivityAt,
    Map<String, int>? tasksByCategory,
    Map<String, int>? tasksByPriority,
  }) {
    return UserStats(
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      pendingTasks: pendingTasks ?? this.pendingTasks,
      overdueTasks: overdueTasks ?? this.overdueTasks,
      teamsJoined: teamsJoined ?? this.teamsJoined,
      projectsJoined: projectsJoined ?? this.projectsJoined,
      completionRate: completionRate ?? this.completionRate,
      streakDays: streakDays ?? this.streakDays,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      tasksByCategory: tasksByCategory ?? this.tasksByCategory,
      tasksByPriority: tasksByPriority ?? this.tasksByPriority,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'pendingTasks': pendingTasks,
      'overdueTasks': overdueTasks,
      'teamsJoined': teamsJoined,
      'projectsJoined': projectsJoined,
      'completionRate': completionRate,
      'streakDays': streakDays,
      'lastActivityAt': lastActivityAt != null ? Timestamp.fromDate(lastActivityAt!) : null,
      'tasksByCategory': tasksByCategory,
      'tasksByPriority': tasksByPriority,
    };
  }

  /// Create from JSON
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalTasks: json['totalTasks'] ?? 0,
      completedTasks: json['completedTasks'] ?? 0,
      pendingTasks: json['pendingTasks'] ?? 0,
      overdueTasks: json['overdueTasks'] ?? 0,
      teamsJoined: json['teamsJoined'] ?? 0,
      projectsJoined: json['projectsJoined'] ?? 0,
      completionRate: (json['completionRate'] ?? 0.0).toDouble(),
      streakDays: json['streakDays'] ?? 0,
      lastActivityAt: (json['lastActivityAt'] as Timestamp?)?.toDate(),
      tasksByCategory: json['tasksByCategory']?.cast<String, int>() ?? {},
      tasksByPriority: json['tasksByPriority']?.cast<String, int>() ?? {},
    );
  }
}
