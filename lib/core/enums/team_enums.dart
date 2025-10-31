/// Team-related enumerations for the multi-admin task management system
/// Defines team roles, project status, invitation status, and other team classifications

/// Team member role enumeration
/// Represents the role of a user within a team
enum TeamRole {
  /// Team owner with full control
  owner('owner', 'Owner', 5),
  
  /// Team admin with management permissions
  admin('admin', 'Admin', 4),
  
  /// Team manager with limited admin permissions
  manager('manager', 'Manager', 3),
  
  /// Regular team member
  member('member', 'Member', 2),
  
  /// Guest with limited access
  guest('guest', 'Guest', 1);

  const TeamRole(this.value, this.displayName, this.level);

  /// String value for database storage
  final String value;
  
  /// Human-readable display name
  final String displayName;
  
  /// Numeric level for hierarchy (higher = more permissions)
  final int level;

  /// Get role from string value
  static TeamRole fromString(String value) {
    return TeamRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => TeamRole.member,
    );
  }

  /// Check if this role has higher permissions than another
  bool isHigherThan(TeamRole other) {
    return level > other.level;
  }

  /// Check if this role has lower permissions than another
  bool isLowerThan(TeamRole other) {
    return level < other.level;
  }

  /// Check if role can manage team settings
  bool get canManageTeam {
    return this == TeamRole.owner || this == TeamRole.admin;
  }

  /// Check if role can manage members
  bool get canManageMembers {
    return level >= TeamRole.manager.level;
  }

  /// Check if role can create projects
  bool get canCreateProjects {
    return level >= TeamRole.manager.level;
  }

  /// Check if role can assign tasks
  bool get canAssignTasks {
    return level >= TeamRole.manager.level;
  }

  /// Check if role can view team analytics
  bool get canViewAnalytics {
    return level >= TeamRole.manager.level;
  }

  /// Get role color hex
  String get colorHex {
    switch (this) {
      case TeamRole.owner:
        return '#9C27B0'; // Purple
      case TeamRole.admin:
        return '#3F51B5'; // Indigo
      case TeamRole.manager:
        return '#2196F3'; // Blue
      case TeamRole.member:
        return '#4CAF50'; // Green
      case TeamRole.guest:
        return '#607D8B'; // Blue Grey
    }
  }

  /// Get role icon name
  String get iconName {
    switch (this) {
      case TeamRole.owner:
        return 'crown';
      case TeamRole.admin:
        return 'admin_panel_settings';
      case TeamRole.manager:
        return 'manage_accounts';
      case TeamRole.member:
        return 'person';
      case TeamRole.guest:
        return 'person_outline';
    }
  }

  /// Get role description
  String get description {
    switch (this) {
      case TeamRole.owner:
        return 'Full control over team settings, members, and projects';
      case TeamRole.admin:
        return 'Manage team settings, members, and all projects';
      case TeamRole.manager:
        return 'Manage team members and assigned projects';
      case TeamRole.member:
        return 'Participate in team projects and tasks';
      case TeamRole.guest:
        return 'Limited access to specific projects only';
    }
  }
}

/// Project status enumeration
/// Represents the current state of a project
enum ProjectStatus {
  /// Project is being planned
  planning('planning', 'Planning', 0),
  
  /// Project is active and in progress
  active('active', 'Active', 1),
  
  /// Project is on hold
  onHold('on_hold', 'On Hold', 2),
  
  /// Project is completed
  completed('completed', 'Completed', 3),
  
  /// Project is cancelled
  cancelled('cancelled', 'Cancelled', -1),
  
  /// Project is archived
  archived('archived', 'Archived', -2);

  const ProjectStatus(this.value, this.displayName, this.order);

  /// String value for database storage
  final String value;
  
  /// Human-readable display name
  final String displayName;
  
  /// Order for sorting (higher = more active, negative = inactive)
  final int order;

  /// Get status from string value
  static ProjectStatus fromString(String value) {
    return ProjectStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ProjectStatus.planning,
    );
  }

  /// Check if project is active
  bool get isActive => this == ProjectStatus.active;
  
  /// Check if project is completed
  bool get isCompleted => this == ProjectStatus.completed;
  
  /// Check if project is cancelled
  bool get isCancelled => this == ProjectStatus.cancelled;
  
  /// Check if project is archived
  bool get isArchived => this == ProjectStatus.archived;
  
  /// Check if project is inactive
  bool get isInactive => order < 0;
  
  /// Check if project can be worked on
  bool get canWork => this == ProjectStatus.active || this == ProjectStatus.planning;

  /// Get next possible statuses
  List<ProjectStatus> get nextStatuses {
    switch (this) {
      case ProjectStatus.planning:
        return [ProjectStatus.active, ProjectStatus.onHold, ProjectStatus.cancelled];
      case ProjectStatus.active:
        return [ProjectStatus.onHold, ProjectStatus.completed, ProjectStatus.cancelled];
      case ProjectStatus.onHold:
        return [ProjectStatus.active, ProjectStatus.cancelled];
      case ProjectStatus.completed:
        return [ProjectStatus.archived];
      case ProjectStatus.cancelled:
        return [ProjectStatus.planning, ProjectStatus.archived];
      case ProjectStatus.archived:
        return []; // Cannot change from archived
    }
  }

  /// Get status color hex
  String get colorHex {
    switch (this) {
      case ProjectStatus.planning:
        return '#FF9800'; // Orange
      case ProjectStatus.active:
        return '#4CAF50'; // Green
      case ProjectStatus.onHold:
        return '#FFC107'; // Amber
      case ProjectStatus.completed:
        return '#2196F3'; // Blue
      case ProjectStatus.cancelled:
        return '#F44336'; // Red
      case ProjectStatus.archived:
        return '#9E9E9E'; // Grey
    }
  }

  /// Get status icon name
  String get iconName {
    switch (this) {
      case ProjectStatus.planning:
        return 'schedule';
      case ProjectStatus.active:
        return 'play_circle';
      case ProjectStatus.onHold:
        return 'pause_circle';
      case ProjectStatus.completed:
        return 'check_circle';
      case ProjectStatus.cancelled:
        return 'cancel';
      case ProjectStatus.archived:
        return 'archive';
    }
  }
}

/// Team invitation status enumeration
/// Represents the status of a team invitation
enum InvitationStatus {
  /// Invitation is pending response
  pending('pending', 'Pending'),
  
  /// Invitation was accepted
  accepted('accepted', 'Accepted'),
  
  /// Invitation was declined
  declined('declined', 'Declined'),
  
  /// Invitation was cancelled by sender
  cancelled('cancelled', 'Cancelled'),
  
  /// Invitation has expired
  expired('expired', 'Expired');

  const InvitationStatus(this.value, this.displayName);

  /// String value for database storage
  final String value;
  
  /// Human-readable display name
  final String displayName;

  /// Get status from string value
  static InvitationStatus fromString(String value) {
    return InvitationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => InvitationStatus.pending,
    );
  }

  /// Check if invitation is still active
  bool get isActive => this == InvitationStatus.pending;
  
  /// Check if invitation was accepted
  bool get isAccepted => this == InvitationStatus.accepted;
  
  /// Check if invitation was declined
  bool get isDeclined => this == InvitationStatus.declined;
  
  /// Check if invitation is finished (cannot be changed)
  bool get isFinished => this != InvitationStatus.pending;

  /// Get status color hex
  String get colorHex {
    switch (this) {
      case InvitationStatus.pending:
        return '#FF9800'; // Orange
      case InvitationStatus.accepted:
        return '#4CAF50'; // Green
      case InvitationStatus.declined:
        return '#F44336'; // Red
      case InvitationStatus.cancelled:
        return '#9E9E9E'; // Grey
      case InvitationStatus.expired:
        return '#795548'; // Brown
    }
  }

  /// Get status icon name
  String get iconName {
    switch (this) {
      case InvitationStatus.pending:
        return 'schedule';
      case InvitationStatus.accepted:
        return 'check_circle';
      case InvitationStatus.declined:
        return 'cancel';
      case InvitationStatus.cancelled:
        return 'block';
      case InvitationStatus.expired:
        return 'access_time';
    }
  }
}

/// Project priority enumeration
/// Represents the priority level of a project
enum ProjectPriority {
  /// Low priority project
  low('low', 'Low', 1),
  
  /// Medium priority project
  medium('medium', 'Medium', 2),
  
  /// High priority project
  high('high', 'High', 3),
  
  /// Critical priority project
  critical('critical', 'Critical', 4);

  const ProjectPriority(this.value, this.displayName, this.level);

  /// String value for database storage
  final String value;
  
  /// Human-readable display name
  final String displayName;
  
  /// Numeric level for comparison (higher = more urgent)
  final int level;

  /// Get priority from string value
  static ProjectPriority fromString(String value) {
    return ProjectPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => ProjectPriority.medium,
    );
  }

  /// Check if this priority is higher than another
  bool isHigherThan(ProjectPriority other) {
    return level > other.level;
  }

  /// Check if this priority is lower than another
  bool isLowerThan(ProjectPriority other) {
    return level < other.level;
  }

  /// Get priority color hex
  String get colorHex {
    switch (this) {
      case ProjectPriority.low:
        return '#4CAF50'; // Green
      case ProjectPriority.medium:
        return '#FF9800'; // Orange
      case ProjectPriority.high:
        return '#FF5722'; // Deep Orange
      case ProjectPriority.critical:
        return '#F44336'; // Red
    }
  }

  /// Get priority icon name
  String get iconName {
    switch (this) {
      case ProjectPriority.low:
        return 'keyboard_arrow_down';
      case ProjectPriority.medium:
        return 'remove';
      case ProjectPriority.high:
        return 'keyboard_arrow_up';
      case ProjectPriority.critical:
        return 'priority_high';
    }
  }

  /// Get priority description
  String get description {
    switch (this) {
      case ProjectPriority.low:
        return 'Can be completed when resources are available';
      case ProjectPriority.medium:
        return 'Standard priority level';
      case ProjectPriority.high:
        return 'Important project that should be prioritized';
      case ProjectPriority.critical:
        return 'Critical project requiring immediate attention';
    }
  }
}

/// Team visibility enumeration
/// Represents who can see and join the team
enum TeamVisibility {
  /// Team is private and invite-only
  private('private', 'Private'),
  
  /// Team is visible to organization members
  internal('internal', 'Internal'),
  
  /// Team is public and anyone can request to join
  public('public', 'Public');

  const TeamVisibility(this.value, this.displayName);

  /// String value for database storage
  final String value;
  
  /// Human-readable display name
  final String displayName;

  /// Get visibility from string value
  static TeamVisibility fromString(String value) {
    return TeamVisibility.values.firstWhere(
      (visibility) => visibility.value == value,
      orElse: () => TeamVisibility.private,
    );
  }

  /// Check if team is private
  bool get isPrivate => this == TeamVisibility.private;
  
  /// Check if team is internal
  bool get isInternal => this == TeamVisibility.internal;
  
  /// Check if team is public
  bool get isPublic => this == TeamVisibility.public;
  
  /// Check if team allows join requests
  bool get allowsJoinRequests => this == TeamVisibility.public;

  /// Get visibility icon name
  String get iconName {
    switch (this) {
      case TeamVisibility.private:
        return 'lock';
      case TeamVisibility.internal:
        return 'business';
      case TeamVisibility.public:
        return 'public';
    }
  }

  /// Get visibility description
  String get description {
    switch (this) {
      case TeamVisibility.private:
        return 'Only invited members can see and join this team';
      case TeamVisibility.internal:
        return 'All organization members can see this team';
      case TeamVisibility.public:
        return 'Anyone can see and request to join this team';
    }
  }
}

/// Project type enumeration
/// Represents the type/category of a project
enum ProjectType {
  /// General project type
  general('general', 'General'),
  
  /// Software development project
  development('development', 'Development'),
  
  /// Marketing campaign project
  marketing('marketing', 'Marketing'),
  
  /// Research project
  research('research', 'Research'),
  
  /// Design project
  design('design', 'Design'),
  
  /// Operations project
  operations('operations', 'Operations'),
  
  /// Training project
  training('training', 'Training'),
  
  /// Event planning project
  event('event', 'Event'),
  
  /// Custom project type
  custom('custom', 'Custom');

  const ProjectType(this.value, this.displayName);

  /// String value for database storage
  final String value;
  
  /// Human-readable display name
  final String displayName;

  /// Get type from string value
  static ProjectType fromString(String value) {
    return ProjectType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ProjectType.general,
    );
  }

  /// Get type color hex
  String get colorHex {
    switch (this) {
      case ProjectType.general:
        return '#607D8B'; // Blue Grey
      case ProjectType.development:
        return '#2196F3'; // Blue
      case ProjectType.marketing:
        return '#E91E63'; // Pink
      case ProjectType.research:
        return '#9C27B0'; // Purple
      case ProjectType.design:
        return '#FF5722'; // Deep Orange
      case ProjectType.operations:
        return '#795548'; // Brown
      case ProjectType.training:
        return '#4CAF50'; // Green
      case ProjectType.event:
        return '#FF9800'; // Orange
      case ProjectType.custom:
        return '#9E9E9E'; // Grey
    }
  }

  /// Get type icon name
  String get iconName {
    switch (this) {
      case ProjectType.general:
        return 'folder';
      case ProjectType.development:
        return 'code';
      case ProjectType.marketing:
        return 'campaign';
      case ProjectType.research:
        return 'science';
      case ProjectType.design:
        return 'palette';
      case ProjectType.operations:
        return 'settings';
      case ProjectType.training:
        return 'school';
      case ProjectType.event:
        return 'event';
      case ProjectType.custom:
        return 'extension';
    }
  }
}
