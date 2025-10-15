/// Application-wide constants and configuration values
class AppConstants {
  // App Information
  static const String appName = 'TaskMaster Pro';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Multi-Admin Task Management App';
  
  // API Configuration
  static const String baseUrl = 'https://api.taskmaster.com';
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String tasksCollection = 'tasks';
  static const String teamsCollection = 'teams';
  static const String projectsCollection = 'projects';
  static const String notificationsCollection = 'notifications';
  static const String auditLogsCollection = 'audit_logs';
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String onboardingKey = 'onboarding_completed';
  
  // Performance Targets
  static const int updatePropagationTarget = 1500; // 1.5 seconds
  static const int offlineSyncRecoveryTarget = 3000; // 3 seconds
  static const int tasksPerPage = 20;
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  
  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxTaskTitleLength = 100;
  static const int maxTaskDescriptionLength = 1000;
  static const int maxTeamNameLength = 50;
  static const int maxProjectNameLength = 80;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Error Messages
  static const String networkError = 'Network connection failed';
  static const String serverError = 'Server error occurred';
  static const String authError = 'Authentication failed';
  static const String permissionError = 'Permission denied';
  static const String validationError = 'Validation failed';
  
  // Success Messages
  static const String taskCreated = 'Task created successfully';
  static const String taskUpdated = 'Task updated successfully';
  static const String taskDeleted = 'Task deleted successfully';
  static const String profileUpdated = 'Profile updated successfully';
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-ddTHH:mm:ss.SSSZ';
  
  // Regex Patterns
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';
  static const String passwordPattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]';
  
  // File Types
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'txt', 'xlsx', 'pptx'];
  
  // Notification Types
  static const String taskAssigned = 'task_assigned';
  static const String taskCompleted = 'task_completed';
  static const String taskOverdue = 'task_overdue';
  static const String teamInvitation = 'team_invitation';
  static const String projectUpdate = 'project_update';
  
  // User Roles
  static const String superAdminRole = 'super_admin';
  static const String adminRole = 'admin';
  static const String teamMemberRole = 'team_member';
  static const String viewerRole = 'viewer';
  
  // Task Categories
  static const String personalCategory = 'personal';
  static const String teamCollaborationCategory = 'team_collaboration';
  static const String projectManagementCategory = 'project_management';
  
  // Task Status
  static const String todoStatus = 'todo';
  static const String inProgressStatus = 'in_progress';
  static const String reviewStatus = 'review';
  static const String completedStatus = 'completed';
  static const String cancelledStatus = 'cancelled';
  
  // Priority Levels
  static const String lowPriority = 'low';
  static const String mediumPriority = 'medium';
  static const String highPriority = 'high';
  static const String urgentPriority = 'urgent';
}
