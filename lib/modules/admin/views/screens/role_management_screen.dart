import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/enums/user_roles.dart';
import '../../../auth/models/user_model.dart';
import '../../controllers/admin_controller.dart';
import '../widgets/user_role_dialog.dart';

/// Role Management Screen
/// Interface for managing user roles and permissions (Super Admin only)
class RoleManagementScreen extends GetView<AdminController> {
  const RoleManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Role Management',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: controller.refreshUserData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Role Statistics
            _buildRoleStatistics(),
            
            // Role Tabs
            Expanded(
              child: DefaultTabController(
                length: UserRole.values.length,
                child: Column(
                  children: [
                    TabBar(
                      isScrollable: true,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      tabs: UserRole.values.map((role) {
                        final count = controller.getUsersByRole(role).length;
                        return Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getRoleIcon(role),
                                size: 16,
                                color: AppColors.getRoleColor(role.value),
                              ),
                              const SizedBox(width: 8),
                              Text('${role.displayName} ($count)'),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: UserRole.values.map((role) {
                          return _buildRoleUsersList(role);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  /// Build role statistics section
  Widget _buildRoleStatistics() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
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
            'Role Distribution',
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Row(
            children: UserRole.values.map((role) {
              final count = controller.getUsersByRole(role).length;
              final percentage = controller.totalUsers.value > 0
                  ? (count / controller.totalUsers.value * 100).round()
                  : 0;
              
              return Expanded(
                child: _buildRoleStatCard(role, count, percentage),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Build role statistics card
  Widget _buildRoleStatCard(UserRole role, int count, int percentage) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.getRoleColor(role.value).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(
          color: AppColors.getRoleColor(role.value).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            _getRoleIcon(role),
            color: AppColors.getRoleColor(role.value),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.getRoleColor(role.value),
            ),
          ),
          Text(
            '$percentage%',
            style: Get.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            role.displayName,
            style: Get.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Build users list for a specific role
  Widget _buildRoleUsersList(UserRole role) {
    final users = controller.getUsersByRole(role);
    
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getRoleIcon(role),
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Text(
              'No ${role.displayName}s found',
              style: Get.textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              'Users with ${role.displayName} role will appear here',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserRoleCard(user, role);
      },
    );
  }

  /// Build user role card
  Widget _buildUserRoleCard(UserModel user, UserRole role) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
        leading: CircleAvatar(
          backgroundColor: AppColors.getRoleColor(role.value).withOpacity(0.2),
          child: user.photoURL != null
              ? ClipOval(
                  child: Image.network(
                    user.photoURL!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        color: AppColors.getRoleColor(role.value),
                      );
                    },
                  ),
                )
              : Icon(
                  Icons.person,
                  color: AppColors.getRoleColor(role.value),
                ),
        ),
        title: Text(
          user.displayName ?? user.email,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.getRoleColor(role.value).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    role.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getRoleColor(role.value),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (user.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.success,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Inactive',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.error,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUserAction(value, user),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'change_role',
              child: ListTile(
                leading: Icon(Icons.admin_panel_settings),
                title: Text('Change Role'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'view_details',
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text('View Details'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (user.isActive)
              const PopupMenuItem(
                value: 'deactivate',
                child: ListTile(
                  leading: Icon(Icons.block, color: Colors.orange),
                  title: Text('Deactivate'),
                  contentPadding: EdgeInsets.zero,
                ),
              )
            else
              const PopupMenuItem(
                value: 'activate',
                child: ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text('Activate'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete User'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle user action from popup menu
  void _handleUserAction(String action, UserModel user) {
    switch (action) {
      case 'change_role':
        _showChangeRoleDialog(user);
        break;
      case 'view_details':
        _showUserDetailsDialog(user);
        break;
      case 'activate':
        controller.activateUser(user.id);
        break;
      case 'deactivate':
        controller.deactivateUser(user.id);
        break;
      case 'delete':
        _showDeleteUserDialog(user);
        break;
    }
  }

  /// Show change role dialog
  void _showChangeRoleDialog(UserModel user) {
    Get.dialog(
      UserRoleDialog(
        user: user,
        onRoleChanged: (newRole) {
          controller.updateUserRole(user.id, newRole);
        },
      ),
    );
  }

  /// Show user details dialog
  void _showUserDetailsDialog(UserModel user) {
    Get.dialog(
      AlertDialog(
        title: Text('User Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Name', user.displayName ?? 'Not provided'),
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Role', user.role.displayName),
              _buildDetailRow('Status', user.isActive ? 'Active' : 'Inactive'),
              _buildDetailRow('Teams', user.teamIds.length.toString()),
              _buildDetailRow('Projects', user.projectIds.length.toString()),
              _buildDetailRow('Created', user.createdAt?.toString() ?? 'Unknown'),
              _buildDetailRow('Last Login', user.lastLoginAt?.toString() ?? 'Never'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Build detail row for user details dialog
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  /// Show delete user confirmation dialog
  void _showDeleteUserDialog(UserModel user) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete ${user.displayName ?? user.email}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteUser(user.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Get icon for user role
  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Icons.admin_panel_settings;
      case UserRole.admin:
        return Icons.manage_accounts;
      case UserRole.teamMember:
        return Icons.person;
      case UserRole.viewer:
        return Icons.visibility;
    }
  }
}
