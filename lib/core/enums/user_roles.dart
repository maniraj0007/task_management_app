/// User role enumeration for multi-admin task management system
/// Defines the hierarchy and permissions for different user types
enum UserRole {
  /// Super Admin - Full system control
  /// - Manage all users and roles (create/edit/delete)
  /// - Configure app-wide settings (themes, categories)
  /// - Access analytics & audit logs
  /// - Add/remove Admins
  /// - Approve/revoke project access
  /// - View/edit all tasks
  superAdmin('super_admin', 'Super Admin', 4),
  
  /// Admin - Operational control (no system config)
  /// - Manage team members
  /// - Create/manage team & project tasks
  /// - Assign/reassign tasks
  /// - Approve task completions
  /// - Moderate comments & attachments
  /// - Cannot modify Super Admin settings
  admin('admin', 'Admin', 3),
  
  /// Team Member - Executes assigned tasks
  /// - Create/edit personal & assigned tasks
  /// - Comment or attach files
  /// - Update task status
  /// - View but not delete shared tasks
  /// - No access to admin settings
  teamMember('team_member', 'Team Member', 2),
  
  /// Viewer - Read-only access
  /// - View assigned/shared tasks only
  /// - Cannot modify or create tasks
  /// - Real-time updates only
  viewer('viewer', 'Viewer', 1);

  const UserRole(this.value, this.displayName, this.level);

  /// String value for database storage
  final String value;
  
  /// Human-readable display name
  final String displayName;
  
  /// Numeric level for hierarchy comparison (higher = more permissions)
  final int level;

  /// Get role from string value
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.viewer,
    );
  }

  /// Check if this role has higher or equal permissions than another role
  bool hasPermissionLevel(UserRole requiredRole) {
    return level >= requiredRole.level;
  }

  /// Check if this role can manage another role
  bool canManage(UserRole targetRole) {
    // Super Admin can manage all roles except other Super Admins
    if (this == UserRole.superAdmin && targetRole != UserRole.superAdmin) {
      return true;
    }
    
    // Admin can manage Team Members and Viewers
    if (this == UserRole.admin && 
        (targetRole == UserRole.teamMember || targetRole == UserRole.viewer)) {
      return true;
    }
    
    return false;
  }

  /// Get all roles that this role can manage
  List<UserRole> get managableRoles {
    switch (this) {
      case UserRole.superAdmin:
        return [UserRole.admin, UserRole.teamMember, UserRole.viewer];
      case UserRole.admin:
        return [UserRole.teamMember, UserRole.viewer];
      case UserRole.teamMember:
      case UserRole.viewer:
        return [];
    }
  }

  /// Check if this role can access admin features
  bool get canAccessAdmin {
    return this == UserRole.superAdmin || this == UserRole.admin;
  }

  /// Check if this role can access super admin features
  bool get canAccessSuperAdmin {
    return this == UserRole.superAdmin;
  }

  /// Check if this role can create tasks
  bool get canCreateTasks {
    return this != UserRole.viewer;
  }

  /// Check if this role can edit tasks
  bool get canEditTasks {
    return this != UserRole.viewer;
  }

  /// Check if this role can delete tasks
  bool get canDeleteTasks {
    return this == UserRole.superAdmin || this == UserRole.admin;
  }

  /// Check if this role can manage teams
  bool get canManageTeams {
    return this == UserRole.superAdmin || this == UserRole.admin;
  }

  /// Check if this role can manage projects
  bool get canManageProjects {
    return this == UserRole.superAdmin || this == UserRole.admin;
  }

  /// Check if this role can view analytics
  bool get canViewAnalytics {
    return this == UserRole.superAdmin || this == UserRole.admin;
  }

  /// Check if this role can access audit logs
  bool get canAccessAuditLogs {
    return this == UserRole.superAdmin;
  }

  /// Check if this role can modify system settings
  bool get canModifySystemSettings {
    return this == UserRole.superAdmin;
  }

  /// Get role color based on hierarchy
  String get colorHex {
    switch (this) {
      case UserRole.superAdmin:
        return '#9C27B0'; // Purple
      case UserRole.admin:
        return '#3F51B5'; // Indigo
      case UserRole.teamMember:
        return '#2196F3'; // Blue
      case UserRole.viewer:
        return '#607D8B'; // Blue Grey
    }
  }

  /// Get role icon based on type
  String get iconName {
    switch (this) {
      case UserRole.superAdmin:
        return 'admin_panel_settings';
      case UserRole.admin:
        return 'manage_accounts';
      case UserRole.teamMember:
        return 'person';
      case UserRole.viewer:
        return 'visibility';
    }
  }

  /// Get role description
  String get description {
    switch (this) {
      case UserRole.superAdmin:
        return 'Full system control with all administrative privileges';
      case UserRole.admin:
        return 'Operational control for team and project management';
      case UserRole.teamMember:
        return 'Can create and manage personal and assigned tasks';
      case UserRole.viewer:
        return 'Read-only access to assigned and shared tasks';
    }
  }

  /// Get all available roles for selection
  static List<UserRole> get selectableRoles => UserRole.values;

  /// Get roles that can be assigned by the current role
  static List<UserRole> getAssignableRoles(UserRole currentRole) {
    return currentRole.managableRoles;
  }
}
