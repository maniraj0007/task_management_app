import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/services/error_handler_service.dart';
import '../../auth/services/auth_service.dart';
import '../models/analytics_data_model.dart';

/// Analytics Service
/// Handles analytics data collection, processing, and dashboard metrics
class AnalyticsService extends GetxService {
  static AnalyticsService get instance => Get.find<AnalyticsService>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  // Collections
  late final CollectionReference _analyticsCollection;
  late final CollectionReference _tasksCollection;
  late final CollectionReference _usersCollection;
  late final CollectionReference _teamsCollection;
  late final CollectionReference _projectsCollection;

  // Reactive state
  final Rx<DashboardMetricsModel?> _dashboardMetrics = Rx<DashboardMetricsModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _selectedTimeRange = '7d'.obs; // 1d, 7d, 30d, 90d, 1y

  // Getters
  DashboardMetricsModel? get dashboardMetrics => _dashboardMetrics.value;
  bool get isLoading => _isLoading.value;
  String get selectedTimeRange => _selectedTimeRange.value;

  @override
  void onInit() {
    super.onInit();
    _initializeCollections();
    _loadDashboardMetrics();
  }

  /// Initialize Firestore collections
  void _initializeCollections() {
    _analyticsCollection = _firestore.collection('analytics');
    _tasksCollection = _firestore.collection('tasks');
    _usersCollection = _firestore.collection('users');
    _teamsCollection = _firestore.collection('teams');
    _projectsCollection = _firestore.collection('projects');
  }

  // ==================== DASHBOARD METRICS ====================

  /// Load dashboard metrics
  Future<void> _loadDashboardMetrics() async {
    try {
      _isLoading.value = true;

      final taskMetrics = await _calculateTaskMetrics();
      final userMetrics = await _calculateUserMetrics();
      final teamMetrics = await _calculateTeamMetrics();
      final projectMetrics = await _calculateProjectMetrics();
      final systemMetrics = await _calculateSystemMetrics();

      _dashboardMetrics.value = DashboardMetricsModel(
        taskMetrics: taskMetrics,
        userMetrics: userMetrics,
        teamMetrics: teamMetrics,
        projectMetrics: projectMetrics,
        systemMetrics: systemMetrics,
      );

    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Load Dashboard Metrics',
        severity: ErrorSeverity.medium,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Refresh dashboard metrics
  Future<void> refreshDashboardMetrics() async {
    await _loadDashboardMetrics();
  }

  /// Set time range for analytics
  void setTimeRange(String timeRange) {
    _selectedTimeRange.value = timeRange;
    _loadDashboardMetrics();
  }

  // ==================== TASK METRICS CALCULATION ====================

  /// Calculate task metrics
  Future<TaskMetrics> _calculateTaskMetrics() async {
    try {
      final dateRange = _getDateRange();
      
      // Get tasks within date range
      final tasksQuery = await _tasksCollection
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end))
          .get();

      final tasks = tasksQuery.docs;
      final totalTasks = tasks.length;
      
      // Calculate task statistics
      int completedTasks = 0;
      int pendingTasks = 0;
      int overdueTasks = 0;
      double totalCompletionTime = 0;
      int completedWithTime = 0;
      
      final tasksByPriority = <String, int>{
        'low': 0,
        'medium': 0,
        'high': 0,
        'urgent': 0,
      };
      
      final tasksByStatus = <String, int>{
        'todo': 0,
        'in_progress': 0,
        'completed': 0,
        'cancelled': 0,
      };

      for (final taskDoc in tasks) {
        final taskData = taskDoc.data() as Map<String, dynamic>;
        final status = taskData['status'] ?? 'todo';
        final priority = taskData['priority'] ?? 'medium';
        final dueDate = (taskData['dueDate'] as Timestamp?)?.toDate();
        final completedAt = (taskData['completedAt'] as Timestamp?)?.toDate();
        final createdAt = (taskData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

        // Count by status
        tasksByStatus[status] = (tasksByStatus[status] ?? 0) + 1;
        
        // Count by priority
        tasksByPriority[priority] = (tasksByPriority[priority] ?? 0) + 1;

        // Calculate completion metrics
        if (status == 'completed') {
          completedTasks++;
          if (completedAt != null) {
            final completionTime = completedAt.difference(createdAt).inHours.toDouble();
            totalCompletionTime += completionTime;
            completedWithTime++;
          }
        } else {
          pendingTasks++;
          if (dueDate != null && dueDate.isBefore(DateTime.now())) {
            overdueTasks++;
          }
        }
      }

      final completionRate = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;
      final averageCompletionTime = completedWithTime > 0 ? totalCompletionTime / completedWithTime : 0.0;

      // Generate completion trend
      final completionTrend = await _generateTaskCompletionTrend(dateRange);

      return TaskMetrics(
        totalTasks: totalTasks,
        completedTasks: completedTasks,
        pendingTasks: pendingTasks,
        overdueTasks: overdueTasks,
        completionRate: completionRate,
        averageCompletionTime: averageCompletionTime,
        completionTrend: completionTrend,
        tasksByPriority: tasksByPriority,
        tasksByStatus: tasksByStatus,
      );

    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Calculate Task Metrics',
        severity: ErrorSeverity.medium,
      );
      return _getEmptyTaskMetrics();
    }
  }

  /// Generate task completion trend
  Future<List<FlSpot>> _generateTaskCompletionTrend(DateTimeRange dateRange) async {
    try {
      final spots = <FlSpot>[];
      final days = dateRange.end.difference(dateRange.start).inDays;
      
      for (int i = 0; i <= days; i++) {
        final date = dateRange.start.add(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        
        final completedTasksQuery = await _tasksCollection
            .where('status', isEqualTo: 'completed')
            .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('completedAt', isLessThan: Timestamp.fromDate(endOfDay))
            .get();
        
        spots.add(FlSpot(i.toDouble(), completedTasksQuery.docs.length.toDouble()));
      }
      
      return spots;
    } catch (e) {
      return [];
    }
  }

  // ==================== USER METRICS CALCULATION ====================

  /// Calculate user metrics
  Future<UserMetrics> _calculateUserMetrics() async {
    try {
      final dateRange = _getDateRange();
      
      // Get all users
      final usersQuery = await _usersCollection.get();
      final users = usersQuery.docs;
      final totalUsers = users.length;
      
      // Calculate user statistics
      int activeUsers = 0;
      int newUsersThisMonth = 0;
      final usersByRole = <String, int>{
        'super_admin': 0,
        'admin': 0,
        'team_member': 0,
        'viewer': 0,
      };
      
      final userProductivity = <String, double>{};
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);

      for (final userDoc in users) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final role = userData['role'] ?? 'team_member';
        final lastLoginAt = (userData['lastLoginAt'] as Timestamp?)?.toDate();
        final createdAt = (userData['createdAt'] as Timestamp?)?.toDate();
        final isActive = userData['isActive'] ?? true;

        // Count by role
        usersByRole[role] = (usersByRole[role] ?? 0) + 1;

        // Count active users (logged in within last 7 days)
        if (isActive && lastLoginAt != null && 
            lastLoginAt.isAfter(now.subtract(const Duration(days: 7)))) {
          activeUsers++;
        }

        // Count new users this month
        if (createdAt != null && createdAt.isAfter(monthStart)) {
          newUsersThisMonth++;
        }

        // Calculate user productivity (tasks completed per day)
        final userTasksQuery = await _tasksCollection
            .where('assignedTo', isEqualTo: userDoc.id)
            .where('status', isEqualTo: 'completed')
            .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start))
            .get();
        
        final completedTasks = userTasksQuery.docs.length;
        final days = dateRange.end.difference(dateRange.start).inDays;
        final productivity = days > 0 ? completedTasks / days : 0.0;
        
        if (completedTasks > 0) {
          userProductivity[userDoc.id] = productivity;
        }
      }

      final userEngagementRate = totalUsers > 0 ? (activeUsers / totalUsers) * 100 : 0.0;
      
      // Generate user growth trend
      final userGrowthTrend = await _generateUserGrowthTrend(dateRange);

      return UserMetrics(
        totalUsers: totalUsers,
        activeUsers: activeUsers,
        newUsersThisMonth: newUsersThisMonth,
        userEngagementRate: userEngagementRate,
        userGrowthTrend: userGrowthTrend,
        usersByRole: usersByRole,
        userProductivity: userProductivity,
      );

    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Calculate User Metrics',
        severity: ErrorSeverity.medium,
      );
      return _getEmptyUserMetrics();
    }
  }

  /// Generate user growth trend
  Future<List<FlSpot>> _generateUserGrowthTrend(DateTimeRange dateRange) async {
    try {
      final spots = <FlSpot>[];
      final days = dateRange.end.difference(dateRange.start).inDays;
      
      for (int i = 0; i <= days; i++) {
        final date = dateRange.start.add(Duration(days: i));
        
        final usersQuery = await _usersCollection
            .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(date))
            .get();
        
        spots.add(FlSpot(i.toDouble(), usersQuery.docs.length.toDouble()));
      }
      
      return spots;
    } catch (e) {
      return [];
    }
  }

  // ==================== TEAM METRICS CALCULATION ====================

  /// Calculate team metrics
  Future<TeamMetrics> _calculateTeamMetrics() async {
    try {
      final dateRange = _getDateRange();
      
      // Get all teams
      final teamsQuery = await _teamsCollection.get();
      final teams = teamsQuery.docs;
      final totalTeams = teams.length;
      
      int activeTeams = 0;
      double totalTeamSize = 0;
      final teamProductivity = <String, double>{};
      final teamTaskDistribution = <String, int>{};

      for (final teamDoc in teams) {
        final teamData = teamDoc.data() as Map<String, dynamic>;
        final members = List<Map<String, dynamic>>.from(teamData['members'] ?? []);
        final isActive = teamData['isActive'] ?? true;
        
        if (isActive) {
          activeTeams++;
        }
        
        totalTeamSize += members.length;

        // Calculate team task distribution
        final teamTasksQuery = await _tasksCollection
            .where('teamId', isEqualTo: teamDoc.id)
            .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start))
            .get();
        
        teamTaskDistribution[teamDoc.id] = teamTasksQuery.docs.length;

        // Calculate team productivity
        final completedTasksQuery = await _tasksCollection
            .where('teamId', isEqualTo: teamDoc.id)
            .where('status', isEqualTo: 'completed')
            .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start))
            .get();
        
        final completedTasks = completedTasksQuery.docs.length;
        final totalTasks = teamTasksQuery.docs.length;
        final productivity = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;
        
        teamProductivity[teamDoc.id] = productivity;
      }

      final averageTeamSize = totalTeams > 0 ? totalTeamSize / totalTeams : 0.0;
      final teamCollaborationScore = _calculateTeamCollaborationScore(teamProductivity);
      
      // Generate team performance trend
      final teamPerformanceTrend = await _generateTeamPerformanceTrend(dateRange);

      return TeamMetrics(
        totalTeams: totalTeams,
        activeTeams: activeTeams,
        averageTeamSize: averageTeamSize,
        teamCollaborationScore: teamCollaborationScore,
        teamPerformanceTrend: teamPerformanceTrend,
        teamProductivity: teamProductivity,
        teamTaskDistribution: teamTaskDistribution,
      );

    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Calculate Team Metrics',
        severity: ErrorSeverity.medium,
      );
      return _getEmptyTeamMetrics();
    }
  }

  /// Calculate team collaboration score
  double _calculateTeamCollaborationScore(Map<String, double> teamProductivity) {
    if (teamProductivity.isEmpty) return 0.0;
    
    final totalScore = teamProductivity.values.reduce((a, b) => a + b);
    return totalScore / teamProductivity.length;
  }

  /// Generate team performance trend
  Future<List<FlSpot>> _generateTeamPerformanceTrend(DateTimeRange dateRange) async {
    try {
      final spots = <FlSpot>[];
      final days = dateRange.end.difference(dateRange.start).inDays;
      
      for (int i = 0; i <= days; i++) {
        final date = dateRange.start.add(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        
        final completedTasksQuery = await _tasksCollection
            .where('status', isEqualTo: 'completed')
            .where('teamId', isNotEqualTo: null)
            .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('completedAt', isLessThan: Timestamp.fromDate(endOfDay))
            .get();
        
        spots.add(FlSpot(i.toDouble(), completedTasksQuery.docs.length.toDouble()));
      }
      
      return spots;
    } catch (e) {
      return [];
    }
  }

  // ==================== PROJECT METRICS CALCULATION ====================

  /// Calculate project metrics
  Future<ProjectMetrics> _calculateProjectMetrics() async {
    try {
      // Get all projects
      final projectsQuery = await _projectsCollection.get();
      final projects = projectsQuery.docs;
      final totalProjects = projects.length;
      
      int activeProjects = 0;
      int completedProjects = 0;
      final projectHealth = <String, double>{};
      final projectsByStatus = <String, int>{
        'planning': 0,
        'active': 0,
        'completed': 0,
        'on_hold': 0,
        'cancelled': 0,
      };

      for (final projectDoc in projects) {
        final projectData = projectDoc.data() as Map<String, dynamic>;
        final status = projectData['status'] ?? 'planning';
        
        projectsByStatus[status] = (projectsByStatus[status] ?? 0) + 1;
        
        if (status == 'active') {
          activeProjects++;
        } else if (status == 'completed') {
          completedProjects++;
        }

        // Calculate project health based on task completion rate
        final projectTasksQuery = await _tasksCollection
            .where('projectId', isEqualTo: projectDoc.id)
            .get();
        
        final totalTasks = projectTasksQuery.docs.length;
        if (totalTasks > 0) {
          final completedTasks = projectTasksQuery.docs
              .where((doc) => (doc.data() as Map<String, dynamic>)['status'] == 'completed')
              .length;
          
          final health = (completedTasks / totalTasks) * 100;
          projectHealth[projectDoc.id] = health;
        }
      }

      final projectSuccessRate = totalProjects > 0 ? (completedProjects / totalProjects) * 100 : 0.0;
      
      // Generate project progress trend
      final projectProgressTrend = await _generateProjectProgressTrend(_getDateRange());

      return ProjectMetrics(
        totalProjects: totalProjects,
        activeProjects: activeProjects,
        completedProjects: completedProjects,
        projectSuccessRate: projectSuccessRate,
        projectProgressTrend: projectProgressTrend,
        projectHealth: projectHealth,
        projectsByStatus: projectsByStatus,
      );

    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Calculate Project Metrics',
        severity: ErrorSeverity.medium,
      );
      return _getEmptyProjectMetrics();
    }
  }

  /// Generate project progress trend
  Future<List<FlSpot>> _generateProjectProgressTrend(DateTimeRange dateRange) async {
    try {
      final spots = <FlSpot>[];
      final days = dateRange.end.difference(dateRange.start).inDays;
      
      for (int i = 0; i <= days; i++) {
        final date = dateRange.start.add(Duration(days: i));
        
        final completedProjectsQuery = await _projectsCollection
            .where('status', isEqualTo: 'completed')
            .where('completedAt', isLessThanOrEqualTo: Timestamp.fromDate(date))
            .get();
        
        spots.add(FlSpot(i.toDouble(), completedProjectsQuery.docs.length.toDouble()));
      }
      
      return spots;
    } catch (e) {
      return [];
    }
  }

  // ==================== SYSTEM METRICS CALCULATION ====================

  /// Calculate system metrics
  Future<SystemMetrics> _calculateSystemMetrics() async {
    try {
      final dateRange = _getDateRange();
      
      // Calculate system uptime (mock data for now)
      final systemUptime = 99.9;
      
      // Get total notifications
      final notificationsQuery = await _firestore
          .collection('notifications')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start))
          .get();
      final totalNotifications = notificationsQuery.docs.length;
      
      // Mock system performance data
      final averageResponseTime = 150.0; // milliseconds
      final errorCount = 5;
      
      final featureUsage = <String, int>{
        'tasks': await _getFeatureUsageCount('tasks', dateRange),
        'teams': await _getFeatureUsageCount('teams', dateRange),
        'projects': await _getFeatureUsageCount('projects', dateRange),
        'notifications': totalNotifications,
      };
      
      final systemHealth = <String, double>{
        'database': 98.5,
        'api': 99.2,
        'storage': 97.8,
        'notifications': 99.5,
      };
      
      // Generate system performance trend
      final systemPerformanceTrend = _generateSystemPerformanceTrend(dateRange);

      return SystemMetrics(
        systemUptime: systemUptime,
        totalNotifications: totalNotifications,
        averageResponseTime: averageResponseTime,
        errorCount: errorCount,
        systemPerformanceTrend: systemPerformanceTrend,
        featureUsage: featureUsage,
        systemHealth: systemHealth,
      );

    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Calculate System Metrics',
        severity: ErrorSeverity.medium,
      );
      return _getEmptySystemMetrics();
    }
  }

  /// Get feature usage count
  Future<int> _getFeatureUsageCount(String feature, DateTimeRange dateRange) async {
    try {
      final query = await _firestore
          .collection(feature)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end))
          .get();
      
      return query.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Generate system performance trend (mock data)
  List<FlSpot> _generateSystemPerformanceTrend(DateTimeRange dateRange) {
    final spots = <FlSpot>[];
    final days = dateRange.end.difference(dateRange.start).inDays;
    
    for (int i = 0; i <= days; i++) {
      // Mock performance data with some variation
      final performance = 95 + (5 * (0.5 - (i % 7) / 14));
      spots.add(FlSpot(i.toDouble(), performance));
    }
    
    return spots;
  }

  // ==================== UTILITY METHODS ====================

  /// Get date range based on selected time range
  DateTimeRange _getDateRange() {
    final now = DateTime.now();
    DateTime start;
    
    switch (_selectedTimeRange.value) {
      case '1d':
        start = now.subtract(const Duration(days: 1));
        break;
      case '7d':
        start = now.subtract(const Duration(days: 7));
        break;
      case '30d':
        start = now.subtract(const Duration(days: 30));
        break;
      case '90d':
        start = now.subtract(const Duration(days: 90));
        break;
      case '1y':
        start = now.subtract(const Duration(days: 365));
        break;
      default:
        start = now.subtract(const Duration(days: 7));
    }
    
    return DateTimeRange(start: start, end: now);
  }

  // ==================== EMPTY METRICS FALLBACKS ====================

  TaskMetrics _getEmptyTaskMetrics() {
    return const TaskMetrics(
      totalTasks: 0,
      completedTasks: 0,
      pendingTasks: 0,
      overdueTasks: 0,
      completionRate: 0.0,
      averageCompletionTime: 0.0,
      completionTrend: [],
      tasksByPriority: {},
      tasksByStatus: {},
    );
  }

  UserMetrics _getEmptyUserMetrics() {
    return const UserMetrics(
      totalUsers: 0,
      activeUsers: 0,
      newUsersThisMonth: 0,
      userEngagementRate: 0.0,
      userGrowthTrend: [],
      usersByRole: {},
      userProductivity: {},
    );
  }

  TeamMetrics _getEmptyTeamMetrics() {
    return const TeamMetrics(
      totalTeams: 0,
      activeTeams: 0,
      averageTeamSize: 0.0,
      teamCollaborationScore: 0.0,
      teamPerformanceTrend: [],
      teamProductivity: {},
      teamTaskDistribution: {},
    );
  }

  ProjectMetrics _getEmptyProjectMetrics() {
    return const ProjectMetrics(
      totalProjects: 0,
      activeProjects: 0,
      completedProjects: 0,
      projectSuccessRate: 0.0,
      projectProgressTrend: [],
      projectHealth: {},
      projectsByStatus: {},
    );
  }

  SystemMetrics _getEmptySystemMetrics() {
    return const SystemMetrics(
      systemUptime: 0.0,
      totalNotifications: 0,
      averageResponseTime: 0.0,
      errorCount: 0,
      systemPerformanceTrend: [],
      featureUsage: {},
      systemHealth: {},
    );
  }
}

/// Date Time Range helper class
class DateTimeRange {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({
    required this.start,
    required this.end,
  });
}
