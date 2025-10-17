import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

/// Analytics Period Selector Widget
/// Allows users to select different time periods for analytics data
class AnalyticsPeriodSelector extends StatefulWidget {
  final Function(String) onPeriodChanged;
  final String? initialPeriod;

  const AnalyticsPeriodSelector({
    super.key,
    required this.onPeriodChanged,
    this.initialPeriod,
  });

  @override
  State<AnalyticsPeriodSelector> createState() => _AnalyticsPeriodSelectorState();
}

class _AnalyticsPeriodSelectorState extends State<AnalyticsPeriodSelector> {
  late String selectedPeriod;

  final List<Map<String, dynamic>> periods = [
    {
      'value': '24h',
      'label': 'Last 24 Hours',
      'description': 'Recent activity',
    },
    {
      'value': '7d',
      'label': 'Last 7 Days',
      'description': 'Weekly overview',
    },
    {
      'value': '30d',
      'label': 'Last 30 Days',
      'description': 'Monthly trends',
    },
    {
      'value': '90d',
      'label': 'Last 90 Days',
      'description': 'Quarterly analysis',
    },
    {
      'value': '1y',
      'label': 'Last Year',
      'description': 'Annual overview',
    },
    {
      'value': 'all',
      'label': 'All Time',
      'description': 'Complete history',
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedPeriod = widget.initialPeriod ?? '30d';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
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
              Icon(
                Icons.date_range,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              Text(
                'Analytics Period',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const Spacer(),
              
              // Quick access dropdown
              _buildQuickSelector(),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingMedium),
          
          // Period chips
          Wrap(
            spacing: AppDimensions.paddingSmall,
            runSpacing: AppDimensions.paddingSmall,
            children: periods.map((period) => _buildPeriodChip(period)).toList(),
          ),
          
          const SizedBox(height: AppDimensions.paddingMedium),
          
          // Selected period info
          _buildSelectedPeriodInfo(),
        ],
      ),
    );
  }

  Widget _buildQuickSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: AppColors.outline.withOpacity(0.3)),
      ),
      child: DropdownButton<String>(
        value: selectedPeriod,
        onChanged: (value) {
          if (value != null) {
            _selectPeriod(value);
          }
        },
        underline: const SizedBox.shrink(),
        icon: Icon(
          Icons.arrow_drop_down,
          color: AppColors.textSecondary,
          size: 16,
        ),
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textPrimary,
        ),
        items: periods.map((period) => DropdownMenuItem(
          value: period['value'],
          child: Text(period['label']),
        )).toList(),
      ),
    );
  }

  Widget _buildPeriodChip(Map<String, dynamic> period) {
    final isSelected = selectedPeriod == period['value'];
    
    return InkWell(
      onTap: () => _selectPeriod(period['value']),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary
              : AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary
                : AppColors.outline.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              period['value'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? AppColors.onPrimary
                    : AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 2),
            
            Text(
              period['description'],
              style: TextStyle(
                fontSize: 10,
                color: isSelected 
                    ? AppColors.onPrimary.withOpacity(0.8)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedPeriodInfo() {
    final selectedPeriodData = periods.firstWhere(
      (period) => period['value'] == selectedPeriod,
      orElse: () => periods[2], // Default to 30d
    );
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 16,
          ),
          
          const SizedBox(width: AppDimensions.paddingSmall),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Showing data for: ${selectedPeriodData['label']}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                
                Text(
                  _getPeriodDescription(selectedPeriod),
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          
          // Refresh indicator
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Icon(
              Icons.refresh,
              color: AppColors.primary,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _selectPeriod(String period) {
    setState(() {
      selectedPeriod = period;
    });
    widget.onPeriodChanged(period);
  }

  String _getPeriodDescription(String period) {
    switch (period) {
      case '24h':
        return 'Real-time data from the last 24 hours';
      case '7d':
        return 'Weekly trends and patterns';
      case '30d':
        return 'Monthly performance overview';
      case '90d':
        return 'Quarterly analysis and trends';
      case '1y':
        return 'Annual performance and growth';
      case 'all':
        return 'Complete historical data';
      default:
        return 'Analytics data for selected period';
    }
  }
}

