import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/enums/team_enums.dart';
import '../../controllers/team_member_controller.dart';

/// Team Member List Widget
/// Displays and manages team members
class TeamMemberList extends StatelessWidget {
  final String teamId;
  final bool canManageMembers;
  final VoidCallback onInviteMember;
  final Function(String) onRemoveMember;
  final Function(String, TeamRole) onChangeRole;

  const TeamMemberList({
    super.key,
    required this.teamId,
    required this.canManageMembers,
    required this.onInviteMember,
    required this.onRemoveMember,
    required this.onChangeRole,
  });

  @override
  Widget build(BuildContext context) {
    final memberController = Get.find<TeamMemberController>();

    return Obx(() {
      final members = memberController.getTeamMembers(teamId);
      
      if (memberController.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (members.isEmpty) {
        return _buildEmptyState(context);
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          return _buildMemberCard(context, member);
        },
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Text(
            'No team members yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            'Invite members to start collaborating',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (canManageMembers) ...[
            const SizedBox(height: AppDimensions.paddingLarge),
            ElevatedButton.icon(
              onPressed: onInviteMember,
              icon: const Icon(Icons.person_add),
              label: const Text('Invite Members'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, dynamic member) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            member.name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(member.name),
        subtitle: Text(member.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRoleBadge(member.role),
            if (canManageMembers) ...[
              const SizedBox(width: AppDimensions.paddingSmall),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMemberAction(value, member),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'change_role',
                    child: Text('Change Role'),
                  ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Text('Remove Member'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(TeamRole role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getRoleColor(role).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role.displayName,
        style: TextStyle(
          color: _getRoleColor(role),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getRoleColor(TeamRole role) {
    switch (role) {
      case TeamRole.owner:
        return AppColors.error;
      case TeamRole.admin:
        return AppColors.warning;
      case TeamRole.manager:
        return AppColors.primary;
      case TeamRole.member:
        return AppColors.success;
      case TeamRole.guest:
        return AppColors.textSecondary;
    }
  }

  void _handleMemberAction(String action, dynamic member) {
    switch (action) {
      case 'change_role':
        _showChangeRoleDialog(member);
        break;
      case 'remove':
        onRemoveMember(member.id);
        break;
    }
  }

  void _showChangeRoleDialog(dynamic member) {
    Get.dialog(
      AlertDialog(
        title: Text('Change Role for ${member.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TeamRole.values.map((role) => 
            ListTile(
              title: Text(role.displayName),
              subtitle: Text(role.description),
              onTap: () {
                Navigator.pop(Get.context!);
                onChangeRole(member.id, role);
              },
            ),
          ).toList(),
        ),
      ),
    );
  }
}
