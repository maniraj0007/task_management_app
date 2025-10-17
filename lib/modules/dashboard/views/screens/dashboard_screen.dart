import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/dashboard_controller.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/stats_overview.dart';
import '../widgets/recent_tasks_section.dart';
import '../widgets/upcoming_tasks_section.dart';
import '../widgets/quick_actions.dart';

/// Dashboard Screen
/// Main user interface after authentication - central hub for task management
class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dashboard Header with user greeting
                const DashboardHeader(),
                
                const SizedBox(height: AppDimensions.paddingLarge),
                
                // Quick Actions
                const QuickActions(),
                
                const SizedBox(height: AppDimensions.paddingLarge),
                
                // Statistics Overview
                const StatsOverview(),
                
                const SizedBox(height: AppDimensions.paddingLarge),
                
                // Recent Tasks Section
                const RecentTasksSection(),
                
                const SizedBox(height: AppDimensions.paddingLarge),
                
                // Upcoming Tasks Section
                const UpcomingTasksSection(),
                
                // Bottom padding for better scrolling
                const SizedBox(height: AppDimensions.paddingXLarge),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.navigateToCreateTask,
        backgroundColor: AppColors.primary,
        child: Icon(
          Icons.add,
          color: AppColors.onPrimary,
        ),
      ),
    );
  }
}
