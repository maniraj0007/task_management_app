import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/enums/team_enums.dart';

/// Team Filter Chips Widget
/// Provides filtering options for teams
class TeamFilterChips extends StatelessWidget {
  final TeamVisibility? selectedVisibility;
  final Function(TeamVisibility?) onVisibilityChanged;

  const TeamFilterChips({
    super.key,
    this.selectedVisibility,
    required this.onVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(
            context,
            'All Teams',
            selectedVisibility == null,
            () => onVisibilityChanged(null),
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          ...TeamVisibility.values.map((visibility) => Padding(
            padding: const EdgeInsets.only(right: AppDimensions.paddingSmall),
            child: _buildFilterChip(
              context,
              visibility.displayName,
              selectedVisibility == visibility,
              () => onVisibilityChanged(visibility),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.outline,
        ),
      ),
    );
  }
}
