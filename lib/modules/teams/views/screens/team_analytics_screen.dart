import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/strings.dart';
import '../../controllers/team_analytics_controller.dart';
import '../../controllers/team_controller.dart';
import '../widgets/analytics_chart.dart';
import '../widgets/performance_metrics.dart';

/// Team Analytics Screen
/// Comprehensive analytics and insights interface for teams
class TeamAnalyticsScreen extends StatefulWidget {
  final String teamId;

  const TeamAnalyticsScreen({
    super.key,
    required this.teamId,
  });

  @override
  State<TeamAnalyticsScreen> createState() => _TeamAnalyticsScreenState();
}

class _TeamAnalyticsScreenState extends State<TeamAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _analyticsController = Get.find<TeamAnalyticsController>();
  final _teamController = Get.find<TeamController>();
  
  String _selectedPeriod = '30d';
  final List<String> _periods = ['7d', '30d', '90d', '1y'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    await _analyticsController.loadTeamAnalytics(widget.teamId, _selectedPeriod);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Analytics Header
          _buildAnalyticsHeader(),
          
          // Period Selector
          _buildPeriodSelector(),
          
          // Tab Bar
          _buildTabBar(),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildPerformanceTab(),
                _buildProductivityTab(),
                _buildInsightsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Team Analytics'),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: _loadAnalytics,
          icon: const Icon(Icons.refresh),
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('Export Data'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('Share Report'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Analytics Settings'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsHeader() {
    return Obx(() => Container(
      margin: const EdgeInsets.all(AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary,
            AppColors.secondary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: AppColors.onSecondary,
                size: 28,
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Team Analytics',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.onSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Performance insights and metrics',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSecondary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // Health Score
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.onSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Column(
                  children: [
                    Text(
                      'Health Score',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSecondary.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_analyticsController.teamHealthScore}%',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.onSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Key Metrics Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Tasks Completed',
                  _analyticsController.tasksCompleted.toString(),
                  Icons.check_circle,
                  AppColors.success,
                  '+${_analyticsController.tasksCompletedChange}%',
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: _buildMetricCard(
                  'Active Projects',
                  _analyticsController.activeProjects.toString(),
                  Icons.folder_open,
                  AppColors.primary,
                  '+${_analyticsController.activeProjectsChange}%',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingMedium),
          
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Team Members',
                  _analyticsController.teamMembers.toString(),
                  Icons.people,
                  AppColors.tertiary,
                  '+${_analyticsController.teamMembersChange}%',
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: _buildMetricCard(
                  'Avg Response',
                  '${_analyticsController.avgResponseTime}h',
                  Icons.schedule,
                  AppColors.warning,
                  '${_analyticsController.avgResponseTimeChange}%',
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, String change) {
    final isPositive = change.startsWith('+');
    final changeColor = isPositive ? AppColors.success : AppColors.error;
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.onSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppColors.onSecondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: changeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.onSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onSecondary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
      child: Row(
        children: [
          Text(
            'Period:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          ..._periods.map((period) => Padding(
            padding: const EdgeInsets.only(right: AppDimensions.paddingSmall),
            child: FilterChip(
              label: Text(_getPeriodLabel(period)),
              selected: _selectedPeriod == period,
              onSelected: (_) => _changePeriod(period),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: _selectedPeriod == period ? AppColors.primary : AppColors.textSecondary,
                fontWeight: _selectedPeriod == period ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        isScrollable: true,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Performance'),
          Tab(text: 'Productivity'),
          Tab(text: 'Insights'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity Chart
          _buildSectionHeader('Team Activity', Icons.trending_up),
          const SizedBox(height: AppDimensions.paddingMedium),
          Obx(() => AnalyticsChart(
            title: 'Daily Activity',
            data: _analyticsController.activityData,
            type: ChartType.line,
            color: AppColors.primary,
          )),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Task Distribution
          _buildSectionHeader('Task Distribution', Icons.pie_chart),
          const SizedBox(height: AppDimensions.paddingMedium),
          Obx(() => AnalyticsChart(
            title: 'Tasks by Status',
            data: _analyticsController.taskDistributionData,
            type: ChartType.pie,
            color: AppColors.secondary,
          )),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Recent Achievements
          _buildSectionHeader('Recent Achievements', Icons.emoji_events),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildAchievementsList(),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance Metrics
          Obx(() => PerformanceMetrics(
            teamId: widget.teamId,
            period: _selectedPeriod,
            metrics: _analyticsController.performanceMetrics,
          )),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Member Performance
          _buildSectionHeader('Member Performance', Icons.person_outline),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildMemberPerformanceList(),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Performance Trends
          _buildSectionHeader('Performance Trends', Icons.show_chart),
          const SizedBox(height: AppDimensions.paddingMedium),
          Obx(() => AnalyticsChart(
            title: 'Performance Over Time',
            data: _analyticsController.performanceTrendData,
            type: ChartType.area,
            color: AppColors.success,
          )),
        ],
      ),
    );
  }

  Widget _buildProductivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Productivity Overview
          _buildSectionHeader('Productivity Overview', Icons.speed),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildProductivityOverview(),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Time Tracking
          _buildSectionHeader('Time Distribution', Icons.access_time),
          const SizedBox(height: AppDimensions.paddingMedium),
          Obx(() => AnalyticsChart(
            title: 'Time by Category',
            data: _analyticsController.timeDistributionData,
            type: ChartType.bar,
            color: AppColors.tertiary,
          )),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Productivity Tips
          _buildSectionHeader('Productivity Insights', Icons.lightbulb),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildProductivityTips(),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Insights
          _buildSectionHeader('AI-Powered Insights', Icons.psychology),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildAIInsights(),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Recommendations
          _buildSectionHeader('Recommendations', Icons.recommend),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildRecommendations(),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Predictive Analytics
          _buildSectionHeader('Predictive Analytics', Icons.trending_up),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildPredictiveAnalytics(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: AppDimensions.paddingSmall),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsList() {
    return Obx(() => Column(
      children: _analyticsController.recentAchievements.map((achievement) => 
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.success.withOpacity(0.1),
              child: Icon(Icons.emoji_events, color: AppColors.success),
            ),
            title: Text(achievement.title),
            subtitle: Text(achievement.description),
            trailing: Text(
              achievement.date,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ).toList(),
    ));
  }

  Widget _buildMemberPerformanceList() {
    return Obx(() => Column(
      children: _analyticsController.memberPerformance.map((member) => 
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                member.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(member.name),
            subtitle: Text('${member.tasksCompleted} tasks completed'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${member.performanceScore}%',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: _getPerformanceColor(member.performanceScore),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  member.trend,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: member.trend.startsWith('+') ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ).toList(),
    ));
  }

  Widget _buildProductivityOverview() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildProductivityMetric(
                  'Focus Time',
                  '${_analyticsController.focusTime}h',
                  Icons.timer,
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildProductivityMetric(
                  'Meetings',
                  '${_analyticsController.meetingTime}h',
                  Icons.video_call,
                  AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Row(
            children: [
              Expanded(
                child: _buildProductivityMetric(
                  'Collaboration',
                  '${_analyticsController.collaborationTime}h',
                  Icons.group_work,
                  AppColors.tertiary,
                ),
              ),
              Expanded(
                child: _buildProductivityMetric(
                  'Break Time',
                  '${_analyticsController.breakTime}h',
                  Icons.coffee,
                  AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildProductivityMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProductivityTips() {
    return Obx(() => Column(
      children: _analyticsController.productivityTips.map((tip) => 
        Card(
          child: ListTile(
            leading: Icon(Icons.lightbulb, color: AppColors.warning),
            title: Text(tip.title),
            subtitle: Text(tip.description),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showTipDetail(tip),
          ),
        ),
      ).toList(),
    ));
  }

  Widget _buildAIInsights() {
    return Obx(() => Column(
      children: _analyticsController.aiInsights.map((insight) => 
        Card(
          color: AppColors.primary.withOpacity(0.05),
          child: ListTile(
            leading: Icon(Icons.psychology, color: AppColors.primary),
            title: Text(insight.title),
            subtitle: Text(insight.description),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getInsightColor(insight.confidence).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${insight.confidence}%',
                style: TextStyle(
                  color: _getInsightColor(insight.confidence),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ).toList(),
    ));
  }

  Widget _buildRecommendations() {
    return Obx(() => Column(
      children: _analyticsController.recommendations.map((recommendation) => 
        Card(
          child: ListTile(
            leading: Icon(Icons.recommend, color: AppColors.success),
            title: Text(recommendation.title),
            subtitle: Text(recommendation.description),
            trailing: ElevatedButton(
              onPressed: () => _implementRecommendation(recommendation),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.onSuccess,
              ),
              child: const Text('Apply'),
            ),
          ),
        ),
      ).toList(),
    ));
  }

  Widget _buildPredictiveAnalytics() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Completion Forecast',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          AnalyticsChart(
            title: 'Predicted vs Actual',
            data: _analyticsController.predictionData,
            type: ChartType.line,
            color: AppColors.tertiary,
          ),
        ],
      ),
    ));
  }

  // Helper methods
  String _getPeriodLabel(String period) {
    switch (period) {
      case '7d': return '7 Days';
      case '30d': return '30 Days';
      case '90d': return '90 Days';
      case '1y': return '1 Year';
      default: return period;
    }
  }

  Color _getPerformanceColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  Color _getInsightColor(int confidence) {
    if (confidence >= 80) return AppColors.success;
    if (confidence >= 60) return AppColors.primary;
    return AppColors.warning;
  }

  void _changePeriod(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    _loadAnalytics();
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportData();
        break;
      case 'share':
        _shareReport();
        break;
      case 'settings':
        _showAnalyticsSettings();
        break;
    }
  }

  void _exportData() {
    Get.snackbar('Export', 'Data export feature coming soon!');
  }

  void _shareReport() {
    Get.snackbar('Share', 'Report sharing feature coming soon!');
  }

  void _showAnalyticsSettings() {
    Get.snackbar('Settings', 'Analytics settings feature coming soon!');
  }

  void _showTipDetail(dynamic tip) {
    Get.snackbar('Tip', tip.description);
  }

  void _implementRecommendation(dynamic recommendation) {
    Get.snackbar('Applied', 'Recommendation applied successfully!');
  }
}
