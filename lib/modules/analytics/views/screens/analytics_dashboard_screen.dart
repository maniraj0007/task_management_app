import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/analytics_controller.dart';
import '../widgets/analytics_overview_card.dart';
import '../widgets/analytics_chart_card.dart';
import '../widgets/analytics_kpi_card.dart';
import '../widgets/analytics_time_range_selector.dart';
import '../widgets/analytics_metric_type_selector.dart';

/// Analytics Dashboard Screen
/// Main dashboard displaying comprehensive analytics and insights
class AnalyticsDashboardScreen extends GetView<AnalyticsController> {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Analytics Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          // Time range selector
          const AnalyticsTimeRangeSelector(),
          
          // Export button
          IconButton(
            onPressed: controller.exportAnalyticsData,
            icon: const Icon(Icons.download),
            tooltip: 'Export Data',
          ),
          
          // Share button
          IconButton(
            onPressed: controller.shareAnalyticsReport,
            icon: const Icon(Icons.share),
            tooltip: 'Share Report',
          ),
          
          // Refresh button
          IconButton(
            onPressed: controller.refreshDashboard,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading && !controller.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.hasData) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshDashboard,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Metric type selector
                const AnalyticsMetricTypeSelector(),
                
                const SizedBox(height: AppDimensions.spacingLarge),
                
                // KPI Cards
                _buildKPISection(),
                
                const SizedBox(height: AppDimensions.spacingLarge),
                
                // Overview Cards
                _buildOverviewSection(),
                
                const SizedBox(height: AppDimensions.spacingLarge),
                
                // Charts Section
                _buildChartsSection(),
                
                const SizedBox(height: AppDimensions.spacingLarge),
                
                // Detailed Analytics
                _buildDetailedAnalyticsSection(),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Build KPI section
  Widget _buildKPISection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Performance Indicators',
          style: Get.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        
        Obx(() {
          final kpis = controller.keyPerformanceIndicators;
          
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: AppDimensions.spacingMedium,
            crossAxisSpacing: AppDimensions.spacingMedium,
            childAspectRatio: 1.5,
            children: [
              AnalyticsKPICard(
                title: 'Task Completion',
                value: '${kpis['taskCompletionRate']?.toStringAsFixed(1) ?? '0'}%',
                icon: Icons.task_alt,
                color: Colors.green,
                trend: _getTrendForKPI('taskCompletionRate'),
              ),
              AnalyticsKPICard(
                title: 'User Engagement',
                value: '${kpis['userEngagementRate']?.toStringAsFixed(1) ?? '0'}%',
                icon: Icons.people,
                color: Colors.blue,
                trend: _getTrendForKPI('userEngagementRate'),
              ),
              AnalyticsKPICard(
                title: 'Team Collaboration',
                value: '${kpis['teamCollaborationScore']?.toStringAsFixed(1) ?? '0'}%',
                icon: Icons.group_work,
                color: Colors.purple,
                trend: _getTrendForKPI('teamCollaborationScore'),
              ),
              AnalyticsKPICard(
                title: 'System Uptime',
                value: '${kpis['systemUptime']?.toStringAsFixed(1) ?? '0'}%',
                icon: Icons.cloud_done,
                color: Colors.orange,
                trend: _getTrendForKPI('systemUptime'),
              ),
            ],
          );
        }),
      ],
    );
  }

  /// Build overview section
  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Get.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        
        Obx(() {
          return Column(
            children: [
              // Task Overview
              if (controller.selectedMetricType == 'overview' || 
                  controller.selectedMetricType == 'tasks')
                AnalyticsOverviewCard(
                  title: 'Tasks Overview',
                  metrics: controller.taskMetrics,
                  type: AnalyticsOverviewType.tasks,
                ),
              
              const SizedBox(height: AppDimensions.spacingMedium),
              
              // User Overview
              if (controller.selectedMetricType == 'overview' || 
                  controller.selectedMetricType == 'users')
                AnalyticsOverviewCard(
                  title: 'Users Overview',
                  metrics: controller.userMetrics,
                  type: AnalyticsOverviewType.users,
                ),
              
              const SizedBox(height: AppDimensions.spacingMedium),
              
              // Team Overview
              if (controller.selectedMetricType == 'overview' || 
                  controller.selectedMetricType == 'teams')
                AnalyticsOverviewCard(
                  title: 'Teams Overview',
                  metrics: controller.teamMetrics,
                  type: AnalyticsOverviewType.teams,
                ),
              
              const SizedBox(height: AppDimensions.spacingMedium),
              
              // Project Overview
              if (controller.selectedMetricType == 'overview' || 
                  controller.selectedMetricType == 'projects')
                AnalyticsOverviewCard(
                  title: 'Projects Overview',
                  metrics: controller.projectMetrics,
                  type: AnalyticsOverviewType.projects,
                ),
            ],
          );
        }),
      ],
    );
  }

  /// Build charts section
  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trends & Analytics',
          style: Get.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        
        Obx(() {
          return Column(
            children: [
              // Task Completion Trend
              if (controller.selectedMetricType == 'overview' || 
                  controller.selectedMetricType == 'tasks')
                AnalyticsChartCard(
                  title: 'Task Completion Trend',
                  chartType: AnalyticsChartType.line,
                  data: controller.taskCompletionTrendData,
                  color: Colors.green,
                ),
              
              const SizedBox(height: AppDimensions.spacingMedium),
              
              // User Growth Trend
              if (controller.selectedMetricType == 'overview' || 
                  controller.selectedMetricType == 'users')
                AnalyticsChartCard(
                  title: 'User Growth Trend',
                  chartType: AnalyticsChartType.line,
                  data: controller.userGrowthTrendData,
                  color: Colors.blue,
                ),
              
              const SizedBox(height: AppDimensions.spacingMedium),
              
              // Task Status Distribution
              if (controller.selectedMetricType == 'overview' || 
                  controller.selectedMetricType == 'tasks')
                AnalyticsChartCard(
                  title: 'Task Status Distribution',
                  chartType: AnalyticsChartType.pie,
                  pieData: controller.taskStatusPieData,
                ),
              
              const SizedBox(height: AppDimensions.spacingMedium),
              
              // Feature Usage
              if (controller.selectedMetricType == 'overview' || 
                  controller.selectedMetricType == 'system')
                AnalyticsChartCard(
                  title: 'Feature Usage',
                  chartType: AnalyticsChartType.bar,
                  barData: controller.featureUsageBarData,
                ),
            ],
          );
        }),
      ],
    );
  }

  /// Build detailed analytics section
  Widget _buildDetailedAnalyticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Analytics',
          style: Get.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        
        Obx(() {
          return Column(
            children: [
              // Growth Metrics
              _buildMetricsCard(
                'Growth Metrics',
                controller.growthMetrics,
                Icons.trending_up,
                Colors.green,
              ),
              
              const SizedBox(height: AppDimensions.spacingMedium),
              
              // Productivity Metrics
              _buildMetricsCard(
                'Productivity Metrics',
                controller.productivityMetrics,
                Icons.speed,
                Colors.orange,
              ),
            ],
          );
        }),
      ],
    );
  }

  /// Build metrics card
  Widget _buildMetricsCard(
    String title,
    Map<String, dynamic> metrics,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spacingMedium),
          
          // Metrics
          Wrap(
            spacing: AppDimensions.spacingMedium,
            runSpacing: AppDimensions.spacingSmall,
            children: metrics.entries.map((entry) {
              return _buildMetricItem(entry.key, entry.value);
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Build metric item
  Widget _buildMetricItem(String key, dynamic value) {
    String displayValue;
    if (value is double) {
      displayValue = value.toStringAsFixed(1);
    } else {
      displayValue = value.toString();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatMetricKey(key),
            style: Get.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            displayValue,
            style: Get.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Format metric key for display
  String _formatMetricKey(String key) {
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ')
        .trim();
  }

  /// Get trend for KPI (mock implementation)
  double _getTrendForKPI(String kpi) {
    // This would typically calculate actual trend from historical data
    switch (kpi) {
      case 'taskCompletionRate':
        return 5.2;
      case 'userEngagementRate':
        return -2.1;
      case 'teamCollaborationScore':
        return 8.7;
      case 'systemUptime':
        return 0.3;
      default:
        return 0.0;
    }
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(
            'No Analytics Data Available',
            style: Get.textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            'Analytics data will appear here once you start using the app.',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          ElevatedButton.icon(
            onPressed: controller.refreshDashboard,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Data'),
          ),
        ],
      ),
    );
  }
}

/// Analytics Overview Type Enum
enum AnalyticsOverviewType {
  tasks,
  users,
  teams,
  projects,
  system,
}

/// Analytics Chart Type Enum
enum AnalyticsChartType {
  line,
  pie,
  bar,
}
