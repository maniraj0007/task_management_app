import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/dashboard_controller.dart';

/// Stats Overview Widget
/// Displays task statistics and productivity metrics
class StatsOverview extends GetView<DashboardController> {
  const StatsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: AppDimensions.paddingMedium),
        
        // Stats Cards Grid
        Row(
          children: [
            Expanded(
              child: Obx(() => _buildStatCard(
                title: 'Total Tasks',
                value: controller.totalTasks.value.toString(),
                icon: Icons.task_alt,
                color: AppColors.primary,
              )),
            ),
            
            const SizedBox(width: AppDimensions.paddingMedium),
            
            Expanded(
              child: Obx(() => _buildStatCard(
                title: 'Completed',
                value: controller.completedTasks.value.toString(),
                icon: Icons.check_circle,
                color: AppColors.success,
              )),
            ),
          ],
        ),
        
        const SizedBox(height: AppDimensions.paddingMedium),
        
        Row(
          children: [
            Expanded(
              child: Obx(() => _buildStatCard(
                title: 'Pending',
                value: controller.pendingTasks.value.toString(),
                icon: Icons.pending,
                color: AppColors.warning,
              )),
            ),
            
            const SizedBox(width: AppDimensions.paddingMedium),
            
            Expanded(
              child: Obx(() => _buildStatCard(
                title: 'Overdue',
                value: controller.overdueTasks.value.toString(),
                icon: Icons.schedule,
                color: AppColors.error,
              )),
            ),
          ],
        ),
        
        const SizedBox(height: AppDimensions.paddingLarge),
        
        // Productivity Card
        Obx(() => _buildProductivityCard()),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              
              const Spacer(),
              
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingSmall),
          
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductivityCard() {
    final percentage = controller.completionPercentage;
    final status = controller.productivityStatus;
    final color = Color(int.parse(controller.productivityColor.replaceAll('#', '0xFF')));
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: color,
                size: 24,
              ),
              
              const SizedBox(width: AppDimensions.paddingSmall),
              
              Text(
                'Productivity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const Spacer(),
              
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingMedium),
          
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${percentage.toInt()}% Complete',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  Text(
                    '${controller.completedTasks.value}/${controller.totalTasks.value}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.paddingSmall),
              
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

