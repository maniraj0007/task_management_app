import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/user_management_controller.dart';

/// Bulk Actions Bar Widget
/// Provides bulk action options for selected users
class BulkActionsBar extends StatelessWidget {
  final UserManagementController controller;

  const BulkActionsBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      color: AppColors.primary.withOpacity(0.1),
      child: Row(
        children: [
          // Selection info
          Expanded(
            child: Obx(() => Text(
              '${controller.selectedUsersCount} users selected',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            )),
          ),
          
          // Bulk actions
          Row(
            children: [
              // Select all button
              TextButton.icon(
                onPressed: () => controller.selectAllUsers(),
                icon: const Icon(Icons.select_all, size: 16),
                label: const Text('Select All'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
              
              const SizedBox(width: AppDimensions.paddingSmall),
              
              // Bulk role change
              PopupMenuButton<String>(
                onSelected: (role) => _showBulkRoleChangeDialog(role),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                    vertical: AppDimensions.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    border: Border.all(color: AppColors.outline.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.admin_panel_settings, size: 16, color: AppColors.textPrimary),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      Text(
                        'Change Role',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textPrimary),
                    ],
                  ),
                ),
                itemBuilder: (context) => controller.availableRoles.map((role) => 
                  PopupMenuItem(
                    value: role,
                    child: Text(controller.getFormattedRoleName(role)),
                  ),
                ).toList(),
              ),
              
              const SizedBox(width: AppDimensions.paddingSmall),
              
              // Bulk activate
              ElevatedButton.icon(
                onPressed: () => _showBulkStatusChangeDialog(true),
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('Activate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.onPrimary,
                ),
              ),
              
              const SizedBox(width: AppDimensions.paddingSmall),
              
              // Bulk deactivate
              ElevatedButton.icon(
                onPressed: () => _showBulkStatusChangeDialog(false),
                icon: const Icon(Icons.person_remove, size: 16),
                label: const Text('Deactivate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: AppColors.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBulkRoleChangeDialog(String newRole) {
    Get.dialog(
      AlertDialog(
        title: const Text('Change User Roles'),
        content: Text(
          'Are you sure you want to change the role of ${controller.selectedUsersCount} selected users to ${controller.getFormattedRoleName(newRole)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.bulkUpdateUserRoles(newRole);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Change Roles'),
          ),
        ],
      ),
    );
  }

  void _showBulkStatusChangeDialog(bool isActive) {
    final action = isActive ? 'activate' : 'deactivate';
    
    Get.dialog(
      AlertDialog(
        title: Text('${action.capitalize} Users'),
        content: Text(
          'Are you sure you want to $action ${controller.selectedUsersCount} selected users?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.bulkUpdateUserStatus(isActive);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? AppColors.success : AppColors.warning,
            ),
            child: Text(action.capitalize),
          ),
        ],
      ),
    );
  }
}

