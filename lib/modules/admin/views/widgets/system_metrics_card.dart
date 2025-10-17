import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

/// System Metrics Card Widget
/// Enhanced version of system stats card with trend indicators and additional metrics
class SystemMetricsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? trend;

  const SystemMetricsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and trend
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              
              const Spacer(),
              
              // Trend indicator
              if (trend != null) _buildTrendIndicator(),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingMedium),
          
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: AppDimensions.paddingSmall),
          
          // Value with enhanced styling
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1.0,
                ),
              ),
              
              if (trend != null)
                Padding(
                  padding: const EdgeInsets.only(left: AppDimensions.paddingSmall, bottom: 4),
                  child: Text(
                    trend!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getTrendColor(),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingSmall),
          
          // Subtitle with progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: AppDimensions.paddingSmall),
              
              // Progress indicator based on subtitle
              _buildProgressIndicator(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendIndicator() {
    final isPositive = trend!.startsWith('+');
    final trendColor = _getTrendColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: trendColor,
            size: 12,
          ),
          const SizedBox(width: 2),
          Text(
            trend!,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: trendColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    // Extract numbers from subtitle to create a progress indicator
    final RegExp numberRegex = RegExp(r'\d+');
    final matches = numberRegex.allMatches(subtitle);
    
    if (matches.length >= 2) {
      final active = int.tryParse(matches.first.group(0) ?? '0') ?? 0;
      final total = int.tryParse(value) ?? 1;
      final progress = total > 0 ? active / total : 0.0;
      
      return Column(
        children: [
          const SizedBox(height: AppDimensions.paddingSmall),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ],
      );
    }
    
    return const SizedBox.shrink();
  }

  Color _getTrendColor() {
    if (trend == null) return AppColors.textSecondary;
    
    if (trend!.startsWith('+')) {
      return AppColors.success;
    } else if (trend!.startsWith('-')) {
      return AppColors.error;
    } else {
      return AppColors.warning;
    }
  }
}

