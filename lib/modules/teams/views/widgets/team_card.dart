import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../models/team_model.dart';

/// Team Card Widget
/// Displays team information in a card format
class TeamCard extends StatelessWidget {
  final TeamModel team;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TeamCard({
    super.key,
    required this.team,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.teamCardRadius),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppDimensions.teamCardRadius),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.teamCardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with avatar and status
              Row(
                children: [
                  CircleAvatar(
                    radius: AppDimensions.teamAvatarSize / 2,
                    backgroundColor: team.visibility.color.withOpacity(0.1),
                    child: Text(
                      team.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: team.visibility.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: team.isActive 
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      team.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: team.isActive ? AppColors.success : AppColors.warning,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.paddingMedium),
              
              // Team name
              Text(
                team.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: AppDimensions.paddingSmall),
              
              // Team description
              Text(
                team.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const Spacer(),
              
              // Team stats
              Row(
                children: [
                  _buildStatItem(
                    context,
                    Icons.people_outline,
                    team.totalMembers.toString(),
                    'Members',
                  ),
                  const SizedBox(width: AppDimensions.paddingMedium),
                  _buildStatItem(
                    context,
                    Icons.folder_outlined,
                    team.totalProjects.toString(),
                    'Projects',
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.paddingSmall),
              
              // Health score indicator
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: team.healthScore / 100,
                      backgroundColor: AppColors.surface,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getHealthColor(team.healthScore),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  Text(
                    '${team.healthScore}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getHealthColor(team.healthScore),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Color _getHealthColor(int healthScore) {
    if (healthScore >= 80) return AppColors.success;
    if (healthScore >= 60) return AppColors.warning;
    return AppColors.error;
  }
}

extension TeamVisibilityColor on TeamVisibility {
  Color get color {
    switch (this) {
      case TeamVisibility.private:
        return AppColors.error;
      case TeamVisibility.internal:
        return AppColors.warning;
      case TeamVisibility.public:
        return AppColors.success;
    }
  }
}
