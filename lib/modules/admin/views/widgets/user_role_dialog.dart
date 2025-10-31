import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/app_constants.dart';

/// User Role Dialog Widget
/// Dialog for changing user roles with role descriptions
class UserRoleDialog extends StatefulWidget {
  final String userId;
  final String currentRole;
  final Function(String) onRoleChanged;

  const UserRoleDialog({
    super.key,
    required this.userId,
    required this.currentRole,
    required this.onRoleChanged,
  });

  @override
  State<UserRoleDialog> createState() => _UserRoleDialogState();
}

class _UserRoleDialogState extends State<UserRoleDialog> {
  late String selectedRole;

  @override
  void initState() {
    super.initState();
    selectedRole = widget.currentRole;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change User Role'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a new role for this user:',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // Role options
            ...availableRoles.map((role) => _buildRoleOption(role)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedRole == widget.currentRole
              ? null
              : () {
                  Get.back();
                  widget.onRoleChanged(selectedRole);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: const Text('Change Role'),
        ),
      ],
    );
  }

  Widget _buildRoleOption(Map<String, dynamic> roleInfo) {
    final role = roleInfo['role'] as String;
    final isSelected = selectedRole == role;
    final isCurrentRole = widget.currentRole == role;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      child: InkWell(
        onTap: () => setState(() => selectedRole = role),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(
              color: isSelected 
                  ? AppColors.primary
                  : AppColors.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Radio button
              Radio<String>(
                value: role,
                groupValue: selectedRole,
                onChanged: (value) => setState(() => selectedRole = value!),
                activeColor: AppColors.primary,
              ),
              
              const SizedBox(width: AppDimensions.paddingMedium),
              
              // Role info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          roleInfo['name'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        
                        if (isCurrentRole)
                          Padding(
                            padding: const EdgeInsets.only(left: AppDimensions.paddingSmall),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingSmall,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.info.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                              ),
                              child: Text(
                                'Current',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.info,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: AppDimensions.paddingSmall),
                    
                    Text(
                      roleInfo['description'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    const SizedBox(height: AppDimensions.paddingSmall),
                    
                    // Permissions preview
                    Wrap(
                      spacing: AppDimensions.paddingSmall,
                      children: (roleInfo['permissions'] as List<String>)
                          .take(3)
                          .map((permission) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.paddingSmall,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(role).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                                ),
                                child: Text(
                                  permission,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _getRoleColor(role),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get availableRoles => [
    {
      'role': AppConstants.superAdminRole,
      'name': 'Super Admin',
      'description': 'Full system control with all administrative privileges',
      'permissions': ['Manage Users', 'System Settings', 'All Access'],
    },
    {
      'role': AppConstants.adminRole,
      'name': 'Admin',
      'description': 'Operational control without system configuration access',
      'permissions': ['Manage Teams', 'Assign Tasks', 'View Analytics'],
    },
    {
      'role': AppConstants.teamMemberRole,
      'name': 'Team Member',
      'description': 'Execute assigned tasks and collaborate with team',
      'permissions': ['Create Tasks', 'Update Status', 'Comment'],
    },
    {
      'role': AppConstants.viewerRole,
      'name': 'Viewer',
      'description': 'Read-only access to assigned and shared tasks',
      'permissions': ['View Tasks', 'Real-time Updates', 'Read Only'],
    },
  ];

  Color _getRoleColor(String role) {
    switch (role) {
      case AppConstants.superAdminRole:
        return const Color(0xFF9C27B0); // Purple
      case AppConstants.adminRole:
        return const Color(0xFF3F51B5); // Indigo
      case AppConstants.teamMemberRole:
        return const Color(0xFF2196F3); // Blue
      case AppConstants.viewerRole:
        return const Color(0xFF607D8B); // Blue Grey
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }
}

