/// User role enumeration for multi-admin system
/// Defines the four-tier access control system
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
  
  /// Numeric level for permission comparison (higher = more permissions)
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

  /// Check if this role can perform admin actions
  bool get isAdmin => this == UserRole.superAdmin || this == UserRole.admin;

  /// Check if this role can perform super admin actions
  bool get isSuperAdmin => this == UserRole.superAdmin;

  /// Check if this role can create teams
  bool get canCreateTeams => isAdmin;

  /// Check if this role can delete teams
  bool get canDeleteTeams => isSuperAdmin;

  /// Check if this role can create projects
  bool get canCreateProjects => isAdmin;

  /// Check if this role can assign tasks to others
  bool get canAssignTasks => isAdmin || this == UserRole.teamMember;

  /// Check if this role can delete tasks
  bool get canDeleteTasks => isAdmin;

  /// Check if this role can view analytics
  bool get canViewAnalytics => isAdmin;

  /// Check if this role can manage system settings
  bool get canManageSystemSettings => isSuperAdmin;

  /// Get role color for UI display
  String get colorHex {
    switch (this) {
      case UserRole.superAdmin:
        return '#FF5722'; // Deep Orange
      case UserRole.admin:
        return '#2196F3'; // Blue
      case UserRole.teamMember:
        return '#4CAF50'; // Green
      case UserRole.viewer:
        return '#9E9E9E'; // Grey
    }
  }

  /// Get role icon for UI display
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
}
