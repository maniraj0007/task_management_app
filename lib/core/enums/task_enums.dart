/// Task-related enumerations for the multi-admin task management system
/// Defines status, priority, category, and other task classifications

/// Task status enumeration
/// Represents the current state of a task in the workflow
enum TaskStatus {
  /// Task is created but not started
  todo('todo', 'To Do', 0),
  
  /// Task is currently being worked on
  inProgress('in_progress', 'In Progress', 1),
  
  /// Task is completed but pending review/approval
  review('review', 'Under Review', 2),
  
  /// Task is completed and approved
  completed('completed', 'Completed', 3),
  
  /// Task is cancelled or abandoned
  cancelled('cancelled', 'Cancelled', -1);

  const TaskStatus(this.value, this.displayName, this.order);

  /// String value for database storage
  final String value;
  
  /// Human-readable display name
  final String displayName;
  
  /// Order for sorting (higher = more complete, -1 = cancelled)
  final int order;

  /// Get status from string value
  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TaskStatus.todo,
    );
  }

  /// Check if task is in progress
  bool get isInProgress => this == TaskStatus.inProgress;
  
  /// Check if task is completed
  bool get isCompleted => this == TaskStatus.completed;
  
  /// Check if task is cancelled
  bool get isCancelled => this == TaskStatus.cancelled;
  
  /// Check if task can be started
  bool get canStart => this == TaskStatus.todo;
  
  /// Check if task can be completed
  bool get canComplete => this == TaskStatus.inProgress || this == TaskStatus.review;
  
  /// Check if task can be cancelled
  bool get canCancel => this != TaskStatus.completed && this != TaskStatus.cancelled;
  
  /// Get next possible statuses
  List<TaskStatus> get nextStatuses {
    switch (this) {
      case TaskStatus.todo:
        return [TaskStatus.inProgress, TaskStatus.cancelled];
      case TaskStatus.inProgress:
        return [TaskStatus.review, TaskStatus.completed, TaskStatus.cancelled];
      case TaskStatus.review:
        return [TaskStatus.completed, TaskStatus.inProgress, TaskStatus.cancelled];
      case TaskStatus.completed:
        return [TaskStatus.inProgress]; // Can reopen if needed
      case TaskStatus.cancelled:
        return [TaskStatus.todo, TaskStatus.inProgress];
    }
  }

  /// Get status color hex
  String get colorHex {
    switch (this) {
      case TaskStatus.todo:
        return '#9E9E9E'; // Grey
      case TaskStatus.inProgress:
        return '#2196F3'; // Blue
      case TaskStatus.review:
        return '#FF9800'; // Orange
      case TaskStatus.completed:
        return '#4CAF50'; // Green
      case TaskStatus.cancelled:
        return '#F44336'; // Red
    }
  }

  /// Get status icon name
  String get iconName {
    switch (this) {
      case TaskStatus.todo:
        return 'radio_button_unchecked';
      case TaskStatus.inProgress:
        return 'play_circle_outline';
      case TaskStatus.review:
        return 'rate_review';
      case TaskStatus.completed:
        return 'check_circle';
      case TaskStatus.cancelled:
        return 'cancel';
    }
  }
}

/// Task priority enumeration
/// Represents the urgency/importance level of a task
enum TaskPriority {
  /// Low priority - can be done when time permits
  low('low', 'Low', 1),
  
  /// Medium priority - normal importance
  medium('medium', 'Medium', 2),
  
  /// High priority - important and should be done soon
  high('high', 'High', 3),
  
  /// Urgent priority - critical and needs immediate attention
  urgent('urgent', 'Urgent', 4);

  const TaskPriority(this.value, this.displayName, this.level);

  /// String value for database storage
  final String value;
  
  /// Human-readable display name
  final String displayName;
  
  /// Numeric level for comparison (higher = more urgent)
  final int level;

  /// Get priority from string value
  static TaskPriority fromString(String value) {
    return TaskPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => TaskPriority.medium,
    );
  }

  /// Check if this priority is higher than another
  bool isHigherThan(TaskPriority other) {
    return level > other.level;
  }

  /// Check if this priority is lower than another
  bool isLowerThan(TaskPriority other) {
    return level < other.level;
  }

  /// Get priority color hex
  String get colorHex {
    switch (this) {
      case TaskPriority.low:
        return '#4CAF50'; // Green
      case TaskPriority.medium:
        return '#FF9800'; // Orange
      case TaskPriority.high:
        return '#FF5722'; // Deep Orange
      case TaskPriority.urgent:
        return '#F44336'; // Red
    }
  }

  /// Get priority icon name
  String get iconName {
    switch (this) {
      case TaskPriority.low:
        return 'keyboard_arrow_down';
      case TaskPriority.medium:
        return 'remove';
      case TaskPriority.high:
        return 'keyboard_arrow_up';
      case TaskPriority.urgent:
        return 'priority_high';
    }
  }

  /// Get priority description
  String get description {
    switch (this) {
      case TaskPriority.low:
        return 'Can be done when time permits';
      case TaskPriority.medium:
        return 'Normal importance level';
      case TaskPriority.high:
        return 'Important and should be done soon';
      case TaskPriority.urgent:
        return 'Critical and needs immediate attention';
    }
  }
}

/// Task category enumeration
/// Represents the type/classification of a task
enum TaskCategory {
  /// Personal tasks - individual user tasks
  personal('personal', 'Personal Tasks', 'Tasks for individual productivity'),
  
  /// Team collaboration tasks - shared among team members
  teamCollaboration('team_collaboration', 'Team Collaboration', 'Shared tasks among team members'),
  
  /// Project management tasks - part of larger projects
  projectManagement('project_management', 'Project Management', 'Tasks within project scope');

  const TaskCategory(this.value, this.displayName, this.description);

  /// String value for database storage
  final String value;
  
  /// Human-readable display name
  final String displayName;
  
  /// Category description
  final String description;

  /// Get category from string value
  static TaskCategory fromString(String value) {
    return TaskCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => TaskCategory.personal,
    );
  }

  /// Check if category allows collaboration
  bool get allowsCollaboration {
    return this == TaskCategory.teamCollaboration || this == TaskCategory.projectManagement;
  }

  /// Check if category requires team membership
  bool get requiresTeamMembership {
    return this == TaskCategory.teamCollaboration || this == TaskCategory.projectManagement;
  }

  /// Get category color hex
  String get colorHex {
    switch (this) {
      case TaskCategory.personal:
        return '#00BCD4'; // Cyan
      case TaskCategory.teamCollaboration:
        return '#4CAF50'; // Green
      case TaskCategory.projectManagement:
        return '#9C27B0'; // Purple
    }
  }

  /// Get category icon name
  String get iconName {
    switch (this) {
      case TaskCategory.personal:
        return 'person';
      case TaskCategory.teamCollaboration:
        return 'group';
      case TaskCategory.projectManagement:
        return 'folder_open';
    }
  }
}

/// Task assignment type enumeration
/// Represents how a task is assigned
enum TaskAssignmentType {
  /// Task is self-assigned by the creator
  selfAssigned('self_assigned', 'Self Assigned'),
  
  /// Task is assigned by a manager/admin to someone else
  managerAssigned('manager_assigned', 'Manager Assigned'),
  
  /// Task is assigned to a team (multiple people)
  teamAssigned('team_assigned', 'Team Assigned'),
  
  /// Task is unassigned and available for pickup
  unassigned('unassigned', 'Unassigned');

  const TaskAssignmentType(this.value, this.displayName);

  /// String value for database storage
  final String value;
  
  /// Human-readable display name
  final String displayName;

  /// Get assignment type from string value
  static TaskAssignmentType fromString(String value) {
    return TaskAssignmentType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => TaskAssignmentType.unassigned,
    );
  }

  /// Check if assignment requires approval
  bool get requiresApproval {
    return this == TaskAssignmentType.managerAssigned;
  }

  /// Check if assignment allows self-pickup
  bool get allowsSelfPickup {
    return this == TaskAssignmentType.unassigned || this == TaskAssignmentType.teamAssigned;
  }
}

/// Task recurrence type enumeration
/// Represents how often a task repeats
enum TaskRecurrence {
  /// Task does not repeat
  none('none', 'No Recurrence'),
  
  /// Task repeats daily
  daily('daily', 'Daily'),
  
  /// Task repeats weekly
  weekly('weekly', 'Weekly'),
  
  /// Task repeats monthly
  monthly('monthly', 'Monthly'),
  
  /// Task repeats yearly
  yearly('yearly', 'Yearly'),
  
  /// Task has custom recurrence pattern
  custom('custom', 'Custom');

  const TaskRecurrence(this.value, this.displayName);

  /// String value for database storage
  final String value;
  
  /// Human-readable display name
  final String displayName;

  /// Get recurrence from string value
  static TaskRecurrence fromString(String value) {
    return TaskRecurrence.values.firstWhere(
      (recurrence) => recurrence.value == value,
      orElse: () => TaskRecurrence.none,
    );
  }

  /// Check if recurrence is active
  bool get isRecurring => this != TaskRecurrence.none;

  /// Get recurrence icon name
  String get iconName {
    switch (this) {
      case TaskRecurrence.none:
        return 'event';
      case TaskRecurrence.daily:
        return 'today';
      case TaskRecurrence.weekly:
        return 'date_range';
      case TaskRecurrence.monthly:
        return 'calendar_month';
      case TaskRecurrence.yearly:
        return 'calendar_today';
      case TaskRecurrence.custom:
        return 'schedule';
    }
  }
}

/// Task visibility enumeration
/// Represents who can see the task
enum TaskVisibility {
  /// Task is private to the creator
  private('private', 'Private'),
  
  /// Task is visible to team members
  team('team', 'Team'),
  
  /// Task is visible to project members
  project('project', 'Project'),
  
  /// Task is public to all organization members
  public('public', 'Public');

  const TaskVisibility(this.value, this.displayName);

  /// String value for database storage
  final String value;
  
  /// Human-readable display name
  final String displayName;

  /// Get visibility from string value
  static TaskVisibility fromString(String value) {
    return TaskVisibility.values.firstWhere(
      (visibility) => visibility.value == value,
      orElse: () => TaskVisibility.private,
    );
  }

  /// Check if visibility allows team access
  bool get allowsTeamAccess {
    return this == TaskVisibility.team || 
           this == TaskVisibility.project || 
           this == TaskVisibility.public;
  }

  /// Check if visibility allows project access
  bool get allowsProjectAccess {
    return this == TaskVisibility.project || this == TaskVisibility.public;
  }

  /// Check if visibility is public
  bool get isPublic => this == TaskVisibility.public;

  /// Get visibility icon name
  String get iconName {
    switch (this) {
      case TaskVisibility.private:
        return 'lock';
      case TaskVisibility.team:
        return 'group';
      case TaskVisibility.project:
        return 'folder_shared';
      case TaskVisibility.public:
        return 'public';
    }
  }
}

/// Task comment type enumeration
/// Represents the type of comment on a task
enum TaskCommentType {
  /// Regular comment from user
  comment('comment', 'Comment'),
  
  /// System-generated status update
  statusUpdate('status_update', 'Status Update'),
  
  /// Assignment change notification
  assignmentChange('assignment_change', 'Assignment Change'),
  
  /// Priority change notification
  priorityChange('priority_change', 'Priority Change'),
  
  /// Due date change notification
  dueDateChange('due_date_change', 'Due Date Change'),
  
  /// File attachment notification
  attachment('attachment', 'Attachment'),
  
  /// Task completion notification
  completion('completion', 'Completion');

  const TaskCommentType(this.value, this.displayName);

  /// String value for database storage
  final String value;
  
  /// Human-readable display name
  final String displayName;

  /// Get comment type from string value
  static TaskCommentType fromString(String value) {
    return TaskCommentType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => TaskCommentType.comment,
    );
  }

  /// Check if comment type is system-generated
  bool get isSystemGenerated {
    return this != TaskCommentType.comment && this != TaskCommentType.attachment;
  }

  /// Get comment type icon name
  String get iconName {
    switch (this) {
      case TaskCommentType.comment:
        return 'comment';
      case TaskCommentType.statusUpdate:
        return 'update';
      case TaskCommentType.assignmentChange:
        return 'person_add';
      case TaskCommentType.priorityChange:
        return 'priority_high';
      case TaskCommentType.dueDateChange:
        return 'schedule';
      case TaskCommentType.attachment:
        return 'attach_file';
      case TaskCommentType.completion:
        return 'check_circle';
    }
  }
}
