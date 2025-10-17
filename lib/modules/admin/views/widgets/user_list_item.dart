import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../auth/models/user_model.dart';

/// User List Item Widget
/// Displays user information in a list format with actions
class UserListItem extends StatelessWidget {
  final UserModel user;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Function(String) onRoleChange;
  final VoidCallback onStatusToggle;
  final VoidCallback onDelete;

  const UserListItem({
    super.key,
    required this.user,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onRoleChange,
    required this.onStatusToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Row(
            children: [
              // Selection checkbox (shown in selection mode)
              if (isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.paddingMedium),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => onTap,
                    activeColor: AppColors.primary,
                  ),
                ),

              // User avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  '${user.firstName[0]}${user.lastName[0]}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: AppDimensions.paddingMedium),

              // User details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: AppDimensions.paddingSmall),
                    
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    const SizedBox(height: AppDimensions.paddingSmall),
                    
                    Row(
                      children: [
                        // Role chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingSmall,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getRoleColor(user.role).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                          ),
                          child: Text(
                            _formatRole(user.role),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getRoleColor(user.role),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: AppDimensions.paddingSmall),
                        
                        // Status chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingSmall,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: user.isActive 
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                          ),
                          child: Text(
                            user.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 10,
                              color: user.isActive ? AppColors.success : AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions (shown when not in selection mode)
              if (!isSelectionMode)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'role':
                        onRoleChange(user.role);
                        break;
                      case 'status':
                        onStatusToggle();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'role',
                      child: Row(
                        children: [
                          Icon(Icons.admin_panel_settings, size: 16),
                          SizedBox(width: 8),
                          Text('Change Role'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'status',
                      child: Row(
                        children: [
                          Icon(
                            user.isActive ? Icons.person_remove : Icons.person_add,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(user.isActive ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRole(String role) {
    switch (role) {
      case 'super_admin':
        return 'Super Admin';
      case 'admin':
        return 'Admin';
      case 'team_member':
        return 'Team Member';
      case 'viewer':
        return 'Viewer';
      default:
        return role.replaceAll('_', ' ').toUpperCase();
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'super_admin':
        return const Color(0xFF9C27B0); // Purple
      case 'admin':
        return const Color(0xFF3F51B5); // Indigo
      case 'team_member':
        return const Color(0xFF2196F3); // Blue
      case 'viewer':
        return const Color(0xFF607D8B); // Blue Grey
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }
}

