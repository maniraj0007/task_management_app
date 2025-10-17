import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/admin_controller.dart';
import '../widgets/system_stats_card.dart';
import '../widgets/system_health_indicator.dart';
import '../widgets/recent_activity_list.dart';
import '../widgets/analytics_overview_chart.dart';

/// Admin Dashboard Screen
/// Main dashboard for administrators with system overview and analytics
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminController = Get.put(AdminController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          // Refresh button
          Obx(() => IconButton(
            onPressed: adminController.isLoadingOverview.value
                ? null
                : () => adminController.refreshAdminData(),
            icon: adminController.isLoadingOverview.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
          )),
          
          // Settings button
          IconButton(
            onPressed: () {
              // Navigate to admin settings
              Get.toNamed('/admin/settings');
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Admin Settings',
          ),
          
          const SizedBox(width: AppDimensions.paddingSmall),
        ],
      ),
      body: Obx(() {
        // Check admin access
        if (!adminController.hasAdminAccess) {
          return _buildAccessDenied();
        }

        // Show loading state
        if (adminController.isLoading.value && adminController.systemOverview.isEmpty) {
          return _buildLoadingState();
        }

        // Show error state
        if (adminController.error.value.isNotEmpty) {
          return _buildErrorState(adminController);
        }

        return RefreshIndicator(
          onRefresh: () => adminController.refreshAdminData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header
                _buildWelcomeHeader(adminController),
                
                const SizedBox(height: AppDimensions.paddingLarge),
                
                // System health indicator
                _buildSystemHealthSection(adminController),
                
                const SizedBox(height: AppDimensions.paddingLarge),
                
                // System statistics cards
                _buildSystemStatsSection(adminController),
                
                const SizedBox(height: AppDimensions.paddingLarge),
                
                // Analytics overview
                _buildAnalyticsSection(adminController),
                
                const SizedBox(height: AppDimensions.paddingLarge),
                
                // Recent activity
                _buildRecentActivitySection(adminController),
                
                const SizedBox(height: AppDimensions.paddingLarge),
                
                // Quick actions
                _buildQuickActionsSection(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAccessDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock,
            size: 64,
            color: AppColors.error.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Text(
            'Access Denied',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            'You do not have permission to access the admin dashboard.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppDimensions.paddingLarge),
          Text('Loading admin dashboard...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(AdminController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Text(
            'Error Loading Dashboard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            controller.error.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          ElevatedButton(
            onPressed: () => controller.refreshAdminData(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(AdminController controller) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Admin Dashboard',
                  style: TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                Text(
                  controller.hasSuperAdminAccess
                      ? 'Super Admin Access'
                      : 'Admin Access',
                  style: TextStyle(
                    color: AppColors.onPrimary.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                Text(
                  'Manage users, monitor system health, and view analytics',
                  style: TextStyle(
                    color: AppColors.onPrimary.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.admin_panel_settings,
            color: AppColors.onPrimary,
            size: 48,
          ),
        ],
      ),
    );
  }

  Widget _buildSystemHealthSection(AdminController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Health',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        SystemHealthIndicator(controller: controller),
      ],
    );
  }

  Widget _buildSystemStatsSection(AdminController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppDimensions.paddingMedium,
            mainAxisSpacing: AppDimensions.paddingMedium,
            childAspectRatio: 1.5,
          ),
          itemCount: controller.formattedSystemStats.length,
          itemBuilder: (context, index) {
            final stat = controller.formattedSystemStats[index];
            return SystemStatsCard(
              title: stat['title'],
              value: stat['value'].toString(),
              subtitle: stat['subtitle'],
              icon: _getIconData(stat['icon']),
              color: _getColorFromString(stat['color']),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection(AdminController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics Overview',
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
              child: AnalyticsOverviewChart(
                title: 'User Roles',
                data: controller.formattedRoleDistribution,
                chartType: ChartType.pie,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: AnalyticsOverviewChart(
                title: 'Task Status',
                data: controller.formattedTaskStatusDistribution,
                chartType: ChartType.bar,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(AdminController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // Navigate to full activity log
                Get.toNamed('/admin/activity-log');
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        RecentActivityList(
          activities: controller.formattedRecentActivity,
          maxItems: 5,
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
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
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppDimensions.paddingMedium,
          mainAxisSpacing: AppDimensions.paddingMedium,
          childAspectRatio: 2.5,
          children: [
            _buildQuickActionCard(
              'Manage Users',
              Icons.people,
              AppColors.primary,
              () => Get.toNamed('/admin/users'),
            ),
            _buildQuickActionCard(
              'System Analytics',
              Icons.analytics,
              AppColors.success,
              () => Get.toNamed('/admin/analytics'),
            ),
            _buildQuickActionCard(
              'Audit Logs',
              Icons.history,
              AppColors.warning,
              () => Get.toNamed('/admin/audit-logs'),
            ),
            _buildQuickActionCard(
              'System Settings',
              Icons.settings,
              AppColors.tertiary,
              () => Get.toNamed('/admin/settings'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: AppColors.outline.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'people':
        return Icons.people;
      case 'groups':
        return Icons.groups;
      case 'task':
        return Icons.task;
      case 'folder':
        return Icons.folder;
      default:
        return Icons.info;
    }
  }

  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'primary':
        return AppColors.primary;
      case 'success':
        return AppColors.success;
      case 'info':
        return AppColors.info;
      case 'warning':
        return AppColors.warning;
      case 'error':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }
}

enum ChartType { pie, bar, line, area }
