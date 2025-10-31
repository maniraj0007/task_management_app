import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/enums/team_enums.dart';
import '../../controllers/project_controller.dart';
import '../../controllers/team_controller.dart';
import '../../models/project_model.dart';
import '../widgets/project_card.dart';
import '../widgets/project_filter_bar.dart';

/// Projects Screen
/// Comprehensive project management interface with filtering and search
class ProjectsScreen extends StatefulWidget {
  final String? teamId;

  const ProjectsScreen({
    super.key,
    this.teamId,
  });

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _projectController = Get.find<ProjectController>();
  final _teamController = Get.find<TeamController>();
  
  // Filter state
  ProjectStatus? _selectedStatus;
  ProjectPriority? _selectedPriority;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProjects();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    if (widget.teamId != null) {
      await _projectController.loadTeamProjects(widget.teamId!);
    } else {
      await _projectController.loadUserProjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Stats Header
          _buildStatsHeader(),
          
          // Filter Bar
          ProjectFilterBar(
            selectedStatus: _selectedStatus,
            selectedPriority: _selectedPriority,
            searchQuery: _searchQuery,
            onStatusChanged: (status) {
              setState(() => _selectedStatus = status);
              _applyFilters();
            },
            onPriorityChanged: (priority) {
              setState(() => _selectedPriority = priority);
              _applyFilters();
            },
            onSearchChanged: (query) {
              setState(() => _searchQuery = query);
              _applyFilters();
            },
            onClearFilters: _clearFilters,
          ),
          
          // Tab Bar
          _buildTabBar(),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActiveTab(),
                _buildCompletedTab(),
                _buildAllTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.teamId != null ? 'Team Projects' : 'My Projects'),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: _loadProjects,
          icon: const Icon(Icons.refresh),
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'sort_name',
              child: ListTile(
                leading: Icon(Icons.sort_by_alpha),
                title: Text('Sort by Name'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'sort_date',
              child: ListTile(
                leading: Icon(Icons.date_range),
                title: Text('Sort by Date'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'sort_priority',
              child: ListTile(
                leading: Icon(Icons.priority_high),
                title: Text('Sort by Priority'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'view_archived',
              child: ListTile(
                leading: Icon(Icons.archive),
                title: Text('View Archived'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsHeader() {
    return Obx(() => Container(
      margin: const EdgeInsets.all(AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.tertiary,
            AppColors.tertiary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.tertiary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.folder_open,
                color: AppColors.onTertiary,
                size: 28,
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.onTertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.teamId != null 
                          ? 'Team project management'
                          : 'Your project dashboard',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onTertiary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Active',
                  _projectController.activeProjectsCount.toString(),
                  Icons.play_circle,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  _projectController.completedProjectsCount.toString(),
                  Icons.check_circle,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: _buildStatCard(
                  'Total',
                  _projectController.totalProjectsCount.toString(),
                  Icons.folder,
                  AppColors.onTertiary,
                ),
              ),
            ],
          ),
          
          // Progress indicator
          const SizedBox(height: AppDimensions.paddingMedium),
          Row(
            children: [
              Text(
                'Overall Progress',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onTertiary.withOpacity(0.8),
                ),
              ),
              const Spacer(),
              Text(
                '${_projectController.overallProgress}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: _projectController.overallProgress / 100,
            backgroundColor: AppColors.onTertiary.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.onTertiary),
          ),
        ],
      ),
    ));
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.onTertiary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppColors.onTertiary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.onTertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onTertiary.withOpacity(0.8),
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
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Active'),
                const SizedBox(width: 4),
                Obx(() {
                  final count = _projectController.activeProjectsCount;
                  if (count > 0) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          color: AppColors.onSuccess,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
          const Tab(text: 'Completed'),
          const Tab(text: 'All'),
        ],
      ),
    );
  }

  Widget _buildActiveTab() {
    return Obx(() {
      final projects = _projectController.filteredActiveProjects;
      return _buildProjectsList(projects, 'No Active Projects', 
          'Start a new project to see it here');
    });
  }

  Widget _buildCompletedTab() {
    return Obx(() {
      final projects = _projectController.filteredCompletedProjects;
      return _buildProjectsList(projects, 'No Completed Projects', 
          'Completed projects will appear here');
    });
  }

  Widget _buildAllTab() {
    return Obx(() {
      final projects = _projectController.filteredAllProjects;
      return _buildProjectsList(projects, 'No Projects', 
          'Create your first project to get started');
    });
  }

  Widget _buildProjectsList(List<ProjectModel> projects, String emptyTitle, String emptySubtitle) {
    if (_projectController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (projects.isEmpty) {
      return _buildEmptyState(emptyTitle, emptySubtitle);
    }
    
    return RefreshIndicator(
      onRefresh: _loadProjects,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return ProjectCard(
            project: project,
            onTap: () => _navigateToProjectDetail(project),
            onLongPress: () => _showProjectOptions(context, project),
            showTeamInfo: widget.teamId == null,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_outlined,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          ElevatedButton.icon(
            onPressed: _createProject,
            icon: const Icon(Icons.add),
            label: const Text('Create Project'),
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

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _createProject,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      icon: const Icon(Icons.add),
      label: const Text('New Project'),
      elevation: 4,
    );
  }

  // Action handlers
  void _applyFilters() {
    _projectController.applyFilters(
      status: _selectedStatus,
      priority: _selectedPriority,
      searchQuery: _searchQuery,
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedPriority = null;
      _searchQuery = '';
    });
    _projectController.clearFilters();
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'sort_name':
        _projectController.sortBy(ProjectSortBy.name);
        break;
      case 'sort_date':
        _projectController.sortBy(ProjectSortBy.date);
        break;
      case 'sort_priority':
        _projectController.sortBy(ProjectSortBy.priority);
        break;
      case 'view_archived':
        _navigateToArchivedProjects();
        break;
    }
  }

  void _navigateToProjectDetail(ProjectModel project) {
    Get.toNamed('/project-detail', arguments: {'projectId': project.id});
  }

  void _showProjectOptions(BuildContext context, ProjectModel project) {
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: project.priority.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.folder,
                    color: project.priority.color,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${project.progress}% complete',
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
                _navigateToProjectDetail(project);
              },
            ),
            
            if (_canManageProject(project))
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit Project'),
                onTap: () {
                  Navigator.pop(context);
                  _editProject(project);
                },
              ),
            
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share Project'),
              onTap: () {
                Navigator.pop(context);
                _shareProject(project);
              },
            ),
            
            if (_canManageProject(project))
              ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: const Text('Archive Project'),
                onTap: () {
                  Navigator.pop(context);
                  _archiveProject(project);
                },
              ),
          ],
        ),
      ),
    );
  }

  bool _canManageProject(ProjectModel project) {
    // Check if current user can manage this project
    return _teamController.canCurrentUserManageTeam || 
           project.ownerId == _teamController.currentUserId;
  }

  void _createProject() {
    Get.toNamed('/create-project', arguments: {'teamId': widget.teamId});
  }

  void _editProject(ProjectModel project) {
    Get.toNamed('/edit-project', arguments: {'projectId': project.id});
  }

  void _shareProject(ProjectModel project) {
    Get.snackbar('Share', 'Project sharing feature coming soon!');
  }

  void _archiveProject(ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Project'),
        content: Text('Are you sure you want to archive "${project.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _projectController.archiveProject(project.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  void _navigateToArchivedProjects() {
    Get.toNamed('/archived-projects');
  }
}
