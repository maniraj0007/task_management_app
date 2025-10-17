import 'dart:async';
import 'package:get/get.dart';
import '../../../core/enums/team_enums.dart';
import '../models/project_model.dart';
import '../services/project_service.dart';
import '../../auth/services/auth_service.dart';
import 'team_controller.dart';

/// Project Controller
/// Manages project-related state and operations with GetX reactive programming
class ProjectController extends GetxController {
  static ProjectController get instance => Get.find<ProjectController>();
  
  final ProjectService _projectService = Get.find<ProjectService>();
  final AuthService _authService = Get.find<AuthService>();
  final TeamController _teamController = Get.find<TeamController>();
  
  // ==================== REACTIVE STATE ====================
  
  // Current project state
  final Rx<ProjectModel?> _currentProject = Rx<ProjectModel?>(null);
  final RxList<ProjectModel> _teamProjects = <ProjectModel>[].obs;
  final RxList<ProjectModel> _userProjects = <ProjectModel>[].obs;
  final RxList<ProjectModel> _overdueProjects = <ProjectModel>[].obs;
  
  // UI state
  final RxBool _isLoading = false.obs;
  final RxBool _isCreatingProject = false.obs;
  final RxBool _isUpdatingProject = false.obs;
  final RxBool _isLoadingTeamProjects = false.obs;
  final RxBool _isLoadingUserProjects = false.obs;
  final RxString _error = ''.obs;
  
  // Search and filtering
  final RxString _searchQuery = ''.obs;
  final RxList<ProjectModel> _searchResults = <ProjectModel>[].obs;
  final RxBool _isSearching = false.obs;
  final Rx<ProjectStatus?> _statusFilter = Rx<ProjectStatus?>(null);
  final Rx<ProjectPriority?> _priorityFilter = Rx<ProjectPriority?>(null);
  final Rx<ProjectType?> _typeFilter = Rx<ProjectType?>(null);
  
  // Project creation form state
  final RxString _projectName = ''.obs;
  final RxString _projectDescription = ''.obs;
  final Rx<ProjectStatus> _projectStatus = ProjectStatus.planning.obs;
  final Rx<ProjectPriority> _projectPriority = ProjectPriority.medium.obs;
  final Rx<ProjectType> _projectType = ProjectType.general.obs;
  final Rx<DateTime?> _startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> _endDate = Rx<DateTime?>(null);
  final RxInt _estimatedHours = 0.obs;
  final RxList<String> _projectTags = <String>[].obs;
  final RxString _repository = ''.obs;
  final RxString _website = ''.obs;
  
  // Stream subscriptions
  StreamSubscription<ProjectModel?>? _currentProjectSubscription;
  StreamSubscription<List<ProjectModel>>? _teamProjectsSubscription;
  
  // ==================== GETTERS ====================
  
  ProjectModel? get currentProject => _currentProject.value;
  List<ProjectModel> get teamProjects => _teamProjects;
  List<ProjectModel> get userProjects => _userProjects;
  List<ProjectModel> get overdueProjects => _overdueProjects;
  
  bool get isLoading => _isLoading.value;
  bool get isCreatingProject => _isCreatingProject.value;
  bool get isUpdatingProject => _isUpdatingProject.value;
  bool get isLoadingTeamProjects => _isLoadingTeamProjects.value;
  bool get isLoadingUserProjects => _isLoadingUserProjects.value;
  String get error => _error.value;
  
  String get searchQuery => _searchQuery.value;
  List<ProjectModel> get searchResults => _searchResults;
  bool get isSearching => _isSearching.value;
  ProjectStatus? get statusFilter => _statusFilter.value;
  ProjectPriority? get priorityFilter => _priorityFilter.value;
  ProjectType? get typeFilter => _typeFilter.value;
  
  // Form getters
  String get projectName => _projectName.value;
  String get projectDescription => _projectDescription.value;
  ProjectStatus get projectStatus => _projectStatus.value;
  ProjectPriority get projectPriority => _projectPriority.value;
  ProjectType get projectType => _projectType.value;
  DateTime? get startDate => _startDate.value;
  DateTime? get endDate => _endDate.value;
  int get estimatedHours => _estimatedHours.value;
  List<String> get projectTags => _projectTags;
  String get repository => _repository.value;
  String get website => _website.value;
  
  // Computed properties
  bool get hasCurrentProject => currentProject != null;
  bool get canCurrentUserManageProject => 
      currentProject != null && _canUserManageProject(currentProject!);
  bool get canCurrentUserDeleteProject => 
      currentProject != null && _canUserDeleteProject(currentProject!);
  
  // Project statistics
  int get totalProjects => _userProjects.length;
  int get activeProjects => _userProjects.where((p) => p.isActive).length;
  int get completedProjects => _userProjects.where((p) => p.isCompleted).length;
  int get overdueProjectsCount => _overdueProjects.length;
  
  // Filtered projects
  List<ProjectModel> get filteredTeamProjects {
    var projects = _teamProjects.toList();
    
    if (_statusFilter.value != null) {
      projects = projects.where((p) => p.status == _statusFilter.value).toList();
    }
    
    if (_priorityFilter.value != null) {
      projects = projects.where((p) => p.priority == _priorityFilter.value).toList();
    }
    
    if (_typeFilter.value != null) {
      projects = projects.where((p) => p.type == _typeFilter.value).toList();
    }
    
    return projects;
  }
  
  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }
  
  @override
  void onClose() {
    _currentProjectSubscription?.cancel();
    _teamProjectsSubscription?.cancel();
    super.onClose();
  }
  
  // ==================== INITIALIZATION ====================
  
  void _initializeController() {
    // Load user's projects on initialization
    loadUserProjects();
    
    // Listen to auth state changes
    ever(_authService.isAuthenticated, (bool isAuthenticated) {
      if (isAuthenticated) {
        loadUserProjects();
      } else {
        _clearState();
      }
    });
    
    // Listen to current team changes
    ever(_teamController.currentTeam, (TeamModel? team) {
      if (team != null) {
        loadTeamProjects(team.id);
      } else {
        _teamProjects.clear();
        _teamProjectsSubscription?.cancel();
      }
    });
  }
  
  void _clearState() {
    _currentProject.value = null;
    _teamProjects.clear();
    _userProjects.clear();
    _overdueProjects.clear();
    _searchResults.clear();
    _clearError();
    _clearFormState();
    _clearFilters();
    
    _currentProjectSubscription?.cancel();
    _teamProjectsSubscription?.cancel();
  }
  
  void _clearError() {
    _error.value = '';
  }
  
  void _setError(String message) {
    _error.value = message;
  }
  
  // ==================== PROJECT OPERATIONS ====================
  
  /// Load user's projects
  Future<void> loadUserProjects() async {
    if (_authService.currentUser == null) return;
    
    try {
      _isLoadingUserProjects.value = true;
      _clearError();
      
      final projects = await _projectService.getUserProjects(_authService.currentUser!.id);
      _userProjects.assignAll(projects);
      
      // Load overdue projects
      await _loadOverdueProjects();
      
    } catch (e) {
      _setError('Failed to load projects: ${e.toString()}');
    } finally {
      _isLoadingUserProjects.value = false;
    }
  }
  
  /// Load team projects
  Future<void> loadTeamProjects(String teamId) async {
    try {
      _isLoadingTeamProjects.value = true;
      _clearError();
      
      // Cancel existing subscription
      _teamProjectsSubscription?.cancel();
      
      // Start listening to team projects
      _teamProjectsSubscription = _projectService.listenToTeamProjects(teamId).listen(
        (projects) {
          _teamProjects.assignAll(projects);
        },
        onError: (error) {
          _setError('Failed to listen to team projects: ${error.toString()}');
        },
      );
      
    } catch (e) {
      _setError('Failed to load team projects: ${e.toString()}');
    } finally {
      _isLoadingTeamProjects.value = false;
    }
  }
  
  /// Load overdue projects
  Future<void> _loadOverdueProjects() async {
    try {
      final overdue = await _projectService.getOverdueProjects();
      _overdueProjects.assignAll(overdue);
    } catch (e) {
      // Don't show error for overdue projects as it's not critical
      print('Failed to load overdue projects: $e');
    }
  }
  
  /// Create a new project
  Future<bool> createProject() async {
    if (_authService.currentUser == null || _teamController.currentTeam == null) return false;
    
    try {
      _isCreatingProject.value = true;
      _clearError();
      
      // Validate form
      if (_projectName.value.trim().isEmpty) {
        _setError('Project name is required');
        return false;
      }
      
      if (_projectDescription.value.trim().isEmpty) {
        _setError('Project description is required');
        return false;
      }
      
      // Create project model
      final project = ProjectModel.create(
        name: _projectName.value.trim(),
        description: _projectDescription.value.trim(),
        teamId: _teamController.currentTeam!.id,
        createdBy: _authService.currentUser!.id,
        status: _projectStatus.value,
        priority: _projectPriority.value,
        type: _projectType.value,
        startDate: _startDate.value,
        endDate: _endDate.value,
        estimatedHours: _estimatedHours.value > 0 ? _estimatedHours.value : null,
        tags: _projectTags.toList(),
        projectManager: _authService.currentUser!.id,
      );
      
      // Create project
      final createdProject = await _projectService.createProject(project);
      if (createdProject == null) {
        _setError('Failed to create project');
        return false;
      }
      
      // Add to user projects and set as current
      _userProjects.add(createdProject);
      await setCurrentProject(createdProject.id);
      
      // Clear form
      _clearFormState();
      
      Get.snackbar(
        'Success',
        'Project "${createdProject.name}" created successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } catch (e) {
      _setError('Failed to create project: ${e.toString()}');
      return false;
    } finally {
      _isCreatingProject.value = false;
    }
  }
  
  /// Update current project
  Future<bool> updateProject(Map<String, dynamic> updates) async {
    if (currentProject == null) return false;
    
    try {
      _isUpdatingProject.value = true;
      _clearError();
      
      final updatedProject = await _projectService.updateProject(currentProject!.id, updates);
      if (updatedProject == null) {
        _setError('Failed to update project');
        return false;
      }
      
      // Update in user projects list
      final index = _userProjects.indexWhere((p) => p.id == updatedProject.id);
      if (index != -1) {
        _userProjects[index] = updatedProject;
      }
      
      Get.snackbar(
        'Success',
        'Project updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } catch (e) {
      _setError('Failed to update project: ${e.toString()}');
      return false;
    } finally {
      _isUpdatingProject.value = false;
    }
  }
  
  /// Delete project
  Future<bool> deleteProject(String projectId) async {
    try {
      _isLoading.value = true;
      _clearError();
      
      final success = await _projectService.deleteProject(projectId);
      if (!success) {
        _setError('Failed to delete project');
        return false;
      }
      
      // Remove from user projects
      _userProjects.removeWhere((p) => p.id == projectId);
      
      // Clear current project if it was deleted
      if (currentProject?.id == projectId) {
        await clearCurrentProject();
      }
      
      Get.snackbar(
        'Success',
        'Project deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } catch (e) {
      _setError('Failed to delete project: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Archive project
  Future<bool> archiveProject(String projectId) async {
    try {
      _isLoading.value = true;
      _clearError();
      
      final success = await _projectService.archiveProject(projectId);
      if (!success) {
        _setError('Failed to archive project');
        return false;
      }
      
      // Refresh user projects
      await loadUserProjects();
      
      Get.snackbar(
        'Success',
        'Project archived successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } catch (e) {
      _setError('Failed to archive project: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  // ==================== PROJECT STATUS MANAGEMENT ====================
  
  /// Update project status
  Future<bool> updateProjectStatus(String projectId, ProjectStatus newStatus) async {
    try {
      _isLoading.value = true;
      _clearError();
      
      final updatedProject = await _projectService.updateProjectStatus(projectId, newStatus);
      if (updatedProject == null) {
        _setError('Failed to update project status');
        return false;
      }
      
      // Update in lists
      _updateProjectInLists(updatedProject);
      
      Get.snackbar(
        'Success',
        'Project status updated to ${newStatus.displayName}!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } catch (e) {
      _setError('Failed to update project status: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Start project
  Future<bool> startProject(String projectId) async {
    return await updateProjectStatus(projectId, ProjectStatus.active);
  }
  
  /// Complete project
  Future<bool> completeProject(String projectId) async {
    return await updateProjectStatus(projectId, ProjectStatus.completed);
  }
  
  /// Put project on hold
  Future<bool> holdProject(String projectId) async {
    return await updateProjectStatus(projectId, ProjectStatus.onHold);
  }
  
  /// Cancel project
  Future<bool> cancelProject(String projectId) async {
    return await updateProjectStatus(projectId, ProjectStatus.cancelled);
  }
  
  // ==================== CURRENT PROJECT MANAGEMENT ====================
  
  /// Set current project and start listening to updates
  Future<void> setCurrentProject(String projectId) async {
    try {
      _isLoading.value = true;
      _clearError();
      
      // Cancel existing subscription
      _currentProjectSubscription?.cancel();
      
      // Get project details
      final project = await _projectService.getProjectById(projectId);
      if (project == null) {
        _setError('Project not found');
        return;
      }
      
      _currentProject.value = project;
      
      // Start listening to project updates
      _currentProjectSubscription = _projectService.listenToProject(projectId).listen(
        (updatedProject) {
          if (updatedProject != null) {
            _currentProject.value = updatedProject;
            _updateProjectInLists(updatedProject);
          }
        },
        onError: (error) {
          _setError('Failed to listen to project updates: ${error.toString()}');
        },
      );
      
    } catch (e) {
      _setError('Failed to set current project: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Clear current project
  Future<void> clearCurrentProject() async {
    _currentProject.value = null;
    _currentProjectSubscription?.cancel();
  }
  
  /// Update project in all lists
  void _updateProjectInLists(ProjectModel updatedProject) {
    // Update in user projects
    final userIndex = _userProjects.indexWhere((p) => p.id == updatedProject.id);
    if (userIndex != -1) {
      _userProjects[userIndex] = updatedProject;
    }
    
    // Update in team projects
    final teamIndex = _teamProjects.indexWhere((p) => p.id == updatedProject.id);
    if (teamIndex != -1) {
      _teamProjects[teamIndex] = updatedProject;
    }
  }
  
  // ==================== PROJECT MEMBER MANAGEMENT ====================
  
  /// Add member to current project
  Future<bool> addProjectMember(String userId, {String? role}) async {
    if (currentProject == null) return false;
    
    try {
      _isLoading.value = true;
      _clearError();
      
      final success = await _projectService.addProjectMember(currentProject!.id, userId, role: role);
      if (!success) {
        _setError('Failed to add project member');
        return false;
      }
      
      Get.snackbar(
        'Success',
        'Member added to project successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } catch (e) {
      _setError('Failed to add project member: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Remove member from current project
  Future<bool> removeProjectMember(String userId) async {
    if (currentProject == null) return false;
    
    try {
      _isLoading.value = true;
      _clearError();
      
      final success = await _projectService.removeProjectMember(currentProject!.id, userId);
      if (!success) {
        _setError('Failed to remove project member');
        return false;
      }
      
      Get.snackbar(
        'Success',
        'Member removed from project successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } catch (e) {
      _setError('Failed to remove project member: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  // ==================== SEARCH AND FILTERING ====================
  
  /// Search projects
  Future<void> searchProjects(String query) async {
    _searchQuery.value = query;
    
    if (query.trim().isEmpty) {
      _searchResults.clear();
      return;
    }
    
    try {
      _isSearching.value = true;
      _clearError();
      
      final results = await _projectService.searchProjects(
        query.trim(),
        teamId: _teamController.currentTeam?.id,
      );
      _searchResults.assignAll(results);
      
    } catch (e) {
      _setError('Failed to search projects: ${e.toString()}');
    } finally {
      _isSearching.value = false;
    }
  }
  
  /// Clear search
  void clearSearch() {
    _searchQuery.value = '';
    _searchResults.clear();
  }
  
  /// Set status filter
  void setStatusFilter(ProjectStatus? status) {
    _statusFilter.value = status;
  }
  
  /// Set priority filter
  void setPriorityFilter(ProjectPriority? priority) {
    _priorityFilter.value = priority;
  }
  
  /// Set type filter
  void setTypeFilter(ProjectType? type) {
    _typeFilter.value = type;
  }
  
  /// Clear all filters
  void _clearFilters() {
    _statusFilter.value = null;
    _priorityFilter.value = null;
    _typeFilter.value = null;
  }
  
  /// Clear all filters (public method)
  void clearFilters() {
    _clearFilters();
  }
  
  // ==================== FORM STATE MANAGEMENT ====================
  
  void setProjectName(String name) => _projectName.value = name;
  void setProjectDescription(String description) => _projectDescription.value = description;
  void setProjectStatus(ProjectStatus status) => _projectStatus.value = status;
  void setProjectPriority(ProjectPriority priority) => _projectPriority.value = priority;
  void setProjectType(ProjectType type) => _projectType.value = type;
  void setStartDate(DateTime? date) => _startDate.value = date;
  void setEndDate(DateTime? date) => _endDate.value = date;
  void setEstimatedHours(int hours) => _estimatedHours.value = hours;
  void setRepository(String repo) => _repository.value = repo;
  void setWebsite(String site) => _website.value = site;
  
  void addProjectTag(String tag) {
    if (!_projectTags.contains(tag)) {
      _projectTags.add(tag);
    }
  }
  
  void removeProjectTag(String tag) {
    _projectTags.remove(tag);
  }
  
  void _clearFormState() {
    _projectName.value = '';
    _projectDescription.value = '';
    _projectStatus.value = ProjectStatus.planning;
    _projectPriority.value = ProjectPriority.medium;
    _projectType.value = ProjectType.general;
    _startDate.value = null;
    _endDate.value = null;
    _estimatedHours.value = 0;
    _projectTags.clear();
    _repository.value = '';
    _website.value = '';
  }
  
  // ==================== UTILITY METHODS ====================
  
  /// Check if user can manage project
  bool _canUserManageProject(ProjectModel project) {
    final userId = _authService.currentUser?.id;
    if (userId == null) return false;
    
    // Project manager or creator can manage
    if (project.projectManager == userId || project.createdBy == userId) {
      return true;
    }
    
    // Check team permissions
    return _teamController.canCurrentUserCreateProjects;
  }
  
  /// Check if user can delete project
  bool _canUserDeleteProject(ProjectModel project) {
    final userId = _authService.currentUser?.id;
    if (userId == null) return false;
    
    // Only project creator or team owner can delete
    if (project.createdBy == userId) return true;
    
    // Check if user is team owner
    return _teamController.currentTeam?.createdBy == userId;
  }
  
  /// Get project by ID from user projects
  ProjectModel? getProjectById(String projectId) {
    return _userProjects.where((p) => p.id == projectId).firstOrNull;
  }
  
  /// Refresh current project data
  Future<void> refreshCurrentProject() async {
    if (currentProject != null) {
      await setCurrentProject(currentProject!.id);
    }
  }
  
  /// Refresh user projects
  Future<void> refreshUserProjects() async {
    await loadUserProjects();
  }
  
  /// Refresh team projects
  Future<void> refreshTeamProjects() async {
    if (_teamController.currentTeam != null) {
      await loadTeamProjects(_teamController.currentTeam!.id);
    }
  }
}
