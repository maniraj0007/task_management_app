import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

/// Analytics Data Model
/// Represents various analytics data points for the dashboard
class AnalyticsDataModel {
  final String id;
  final String type; // task, user, team, project
  final String metric; // completion_rate, productivity, engagement, etc.
  final double value;
  final DateTime timestamp;
  final String? userId;
  final String? teamId;
  final String? projectId;
  final Map<String, dynamic> metadata;

  const AnalyticsDataModel({
    required this.id,
    required this.type,
    required this.metric,
    required this.value,
    required this.timestamp,
    this.userId,
    this.teamId,
    this.projectId,
    this.metadata = const {},
  });

  /// Create from Firestore document
  factory AnalyticsDataModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AnalyticsDataModel(
      id: doc.id,
      type: data['type'] ?? '',
      metric: data['metric'] ?? '',
      value: (data['value'] ?? 0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'],
      teamId: data['teamId'],
      projectId: data['projectId'],
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'metric': metric,
      'value': value,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
      'teamId': teamId,
      'projectId': projectId,
      'metadata': metadata,
    };
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'metric': metric,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'teamId': teamId,
      'projectId': projectId,
      'metadata': metadata,
    };
  }

  /// Create copy with updated fields
  AnalyticsDataModel copyWith({
    String? id,
    String? type,
    String? metric,
    double? value,
    DateTime? timestamp,
    String? userId,
    String? teamId,
    String? projectId,
    Map<String, dynamic>? metadata,
  }) {
    return AnalyticsDataModel(
      id: id ?? this.id,
      type: type ?? this.type,
      metric: metric ?? this.metric,
      value: value ?? this.value,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      teamId: teamId ?? this.teamId,
      projectId: projectId ?? this.projectId,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Dashboard Metrics Model
/// Aggregated metrics for dashboard display
class DashboardMetricsModel {
  final TaskMetrics taskMetrics;
  final UserMetrics userMetrics;
  final TeamMetrics teamMetrics;
  final ProjectMetrics projectMetrics;
  final SystemMetrics systemMetrics;

  const DashboardMetricsModel({
    required this.taskMetrics,
    required this.userMetrics,
    required this.teamMetrics,
    required this.projectMetrics,
    required this.systemMetrics,
  });

  /// Create from JSON
  factory DashboardMetricsModel.fromJson(Map<String, dynamic> json) {
    return DashboardMetricsModel(
      taskMetrics: TaskMetrics.fromJson(json['taskMetrics'] ?? {}),
      userMetrics: UserMetrics.fromJson(json['userMetrics'] ?? {}),
      teamMetrics: TeamMetrics.fromJson(json['teamMetrics'] ?? {}),
      projectMetrics: ProjectMetrics.fromJson(json['projectMetrics'] ?? {}),
      systemMetrics: SystemMetrics.fromJson(json['systemMetrics'] ?? {}),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'taskMetrics': taskMetrics.toJson(),
      'userMetrics': userMetrics.toJson(),
      'teamMetrics': teamMetrics.toJson(),
      'projectMetrics': projectMetrics.toJson(),
      'systemMetrics': systemMetrics.toJson(),
    };
  }
}

/// Task Metrics
class TaskMetrics {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int overdueTasks;
  final double completionRate;
  final double averageCompletionTime; // in hours
  final List<FlSpot> completionTrend;
  final Map<String, int> tasksByPriority;
  final Map<String, int> tasksByStatus;

  const TaskMetrics({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.overdueTasks,
    required this.completionRate,
    required this.averageCompletionTime,
    required this.completionTrend,
    required this.tasksByPriority,
    required this.tasksByStatus,
  });

  factory TaskMetrics.fromJson(Map<String, dynamic> json) {
    return TaskMetrics(
      totalTasks: json['totalTasks'] ?? 0,
      completedTasks: json['completedTasks'] ?? 0,
      pendingTasks: json['pendingTasks'] ?? 0,
      overdueTasks: json['overdueTasks'] ?? 0,
      completionRate: (json['completionRate'] ?? 0).toDouble(),
      averageCompletionTime: (json['averageCompletionTime'] ?? 0).toDouble(),
      completionTrend: (json['completionTrend'] as List<dynamic>?)
          ?.map((e) => FlSpot(e['x'].toDouble(), e['y'].toDouble()))
          .toList() ?? [],
      tasksByPriority: Map<String, int>.from(json['tasksByPriority'] ?? {}),
      tasksByStatus: Map<String, int>.from(json['tasksByStatus'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'pendingTasks': pendingTasks,
      'overdueTasks': overdueTasks,
      'completionRate': completionRate,
      'averageCompletionTime': averageCompletionTime,
      'completionTrend': completionTrend.map((e) => {'x': e.x, 'y': e.y}).toList(),
      'tasksByPriority': tasksByPriority,
      'tasksByStatus': tasksByStatus,
    };
  }
}

/// User Metrics
class UserMetrics {
  final int totalUsers;
  final int activeUsers;
  final int newUsersThisMonth;
  final double userEngagementRate;
  final List<FlSpot> userGrowthTrend;
  final Map<String, int> usersByRole;
  final Map<String, double> userProductivity;

  const UserMetrics({
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsersThisMonth,
    required this.userEngagementRate,
    required this.userGrowthTrend,
    required this.usersByRole,
    required this.userProductivity,
  });

  factory UserMetrics.fromJson(Map<String, dynamic> json) {
    return UserMetrics(
      totalUsers: json['totalUsers'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      newUsersThisMonth: json['newUsersThisMonth'] ?? 0,
      userEngagementRate: (json['userEngagementRate'] ?? 0).toDouble(),
      userGrowthTrend: (json['userGrowthTrend'] as List<dynamic>?)
          ?.map((e) => FlSpot(e['x'].toDouble(), e['y'].toDouble()))
          .toList() ?? [],
      usersByRole: Map<String, int>.from(json['usersByRole'] ?? {}),
      userProductivity: Map<String, double>.from(json['userProductivity'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
      'newUsersThisMonth': newUsersThisMonth,
      'userEngagementRate': userEngagementRate,
      'userGrowthTrend': userGrowthTrend.map((e) => {'x': e.x, 'y': e.y}).toList(),
      'usersByRole': usersByRole,
      'userProductivity': userProductivity,
    };
  }
}

/// Team Metrics
class TeamMetrics {
  final int totalTeams;
  final int activeTeams;
  final double averageTeamSize;
  final double teamCollaborationScore;
  final List<FlSpot> teamPerformanceTrend;
  final Map<String, double> teamProductivity;
  final Map<String, int> teamTaskDistribution;

  const TeamMetrics({
    required this.totalTeams,
    required this.activeTeams,
    required this.averageTeamSize,
    required this.teamCollaborationScore,
    required this.teamPerformanceTrend,
    required this.teamProductivity,
    required this.teamTaskDistribution,
  });

  factory TeamMetrics.fromJson(Map<String, dynamic> json) {
    return TeamMetrics(
      totalTeams: json['totalTeams'] ?? 0,
      activeTeams: json['activeTeams'] ?? 0,
      averageTeamSize: (json['averageTeamSize'] ?? 0).toDouble(),
      teamCollaborationScore: (json['teamCollaborationScore'] ?? 0).toDouble(),
      teamPerformanceTrend: (json['teamPerformanceTrend'] as List<dynamic>?)
          ?.map((e) => FlSpot(e['x'].toDouble(), e['y'].toDouble()))
          .toList() ?? [],
      teamProductivity: Map<String, double>.from(json['teamProductivity'] ?? {}),
      teamTaskDistribution: Map<String, int>.from(json['teamTaskDistribution'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTeams': totalTeams,
      'activeTeams': activeTeams,
      'averageTeamSize': averageTeamSize,
      'teamCollaborationScore': teamCollaborationScore,
      'teamPerformanceTrend': teamPerformanceTrend.map((e) => {'x': e.x, 'y': e.y}).toList(),
      'teamProductivity': teamProductivity,
      'teamTaskDistribution': teamTaskDistribution,
    };
  }
}

/// Project Metrics
class ProjectMetrics {
  final int totalProjects;
  final int activeProjects;
  final int completedProjects;
  final double projectSuccessRate;
  final List<FlSpot> projectProgressTrend;
  final Map<String, double> projectHealth;
  final Map<String, int> projectsByStatus;

  const ProjectMetrics({
    required this.totalProjects,
    required this.activeProjects,
    required this.completedProjects,
    required this.projectSuccessRate,
    required this.projectProgressTrend,
    required this.projectHealth,
    required this.projectsByStatus,
  });

  factory ProjectMetrics.fromJson(Map<String, dynamic> json) {
    return ProjectMetrics(
      totalProjects: json['totalProjects'] ?? 0,
      activeProjects: json['activeProjects'] ?? 0,
      completedProjects: json['completedProjects'] ?? 0,
      projectSuccessRate: (json['projectSuccessRate'] ?? 0).toDouble(),
      projectProgressTrend: (json['projectProgressTrend'] as List<dynamic>?)
          ?.map((e) => FlSpot(e['x'].toDouble(), e['y'].toDouble()))
          .toList() ?? [],
      projectHealth: Map<String, double>.from(json['projectHealth'] ?? {}),
      projectsByStatus: Map<String, int>.from(json['projectsByStatus'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalProjects': totalProjects,
      'activeProjects': activeProjects,
      'completedProjects': completedProjects,
      'projectSuccessRate': projectSuccessRate,
      'projectProgressTrend': projectProgressTrend.map((e) => {'x': e.x, 'y': e.y}).toList(),
      'projectHealth': projectHealth,
      'projectsByStatus': projectsByStatus,
    };
  }
}

/// System Metrics
class SystemMetrics {
  final double systemUptime;
  final int totalNotifications;
  final double averageResponseTime;
  final int errorCount;
  final List<FlSpot> systemPerformanceTrend;
  final Map<String, int> featureUsage;
  final Map<String, double> systemHealth;

  const SystemMetrics({
    required this.systemUptime,
    required this.totalNotifications,
    required this.averageResponseTime,
    required this.errorCount,
    required this.systemPerformanceTrend,
    required this.featureUsage,
    required this.systemHealth,
  });

  factory SystemMetrics.fromJson(Map<String, dynamic> json) {
    return SystemMetrics(
      systemUptime: (json['systemUptime'] ?? 0).toDouble(),
      totalNotifications: json['totalNotifications'] ?? 0,
      averageResponseTime: (json['averageResponseTime'] ?? 0).toDouble(),
      errorCount: json['errorCount'] ?? 0,
      systemPerformanceTrend: (json['systemPerformanceTrend'] as List<dynamic>?)
          ?.map((e) => FlSpot(e['x'].toDouble(), e['y'].toDouble()))
          .toList() ?? [],
      featureUsage: Map<String, int>.from(json['featureUsage'] ?? {}),
      systemHealth: Map<String, double>.from(json['systemHealth'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'systemUptime': systemUptime,
      'totalNotifications': totalNotifications,
      'averageResponseTime': averageResponseTime,
      'errorCount': errorCount,
      'systemPerformanceTrend': systemPerformanceTrend.map((e) => {'x': e.x, 'y': e.y}).toList(),
      'featureUsage': featureUsage,
      'systemHealth': systemHealth,
    };
  }
}
