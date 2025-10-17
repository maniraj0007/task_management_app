import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

enum ChartType { pie, bar, line, area }

/// Analytics Chart Card Widget
/// Displays analytics data in various chart formats with enhanced styling
class AnalyticsChartCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;
  final ChartType chartType;
  final double height;

  const AnalyticsChartCard({
    super.key,
    required this.title,
    required this.data,
    required this.chartType,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
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
          // Header with title and chart type indicator
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSmall,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                ),
                child: Text(
                  _getChartTypeLabel(),
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingMedium),
          
          // Chart content
          Expanded(
            child: data.isEmpty ? _buildEmptyState() : _buildChart(),
          ),
          
          // Data summary
          if (data.isNotEmpty) _buildDataSummary(),
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
            _getChartIcon(),
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            'No Data Available',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            'Data will appear here when available',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary.withOpacity(0.7),
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
        // Enhanced pie chart representation
        Expanded(
          flex: 2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: data.map((item) => _getItemColor(item)).toList(),
                    stops: _generateStops(),
                  ),
                ),
              ),
              
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${data.length}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Items',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: AppDimensions.paddingLarge),
        
        // Enhanced legend
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.map((item) => _buildEnhancedLegendItem(item)).toList(),
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
            children: data.asMap().entries.map((entry) => 
              _buildEnhancedBarItem(entry.value, maxValue, entry.key)
            ).toList(),
          ),
        ),
        
        const SizedBox(height: AppDimensions.paddingMedium),
        
        // Enhanced X-axis labels
        Row(
          children: data.map((item) => Expanded(
            child: Text(
              item['label'] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
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
      child: Stack(
        children: [
          // Mock line path
          CustomPaint(
            size: Size.infinite,
            painter: LineChartPainter(data, AppColors.primary),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.trending_up,
                  color: AppColors.primary,
                  size: 32,
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                Text(
                  'Line Chart',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${data.length} data points',
                  style: TextStyle(
                    color: AppColors.primary.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.area_chart,
              color: AppColors.success,
              size: 32,
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              'Area Chart',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${data.length} data points',
              style: TextStyle(
                color: AppColors.success.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedLegendItem(Map<String, dynamic> item) {
    final color = _getItemColor(item);
    final value = item['value'] as double? ?? 0.0;
    final total = data.fold<double>(0.0, (sum, item) => sum + (item['value'] as double? ?? 0.0));
    final percentage = total > 0 ? (value / total * 100).round() : 0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          
          const SizedBox(width: AppDimensions.paddingSmall),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['label'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          Text(
            '${value.toInt()}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedBarItem(Map<String, dynamic> item, double maxValue, int index) {
    final value = item['value'] as double? ?? 0.0;
    final height = (value / maxValue) * 100;
    final color = _getItemColor(item);
    
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Value label on top of bar
            if (height > 20)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${value.toInt()}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            
            Container(
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
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

  Widget _buildDataSummary() {
    final total = data.fold<double>(0.0, (sum, item) => sum + (item['value'] as double? ?? 0.0));
    final average = data.isNotEmpty ? total / data.length : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total', total.toInt().toString()),
          _buildSummaryItem('Average', average.toStringAsFixed(1)),
          _buildSummaryItem('Items', data.length.toString()),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getItemColor(Map<String, dynamic> item) {
    if (item['color'] != null) {
      try {
        return Color(int.parse(item['color'].toString().replaceAll('#', '0xFF')));
      } catch (e) {
        // Fallback to default color
      }
    }
    return AppColors.primary;
  }

  List<double> _generateStops() {
    if (data.isEmpty) return [0.0, 1.0];
    
    final total = data.fold<double>(0.0, (sum, item) => sum + (item['value'] as double? ?? 0.0));
    double currentStop = 0.0;
    final stops = <double>[];
    
    for (final item in data) {
      stops.add(currentStop);
      currentStop += (item['value'] as double? ?? 0.0) / total;
    }
    stops.add(1.0);
    
    return stops;
  }

  String _getChartTypeLabel() {
    switch (chartType) {
      case ChartType.pie:
        return 'PIE';
      case ChartType.bar:
        return 'BAR';
      case ChartType.line:
        return 'LINE';
      case ChartType.area:
        return 'AREA';
    }
  }

  IconData _getChartIcon() {
    switch (chartType) {
      case ChartType.pie:
        return Icons.pie_chart;
      case ChartType.bar:
        return Icons.bar_chart;
      case ChartType.line:
        return Icons.show_chart;
      case ChartType.area:
        return Icons.area_chart;
    }
  }
}

/// Custom painter for line chart
class LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final Color color;

  LineChartPainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final stepX = size.width / (data.length - 1);
    final maxValue = data.map((e) => e['value'] as double).reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - ((data[i]['value'] as double) / maxValue * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

