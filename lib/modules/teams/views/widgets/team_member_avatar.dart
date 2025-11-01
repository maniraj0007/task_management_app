import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../models/team_member_model.dart';

/// Team Member Avatar Widget
/// Displays team member avatar with status indicator
class TeamMemberAvatar extends StatelessWidget {
  final TeamMemberModel member;
  final double? size;
  final bool showStatus;
  final VoidCallback? onTap;

  const TeamMemberAvatar({
    super.key,
    required this.member,
    this.size,
    this.showStatus = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = size ?? AppDimensions.avatarSize;
    
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: avatarSize / 2,
            backgroundColor: AppColors.primary,
            backgroundImage: member.avatarUrl != null 
                ? NetworkImage(member.avatarUrl!)
                : null,
            child: member.avatarUrl == null
                ? Text(
                    member.initials,
                    style: TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: avatarSize * 0.4,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          if (showStatus)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: avatarSize * 0.3,
                height: avatarSize * 0.3,
                decoration: BoxDecoration(
                  color: member.isCurrentlyActive 
                      ? AppColors.success 
                      : AppColors.grey400,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.background,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
