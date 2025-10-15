import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

/// Chart Types for Analytics
enum ChartType { line, bar, pie, area }

/// Analytics Chart Widget
/// Displays various types of charts for team analytics
class AnalyticsChart extends StatelessWidget {
  final String title;
  final List<dynamic> data;
  final ChartType type;
  final Color color;
  final double? height;

  const AnalyticsChart({
    super.key,
    required this.title,
    required this.data,
    required this.type,
    required this.color,
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
          // Chart Title
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: AppDimensions.paddingMedium),
          
          // Chart Content
          Expanded(
            child: _buildChart(context),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyChart(context);
    }

    switch (type) {
      case ChartType.line:
        return _buildLineChart(context);
      case ChartType.bar:
        return _buildBarChart(context);
      case ChartType.pie:
        return _buildPieChart(context);
      case ChartType.area:
        return _buildAreaChart(context);
    }
  }

  Widget _buildEmptyChart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            'No data available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: LineChartPainter(
        data: data,
        color: color,
        backgroundColor: AppColors.background,
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final value = item['value'] as double? ?? 0.0;
        final maxValue = data.map((e) => e['value'] as double? ?? 0.0).reduce((a, b) => a > b ? a : b);
        final height = (value / maxValue) * 120; // Max height of 120
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Value label
                Text(
                  value.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                
                // Bar
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.8),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Label
                Text(
                  item['label'] ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPieChart(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: PieChartPainter(
        data: data,
        colors: _generateColors(data.length),
      ),
    );
  }

  Widget _buildAreaChart(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: AreaChartPainter(
        data: data,
        color: color,
        backgroundColor: AppColors.background,
      ),
    );
  }

  List<Color> _generateColors(int count) {
    final baseColors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.tertiary,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
    ];
    
    final colors = <Color>[];
    for (int i = 0; i < count; i++) {
      colors.add(baseColors[i % baseColors.length]);
    }
    
    return colors;
  }
}

/// Line Chart Painter
class LineChartPainter extends CustomPainter {
  final List<dynamic> data;
  final Color color;
  final Color backgroundColor;

  LineChartPainter({
    required this.data,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final maxValue = data.map((e) => e['value'] as double? ?? 0.0).reduce((a, b) => a > b ? a : b);
    
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final value = data[i]['value'] as double? ?? 0.0;
      final y = size.height - (value / maxValue) * size.height;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final value = data[i]['value'] as double? ?? 0.0;
      final y = size.height - (value / maxValue) * size.height;
      
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Pie Chart Painter
class PieChartPainter extends CustomPainter {
  final List<dynamic> data;
  final List<Color> colors;

  PieChartPainter({
    required this.data,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width < size.height ? size.width / 2 - 20 : size.height / 2 - 20;
    
    final total = data.map((e) => e['value'] as double? ?? 0.0).reduce((a, b) => a + b);
    double startAngle = -90 * (3.14159 / 180); // Start from top

    for (int i = 0; i < data.length; i++) {
      final value = data[i]['value'] as double? ?? 0.0;
      final sweepAngle = (value / total) * 2 * 3.14159;
      
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Area Chart Painter
class AreaChartPainter extends CustomPainter {
  final List<dynamic> data;
  final Color color;
  final Color backgroundColor;

  AreaChartPainter({
    required this.data,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final strokePath = Path();
    final maxValue = data.map((e) => e['value'] as double? ?? 0.0).reduce((a, b) => a > b ? a : b);
    
    // Start from bottom left
    path.moveTo(0, size.height);
    strokePath.moveTo(0, size.height - (data[0]['value'] as double? ?? 0.0) / maxValue * size.height);
    
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final value = data[i]['value'] as double? ?? 0.0;
      final y = size.height - (value / maxValue) * size.height;
      
      path.lineTo(x, y);
      if (i == 0) {
        strokePath.moveTo(x, y);
      } else {
        strokePath.lineTo(x, y);
      }
    }

    // Close the area path
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(strokePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
