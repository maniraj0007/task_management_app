import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/admin_controller.dart';
import '../widgets/analytics_chart_card.dart';
import '../widgets/system_metrics_card.dart';
import '../widgets/analytics_period_selector.dart';

/// System Analytics Screen
/// Comprehensive analytics and insights for system administrators
class SystemAnalyticsScreen extends StatelessWidget {
  const SystemAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminController = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'System Analytics',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          // Export button
          IconButton(
            onPressed: () => _showExportDialog(context),
            icon: const Icon(Icons.download),
            tooltip: 'Export Analytics',
          ),
          
          // Refresh button
          Obx(() => IconButton(
            onPressed: adminController.isLoadingOverview.value
                ? null
                : () => adminController.refreshAdminData(),
            icon: adminController.isLoadingOverview.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
          )),
          
          const SizedBox(width: AppDimensions.paddingSmall),
        ],
      ),
      body: Obx(() {
        // Check admin access
        if (!adminController.hasAdminAccess) {
          return _buildAccessDenied();
        }

        // Show loading state
        if (adminController.isLoadingOverview.value && adminController.systemOverview.isEmpty) {
          return _buildLoadingState();
        }

        // Show error state
        if (adminController.error.value.isNotEmpty) {
          return _buildErrorState(adminController);
        }

        return RefreshIndicator(
          onRefresh: () => adminController.refreshAdminData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Analytics header
                _buildAnalyticsHeader(adminController),
                
                const SizedBox(height: AppDimensions.paddingLarge),
                
                // Period selector
                AnalyticsPeriodSelector(
                  onPeriodChanged: (period) => _handlePeriodChange(adminController, period),
                ),
                
                const SizedBox(height: AppDimensions.paddingLarge),
                
                // System health overview
                _buildSystemHealthOverview(adminController),
                
                const SizedBox(height: AppDimensions.paddingLarge),
                
                // Key metrics
                _buildKeyMetricsSection(adminController),
                
                const SizedBox(height: AppDimensions.paddingLarge),
                
                // User analytics
                _buildUserAnalyticsSection(adminController),
                
                const SizedBox(height: AppDimensions.paddingLarge),
                
                // Task analytics
                _buildTaskAnalyticsSection(adminController),
                
                const SizedBox(height: AppDimensions.paddingLarge),
                
                // Team analytics
                _buildTeamAnalyticsSection(adminController),
                
                const SizedBox(height: AppDimensions.paddingLarge),
                
                // Performance insights
                _buildPerformanceInsightsSection(adminController),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAccessDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock,
            size: 64,
            color: AppColors.error.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Text(
            'Access Denied',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            'You do not have permission to access system analytics.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppDimensions.paddingLarge),
          Text('Loading analytics...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(AdminController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Text(
            'Error Loading Analytics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            controller.error.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          ElevatedButton(
            onPressed: () => controller.refreshAdminData(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsHeader(AdminController controller) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Analytics',
                  style: TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                Text(
                  'Comprehensive insights and performance metrics',
                  style: TextStyle(
                    color: AppColors.onPrimary.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                Row(
                  children: [
                    _buildHeaderStat('Health Score', '${controller.systemHealthScore.toInt()}%'),
                    const SizedBox(width: AppDimensions.paddingLarge),
                    _buildHeaderStat('Status', controller.systemHealthStatus),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.analytics,
            color: AppColors.onPrimary,
            size: 48,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColors.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.onPrimary.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSystemHealthOverview(AdminController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Health Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: AppColors.outline.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              // Health score indicator
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(int.parse(controller.systemHealthColor.replaceAll('#', '0xFF'))).withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    '${controller.systemHealthScore.toInt()}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(int.parse(controller.systemHealthColor.replaceAll('#', '0xFF'))),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: AppDimensions.paddingLarge),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Status: ${controller.systemHealthStatus}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    Text(
                      _getHealthDescription(controller.systemHealthScore),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyMetricsSection(AdminController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppDimensions.paddingMedium,
            mainAxisSpacing: AppDimensions.paddingMedium,
            childAspectRatio: 1.5,
          ),
          itemCount: controller.formattedSystemStats.length,
          itemBuilder: (context, index) {
            final stat = controller.formattedSystemStats[index];
            return SystemMetricsCard(
              title: stat['title'],
              value: stat['value'].toString(),
              subtitle: stat['subtitle'],
              icon: _getIconData(stat['icon']),
              color: _getColorFromString(stat['color']),
              trend: _getTrendForMetric(stat['title']),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUserAnalyticsSection(AdminController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Analytics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        Row(
          children: [
            Expanded(
              child: AnalyticsChartCard(
                title: 'User Roles Distribution',
                data: controller.formattedRoleDistribution,
                chartType: ChartType.pie,
                height: 250,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: AnalyticsChartCard(
                title: 'User Activity Trend',
                data: _generateUserActivityData(),
                chartType: ChartType.line,
                height: 250,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskAnalyticsSection(AdminController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Analytics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        Row(
          children: [
            Expanded(
              child: AnalyticsChartCard(
                title: 'Task Status Distribution',
                data: controller.formattedTaskStatusDistribution,
                chartType: ChartType.bar,
                height: 250,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: AnalyticsChartCard(
                title: 'Task Completion Trend',
                data: _generateTaskCompletionData(),
                chartType: ChartType.area,
                height: 250,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamAnalyticsSection(AdminController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Team Analytics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        AnalyticsChartCard(
          title: 'Team Performance Overview',
          data: _generateTeamPerformanceData(),
          chartType: ChartType.bar,
          height: 200,
        ),
      ],
    );
  }

  Widget _buildPerformanceInsightsSection(AdminController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Insights',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: AppColors.outline.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb, color: AppColors.warning),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  Text(
                    'AI-Powered Insights',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              ..._generateInsights(controller).map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.arrow_right,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Expanded(
                      child: Text(
                        insight,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  // Helper methods
  String _getHealthDescription(double score) {
    if (score >= 80) return 'System is performing excellently with optimal metrics.';
    if (score >= 60) return 'System is performing well with good overall health.';
    if (score >= 40) return 'System performance is fair, some areas need attention.';
    if (score >= 20) return 'System performance is poor, immediate action required.';
    return 'System is in critical condition, urgent intervention needed.';
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'people': return Icons.people;
      case 'groups': return Icons.groups;
      case 'task': return Icons.task;
      case 'folder': return Icons.folder;
      default: return Icons.info;
    }
  }

  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'primary': return AppColors.primary;
      case 'success': return AppColors.success;
      case 'info': return AppColors.info;
      case 'warning': return AppColors.warning;
      case 'error': return AppColors.error;
      default: return AppColors.primary;
    }
  }

  String _getTrendForMetric(String metricName) {
    // Mock trend data - in real app, this would come from historical data
    switch (metricName) {
      case 'Total Users': return '+12%';
      case 'Total Teams': return '+8%';
      case 'Total Tasks': return '+25%';
      case 'Total Projects': return '+15%';
      default: return '+5%';
    }
  }

  List<Map<String, dynamic>> _generateUserActivityData() {
    return [
      {'label': 'Mon', 'value': 45.0},
      {'label': 'Tue', 'value': 52.0},
      {'label': 'Wed', 'value': 48.0},
      {'label': 'Thu', 'value': 61.0},
      {'label': 'Fri', 'value': 55.0},
      {'label': 'Sat', 'value': 32.0},
      {'label': 'Sun', 'value': 28.0},
    ];
  }

  List<Map<String, dynamic>> _generateTaskCompletionData() {
    return [
      {'label': 'Week 1', 'value': 85.0},
      {'label': 'Week 2', 'value': 92.0},
      {'label': 'Week 3', 'value': 78.0},
      {'label': 'Week 4', 'value': 95.0},
    ];
  }

  List<Map<String, dynamic>> _generateTeamPerformanceData() {
    return [
      {'label': 'Development', 'value': 88.0},
      {'label': 'Design', 'value': 92.0},
      {'label': 'Marketing', 'value': 76.0},
      {'label': 'Sales', 'value': 84.0},
    ];
  }

  List<String> _generateInsights(AdminController controller) {
    final insights = <String>[];
    final stats = controller.systemStats;
    
    if (stats.isNotEmpty) {
      final activeUsers = stats['activeUsers'] as int? ?? 0;
      final totalUsers = stats['totalUsers'] as int? ?? 0;
      
      if (totalUsers > 0) {
        final activePercentage = (activeUsers / totalUsers * 100).round();
        if (activePercentage < 70) {
          insights.add('User engagement is below optimal levels. Consider implementing user retention strategies.');
        }
      }
      
      final completedTasks = stats['completedTasks'] as int? ?? 0;
      final totalTasks = stats['totalTasks'] as int? ?? 0;
      
      if (totalTasks > 0) {
        final completionRate = (completedTasks / totalTasks * 100).round();
        if (completionRate > 85) {
          insights.add('Excellent task completion rate! Teams are highly productive.');
        } else if (completionRate < 60) {
          insights.add('Task completion rate could be improved. Consider reviewing task assignment and deadlines.');
        }
      }
    }
    
    if (insights.isEmpty) {
      insights.addAll([
        'System performance is stable across all key metrics.',
        'User activity patterns show consistent engagement throughout the week.',
        'Team collaboration features are being utilized effectively.',
      ]);
    }
    
    return insights;
  }

  void _handlePeriodChange(AdminController controller, String period) {
    // Handle period change - refresh data for selected period
    controller.refreshAdminData();
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Analytics'),
        content: const Text('Choose export format:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Export as PDF
              _exportAnalytics('pdf');
            },
            child: const Text('PDF'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Export as CSV
              _exportAnalytics('csv');
            },
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _exportAnalytics(String format) {
    // Mock export functionality
    Get.snackbar(
      'Export Started',
      'Analytics data is being exported as $format...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

enum ChartType { pie, bar, line, area }
