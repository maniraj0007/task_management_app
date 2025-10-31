import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/admin_controller.dart';

/// System Health Indicator Widget
/// Displays system health score with visual indicator and status
class SystemHealthIndicator extends StatelessWidget {
  final AdminController controller;

  const SystemHealthIndicator({
    super.key,
    required this.controller,
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
      child: Row(
        children: [
          // Health score circular indicator
          _buildHealthScoreIndicator(),
          
          const SizedBox(width: AppDimensions.paddingLarge),
          
          // Health status and description
          Expanded(
            child: _buildHealthStatusInfo(),
          ),
          
          // Health trend indicator
          _buildHealthTrendIndicator(),
        ],
      ),
    );
  }

  Widget _buildHealthScoreIndicator() {
    final score = controller.systemHealthScore;
    final color = Color(int.parse(controller.systemHealthColor.replaceAll('#', '0xFF')));
    
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          // Background circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
            ),
          ),
          
          // Progress indicator
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 6,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          
          // Score text
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${score.toInt()}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  'Health',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatusInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Status',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        
        const SizedBox(height: AppDimensions.paddingSmall),
        
        Text(
          controller.systemHealthStatus,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(int.parse(controller.systemHealthColor.replaceAll('#', '0xFF'))),
          ),
        ),
        
        const SizedBox(height: AppDimensions.paddingSmall),
        
        Text(
          _getHealthDescription(controller.systemHealthScore),
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthTrendIndicator() {
    // Mock trend data - in real app, this would come from historical data
    final isPositiveTrend = controller.systemHealthScore > 70;
    
    return Column(
      children: [
        Icon(
          isPositiveTrend ? Icons.trending_up : Icons.trending_down,
          color: isPositiveTrend ? AppColors.success : AppColors.warning,
          size: 24,
        ),
        
        const SizedBox(height: AppDimensions.paddingSmall),
        
        Text(
          isPositiveTrend ? '+5%' : '-2%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isPositiveTrend ? AppColors.success : AppColors.warning,
          ),
        ),
        
        Text(
          '24h',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _getHealthDescription(double score) {
    if (score >= 80) return 'All systems operating optimally';
    if (score >= 60) return 'Good performance across metrics';
    if (score >= 40) return 'Some areas need attention';
    if (score >= 20) return 'Performance issues detected';
    return 'Critical issues require immediate action';
  }
}
