import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/user_management_controller.dart';
import '../widgets/user_list_item.dart';
import '../widgets/user_filter_bar.dart';
import '../widgets/bulk_actions_bar.dart';
import '../widgets/user_role_dialog.dart';

/// User Management Screen
/// Comprehensive user management interface for administrators
class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserManagementController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'User Management',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          // Search button
          IconButton(
            onPressed: () => _showSearchDialog(context, controller),
            icon: const Icon(Icons.search),
            tooltip: 'Search Users',
          ),
          
          // Selection mode toggle
          Obx(() => IconButton(
            onPressed: () => controller.toggleSelectionMode(),
            icon: Icon(
              controller.isSelectionMode.value
                  ? Icons.close
                  : Icons.checklist,
            ),
            tooltip: controller.isSelectionMode.value
                ? 'Exit Selection Mode'
                : 'Enter Selection Mode',
          )),
          
          // Refresh button
          Obx(() => IconButton(
            onPressed: controller.isLoadingUsers.value
                ? null
                : () => controller.refreshUsers(),
            icon: controller.isLoadingUsers.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Refresh Users',
          )),
          
          const SizedBox(width: AppDimensions.paddingSmall),
        ],
      ),
      body: Column(
        children: [
          // Filter bar
          UserFilterBar(controller: controller),
          
          // Bulk actions bar (shown when in selection mode)
          Obx(() => controller.isSelectionMode.value
              ? BulkActionsBar(controller: controller)
              : const SizedBox.shrink()),
          
          // User list
          Expanded(
            child: Obx(() => _buildUserList(controller)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        tooltip: 'Add User',
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildUserList(UserManagementController controller) {
    // Show loading state for initial load
    if (controller.isLoadingUsers.value && controller.users.isEmpty) {
      return _buildLoadingState();
    }

    // Show error state
    if (controller.error.value.isNotEmpty && controller.users.isEmpty) {
      return _buildErrorState(controller);
    }

    // Show empty state
    if (controller.users.isEmpty) {
      return _buildEmptyState(controller);
    }

    return RefreshIndicator(
      onRefresh: () => controller.refreshUsers(),
      child: Column(
        children: [
          // User count header
          _buildUserCountHeader(controller),
          
          // User list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
              itemCount: controller.users.length + (controller.hasMoreUsers.value ? 1 : 0),
              itemBuilder: (context, index) {
                // Load more indicator
                if (index == controller.users.length) {
                  if (controller.hasMoreUsers.value) {
                    // Trigger load more
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.loadMoreUsers();
                    });
                    return _buildLoadMoreIndicator();
                  }
                  return const SizedBox.shrink();
                }

                final user = controller.users[index];
                return UserListItem(
                  user: user,
                  isSelected: controller.isUserSelected(user.id),
                  isSelectionMode: controller.isSelectionMode.value,
                  onTap: () => _handleUserTap(controller, user.id),
                  onLongPress: () => _handleUserLongPress(controller, user.id),
                  onRoleChange: (newRole) => _handleRoleChange(controller, user.id, newRole),
                  onStatusToggle: () => _handleStatusToggle(controller, user.id, !user.isActive),
                  onDelete: () => _handleUserDelete(controller, user.id),
                );
              },
            ),
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
          Text('Loading users...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(UserManagementController controller) {
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
            'Error Loading Users',
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
            onPressed: () => controller.refreshUsers(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(UserManagementController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Text(
            controller.hasActiveFilters ? 'No Users Found' : 'No Users Yet',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            controller.hasActiveFilters
                ? 'Try adjusting your search or filters'
                : 'Users will appear here once they are added',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          if (controller.hasActiveFilters)
            ElevatedButton(
              onPressed: () => controller.clearFilters(),
              child: const Text('Clear Filters'),
            )
          else
            ElevatedButton(
              onPressed: () => _showAddUserDialog(Get.context!),
              child: const Text('Add First User'),
            ),
        ],
      ),
    );
  }

  Widget _buildUserCountHeader(UserManagementController controller) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${controller.filteredUsersCount} Users',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (controller.hasActiveFilters)
                  Text(
                    'Filtered results',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (controller.isSelectionMode.value)
            Text(
              '${controller.selectedUsersCount} selected',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(AppDimensions.paddingLarge),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // Event handlers
  void _handleUserTap(UserManagementController controller, String userId) {
    if (controller.isSelectionMode.value) {
      controller.toggleUserSelection(userId);
    } else {
      // Navigate to user details
      Get.toNamed('/admin/users/$userId');
    }
  }

  void _handleUserLongPress(UserManagementController controller, String userId) {
    if (!controller.isSelectionMode.value) {
      controller.toggleSelectionMode();
    }
    controller.toggleUserSelection(userId);
  }

  void _handleRoleChange(UserManagementController controller, String userId, String newRole) {
    _showRoleChangeConfirmation(controller, userId, newRole);
  }

  void _handleStatusToggle(UserManagementController controller, String userId, bool newStatus) {
    _showStatusChangeConfirmation(controller, userId, newStatus);
  }

  void _handleUserDelete(UserManagementController controller, String userId) {
    _showDeleteConfirmation(controller, userId);
  }

  // Dialogs and confirmations
  void _showSearchDialog(BuildContext context, UserManagementController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Users'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter name or email...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => controller.setSearchQuery(value),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.setSearchQuery('');
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    // Navigate to add user screen or show dialog
    Get.toNamed('/admin/users/add');
  }

  void _showRoleChangeConfirmation(UserManagementController controller, String userId, String newRole) {
    Get.dialog(
      UserRoleDialog(
        userId: userId,
        currentRole: controller.users.firstWhere((u) => u.id == userId).role,
        onRoleChanged: (role) => controller.updateUserRole(userId, role),
      ),
    );
  }

  void _showStatusChangeConfirmation(UserManagementController controller, String userId, bool newStatus) {
    final user = controller.users.firstWhere((u) => u.id == userId);
    final action = newStatus ? 'activate' : 'deactivate';
    
    Get.dialog(
      AlertDialog(
        title: Text('${action.capitalize} User'),
        content: Text(
          'Are you sure you want to $action ${user.firstName} ${user.lastName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.updateUserStatus(userId, newStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? AppColors.success : AppColors.warning,
            ),
            child: Text(action.capitalize),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(UserManagementController controller, String userId) {
    final user = controller.users.firstWhere((u) => u.id == userId);
    
    Get.dialog(
      AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete ${user.firstName} ${user.lastName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteUser(userId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
