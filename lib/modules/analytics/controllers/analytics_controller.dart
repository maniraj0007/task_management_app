import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/analytics_data_model.dart';
import '../services/analytics_service.dart';

/// Analytics Controller
/// Manages analytics dashboard state and user interactions
class AnalyticsController extends GetxController {
  final AnalyticsService _analyticsService = Get.find<AnalyticsService>();

  // Reactive state
  final RxString _selectedMetricType = 'overview'.obs;
  final RxString _selectedTimeRange = '7d'.obs;
  final RxBool _isLoading = false.obs;

  // Getters
  DashboardMetricsModel? get dashboardMetrics => _analyticsService.dashboardMetrics;
  bool get isLoading => _isLoading.value || _analyticsService.isLoading;
  String get selectedMetricType => _selectedMetricType.value;
  String get selectedTimeRange => _selectedTimeRange.value;

  // Computed properties
  TaskMetrics? get taskMetrics => dashboardMetrics?.taskMetrics;
  UserMetrics? get userMetrics => dashboardMetrics?.userMetrics;
  TeamMetrics? get teamMetrics => dashboardMetrics?.teamMetrics;
  ProjectMetrics? get projectMetrics => dashboardMetrics?.projectMetrics;
  SystemMetrics? get systemMetrics => dashboardMetrics?.systemMetrics;

  @override
  void onInit() {
    super.onInit();
    _setupServiceListener();
    refreshDashboard();
  }

  /// Setup service listener
  void _setupServiceListener() {
    // Listen to service state changes
    ever(_analyticsService._dashboardMetrics, (_) => update());
    ever(_analyticsService._isLoading, (loading) => _isLoading.value = loading);
  }

  // ==================== DASHBOARD ACTIONS ====================

  /// Refresh dashboard data
  Future<void> refreshDashboard() async {
    _isLoading.value = true;
    try {
      await _analyticsService.refreshDashboardMetrics();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Set metric type filter
  void setMetricType(String type) {
    _selectedMetricType.value = type;
  }

  /// Set time range
  void setTimeRange(String timeRange) {
    _selectedTimeRange.value = timeRange;
    _analyticsService.setTimeRange(timeRange);
  }

  // ==================== CHART DATA PROCESSING ====================

  /// Get task completion trend data
  List<FlSpot> get taskCompletionTrendData {
    return taskMetrics?.completionTrend ?? [];
  }

  /// Get user growth trend data
  List<FlSpot> get userGrowthTrendData {
    return userMetrics?.userGrowthTrend ?? [];
  }

  /// Get team performance trend data
  List<FlSpot> get teamPerformanceTrendData {
    return teamMetrics?.teamPerformanceTrend ?? [];
  }

  /// Get project progress trend data
  List<FlSpot> get projectProgressTrendData {
    return projectMetrics?.projectProgressTrend ?? [];
  }

  /// Get system performance trend data
  List<FlSpot> get systemPerformanceTrendData {
    return systemMetrics?.systemPerformanceTrend ?? [];
  }

  // ==================== PIE CHART DATA ====================

  /// Get task status pie chart data
  List<PieChartSectionData> get taskStatusPieData {
    final tasksByStatus = taskMetrics?.tasksByStatus ?? {};
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
    ];
    
    return tasksByStatus.entries.map((entry) {
      final index = tasksByStatus.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  /// Get task priority pie chart data
  List<PieChartSectionData> get taskPriorityPieData {
    final tasksByPriority = taskMetrics?.tasksByPriority ?? {};
    final colors = [
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.red,
    ];
    
    return tasksByPriority.entries.map((entry) {
      final index = tasksByPriority.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  /// Get user role pie chart data
  List<PieChartSectionData> get userRolePieData {
    final usersByRole = userMetrics?.usersByRole ?? {};
    final colors = [
      Colors.purple,
      Colors.indigo,
      Colors.blue,
      Colors.teal,
    ];
    
    return usersByRole.entries.map((entry) {
      final index = usersByRole.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  /// Get project status pie chart data
  List<PieChartSectionData> get projectStatusPieData {
    final projectsByStatus = projectMetrics?.projectsByStatus ?? {};
    final colors = [
      Colors.grey,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
    ];
    
    return projectsByStatus.entries.map((entry) {
      final index = projectsByStatus.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  // ==================== BAR CHART DATA ====================

  /// Get feature usage bar chart data
  List<BarChartGroupData> get featureUsageBarData {
    final featureUsage = systemMetrics?.featureUsage ?? {};
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];
    
    return featureUsage.entries.map((entry) {
      final index = featureUsage.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: colors[index % colors.length],
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  /// Get team productivity bar chart data
  List<BarChartGroupData> get teamProductivityBarData {
    final teamProductivity = teamMetrics?.teamProductivity ?? {};
    
    return teamProductivity.entries.take(10).map((entry) {
      final index = teamProductivity.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  // ==================== STATISTICS CALCULATIONS ====================

  /// Get key performance indicators
  Map<String, dynamic> get keyPerformanceIndicators {
    return {
      'taskCompletionRate': taskMetrics?.completionRate ?? 0.0,
      'userEngagementRate': userMetrics?.userEngagementRate ?? 0.0,
      'teamCollaborationScore': teamMetrics?.teamCollaborationScore ?? 0.0,
      'projectSuccessRate': projectMetrics?.projectSuccessRate ?? 0.0,
      'systemUptime': systemMetrics?.systemUptime ?? 0.0,
    };
  }

  /// Get growth metrics
  Map<String, dynamic> get growthMetrics {
    final currentUsers = userMetrics?.totalUsers ?? 0;
    final newUsers = userMetrics?.newUsersThisMonth ?? 0;
    final growthRate = currentUsers > 0 ? (newUsers / currentUsers) * 100 : 0.0;

    return {
      'userGrowthRate': growthRate,
      'newUsersThisMonth': newUsers,
      'totalUsers': currentUsers,
      'activeUsers': userMetrics?.activeUsers ?? 0,
    };
  }

  /// Get productivity metrics
  Map<String, dynamic> get productivityMetrics {
    return {
      'averageTaskCompletionTime': taskMetrics?.averageCompletionTime ?? 0.0,
      'tasksCompletedToday': _getTasksCompletedToday(),
      'averageTeamSize': teamMetrics?.averageTeamSize ?? 0.0,
      'systemResponseTime': systemMetrics?.averageResponseTime ?? 0.0,
    };
  }

  /// Get tasks completed today
  int _getTasksCompletedToday() {
    // This would typically be calculated from the trend data
    final trendData = taskCompletionTrendData;
    if (trendData.isNotEmpty) {
      return trendData.last.y.toInt();
    }
    return 0;
  }

  // ==================== UTILITY METHODS ====================

  /// Get time range display text
  String getTimeRangeDisplayText(String timeRange) {
    switch (timeRange) {
      case '1d':
        return 'Last 24 Hours';
      case '7d':
        return 'Last 7 Days';
      case '30d':
        return 'Last 30 Days';
      case '90d':
        return 'Last 90 Days';
      case '1y':
        return 'Last Year';
      default:
        return 'Last 7 Days';
    }
  }

  /// Get metric type display text
  String getMetricTypeDisplayText(String type) {
    switch (type) {
      case 'overview':
        return 'Overview';
      case 'tasks':
        return 'Tasks';
      case 'users':
        return 'Users';
      case 'teams':
        return 'Teams';
      case 'projects':
        return 'Projects';
      case 'system':
        return 'System';
      default:
        return 'Overview';
    }
  }

  /// Check if data is available
  bool get hasData {
    return dashboardMetrics != null;
  }

  /// Check if specific metric type has data
  bool hasDataForMetricType(String type) {
    switch (type) {
      case 'tasks':
        return taskMetrics != null && taskMetrics!.totalTasks > 0;
      case 'users':
        return userMetrics != null && userMetrics!.totalUsers > 0;
      case 'teams':
        return teamMetrics != null && teamMetrics!.totalTeams > 0;
      case 'projects':
        return projectMetrics != null && projectMetrics!.totalProjects > 0;
      case 'system':
        return systemMetrics != null;
      default:
        return hasData;
    }
  }

  /// Export analytics data
  Future<void> exportAnalyticsData() async {
    try {
      _isLoading.value = true;
      
      // TODO: Implement data export functionality
      // This would typically generate a CSV or PDF report
      
      await Future.delayed(const Duration(seconds: 2)); // Simulate export
      
      Get.snackbar(
        'Success',
        'Analytics data exported successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to export analytics data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Share analytics report
  Future<void> shareAnalyticsReport() async {
    try {
      _isLoading.value = true;
      
      // TODO: Implement report sharing functionality
      // This would typically generate a shareable link or send via email
      
      await Future.delayed(const Duration(seconds: 1)); // Simulate sharing
      
      Get.snackbar(
        'Success',
        'Analytics report shared successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share analytics report',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // ==================== DATA UPDATE METHODS ====================
  
  /// Update task data for analytics
  void updateTaskData(List<dynamic> tasks) {
    // Update analytics with new task data
    // This method is called by StateManagementService
    refreshDashboard();
  }
  
  /// Update team data for analytics
  void updateTeamData(List<dynamic> teams) {
    // Update analytics with new team data
    // This method is called by StateManagementService
    refreshDashboard();
  }
  
  /// Update project data for analytics
  void updateProjectData(List<dynamic> projects) {
    // Update analytics with new project data
    // This method is called by StateManagementService
    refreshDashboard();
  }
}
