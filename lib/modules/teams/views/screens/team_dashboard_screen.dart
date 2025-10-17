import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/team_controller.dart';
import '../../models/team_model.dart';
import '../widgets/team_stats_card.dart';
import '../widgets/team_member_avatar.dart';
import '../widgets/recent_team_activities.dart';
import '../widgets/team_project_card.dart';

/// Team Dashboard Screen
/// Comprehensive dashboard for team overview and management
class TeamDashboardScreen extends GetView<TeamController> {
  const TeamDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String teamId = Get.parameters['teamId'] ?? '';
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final team = controller.currentTeam.value;
        if (team == null) {
          return _buildTeamNotFound();
        }

        return CustomScrollView(
          slivers: [
            // App Bar with Team Info
            _buildSliverAppBar(team),
            
            // Dashboard Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Team Statistics
                    _buildTeamStatistics(team),
                    const SizedBox(height: AppDimensions.spacingLarge),

                    // Team Members Section
                    _buildTeamMembersSection(team),
                    const SizedBox(height: AppDimensions.spacingLarge),

                    // Projects Section
                    _buildProjectsSection(team),
                    const SizedBox(height: AppDimensions.spacingLarge),

                    // Performance Analytics
                    _buildPerformanceSection(team),
                    const SizedBox(height: AppDimensions.spacingLarge),

                    // Recent Activities
                    _buildRecentActivitiesSection(team),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Build sliver app bar with team information
  Widget _buildSliverAppBar(TeamModel team) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          team.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60), // Account for app bar
                Text(
                  team.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${team.members.length} members',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.folder,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${controller.teamProjects.length} projects',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showTeamMenu(),
          icon: const Icon(Icons.more_vert, color: Colors.white),
        ),
      ],
    );
  }

  /// Build team statistics section
  Widget _buildTeamStatistics(TeamModel team) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Team Overview',
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppDimensions.spacingMedium,
          mainAxisSpacing: AppDimensions.spacingMedium,
          childAspectRatio: 1.5,
          children: [
            TeamStatsCard(
              title: 'Active Tasks',
              value: controller.activeTasksCount.value.toString(),
              icon: Icons.task_alt,
              color: AppColors.info,
              onTap: () => Get.toNamed('/teams/${team.id}/tasks'),
            ),
            TeamStatsCard(
              title: 'Completed Tasks',
              value: controller.completedTasksCount.value.toString(),
              icon: Icons.check_circle,
              color: AppColors.success,
              onTap: () => Get.toNamed('/teams/${team.id}/tasks?status=completed'),
            ),
            TeamStatsCard(
              title: 'Team Projects',
              value: controller.teamProjects.length.toString(),
              icon: Icons.folder_open,
              color: AppColors.warning,
              onTap: () => Get.toNamed('/teams/${team.id}/projects'),
            ),
            TeamStatsCard(
              title: 'Team Members',
              value: team.members.length.toString(),
              icon: Icons.people,
              color: AppColors.primary,
              onTap: () => Get.toNamed('/teams/${team.id}/members'),
            ),
          ],
        ),
      ],
    );
  }

  /// Build team members section
  Widget _buildTeamMembersSection(TeamModel team) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Team Members',
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/teams/${team.id}/members'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        Container(
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
            children: [
              // Member Avatars
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: team.members.take(8).length + (team.members.length > 8 ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == 8 && team.members.length > 8) {
                      return Container(
                        width: 60,
                        margin: const EdgeInsets.only(right: 8),
                        child: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          child: Text(
                            '+${team.members.length - 8}',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }
                    
                    final member = team.members[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: TeamMemberAvatar(
                        member: member,
                        size: 60,
                        showOnlineStatus: true,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.spacingMedium),
              
              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showInviteMemberDialog(team),
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Invite Member'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMedium),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Get.toNamed('/teams/${team.id}/members'),
                      icon: const Icon(Icons.manage_accounts, size: 18),
                      label: const Text('Manage'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build projects section
  Widget _buildProjectsSection(TeamModel team) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Projects',
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/teams/${team.id}/projects'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        Obx(() {
          final projects = controller.teamProjects.take(3).toList();
          
          if (projects.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 48,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  Text(
                    'No projects yet',
                    style: Get.textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Text(
                    'Create your first project to get started',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed('/teams/${team.id}/projects/create'),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Project'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: projects.map((project) {
              return Container(
                margin: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
                child: TeamProjectCard(
                  project: project,
                  onTap: () => Get.toNamed('/projects/${project.id}'),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  /// Build performance section
  Widget _buildPerformanceSection(TeamModel team) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Team Performance',
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        Container(
          height: 200,
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
                'Task Completion Rate',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingMedium),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: controller.performanceData,
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build recent activities section
  Widget _buildRecentActivitiesSection(TeamModel team) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activities',
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/teams/${team.id}/activities'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        RecentTeamActivities(
          teamId: team.id,
          maxItems: 5,
        ),
      ],
    );
  }

  /// Build floating action button
  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickActions(),
      icon: const Icon(Icons.add),
      label: const Text('Quick Action'),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    );
  }

  /// Build team not found widget
  Widget _buildTeamNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_off,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(
            'Team not found',
            style: Get.textTheme.titleLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            'The team you\'re looking for doesn\'t exist or you don\'t have access to it.',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  /// Show team menu
  void _showTeamMenu() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusLarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Team'),
              onTap: () {
                Get.back();
                Get.toNamed('/teams/${controller.currentTeam.value?.id}/edit');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Team Settings'),
              onTap: () {
                Get.back();
                Get.toNamed('/teams/${controller.currentTeam.value?.id}/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Analytics'),
              onTap: () {
                Get.back();
                Get.toNamed('/teams/${controller.currentTeam.value?.id}/analytics');
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Team'),
              onTap: () {
                Get.back();
                _shareTeam();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Show invite member dialog
  void _showInviteMemberDialog(TeamModel team) {
    final emailController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Invite Team Member'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            hintText: 'Enter email address',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                controller.inviteMember(team.id, emailController.text);
                Get.back();
              }
            },
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }

  /// Show quick actions
  void _showQuickActions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusLarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quick Actions',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppDimensions.spacingMedium,
              mainAxisSpacing: AppDimensions.spacingMedium,
              childAspectRatio: 1.5,
              children: [
                _buildQuickActionCard(
                  'Create Task',
                  Icons.add_task,
                  AppColors.primary,
                  () {
                    Get.back();
                    Get.toNamed('/tasks/create?teamId=${controller.currentTeam.value?.id}');
                  },
                ),
                _buildQuickActionCard(
                  'New Project',
                  Icons.create_new_folder,
                  AppColors.success,
                  () {
                    Get.back();
                    Get.toNamed('/teams/${controller.currentTeam.value?.id}/projects/create');
                  },
                ),
                _buildQuickActionCard(
                  'Invite Member',
                  Icons.person_add,
                  AppColors.info,
                  () {
                    Get.back();
                    _showInviteMemberDialog(controller.currentTeam.value!);
                  },
                ),
                _buildQuickActionCard(
                  'Team Meeting',
                  Icons.video_call,
                  AppColors.warning,
                  () {
                    Get.back();
                    _startTeamMeeting();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build quick action card
  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Share team
  void _shareTeam() {
    // Implement team sharing functionality
    Get.snackbar(
      'Share Team',
      'Team sharing link copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Start team meeting
  void _startTeamMeeting() {
    // Implement team meeting functionality
    Get.snackbar(
      'Team Meeting',
      'Starting team meeting...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
