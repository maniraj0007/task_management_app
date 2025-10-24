/// Application route names and paths
/// Centralized route management for the entire application
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();
  
  // ==================== AUTHENTICATION ROUTES ====================
  
  /// Initial route - splash screen
  static const String initial = '/';
  
  /// Onboarding flow
  static const String onboarding = '/onboarding';
  
  /// Login screen
  static const String login = '/login';
  
  /// Register screen
  static const String register = '/register';
  
  /// Forgot password screen
  static const String forgotPassword = '/forgot-password';
  
  /// Email verification screen
  static const String emailVerification = '/email-verification';
  
  // ==================== MAIN APP ROUTES ====================
  
  /// Main navigation screen with bottom navigation
  static const String mainNavigation = '/main';
  
  /// Main dashboard/home screen
  static const String dashboard = '/dashboard';
  
  /// User profile screen
  static const String profile = '/profile';
  
  /// Settings screen
  static const String settings = '/settings';
  
  /// Notifications screen
  static const String notifications = '/notifications';
  
  // ==================== TASK MANAGEMENT ROUTES ====================
  
  /// Tasks list screen
  static const String tasks = '/tasks';
  
  /// Create new task screen
  static const String createTask = '/tasks/create';
  
  /// Edit task screen (requires task ID parameter)
  static const String editTask = '/tasks/edit';
  
  /// Task details screen (requires task ID parameter)
  static const String taskDetails = '/tasks/details';
  
  /// Personal tasks screen
  static const String personalTasks = '/tasks/personal';
  
  /// Team tasks screen
  static const String teamTasks = '/tasks/team';
  
  /// Project tasks screen
  static const String projectTasks = '/tasks/project';
  
  // ==================== TEAM MANAGEMENT ROUTES ====================
  
  /// Teams list screen
  static const String teams = '/teams';
  
  /// Create new team screen
  static const String createTeam = '/teams/create';
  
  /// Edit team screen (requires team ID parameter)
  static const String editTeam = '/teams/edit';
  
  /// Team details screen (requires team ID parameter)
  static const String teamDetails = '/teams/details';
  
  /// Team members screen (requires team ID parameter)
  static const String teamMembers = '/teams/members';
  
  /// Join team screen
  static const String joinTeam = '/teams/join';
  
  // ==================== PROJECT MANAGEMENT ROUTES ====================
  
  /// Projects list screen
  static const String projects = '/projects';
  
  /// Create new project screen
  static const String createProject = '/projects/create';
  
  /// Edit project screen (requires project ID parameter)
  static const String editProject = '/projects/edit';
  
  /// Project details screen (requires project ID parameter)
  static const String projectDetails = '/projects/details';
  
  /// Project timeline/Gantt chart screen
  static const String projectTimeline = '/projects/timeline';
  
  /// Project milestones screen
  static const String projectMilestones = '/projects/milestones';
  
  // ==================== ADMIN ROUTES ====================
  
  /// Admin dashboard
  static const String adminDashboard = '/admin';
  
  /// User management screen (Super Admin only)
  static const String userManagement = '/admin/users';
  
  /// Role management screen (Super Admin only)
  static const String roleManagement = '/admin/roles';
  
  /// System settings screen (Super Admin only)
  static const String systemSettings = '/admin/system-settings';
  
  /// Analytics dashboard
  static const String analytics = '/admin/analytics';
  
  /// Audit logs screen
  static const String auditLogs = '/admin/audit-logs';
  
  /// Reports screen
  static const String reports = '/admin/reports';
  
  // ==================== SETTINGS ROUTES ====================
  
  /// Account settings
  static const String accountSettings = '/settings/account';
  
  /// Privacy settings
  static const String privacySettings = '/settings/privacy';
  
  /// Notification settings
  static const String notificationSettings = '/settings/notifications';
  
  /// Theme settings
  static const String themeSettings = '/settings/theme';
  
  /// Language settings
  static const String languageSettings = '/settings/language';
  
  /// Security settings
  static const String securitySettings = '/settings/security';
  
  /// Change password screen
  static const String changePassword = '/settings/change-password';
  
  // ==================== UTILITY ROUTES ====================
  
  /// Search screen
  static const String search = '/search';
  
  /// Help & Support screen
  static const String help = '/help';
  
  /// About app screen
  static const String about = '/about';
  
  /// Terms of service screen
  static const String termsOfService = '/terms';
  
  /// Privacy policy screen
  static const String privacyPolicy = '/privacy-policy';
  
  // ==================== ERROR ROUTES ====================
  
  /// 404 Not Found screen
  static const String notFound = '/404';
  
  /// Unauthorized access screen
  static const String unauthorized = '/unauthorized';
  
  /// No internet connection screen
  static const String noInternet = '/no-internet';
  
  // ==================== HELPER METHODS ====================
  
  /// Get route with parameters
  static String getRouteWithId(String route, String id) {
    return '$route/$id';
  }
  
  /// Get task details route with ID
  static String getTaskDetailsRoute(String taskId) {
    return '$taskDetails/$taskId';
  }
  
  /// Get edit task route with ID
  static String getEditTaskRoute(String taskId) {
    return '$editTask/$taskId';
  }
  
  /// Get team details route with ID
  static String getTeamDetailsRoute(String teamId) {
    return '$teamDetails/$teamId';
  }
  
  /// Get edit team route with ID
  static String getEditTeamRoute(String teamId) {
    return '$editTeam/$teamId';
  }
  
  /// Get team members route with ID
  static String getTeamMembersRoute(String teamId) {
    return '$teamMembers/$teamId';
  }
  
  /// Get project details route with ID
  static String getProjectDetailsRoute(String projectId) {
    return '$projectDetails/$projectId';
  }
  
  /// Get edit project route with ID
  static String getEditProjectRoute(String projectId) {
    return '$editProject/$projectId';
  }
  
  /// Get project timeline route with ID
  static String getProjectTimelineRoute(String projectId) {
    return '$projectTimeline/$projectId';
  }
  
  /// Get project milestones route with ID
  static String getProjectMilestonesRoute(String projectId) {
    return '$projectMilestones/$projectId';
  }
  
  /// Check if route requires authentication
  static bool requiresAuth(String route) {
    const publicRoutes = [
      initial,
      onboarding,
      login,
      register,
      forgotPassword,
      emailVerification,
      termsOfService,
      privacyPolicy,
      noInternet,
    ];
    
    return !publicRoutes.contains(route);
  }
  
  /// Check if route requires admin privileges
  static bool requiresAdmin(String route) {
    return route.startsWith('/admin');
  }
  
  /// Check if route requires super admin privileges
  static bool requiresSuperAdmin(String route) {
    const superAdminRoutes = [
      userManagement,
      roleManagement,
      systemSettings,
      auditLogs,
    ];
    
    return superAdminRoutes.contains(route);
  }
  
  /// Get all routes list
  static List<String> get allRoutes => [
    // Authentication
    initial,
    onboarding,
    login,
    register,
    forgotPassword,
    emailVerification,
    
    // Main app
    dashboard,
    profile,
    settings,
    notifications,
    
    // Tasks
    tasks,
    createTask,
    editTask,
    taskDetails,
    personalTasks,
    teamTasks,
    projectTasks,
    
    // Teams
    teams,
    createTeam,
    editTeam,
    teamDetails,
    teamMembers,
    joinTeam,
    
    // Projects
    projects,
    createProject,
    editProject,
    projectDetails,
    projectTimeline,
    projectMilestones,
    
    // Admin
    adminDashboard,
    userManagement,
    roleManagement,
    systemSettings,
    analytics,
    auditLogs,
    reports,
    
    // Settings
    accountSettings,
    privacySettings,
    notificationSettings,
    themeSettings,
    languageSettings,
    securitySettings,
    changePassword,
    
    // Utility
    search,
    help,
    about,
    termsOfService,
    privacyPolicy,
    
    // Error
    notFound,
    unauthorized,
    noInternet,
  ];
}
