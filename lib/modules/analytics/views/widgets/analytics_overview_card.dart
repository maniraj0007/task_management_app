import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../models/analytics_data_model.dart';
import '../../screens/analytics_dashboard_screen.dart';

/// Analytics Overview Card Widget
/// Displays overview metrics for different categories
class AnalyticsOverviewCard extends StatelessWidget {
  final String title;
  final dynamic metrics;
  final AnalyticsOverviewType type;
  final VoidCallback? onTap;

  const AnalyticsOverviewCard({
    super.key,
    required this.title,
    required this.metrics,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                
                const SizedBox(height: AppDimensions.spacingMedium),
                
                // Metrics grid
                _buildMetricsGrid(),
                
                const SizedBox(height: AppDimensions.spacingMedium),
                
                // Additional info
                _buildAdditionalInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build header
  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          _getTypeIcon(),
          color: _getTypeColor(),
          size: 24,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  /// Build metrics grid
  Widget _buildMetricsGrid() {
    if (metrics == null) {
      return _buildEmptyState();
    }

    switch (type) {
      case AnalyticsOverviewType.tasks:
        return _buildTaskMetrics(metrics as TaskMetrics);
      case AnalyticsOverviewType.users:
        return _buildUserMetrics(metrics as UserMetrics);
      case AnalyticsOverviewType.teams:
        return _buildTeamMetrics(metrics as TeamMetrics);
      case AnalyticsOverviewType.projects:
        return _buildProjectMetrics(metrics as ProjectMetrics);
      case AnalyticsOverviewType.system:
        return _buildSystemMetrics(metrics as SystemMetrics);
    }
  }

  /// Build task metrics
  Widget _buildTaskMetrics(TaskMetrics taskMetrics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                'Total Tasks',
                taskMetrics.totalTasks.toString(),
                Icons.task,
                Colors.blue,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: _buildMetricItem(
                'Completed',
                taskMetrics.completedTasks.toString(),
                Icons.task_alt,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                'Pending',
                taskMetrics.pendingTasks.toString(),
                Icons.pending,
                Colors.orange,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: _buildMetricItem(
                'Overdue',
                taskMetrics.overdueTasks.toString(),
                Icons.warning,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build user metrics
  Widget _buildUserMetrics(UserMetrics userMetrics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                'Total Users',
                userMetrics.totalUsers.toString(),
                Icons.people,
                Colors.blue,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: _buildMetricItem(
                'Active',
                userMetrics.activeUsers.toString(),
                Icons.person,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                'New This Month',
                userMetrics.newUsersThisMonth.toString(),
                Icons.person_add,
                Colors.purple,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: _buildMetricItem(
                'Engagement',
                '${userMetrics.userEngagementRate.toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build team metrics
  Widget _buildTeamMetrics(TeamMetrics teamMetrics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                'Total Teams',
                teamMetrics.totalTeams.toString(),
                Icons.group,
                Colors.blue,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: _buildMetricItem(
                'Active',
                teamMetrics.activeTeams.toString(),
                Icons.group_work,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                'Avg Size',
                teamMetrics.averageTeamSize.toStringAsFixed(1),
                Icons.people_outline,
                Colors.purple,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: _buildMetricItem(
                'Collaboration',
                '${teamMetrics.teamCollaborationScore.toStringAsFixed(1)}%',
                Icons.handshake,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build project metrics
  Widget _buildProjectMetrics(ProjectMetrics projectMetrics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                'Total Projects',
                projectMetrics.totalProjects.toString(),
                Icons.folder,
                Colors.blue,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: _buildMetricItem(
                'Active',
                projectMetrics.activeProjects.toString(),
                Icons.folder_open,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                'Completed',
                projectMetrics.completedProjects.toString(),
                Icons.folder_special,
                Colors.purple,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: _buildMetricItem(
                'Success Rate',
                '${projectMetrics.projectSuccessRate.toStringAsFixed(1)}%',
                Icons.check_circle,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build system metrics
  Widget _buildSystemMetrics(SystemMetrics systemMetrics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                'Uptime',
                '${systemMetrics.systemUptime.toStringAsFixed(1)}%',
                Icons.cloud_done,
                Colors.green,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: _buildMetricItem(
                'Notifications',
                systemMetrics.totalNotifications.toString(),
                Icons.notifications,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                'Response Time',
                '${systemMetrics.averageResponseTime.toStringAsFixed(0)}ms',
                Icons.speed,
                Colors.orange,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: _buildMetricItem(
                'Errors',
                systemMetrics.errorCount.toString(),
                Icons.error,
                systemMetrics.errorCount > 0 ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build metric item
  Widget _buildMetricItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Get.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build additional info
  Widget _buildAdditionalInfo() {
    switch (type) {
      case AnalyticsOverviewType.tasks:
        final taskMetrics = metrics as TaskMetrics;
        return _buildProgressBar(
          'Completion Rate',
          taskMetrics.completionRate / 100,
          Colors.green,
        );
      case AnalyticsOverviewType.users:
        final userMetrics = metrics as UserMetrics;
        return _buildProgressBar(
          'Engagement Rate',
          userMetrics.userEngagementRate / 100,
          Colors.blue,
        );
      case AnalyticsOverviewType.teams:
        final teamMetrics = metrics as TeamMetrics;
        return _buildProgressBar(
          'Collaboration Score',
          teamMetrics.teamCollaborationScore / 100,
          Colors.purple,
        );
      case AnalyticsOverviewType.projects:
        final projectMetrics = metrics as ProjectMetrics;
        return _buildProgressBar(
          'Success Rate',
          projectMetrics.projectSuccessRate / 100,
          Colors.orange,
        );
      case AnalyticsOverviewType.system:
        final systemMetrics = metrics as SystemMetrics;
        return _buildProgressBar(
          'System Health',
          systemMetrics.systemUptime / 100,
          Colors.green,
        );
    }
  }

  /// Build progress bar
  Widget _buildProgressBar(String label, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Get.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: Get.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(
            _getTypeIcon(),
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'No data available',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Get type icon
  IconData _getTypeIcon() {
    switch (type) {
      case AnalyticsOverviewType.tasks:
        return Icons.task_alt;
      case AnalyticsOverviewType.users:
        return Icons.people;
      case AnalyticsOverviewType.teams:
        return Icons.group;
      case AnalyticsOverviewType.projects:
        return Icons.folder;
      case AnalyticsOverviewType.system:
        return Icons.settings;
    }
  }

  /// Get type color
  Color _getTypeColor() {
    switch (type) {
      case AnalyticsOverviewType.tasks:
        return Colors.blue;
      case AnalyticsOverviewType.users:
        return Colors.green;
      case AnalyticsOverviewType.teams:
        return Colors.purple;
      case AnalyticsOverviewType.projects:
        return Colors.orange;
      case AnalyticsOverviewType.system:
        return Colors.grey;
    }
  }
}
