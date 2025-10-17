import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

enum ChartType { pie, bar, line, area }

/// Analytics Overview Chart Widget
/// Displays analytics data in various chart formats
class AnalyticsOverviewChart extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;
  final ChartType chartType;
  final double? height;

  const AnalyticsOverviewChart({
    super.key,
    required this.title,
    required this.data,
    required this.chartType,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 200,
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart title
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: AppDimensions.paddingMedium),
          
          // Chart content
          Expanded(
            child: data.isEmpty ? _buildEmptyState() : _buildChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            'No Data Available',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    switch (chartType) {
      case ChartType.pie:
        return _buildPieChart();
      case ChartType.bar:
        return _buildBarChart();
      case ChartType.line:
        return _buildLineChart();
      case ChartType.area:
        return _buildAreaChart();
    }
  }

  Widget _buildPieChart() {
    return Row(
      children: [
        // Mock pie chart representation
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.secondary,
                  AppColors.tertiary,
                  AppColors.success,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                ),
                child: Center(
                  child: Text(
                    '${data.length}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: AppDimensions.paddingMedium),
        
        // Legend
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.map((item) => _buildLegendItem(item)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    final maxValue = data.isEmpty ? 1.0 : data.map((e) => e['value'] as double).reduce((a, b) => a > b ? a : b);
    
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((item) => _buildBarItem(item, maxValue)).toList(),
          ),
        ),
        
        const SizedBox(height: AppDimensions.paddingSmall),
        
        // X-axis labels
        Row(
          children: data.map((item) => Expanded(
            child: Text(
              item['label'] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Center(
        child: Text(
          'Line Chart\n${data.length} data points',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAreaChart() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withOpacity(0.2),
            AppColors.success.withOpacity(0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Center(
        child: Text(
          'Area Chart\n${data.length} data points',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.success,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Map<String, dynamic> item) {
    final color = item['color'] != null 
        ? Color(int.parse(item['color'].toString().replaceAll('#', '0xFF')))
        : AppColors.primary;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(width: AppDimensions.paddingSmall),
          
          Expanded(
            child: Text(
              item['label'] ?? '',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          
          Text(
            '${item['value']?.toInt() ?? 0}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarItem(Map<String, dynamic> item, double maxValue) {
    final value = item['value'] as double? ?? 0.0;
    final height = (value / maxValue) * 100;
    final color = item['color'] != null 
        ? Color(int.parse(item['color'].toString().replaceAll('#', '0xFF')))
        : AppColors.primary;
    
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusSmall),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
