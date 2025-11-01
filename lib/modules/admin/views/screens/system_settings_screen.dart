import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/admin_controller.dart';

/// System Overview Screen
/// Displays system statistics and overview for Super Admins
class SystemSettingsScreen extends GetView<AdminController> {
  const SystemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'System Overview',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => controller.refreshAdminData(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // System Health
              _buildSystemHealthCard(),
              
              const SizedBox(height: AppDimensions.spacingLarge),

              // System Statistics
              _buildSystemStatsSection(),

              const SizedBox(height: AppDimensions.spacingLarge),

              // Role Distribution
              _buildRoleDistributionSection(),

              const SizedBox(height: AppDimensions.spacingLarge),

              // Task Status Distribution
              _buildTaskStatusSection(),

              const SizedBox(height: AppDimensions.spacingLarge),

              // Recent Activity
              _buildRecentActivitySection(),

              const SizedBox(height: AppDimensions.spacing48),
            ],
          ),
        );
      }),
    );
  }

  /// Build system health card
  Widget _buildSystemHealthCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Health',
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Score',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${controller.systemHealthScore.toStringAsFixed(1)}%',
                      style: Get.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Color(int.parse(controller.systemHealthColor.substring(1), radix: 16) + 0xFF000000),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.systemHealthStatus,
                      style: Get.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Color(int.parse(controller.systemHealthColor.substring(1), radix: 16) + 0xFF000000),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build system statistics section
  Widget _buildSystemStatsSection() {
    final stats = controller.formattedSystemStats;
    if (stats.isEmpty) {
      return _buildEmptySection('System Statistics', 'No statistics available');
    }

    return _buildSection(
      title: 'System Statistics',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: AppDimensions.spacingMedium,
          mainAxisSpacing: AppDimensions.spacingMedium,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return _buildStatCard(
            title: stat['title'],
            value: stat['value'].toString(),
            subtitle: stat['subtitle'],
            icon: _getIconData(stat['icon']),
            color: _getColorFromString(stat['color']),
          );
        },
      ),
    );
  }

  /// Build role distribution section
  Widget _buildRoleDistributionSection() {
    final distribution = controller.formattedRoleDistribution;
    if (distribution.isEmpty) {
      return _buildEmptySection('Role Distribution', 'No role data available');
    }

    return _buildSection(
      title: 'Role Distribution',
      child: Column(
        children: distribution.map((role) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Color(int.parse(role['color'].substring(1), radix: 16) + 0xFF000000),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSmall),
                Expanded(
                  child: Text(
                    role['label'],
                    style: Get.textTheme.bodyMedium,
                  ),
                ),
                Text(
                  role['value'].toInt().toString(),
                  style: Get.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build task status section
  Widget _buildTaskStatusSection() {
    final distribution = controller.formattedTaskStatusDistribution;
    if (distribution.isEmpty) {
      return _buildEmptySection('Task Status Distribution', 'No task data available');
    }

    return _buildSection(
      title: 'Task Status Distribution',
      child: Column(
        children: distribution.map((status) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Color(int.parse(status['color'].substring(1), radix: 16) + 0xFF000000),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSmall),
                Expanded(
                  child: Text(
                    status['label'],
                    style: Get.textTheme.bodyMedium,
                  ),
                ),
                Text(
                  status['value'].toInt().toString(),
                  style: Get.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build recent activity section
  Widget _buildRecentActivitySection() {
    final activities = controller.formattedRecentActivity;
    if (activities.isEmpty) {
      return _buildEmptySection('Recent Activity', 'No recent activity');
    }

    return _buildSection(
      title: 'Recent Activity',
      child: Column(
        children: activities.take(10).map((activity) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: Color(int.parse(activity['actionColor'].substring(1), radix: 16) + 0xFF000000).withOpacity(0.1),
              child: Icon(
                _getIconData(activity['actionIcon']),
                color: Color(int.parse(activity['actionColor'].substring(1), radix: 16) + 0xFF000000),
                size: 20,
              ),
            ),
            title: Text(
              activity['formattedAction'],
              style: Get.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'by ${activity['userName'] ?? 'Unknown'} • ${activity['formattedTime']}',
              style: Get.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build a section with title and content
  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Text(
              title,
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: child,
          ),
        ],
      ),
    );
  }

  /// Build empty section
  Widget _buildEmptySection(String title, String message) {
    return _buildSection(
      title: title,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: AppDimensions.spacingMedium),
              Text(
                message,
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build stat card
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: Get.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Get.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: Get.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Get icon data from string
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
      case 'admin_panel_settings':
        return Icons.admin_panel_settings;
      case 'person_add':
        return Icons.person_add;
      case 'person_remove':
        return Icons.person_remove;
      case 'delete':
        return Icons.delete;
      case 'settings':
        return Icons.settings;
      case 'group':
        return Icons.group;
      case 'group_add':
        return Icons.group_add;
      case 'group_remove':
        return Icons.group_remove;
      default:
        return Icons.info;
    }
  }

  /// Get color from string
  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'primary':
        return Colors.blue;
      case 'success':
        return Colors.green;
      case 'info':
        return Colors.cyan;
      case 'warning':
        return Colors.orange;
      case 'danger':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
