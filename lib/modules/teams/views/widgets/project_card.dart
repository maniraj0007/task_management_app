import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/enums/team_enums.dart';
import '../../models/project_model.dart';

/// Project Card Widget
/// Displays project information in a card format with progress indicators
class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showTeamInfo;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.onLongPress,
    this.showTeamInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.projectCardRadius),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppDimensions.projectCardRadius),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.projectCardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with project info and status
              Row(
                children: [
                  // Project icon with priority color
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: project.priority.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getProjectTypeIcon(),
                      color: project.priority.color,
                      size: 20,
                    ),
                  ),
                  
                  const SizedBox(width: AppDimensions.paddingMedium),
                  
                  // Project name and team info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (showTeamInfo && project.teamName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.group,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                project.teamName,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Status and priority badges
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusBadge(),
                      const SizedBox(height: 4),
                      _buildPriorityBadge(),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.paddingMedium),
              
              // Project description
              if (project.description.isNotEmpty) ...[
                Text(
                  project.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
              ],
              
              // Progress section
              Row(
                children: [
                  Text(
                    'Progress',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${project.progress}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getProgressColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              LinearProgressIndicator(
                value: project.progress / 100,
                backgroundColor: AppColors.surface,
                valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
                minHeight: AppDimensions.projectProgressHeight,
              ),
              
              const SizedBox(height: AppDimensions.paddingMedium),
              
              // Project stats
              Row(
                children: [
                  _buildStatItem(
                    Icons.task_outlined,
                    '${project.completedTasks}/${project.totalTasks}',
                    'Tasks',
                  ),
                  const SizedBox(width: AppDimensions.paddingLarge),
                  _buildStatItem(
                    Icons.people_outline,
                    project.memberCount.toString(),
                    'Members',
                  ),
                  const Spacer(),
                  _buildDateInfo(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: project.status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        project.status.displayName,
        style: TextStyle(
          color: project.status.color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: project.priority.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPriorityIcon(),
            size: 8,
            color: project.priority.color,
          ),
          const SizedBox(width: 2),
          Text(
            project.priority.displayName,
            style: TextStyle(
              color: project.priority.color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 2),
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

  Widget _buildDateInfo() {
    final now = DateTime.now();
    final isOverdue = project.dueDate != null && 
                     project.dueDate!.isBefore(now) && 
                     !project.status.isCompleted;
    
    if (project.dueDate == null) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          isOverdue ? 'Overdue' : 'Due',
          style: TextStyle(
            fontSize: 10,
            color: isOverdue ? AppColors.error : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          _formatDate(project.dueDate!),
          style: TextStyle(
            fontSize: 10,
            color: isOverdue ? AppColors.error : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  IconData _getProjectTypeIcon() {
    switch (project.type) {
      case ProjectType.development:
        return Icons.code;
      case ProjectType.design:
        return Icons.palette;
      case ProjectType.marketing:
        return Icons.campaign;
      case ProjectType.research:
        return Icons.science;
      case ProjectType.operations:
        return Icons.settings;
      case ProjectType.training:
        return Icons.school;
      case ProjectType.event:
        return Icons.event;
      case ProjectType.general:
      case ProjectType.custom:
      default:
        return Icons.folder;
    }
  }

  IconData _getPriorityIcon() {
    switch (project.priority) {
      case ProjectPriority.critical:
        return Icons.keyboard_double_arrow_up;
      case ProjectPriority.high:
        return Icons.keyboard_arrow_up;
      case ProjectPriority.medium:
        return Icons.remove;
      case ProjectPriority.low:
        return Icons.keyboard_arrow_down;
    }
  }

  Color _getProgressColor() {
    if (project.progress >= 80) return AppColors.success;
    if (project.progress >= 50) return AppColors.primary;
    if (project.progress >= 25) return AppColors.warning;
    return AppColors.error;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inDays == 0) {
      return 'Today';
    } else {
      return '${difference.inDays.abs()}d ago';
    }
  }
}

// Extensions for project enums
extension ProjectStatusColor on ProjectStatus {
  Color get color {
    switch (this) {
      case ProjectStatus.planning:
        return AppColors.warning;
      case ProjectStatus.active:
        return AppColors.success;
      case ProjectStatus.onHold:
        return AppColors.warning;
      case ProjectStatus.completed:
        return AppColors.primary;
      case ProjectStatus.cancelled:
        return AppColors.error;
      case ProjectStatus.archived:
        return AppColors.textSecondary;
    }
  }
}

extension ProjectPriorityColor on ProjectPriority {
  Color get color {
    switch (this) {
      case ProjectPriority.low:
        return AppColors.success;
      case ProjectPriority.medium:
        return AppColors.primary;
      case ProjectPriority.high:
        return AppColors.warning;
      case ProjectPriority.critical:
        return AppColors.error;
    }
  }
}
