import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/enums/team_enums.dart';
import '../../controllers/team_controller.dart';
import '../../controllers/team_member_controller.dart';
import '../widgets/team_card.dart';
import '../widgets/team_search_bar.dart';
import '../widgets/team_filter_chips.dart';
import '../widgets/create_team_fab.dart';
import '../widgets/team_stats_header.dart';
import 'team_detail_screen.dart';
import 'create_team_screen.dart';

/// Teams Screen
/// Main screen for displaying and managing teams
class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teamController = Get.find<TeamController>();
    final memberController = Get.find<TeamMemberController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: () => teamController.refreshUserTeams(),
        child: CustomScrollView(
          slivers: [
            // Stats Header
            SliverToBoxAdapter(
              child: Obx(() => TeamStatsHeader(
                totalTeams: teamController.totalTeams,
                activeTeams: teamController.activeTeams,
                ownedTeams: teamController.ownedTeams,
                pendingInvitations: memberController.pendingInvitationsCount,
              )),
            ),
            
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: TeamSearchBar(
                  onSearch: teamController.searchTeams,
                  onClear: teamController.clearSearch,
                ),
              ),
            ),
            
            // Filter Chips
            SliverToBoxAdapter(
              child: Obx(() => TeamFilterChips(
                selectedVisibility: null, // Add filter state if needed
                onVisibilityChanged: (visibility) {
                  // Implement filtering logic
                },
              )),
            ),
            
            // Teams List
            Obx(() {
              if (teamController.isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              final teams = teamController.searchQuery.isNotEmpty
                  ? teamController.searchResults
                  : teamController.userTeams;
              
              if (teams.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(context),
                );
              }
              
              return SliverPadding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: AppDimensions.paddingMedium,
                    mainAxisSpacing: AppDimensions.paddingMedium,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final team = teams[index];
                      return TeamCard(
                        team: team,
                        onTap: () => _navigateToTeamDetail(team.id),
                        onLongPress: () => _showTeamOptions(context, team.id),
                      );
                    },
                    childCount: teams.length,
                  ),
                ),
              );
            }),
            
            // Error Display
            Obx(() {
              if (teamController.error.isNotEmpty) {
                return SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(AppDimensions.paddingMedium),
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: AppDimensions.paddingSmall),
                        Expanded(
                          child: Text(
                            teamController.error,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => teamController.clearSearch(),
                          icon: Icon(Icons.close, color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }),
          ],
        ),
      ),
      floatingActionButton: CreateTeamFAB(
        onPressed: () => _navigateToCreateTeam(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(AppStrings.teams),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () => _showTeamInvitations(context),
          icon: Obx(() {
            final memberController = Get.find<TeamMemberController>();
            final pendingCount = memberController.pendingInvitationsCount;
            
            return Stack(
              children: [
                const Icon(Icons.mail_outline),
                if (pendingCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        pendingCount > 99 ? '99+' : pendingCount.toString(),
                        style: const TextStyle(
                          color: AppColors.onError,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
        IconButton(
          onPressed: () => _showTeamSettings(context),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups_outlined,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Text(
            AppStrings.noTeams,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            'Create your first team to start collaborating',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateTeam(),
            icon: const Icon(Icons.add),
            label: const Text(AppStrings.createTeam),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingLarge,
                vertical: AppDimensions.paddingMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToTeamDetail(String teamId) {
    Get.to(() => TeamDetailScreen(teamId: teamId));
  }

  void _navigateToCreateTeam() {
    Get.to(() => const CreateTeamScreen());
  }

  void _showTeamOptions(BuildContext context, String teamId) {
    final teamController = Get.find<TeamController>();
    final team = teamController.getTeamById(teamId);
    
    if (team == null) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    team.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${team.totalMembers} members',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // Options
            ListTile(
              leading: const Icon(Icons.visibility_outlined),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                _navigateToTeamDetail(teamId);
              },
            ),
            
            if (teamController.canCurrentUserManageTeam)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit Team'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to edit team screen
                },
              ),
            
            if (teamController.canCurrentUserManageTeam)
              ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: const Text('Archive Team'),
                onTap: () {
                  Navigator.pop(context);
                  _showArchiveConfirmation(context, teamId);
                },
              ),
            
            ListTile(
              leading: const Icon(Icons.exit_to_app_outlined),
              title: const Text('Leave Team'),
              onTap: () {
                Navigator.pop(context);
                _showLeaveConfirmation(context, teamId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTeamInvitations(BuildContext context) {
    // Navigate to team invitations screen
    Get.toNamed('/team-invitations');
  }

  void _showTeamSettings(BuildContext context) {
    // Navigate to team settings screen
    Get.toNamed('/team-settings');
  }

  void _showArchiveConfirmation(BuildContext context, String teamId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Team'),
        content: const Text(
          'Are you sure you want to archive this team? This action can be undone later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final teamController = Get.find<TeamController>();
              await teamController.archiveTeam(teamId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: AppColors.onWarning,
            ),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  void _showLeaveConfirmation(BuildContext context, String teamId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Team'),
        content: const Text(AppStrings.leaveTeamConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final teamController = Get.find<TeamController>();
              final authService = Get.find();
              await teamController.removeTeamMember(authService.currentUser?.id ?? '');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}
