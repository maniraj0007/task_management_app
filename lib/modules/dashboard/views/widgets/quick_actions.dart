import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/dashboard_controller.dart';

/// Quick Actions Widget
/// Provides quick access to common actions
class QuickActions extends GetView<DashboardController> {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: AppDimensions.paddingMedium),
        
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.add_task,
                title: 'New Task',
                subtitle: 'Create a task',
                color: AppColors.primary,
                onTap: controller.navigateToCreateTask,
              ),
            ),
            
            const SizedBox(width: AppDimensions.paddingMedium),
            
            Expanded(
              child: _buildActionCard(
                icon: Icons.list_alt,
                title: 'My Tasks',
                subtitle: 'View all tasks',
                color: AppColors.secondary,
                onTap: controller.navigateToTasks,
              ),
            ),
            
            const SizedBox(width: AppDimensions.paddingMedium),
            
            Expanded(
              child: _buildActionCard(
                icon: Icons.group,
                title: 'Teams',
                subtitle: 'Collaborate',
                color: AppColors.tertiary,
                onTap: controller.navigateToTeams,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: AppColors.outline.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
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
            
            const SizedBox(height: AppDimensions.paddingSmall),
            
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 2),
            
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

