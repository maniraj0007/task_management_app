import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../screens/analytics_dashboard_screen.dart';

/// Analytics Chart Card Widget
/// Displays various types of charts (line, pie, bar) in a card format
class AnalyticsChartCard extends StatelessWidget {
  final String title;
  final AnalyticsChartType chartType;
  final List<FlSpot>? data;
  final List<PieChartSectionData>? pieData;
  final List<BarChartGroupData>? barData;
  final Color? color;
  final String? subtitle;
  final VoidCallback? onTap;

  const AnalyticsChartCard({
    super.key,
    required this.title,
    required this.chartType,
    this.data,
    this.pieData,
    this.barData,
    this.color,
    this.subtitle,
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
                
                // Chart
                SizedBox(
                  height: 200,
                  child: _buildChart(),
                ),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        Icon(
          _getChartIcon(),
          color: color ?? AppColors.primary,
          size: 20,
        ),
      ],
    );
  }

  /// Build chart based on type
  Widget _buildChart() {
    switch (chartType) {
      case AnalyticsChartType.line:
        return _buildLineChart();
      case AnalyticsChartType.pie:
        return _buildPieChart();
      case AnalyticsChartType.bar:
        return _buildBarChart();
    }
  }

  /// Build line chart
  Widget _buildLineChart() {
    if (data == null || data!.isEmpty) {
      return _buildEmptyChart();
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toInt().toString(),
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toInt().toString(),
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                );
              },
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.border),
        ),
        minX: 0,
        maxX: data!.isNotEmpty ? data!.last.x : 10,
        minY: 0,
        maxY: data!.isNotEmpty 
            ? data!.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) * 1.2
            : 10,
        lineBarsData: [
          LineChartBarData(
            spots: data!,
            isCurved: true,
            color: color ?? AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: color ?? AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: (color ?? AppColors.primary).withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  /// Build pie chart
  Widget _buildPieChart() {
    if (pieData == null || pieData!.isEmpty) {
      return _buildEmptyChart();
    }

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // Handle touch events if needed
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: pieData!,
      ),
    );
  }

  /// Build bar chart
  Widget _buildBarChart() {
    if (barData == null || barData!.isEmpty) {
      return _buildEmptyChart();
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: barData!.isNotEmpty
            ? barData!
                .map((group) => group.barRods.first.toY)
                .reduce((a, b) => a > b ? a : b) * 1.2
            : 10,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: AppColors.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.round()}',
                TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final labels = ['Tasks', 'Teams', 'Projects', 'Users'];
                final index = value.toInt();
                if (index >= 0 && index < labels.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      labels[index],
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 38,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toInt().toString(),
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: barData!,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            );
          },
        ),
      ),
    );
  }

  /// Build empty chart state
  Widget _buildEmptyChart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getChartIcon(),
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

  /// Get chart icon based on type
  IconData _getChartIcon() {
    switch (chartType) {
      case AnalyticsChartType.line:
        return Icons.show_chart;
      case AnalyticsChartType.pie:
        return Icons.pie_chart;
      case AnalyticsChartType.bar:
        return Icons.bar_chart;
    }
  }
}
