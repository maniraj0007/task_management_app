import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/enums/team_enums.dart';
import '../../controllers/team_controller.dart';
import '../../controllers/team_member_controller.dart';
import '../../models/team_model.dart';
import '../widgets/team_member_list.dart';
import '../widgets/team_projects_overview.dart';
import '../widgets/invite_member_dialog.dart';

/// Team Detail Screen
/// Comprehensive team management interface with member management
class TeamDetailScreen extends StatefulWidget {
  final String teamId;

  const TeamDetailScreen({
    super.key,
    required this.teamId,
  });

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _teamController = Get.find<TeamController>();
  final _memberController = Get.find<TeamMemberController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTeamData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTeamData() async {
    await Future.wait([
      _teamController.loadTeamById(widget.teamId),
      _memberController.loadTeamMembers(widget.teamId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        final team = _teamController.getTeamById(widget.teamId);
        
        if (team == null) {
          return _buildLoadingState();
        }
        
        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSliverAppBar(team),
            _buildTeamInfoHeader(team),
          ],
          body: Column(
            children: [
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(team),
                    _buildMembersTab(team),
                    _buildProjectsTab(team),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading...'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildSliverAppBar(TeamModel team) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          team.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      actions: [
        if (_teamController.canCurrentUserManageTeam)
          IconButton(
            onPressed: () => _showTeamSettings(team),
            icon: const Icon(Icons.settings),
          ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, team),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('Share Team'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (_teamController.canCurrentUserManageTeam)
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit Team'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            if (_teamController.canCurrentUserManageTeam)
              const PopupMenuItem(
                value: 'archive',
                child: ListTile(
                  leading: Icon(Icons.archive),
                  title: Text('Archive Team'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            const PopupMenuItem(
              value: 'leave',
              child: ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Leave Team'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamInfoHeader(TeamModel team) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(AppDimensions.paddingMedium),
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Team basic info
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    team.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              team.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildVisibilityBadge(team.visibility),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        team.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // Team stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Members',
                    team.totalMembers.toString(),
                    Icons.people,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: _buildStatCard(
                    'Projects',
                    team.totalProjects.toString(),
                    Icons.folder,
                    AppColors.secondary,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: _buildStatCard(
                    'Health',
                    '${team.healthScore}%',
                    Icons.favorite,
                    _getHealthColor(team.healthScore),
                  ),
                ),
              ],
            ),
            
            // Additional info
            if (team.website.isNotEmpty || team.location.isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: AppDimensions.paddingMedium),
                  const Divider(),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  Row(
                    children: [
                      if (team.website.isNotEmpty) ...[
                        Icon(Icons.language, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            team.website,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                      if (team.website.isNotEmpty && team.location.isNotEmpty)
                        const SizedBox(width: AppDimensions.paddingMedium),
                      if (team.location.isNotEmpty) ...[
                        Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            team.location,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            
            // Tags
            if (team.tags.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.paddingMedium),
              Wrap(
                spacing: AppDimensions.paddingSmall,
                runSpacing: AppDimensions.paddingSmall,
                children: team.tags.map((tag) => Chip(
                  label: Text(tag),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityBadge(TeamVisibility visibility) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getVisibilityColor(visibility).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getVisibilityIcon(visibility),
            size: 12,
            color: _getVisibilityColor(visibility),
          ),
          const SizedBox(width: 4),
          Text(
            visibility.displayName,
            style: TextStyle(
              color: _getVisibilityColor(visibility),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Members'),
          Tab(text: 'Projects'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(TeamModel team) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Activity
          _buildSectionHeader('Recent Activity', Icons.timeline),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildActivityList(),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Team Performance
          _buildSectionHeader('Team Performance', Icons.analytics),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildPerformanceMetrics(team),
        ],
      ),
    );
  }

  Widget _buildMembersTab(TeamModel team) {
    return TeamMemberList(
      teamId: widget.teamId,
      canManageMembers: _teamController.canCurrentUserManageTeam,
      onInviteMember: () => _showInviteMemberDialog(),
      onRemoveMember: (memberId) => _removeMember(memberId),
      onChangeRole: (memberId, role) => _changeRole(memberId, role),
    );
  }

  Widget _buildProjectsTab(TeamModel team) {
    return TeamProjectsOverview(
      teamId: widget.teamId,
      canManageProjects: _teamController.canCurrentUserManageTeam,
      onCreateProject: () => _createProject(),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: AppDimensions.paddingSmall),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        children: [
          _buildActivityItem(
            'John Doe joined the team',
            '2 hours ago',
            Icons.person_add,
            AppColors.success,
          ),
          _buildActivityItem(
            'New project "Mobile App" created',
            '1 day ago',
            Icons.add_circle,
            AppColors.primary,
          ),
          _buildActivityItem(
            'Team settings updated',
            '3 days ago',
            Icons.settings,
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title),
      subtitle: Text(time),
      dense: true,
    );
  }

  Widget _buildPerformanceMetrics(TeamModel team) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        children: [
          _buildMetricRow('Task Completion Rate', '85%', 0.85),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildMetricRow('Team Collaboration', '92%', 0.92),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildMetricRow('Project Delivery', '78%', 0.78),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.outline.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 0.8 ? AppColors.success : 
            progress >= 0.6 ? AppColors.warning : AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget? _buildFloatingActionButton() {
    return Obx(() {
      final currentTab = _tabController.index;
      
      switch (currentTab) {
        case 1: // Members tab
          if (_teamController.canCurrentUserManageTeam) {
            return FloatingActionButton(
              onPressed: _showInviteMemberDialog,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.person_add),
            );
          }
          break;
        case 2: // Projects tab
          if (_teamController.canCurrentUserManageTeam) {
            return FloatingActionButton(
              onPressed: _createProject,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            );
          }
          break;
      }
      return null;
    });
  }

  // Helper methods
  Color _getHealthColor(int healthScore) {
    if (healthScore >= 80) return AppColors.success;
    if (healthScore >= 60) return AppColors.warning;
    return AppColors.error;
  }

  IconData _getVisibilityIcon(TeamVisibility visibility) {
    switch (visibility) {
      case TeamVisibility.private:
        return Icons.lock;
      case TeamVisibility.internal:
        return Icons.business;
      case TeamVisibility.public:
        return Icons.public;
    }
  }

  Color _getVisibilityColor(TeamVisibility visibility) {
    switch (visibility) {
      case TeamVisibility.private:
        return AppColors.error;
      case TeamVisibility.internal:
        return AppColors.warning;
      case TeamVisibility.public:
        return AppColors.success;
    }
  }

  // Action handlers
  void _handleMenuAction(String action, TeamModel team) {
    switch (action) {
      case 'share':
        _shareTeam(team);
        break;
      case 'edit':
        _editTeam(team);
        break;
      case 'archive':
        _archiveTeam(team);
        break;
      case 'leave':
        _leaveTeam(team);
        break;
    }
  }

  void _shareTeam(TeamModel team) {
    // Implement team sharing
    Get.snackbar('Share', 'Team sharing feature coming soon!');
  }

  void _editTeam(TeamModel team) {
    // Navigate to edit team screen
    Get.snackbar('Edit', 'Team editing feature coming soon!');
  }

  void _archiveTeam(TeamModel team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Team'),
        content: Text('Are you sure you want to archive "${team.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _teamController.archiveTeam(team.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  void _leaveTeam(TeamModel team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Team'),
        content: Text('Are you sure you want to leave "${team.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Implement leave team logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _showTeamSettings(TeamModel team) {
    Get.snackbar('Settings', 'Team settings feature coming soon!');
  }

  void _showInviteMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => InviteMemberDialog(
        teamId: widget.teamId,
        onInvite: (email, role) => _inviteMember(email, role),
      ),
    );
  }

  Future<void> _inviteMember(String email, TeamRole role) async {
    await _memberController.inviteTeamMember(widget.teamId, email, role);
  }

  Future<void> _removeMember(String memberId) async {
    await _memberController.removeTeamMember(widget.teamId, memberId);
  }

  Future<void> _changeRole(String memberId, TeamRole role) async {
    await _memberController.updateMemberRole(widget.teamId, memberId, role);
  }

  void _createProject() {
    Get.snackbar('Create Project', 'Project creation feature coming soon!');
  }
}
