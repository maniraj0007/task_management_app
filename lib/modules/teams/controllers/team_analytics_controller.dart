import 'dart:async';
import 'package:get/get.dart';
import '../../../core/enums/team_enums.dart';
import '../models/team_model.dart';
import '../models/project_model.dart';
import '../models/team_member_model.dart';
import '../../auth/services/auth_service.dart';
import 'team_controller.dart';
import 'project_controller.dart';
import 'team_member_controller.dart';

/// Team Analytics Controller
/// Manages team performance analytics and insights with GetX reactive programming
class TeamAnalyticsController extends GetxController {
  static TeamAnalyticsController get instance => Get.find<TeamAnalyticsController>();
  
  final AuthService _authService = Get.find<AuthService>();
  final TeamController _teamController = Get.find<TeamController>();
  final ProjectController _projectController = Get.find<ProjectController>();
  final TeamMemberController _memberController = Get.find<TeamMemberController>();
  
  // ==================== REACTIVE STATE ====================
  
  // Analytics data
  final RxMap<String, dynamic> _teamMetrics = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> _projectMetrics = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> _memberMetrics = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> _performanceMetrics = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> _collaborationMetrics = <String, dynamic>{}.obs;
  
  // Time-based analytics
  final RxList<Map<String, dynamic>> _weeklyStats = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _monthlyStats = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _quarterlyStats = <Map<String, dynamic>>[].obs;
  
  // UI state
  final RxBool _isLoading = false.obs;
  final RxBool _isCalculating = false.obs;
  final RxString _error = ''.obs;
  
  // Analytics filters
  final Rx<DateTime> _startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final Rx<DateTime> _endDate = DateTime.now().obs;
  final RxString _selectedMetric = 'overview'.obs;
  final Rx<TeamRole?> _roleFilter = Rx<TeamRole?>(null);
  final Rx<ProjectStatus?> _projectStatusFilter = Rx<ProjectStatus?>(null);
  
  // Chart data
  final RxList<Map<String, dynamic>> _chartData = <Map<String, dynamic>>[].obs;
  final RxString _chartType = 'line'.obs;
  
  // ==================== GETTERS ====================
  
  Map<String, dynamic> get teamMetrics => _teamMetrics;
  Map<String, dynamic> get projectMetrics => _projectMetrics;
  Map<String, dynamic> get memberMetrics => _memberMetrics;
  Map<String, dynamic> get performanceMetrics => _performanceMetrics;
  Map<String, dynamic> get collaborationMetrics => _collaborationMetrics;
  
  List<Map<String, dynamic>> get weeklyStats => _weeklyStats;
  List<Map<String, dynamic>> get monthlyStats => _monthlyStats;
  List<Map<String, dynamic>> get quarterlyStats => _quarterlyStats;
  
  bool get isLoading => _isLoading.value;
  bool get isCalculating => _isCalculating.value;
  String get error => _error.value;
  
  DateTime get startDate => _startDate.value;
  DateTime get endDate => _endDate.value;
  String get selectedMetric => _selectedMetric.value;
  TeamRole? get roleFilter => _roleFilter.value;
  ProjectStatus? get projectStatusFilter => _projectStatusFilter.value;
  
  List<Map<String, dynamic>> get chartData => _chartData;
  String get chartType => _chartType.value;
  
  // Computed analytics
  double get teamHealthScore {
    final team = _teamController.currentTeam;
    return team?.healthScore.toDouble() ?? 0.0;
  }
  
  double get averageProjectHealth {
    final projects = _projectController.teamProjects;
    if (projects.isEmpty) return 0.0;
    
    final totalHealth = projects.fold<int>(0, (sum, project) => sum + project.healthScore);
    return totalHealth / projects.length;
  }
  
  double get averageMemberPerformance {
    final members = _teamController.currentTeamMembers;
    if (members.isEmpty) return 0.0;
    
    final totalPerformance = members.fold<int>(0, (sum, member) => sum + member.performanceScore);
    return totalPerformance / members.length;
  }
  
  double get teamProductivity {
    final completedTasks = _teamController.currentTeam?.completedTasks ?? 0;
    final totalTasks = _teamController.currentTeam?.totalTasks ?? 0;
    
    if (totalTasks == 0) return 0.0;
    return completedTasks / totalTasks;
  }
  
  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }
  
  // ==================== INITIALIZATION ====================
  
  void _initializeController() {
    // Listen to team changes
    ever(_teamController.currentTeam, (TeamModel? team) {
      if (team != null) {
        calculateAnalytics();
      } else {
        _clearAnalytics();
      }
    });
    
    // Listen to project changes
    ever(_projectController.teamProjects, (_) {
      if (_teamController.hasCurrentTeam) {
        calculateAnalytics();
      }
    });
    
    // Listen to member changes
    ever(_teamController.currentTeamMembers, (_) {
      if (_teamController.hasCurrentTeam) {
        calculateAnalytics();
      }
    });
  }
  
  void _clearAnalytics() {
    _teamMetrics.clear();
    _projectMetrics.clear();
    _memberMetrics.clear();
    _performanceMetrics.clear();
    _collaborationMetrics.clear();
    _weeklyStats.clear();
    _monthlyStats.clear();
    _quarterlyStats.clear();
    _chartData.clear();
    _clearError();
  }
  
  void _clearError() {
    _error.value = '';
  }
  
  void _setError(String message) {
    _error.value = message;
  }
  
  // ==================== ANALYTICS CALCULATION ====================
  
  /// Calculate comprehensive team analytics
  Future<void> calculateAnalytics() async {
    if (!_teamController.hasCurrentTeam) return;
    
    try {
      _isCalculating.value = true;
      _clearError();
      
      await Future.wait([
        _calculateTeamMetrics(),
        _calculateProjectMetrics(),
        _calculateMemberMetrics(),
        _calculatePerformanceMetrics(),
        _calculateCollaborationMetrics(),
        _calculateTimeBasedStats(),
      ]);
      
      _generateChartData();
      
    } catch (e) {
      _setError('Failed to calculate analytics: ${e.toString()}');
    } finally {
      _isCalculating.value = false;
    }
  }
  
  /// Calculate team-level metrics
  Future<void> _calculateTeamMetrics() async {
    final team = _teamController.currentTeam!;
    final members = _teamController.currentTeamMembers;
    
    _teamMetrics.assignAll({
      'healthScore': team.healthScore,
      'totalMembers': team.totalMembers,
      'activeMembers': members.where((m) => m.isCurrentlyActive).length,
      'totalProjects': team.totalProjects,
      'totalTasks': team.totalTasks,
      'completedTasks': team.completedTasks,
      'completionRate': team.completionPercentage,
      'activityLevel': team.activityLevel,
      'ageInDays': team.ageInDays,
      'isNew': team.isNew,
      'lastActivityAt': team.lastActivityAt,
      'memberGrowthRate': _calculateMemberGrowthRate(),
      'taskVelocity': _calculateTaskVelocity(),
      'averageTaskCompletionTime': _calculateAverageTaskCompletionTime(),
    });
  }
  
  /// Calculate project-level metrics
  Future<void> _calculateProjectMetrics() async {
    final projects = _projectController.teamProjects;
    
    if (projects.isEmpty) {
      _projectMetrics.assignAll({
        'totalProjects': 0,
        'activeProjects': 0,
        'completedProjects': 0,
        'overdueProjects': 0,
        'averageHealth': 0.0,
        'averageProgress': 0.0,
        'projectsByStatus': <String, int>{},
        'projectsByPriority': <String, int>{},
        'projectsByType': <String, int>{},
      });
      return;
    }
    
    final activeProjects = projects.where((p) => p.isActive).length;
    final completedProjects = projects.where((p) => p.isCompleted).length;
    final overdueProjects = projects.where((p) => p.isOverdue).length;
    
    final totalHealth = projects.fold<int>(0, (sum, p) => sum + p.healthScore);
    final totalProgress = projects.fold<double>(0, (sum, p) => sum + p.progress);
    
    final projectsByStatus = <String, int>{};
    final projectsByPriority = <String, int>{};
    final projectsByType = <String, int>{};
    
    for (final project in projects) {
      projectsByStatus[project.status.displayName] = 
          (projectsByStatus[project.status.displayName] ?? 0) + 1;
      projectsByPriority[project.priority.displayName] = 
          (projectsByPriority[project.priority.displayName] ?? 0) + 1;
      projectsByType[project.type.displayName] = 
          (projectsByType[project.type.displayName] ?? 0) + 1;
    }
    
    _projectMetrics.assignAll({
      'totalProjects': projects.length,
      'activeProjects': activeProjects,
      'completedProjects': completedProjects,
      'overdueProjects': overdueProjects,
      'averageHealth': totalHealth / projects.length,
      'averageProgress': totalProgress / projects.length,
      'projectsByStatus': projectsByStatus,
      'projectsByPriority': projectsByPriority,
      'projectsByType': projectsByType,
      'completionRate': projects.isEmpty ? 0.0 : completedProjects / projects.length,
      'overdueRate': projects.isEmpty ? 0.0 : overdueProjects / projects.length,
    });
  }
  
  /// Calculate member-level metrics
  Future<void> _calculateMemberMetrics() async {
    final members = _teamController.currentTeamMembers;
    
    if (members.isEmpty) {
      _memberMetrics.assignAll({
        'totalMembers': 0,
        'activeMembers': 0,
        'averagePerformance': 0.0,
        'membersByRole': <String, int>{},
        'membersByActivity': <String, int>{},
        'highPerformers': 0,
        'membersNeedingAttention': 0,
        'availableMembers': 0,
      });
      return;
    }
    
    final activeMembers = members.where((m) => m.isCurrentlyActive).length;
    final totalPerformance = members.fold<int>(0, (sum, m) => sum + m.performanceScore);
    
    final membersByRole = <String, int>{};
    final membersByActivity = <String, int>{};
    
    for (final member in members) {
      membersByRole[member.role.displayName] = 
          (membersByRole[member.role.displayName] ?? 0) + 1;
      membersByActivity[member.activityLevel] = 
          (membersByActivity[member.activityLevel] ?? 0) + 1;
    }
    
    _memberMetrics.assignAll({
      'totalMembers': members.length,
      'activeMembers': activeMembers,
      'averagePerformance': totalPerformance / members.length,
      'membersByRole': membersByRole,
      'membersByActivity': membersByActivity,
      'highPerformers': members.where((m) => m.performanceScore >= 80).length,
      'membersNeedingAttention': members.where((m) => m.needsAttention).length,
      'availableMembers': members.where((m) => m.isAvailableForAssignments).length,
      'averageTenure': _calculateAverageTenure(members),
      'retentionRate': _calculateRetentionRate(members),
    });
  }
  
  /// Calculate performance metrics
  Future<void> _calculatePerformanceMetrics() async {
    final team = _teamController.currentTeam!;
    final projects = _projectController.teamProjects;
    final members = _teamController.currentTeamMembers;
    
    _performanceMetrics.assignAll({
      'teamHealthScore': team.healthScore,
      'projectHealthScore': averageProjectHealth,
      'memberPerformanceScore': averageMemberPerformance,
      'productivityScore': teamProductivity * 100,
      'collaborationScore': _calculateCollaborationScore(),
      'efficiencyScore': _calculateEfficiencyScore(),
      'qualityScore': _calculateQualityScore(),
      'innovationScore': _calculateInnovationScore(),
      'overallScore': _calculateOverallPerformanceScore(),
      'trends': _calculatePerformanceTrends(),
    });
  }
  
  /// Calculate collaboration metrics
  Future<void> _calculateCollaborationMetrics() async {
    final members = _teamController.currentTeamMembers;
    final invitations = _memberController.teamInvitations;
    
    _collaborationMetrics.assignAll({
      'totalInvitations': invitations.length,
      'acceptedInvitations': invitations.where((i) => i.isAccepted).length,
      'pendingInvitations': invitations.where((i) => i.isPending).length,
      'invitationAcceptanceRate': _calculateInvitationAcceptanceRate(invitations),
      'averageResponseTime': _calculateAverageResponseTime(invitations),
      'memberEngagement': _calculateMemberEngagement(members),
      'communicationFrequency': _calculateCommunicationFrequency(),
      'crossFunctionalCollaboration': _calculateCrossFunctionalCollaboration(members),
      'knowledgeSharing': _calculateKnowledgeSharing(members),
    });
  }
  
  /// Calculate time-based statistics
  Future<void> _calculateTimeBasedStats() async {
    // Generate weekly stats for the last 12 weeks
    final weeklyData = <Map<String, dynamic>>[];
    for (int i = 11; i >= 0; i--) {
      final weekStart = DateTime.now().subtract(Duration(days: i * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));
      
      weeklyData.add({
        'week': 'Week ${12 - i}',
        'startDate': weekStart,
        'endDate': weekEnd,
        'tasksCompleted': _getTasksCompletedInPeriod(weekStart, weekEnd),
        'projectsStarted': _getProjectsStartedInPeriod(weekStart, weekEnd),
        'membersJoined': _getMembersJoinedInPeriod(weekStart, weekEnd),
        'teamHealth': teamHealthScore,
      });
    }
    _weeklyStats.assignAll(weeklyData);
    
    // Generate monthly stats for the last 6 months
    final monthlyData = <Map<String, dynamic>>[];
    for (int i = 5; i >= 0; i--) {
      final monthStart = DateTime(DateTime.now().year, DateTime.now().month - i, 1);
      final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);
      
      monthlyData.add({
        'month': _getMonthName(monthStart.month),
        'startDate': monthStart,
        'endDate': monthEnd,
        'tasksCompleted': _getTasksCompletedInPeriod(monthStart, monthEnd),
        'projectsCompleted': _getProjectsCompletedInPeriod(monthStart, monthEnd),
        'productivity': _getProductivityInPeriod(monthStart, monthEnd),
        'teamGrowth': _getTeamGrowthInPeriod(monthStart, monthEnd),
      });
    }
    _monthlyStats.assignAll(monthlyData);
    
    // Generate quarterly stats for the last 4 quarters
    final quarterlyData = <Map<String, dynamic>>[];
    for (int i = 3; i >= 0; i--) {
      final quarterStart = _getQuarterStart(DateTime.now(), i);
      final quarterEnd = _getQuarterEnd(quarterStart);
      
      quarterlyData.add({
        'quarter': 'Q${_getQuarterNumber(quarterStart)} ${quarterStart.year}',
        'startDate': quarterStart,
        'endDate': quarterEnd,
        'revenue': _getRevenueInPeriod(quarterStart, quarterEnd),
        'growth': _getGrowthInPeriod(quarterStart, quarterEnd),
        'efficiency': _getEfficiencyInPeriod(quarterStart, quarterEnd),
        'satisfaction': _getSatisfactionInPeriod(quarterStart, quarterEnd),
      });
    }
    _quarterlyStats.assignAll(quarterlyData);
  }
  
  /// Generate chart data based on selected metric
  void _generateChartData() {
    switch (_selectedMetric.value) {
      case 'team_health':
        _generateTeamHealthChart();
        break;
      case 'project_progress':
        _generateProjectProgressChart();
        break;
      case 'member_performance':
        _generateMemberPerformanceChart();
        break;
      case 'task_completion':
        _generateTaskCompletionChart();
        break;
      default:
        _generateOverviewChart();
    }
  }
  
  // ==================== CHART GENERATION ====================
  
  void _generateOverviewChart() {
    _chartData.assignAll([
      {'label': 'Team Health', 'value': teamHealthScore, 'color': '#4CAF50'},
      {'label': 'Project Health', 'value': averageProjectHealth, 'color': '#2196F3'},
      {'label': 'Member Performance', 'value': averageMemberPerformance, 'color': '#FF9800'},
      {'label': 'Productivity', 'value': teamProductivity * 100, 'color': '#9C27B0'},
    ]);
    _chartType.value = 'bar';
  }
  
  void _generateTeamHealthChart() {
    _chartData.assignAll(_weeklyStats.map((week) => {
      'label': week['week'],
      'value': week['teamHealth'],
      'date': week['startDate'],
    }).toList());
    _chartType.value = 'line';
  }
  
  void _generateProjectProgressChart() {
    final projects = _projectController.teamProjects;
    _chartData.assignAll(projects.map((project) => {
      'label': project.name,
      'value': project.progress * 100,
      'status': project.status.displayName,
      'color': project.statusColor,
    }).toList());
    _chartType.value = 'bar';
  }
  
  void _generateMemberPerformanceChart() {
    final members = _teamController.currentTeamMembers;
    _chartData.assignAll(members.map((member) => {
      'label': member.displayName ?? 'Unknown',
      'value': member.performanceScore,
      'role': member.role.displayName,
      'color': member.roleColor,
    }).toList());
    _chartType.value = 'bar';
  }
  
  void _generateTaskCompletionChart() {
    _chartData.assignAll(_monthlyStats.map((month) => {
      'label': month['month'],
      'value': month['tasksCompleted'],
      'date': month['startDate'],
    }).toList());
    _chartType.value = 'line';
  }
  
  // ==================== HELPER METHODS ====================
  
  double _calculateMemberGrowthRate() {
    // Simplified calculation - would need historical data in real implementation
    final currentMembers = _teamController.currentTeam?.totalMembers ?? 0;
    return currentMembers > 0 ? 0.1 : 0.0; // 10% growth placeholder
  }
  
  double _calculateTaskVelocity() {
    // Tasks completed per week - simplified calculation
    final completedTasks = _teamController.currentTeam?.completedTasks ?? 0;
    final ageInWeeks = (_teamController.currentTeam?.ageInDays ?? 1) / 7;
    return ageInWeeks > 0 ? completedTasks / ageInWeeks : 0.0;
  }
  
  double _calculateAverageTaskCompletionTime() {
    final members = _teamController.currentTeamMembers;
    if (members.isEmpty) return 0.0;
    
    final totalTime = members.fold<double>(0, (sum, m) => sum + m.averageTaskCompletionTime);
    return totalTime / members.length;
  }
  
  double _calculateAverageTenure(List<TeamMemberModel> members) {
    if (members.isEmpty) return 0.0;
    
    final totalTenure = members.fold<int>(0, (sum, m) => sum + m.tenureInDays);
    return totalTenure / members.length;
  }
  
  double _calculateRetentionRate(List<TeamMemberModel> members) {
    final activeMembers = members.where((m) => m.isCurrentlyActive).length;
    return members.isEmpty ? 0.0 : activeMembers / members.length;
  }
  
  double _calculateCollaborationScore() {
    final members = _teamController.currentTeamMembers;
    if (members.isEmpty) return 0.0;
    
    final totalCollaboration = members.fold<int>(0, (sum, m) => sum + m.collaborationScore);
    return totalCollaboration / members.length;
  }
  
  double _calculateEfficiencyScore() {
    // Simplified efficiency calculation
    final completionRate = teamProductivity;
    final healthScore = teamHealthScore / 100;
    return (completionRate + healthScore) / 2 * 100;
  }
  
  double _calculateQualityScore() {
    // Placeholder for quality metrics
    return 85.0; // Would be calculated from actual quality metrics
  }
  
  double _calculateInnovationScore() {
    // Placeholder for innovation metrics
    return 75.0; // Would be calculated from innovation indicators
  }
  
  double _calculateOverallPerformanceScore() {
    final health = teamHealthScore;
    final productivity = teamProductivity * 100;
    final collaboration = _calculateCollaborationScore();
    final efficiency = _calculateEfficiencyScore();
    
    return (health + productivity + collaboration + efficiency) / 4;
  }
  
  Map<String, double> _calculatePerformanceTrends() {
    // Simplified trend calculation - would need historical data
    return {
      'health': 5.0, // +5% trend
      'productivity': -2.0, // -2% trend
      'collaboration': 8.0, // +8% trend
      'efficiency': 3.0, // +3% trend
    };
  }
  
  double _calculateInvitationAcceptanceRate(List<TeamInvitationModel> invitations) {
    if (invitations.isEmpty) return 0.0;
    
    final accepted = invitations.where((i) => i.isAccepted).length;
    return accepted / invitations.length;
  }
  
  double _calculateAverageResponseTime(List<TeamInvitationModel> invitations) {
    final respondedInvitations = invitations.where((i) => i.responseTimeInHours != null);
    if (respondedInvitations.isEmpty) return 0.0;
    
    final totalTime = respondedInvitations.fold<int>(0, (sum, i) => sum + (i.responseTimeInHours ?? 0));
    return totalTime / respondedInvitations.length;
  }
  
  double _calculateMemberEngagement(List<TeamMemberModel> members) {
    if (members.isEmpty) return 0.0;
    
    final engagedMembers = members.where((m) => m.performanceScore >= 70).length;
    return engagedMembers / members.length;
  }
  
  double _calculateCommunicationFrequency() {
    // Placeholder - would be calculated from actual communication data
    return 8.5; // Average communications per day
  }
  
  double _calculateCrossFunctionalCollaboration(List<TeamMemberModel> members) {
    // Simplified calculation based on role diversity
    final roles = members.map((m) => m.role).toSet();
    return roles.length / TeamRole.values.length;
  }
  
  double _calculateKnowledgeSharing(List<TeamMemberModel> members) {
    // Placeholder - would be calculated from knowledge sharing activities
    return 0.75; // 75% knowledge sharing score
  }
  
  // Time-based calculation helpers
  int _getTasksCompletedInPeriod(DateTime start, DateTime end) {
    // Placeholder - would query actual data
    return 15 + (start.day % 10); // Simulated data
  }
  
  int _getProjectsStartedInPeriod(DateTime start, DateTime end) {
    return 2 + (start.day % 3); // Simulated data
  }
  
  int _getMembersJoinedInPeriod(DateTime start, DateTime end) {
    return start.day % 2; // Simulated data
  }
  
  int _getProjectsCompletedInPeriod(DateTime start, DateTime end) {
    return 1 + (start.day % 2); // Simulated data
  }
  
  double _getProductivityInPeriod(DateTime start, DateTime end) {
    return 0.7 + (start.day % 10) * 0.03; // Simulated data
  }
  
  double _getTeamGrowthInPeriod(DateTime start, DateTime end) {
    return 0.05 + (start.day % 5) * 0.01; // Simulated data
  }
  
  double _getRevenueInPeriod(DateTime start, DateTime end) {
    return 100000 + (start.day % 20) * 5000; // Simulated data
  }
  
  double _getGrowthInPeriod(DateTime start, DateTime end) {
    return 0.1 + (start.day % 10) * 0.01; // Simulated data
  }
  
  double _getEfficiencyInPeriod(DateTime start, DateTime end) {
    return 0.8 + (start.day % 10) * 0.02; // Simulated data
  }
  
  double _getSatisfactionInPeriod(DateTime start, DateTime end) {
    return 4.0 + (start.day % 10) * 0.1; // Simulated data
  }
  
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
  
  DateTime _getQuarterStart(DateTime date, int quartersBack) {
    final currentQuarter = ((date.month - 1) ~/ 3) + 1;
    final targetQuarter = currentQuarter - quartersBack;
    
    if (targetQuarter > 0) {
      return DateTime(date.year, (targetQuarter - 1) * 3 + 1, 1);
    } else {
      final yearOffset = (targetQuarter.abs() ~/ 4) + 1;
      final adjustedQuarter = 4 + (targetQuarter % 4);
      return DateTime(date.year - yearOffset, (adjustedQuarter - 1) * 3 + 1, 1);
    }
  }
  
  DateTime _getQuarterEnd(DateTime quarterStart) {
    return DateTime(quarterStart.year, quarterStart.month + 3, 0);
  }
  
  int _getQuarterNumber(DateTime date) {
    return ((date.month - 1) ~/ 3) + 1;
  }
  
  // ==================== PUBLIC METHODS ====================
  
  /// Set date range for analytics
  void setDateRange(DateTime start, DateTime end) {
    _startDate.value = start;
    _endDate.value = end;
    calculateAnalytics();
  }
  
  /// Set selected metric for detailed view
  void setSelectedMetric(String metric) {
    _selectedMetric.value = metric;
    _generateChartData();
  }
  
  /// Set role filter
  void setRoleFilter(TeamRole? role) {
    _roleFilter.value = role;
    calculateAnalytics();
  }
  
  /// Set project status filter
  void setProjectStatusFilter(ProjectStatus? status) {
    _projectStatusFilter.value = status;
    calculateAnalytics();
  }
  
  /// Set chart type
  void setChartType(String type) {
    _chartType.value = type;
  }
  
  /// Refresh all analytics
  Future<void> refreshAnalytics() async {
    await calculateAnalytics();
  }
  
  /// Export analytics data
  Map<String, dynamic> exportAnalytics() {
    return {
      'teamMetrics': _teamMetrics,
      'projectMetrics': _projectMetrics,
      'memberMetrics': _memberMetrics,
      'performanceMetrics': _performanceMetrics,
      'collaborationMetrics': _collaborationMetrics,
      'weeklyStats': _weeklyStats,
      'monthlyStats': _monthlyStats,
      'quarterlyStats': _quarterlyStats,
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }
}
