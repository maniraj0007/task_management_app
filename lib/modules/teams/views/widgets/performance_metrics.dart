import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

/// Performance Metrics Widget
/// Displays comprehensive performance metrics for teams
class PerformanceMetrics extends StatelessWidget {
  final String teamId;
  final String period;
  final Map<String, dynamic> metrics;

  const PerformanceMetrics({
    super.key,
    required this.teamId,
    required this.period,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.speed, color: AppColors.primary),
              const SizedBox(width: AppDimensions.paddingSmall),
              Text(
                'Performance Metrics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getPeriodLabel(period),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Metrics Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppDimensions.paddingMedium,
            mainAxisSpacing: AppDimensions.paddingMedium,
            childAspectRatio: 1.5,
            children: [
              _buildMetricCard(
                'Completion Rate',
                '${metrics['completionRate'] ?? 0}%',
                Icons.check_circle,
                AppColors.success,
                '${metrics['completionRateChange'] ?? 0}%',
              ),
              _buildMetricCard(
                'Quality Score',
                '${metrics['qualityScore'] ?? 0}%',
                Icons.star,
                AppColors.warning,
                '${metrics['qualityScoreChange'] ?? 0}%',
              ),
              _buildMetricCard(
                'Velocity',
                '${metrics['velocity'] ?? 0} pts',
                Icons.speed,
                AppColors.primary,
                '${metrics['velocityChange'] ?? 0}%',
              ),
              _buildMetricCard(
                'Efficiency',
                '${metrics['efficiency'] ?? 0}%',
                Icons.trending_up,
                AppColors.tertiary,
                '${metrics['efficiencyChange'] ?? 0}%',
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Performance Indicators
          _buildPerformanceIndicators(),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Key Performance Areas
          _buildKeyPerformanceAreas(),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, String change) {
    final isPositive = change.startsWith('+') || (!change.startsWith('-') && double.tryParse(change.replaceAll('%', '')) != null && double.parse(change.replaceAll('%', '')) > 0);
    final changeColor = isPositive ? AppColors.success : AppColors.error;
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and change indicator
          Row(
            children: [
              Icon(icon, color: color, size: 20),
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
          
          const SizedBox(height: AppDimensions.paddingSmall),
          
          // Value
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Label
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceIndicators() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Indicators',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: AppDimensions.paddingMedium),
        
        // Burndown Rate
        _buildIndicatorRow(
          'Burndown Rate',
          metrics['burndownRate'] ?? 0.0,
          Icons.trending_down,
          AppColors.primary,
        ),
        
        const SizedBox(height: AppDimensions.paddingSmall),
        
        // Sprint Success Rate
        _buildIndicatorRow(
          'Sprint Success',
          metrics['sprintSuccessRate'] ?? 0.0,
          Icons.flag,
          AppColors.success,
        ),
        
        const SizedBox(height: AppDimensions.paddingSmall),
        
        // Code Review Rate
        _buildIndicatorRow(
          'Code Review Rate',
          metrics['codeReviewRate'] ?? 0.0,
          Icons.rate_review,
          AppColors.secondary,
        ),
        
        const SizedBox(height: AppDimensions.paddingSmall),
        
        // Bug Resolution Time
        _buildIndicatorRow(
          'Bug Resolution',
          metrics['bugResolutionTime'] ?? 0.0,
          Icons.bug_report,
          AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildIndicatorRow(String label, double value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: AppDimensions.paddingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Text(
                    '${value.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: value / 100,
                backgroundColor: AppColors.outline.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyPerformanceAreas() {
    final areas = [
      {
        'title': 'Communication',
        'score': metrics['communicationScore'] ?? 85,
        'icon': Icons.chat,
        'color': AppColors.primary,
      },
      {
        'title': 'Collaboration',
        'score': metrics['collaborationScore'] ?? 92,
        'icon': Icons.group_work,
        'color': AppColors.success,
      },
      {
        'title': 'Innovation',
        'score': metrics['innovationScore'] ?? 78,
        'icon': Icons.lightbulb,
        'color': AppColors.warning,
      },
      {
        'title': 'Delivery',
        'score': metrics['deliveryScore'] ?? 88,
        'icon': Icons.delivery_dining,
        'color': AppColors.tertiary,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Performance Areas',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: AppDimensions.paddingMedium),
        
        Row(
          children: areas.map((area) => Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: AppDimensions.paddingSmall),
              child: _buildPerformanceArea(
                area['title'] as String,
                area['score'] as int,
                area['icon'] as IconData,
                area['color'] as Color,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildPerformanceArea(String title, int score, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            '$score%',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case '7d': return 'Last 7 Days';
      case '30d': return 'Last 30 Days';
      case '90d': return 'Last 90 Days';
      case '1y': return 'Last Year';
      default: return period;
    }
  }
}
