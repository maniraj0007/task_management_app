import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/enums/team_enums.dart';

/// Visibility Selector Widget
/// Allows users to select team visibility settings
class VisibilitySelector extends StatelessWidget {
  final TeamVisibility selectedVisibility;
  final Function(TeamVisibility) onVisibilityChanged;

  const VisibilitySelector({
    super.key,
    required this.selectedVisibility,
    required this.onVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Team Visibility',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Text(
          'Choose who can see and join your team',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        
        // Visibility options
        ...TeamVisibility.values.map((visibility) => 
          _buildVisibilityOption(context, visibility)),
      ],
    );
  }

  Widget _buildVisibilityOption(BuildContext context, TeamVisibility visibility) {
    final isSelected = selectedVisibility == visibility;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: InkWell(
        onTap: () => onVisibilityChanged(visibility),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(
              color: isSelected 
                  ? AppColors.primary
                  : AppColors.outline.withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Radio button
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.outline,
                    width: 2,
                  ),
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 12,
                        color: AppColors.onPrimary,
                      )
                    : null,
              ),
              
              const SizedBox(width: AppDimensions.paddingMedium),
              
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getVisibilityColor(visibility).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getVisibilityIcon(visibility),
                  color: _getVisibilityColor(visibility),
                  size: 20,
                ),
              ),
              
              const SizedBox(width: AppDimensions.paddingMedium),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visibility.displayName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isSelected ? AppColors.primary : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      visibility.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Selected indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getVisibilityIcon(TeamVisibility visibility) {
    switch (visibility) {
      case TeamVisibility.private:
        return Icons.lock;
      case TeamVisibility.internal:
        return Icons.business;
      case TeamVisibility.public:
        return Icons.public;
    }
  }

  Color _getVisibilityColor(TeamVisibility visibility) {
    switch (visibility) {
      case TeamVisibility.private:
        return AppColors.error;
      case TeamVisibility.internal:
        return AppColors.warning;
      case TeamVisibility.public:
        return AppColors.success;
    }
  }
}
