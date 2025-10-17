import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/user_management_controller.dart';

/// User Filter Bar Widget
/// Provides filtering options for user management
class UserFilterBar extends StatelessWidget {
  final UserManagementController controller;

  const UserFilterBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      color: AppColors.surface,
      child: Column(
        children: [
          // Search and filter row
          Row(
            children: [
              // Search field
              Expanded(
                flex: 3,
                child: TextField(
                  onChanged: (value) => controller.setSearchQuery(value),
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      borderSide: BorderSide(color: AppColors.outline.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      borderSide: BorderSide(color: AppColors.outline.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium,
                      vertical: AppDimensions.paddingSmall,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: AppDimensions.paddingMedium),
              
              // Role filter dropdown
              Expanded(
                flex: 2,
                child: Obx(() => DropdownButtonFormField<String>(
                  value: controller.roleFilter.value.isEmpty ? null : controller.roleFilter.value,
                  onChanged: (value) => controller.setRoleFilter(value ?? ''),
                  decoration: InputDecoration(
                    hintText: 'All Roles',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      borderSide: BorderSide(color: AppColors.outline.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      borderSide: BorderSide(color: AppColors.outline.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium,
                      vertical: AppDimensions.paddingSmall,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('All Roles'),
                    ),
                    ...controller.availableRoles.map((role) => DropdownMenuItem(
                      value: role,
                      child: Text(controller.getFormattedRoleName(role)),
                    )),
                  ],
                )),
              ),
              
              const SizedBox(width: AppDimensions.paddingMedium),
              
              // Status filter dropdown
              Expanded(
                flex: 2,
                child: Obx(() => DropdownButtonFormField<bool?>(
                  value: controller.isActiveFilter.value,
                  onChanged: (value) => controller.setActiveFilter(value),
                  decoration: InputDecoration(
                    hintText: 'All Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      borderSide: BorderSide(color: AppColors.outline.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      borderSide: BorderSide(color: AppColors.outline.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium,
                      vertical: AppDimensions.paddingSmall,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Text('All Status'),
                    ),
                    DropdownMenuItem(
                      value: true,
                      child: Text('Active'),
                    ),
                    DropdownMenuItem(
                      value: false,
                      child: Text('Inactive'),
                    ),
                  ],
                )),
              ),
            ],
          ),
          
          // Filter chips and clear button
          Obx(() {
            if (!controller.hasActiveFilters) {
              return const SizedBox.shrink();
            }
            
            return Padding(
              padding: const EdgeInsets.only(top: AppDimensions.paddingMedium),
              child: Row(
                children: [
                  // Active filters chips
                  Expanded(
                    child: Wrap(
                      spacing: AppDimensions.paddingSmall,
                      children: [
                        if (controller.searchQuery.value.isNotEmpty)
                          _buildFilterChip(
                            'Search: ${controller.searchQuery.value}',
                            () => controller.setSearchQuery(''),
                          ),
                        
                        if (controller.roleFilter.value.isNotEmpty)
                          _buildFilterChip(
                            'Role: ${controller.getFormattedRoleName(controller.roleFilter.value)}',
                            () => controller.setRoleFilter(''),
                          ),
                        
                        if (controller.isActiveFilter.value != null)
                          _buildFilterChip(
                            'Status: ${controller.isActiveFilter.value! ? 'Active' : 'Inactive'}',
                            () => controller.setActiveFilter(null),
                          ),
                      ],
                    ),
                  ),
                  
                  // Clear all filters button
                  TextButton.icon(
                    onPressed: () => controller.clearFilters(),
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Clear All'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      onDeleted: onDeleted,
      deleteIcon: const Icon(Icons.close, size: 16),
      backgroundColor: AppColors.primary.withOpacity(0.1),
      deleteIconColor: AppColors.primary,
      labelStyle: TextStyle(color: AppColors.primary),
    );
  }
}

