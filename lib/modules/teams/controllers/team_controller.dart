import 'dart:async';
import 'package:get/get.dart';
import '../../../core/enums/team_enums.dart';
import '../models/team_model.dart';
import '../models/team_member_model.dart';
import '../services/team_service.dart';
import '../../auth/services/auth_service.dart';

/// Team Controller
/// Manages team-related state and operations with GetX reactive programming
class TeamController extends GetxController {
  static TeamController get instance => Get.find<TeamController>();
  
  final TeamService _teamService = Get.find<TeamService>();
  final AuthService _authService = Get.find<AuthService>();
  
  // ==================== REACTIVE STATE ====================
  
  // Current team state
  final Rx<TeamModel?> _currentTeam = Rx<TeamModel?>(null);
  final RxList<TeamModel> _userTeams = <TeamModel>[].obs;
  final RxList<TeamMemberModel> _currentTeamMembers = <TeamMemberModel>[].obs;
  
  // UI state
  final RxBool _isLoading = false.obs;
  final RxBool _isCreatingTeam = false.obs;
  final RxBool _isUpdatingTeam = false.obs;
  final RxBool _isLoadingMembers = false.obs;
  final RxString _error = ''.obs;
  
  // Search and filtering
  final RxString _searchQuery = ''.obs;
  final RxList<TeamModel> _searchResults = <TeamModel>[].obs;
  final RxBool _isSearching = false.obs;
  
  // Team creation form state
  final RxString _teamName = ''.obs;
  final RxString _teamDescription = ''.obs;
  final Rx<TeamVisibility> _teamVisibility = TeamVisibility.private.obs;
  final RxList<String> _teamTags = <String>[].obs;
  final RxString _teamWebsite = ''.obs;
  final RxString _teamLocation = ''.obs;
  final RxInt _maxMembers = 50.obs;
  
  // Stream subscriptions
  StreamSubscription<TeamModel?>? _currentTeamSubscription;
  StreamSubscription<List<TeamMemberModel>>? _currentTeamMembersSubscription;
  
  // ==================== GETTERS ====================
  
  TeamModel? get currentTeam => _currentTeam.value;
  List<TeamModel> get userTeams => _userTeams;
  List<TeamMemberModel> get currentTeamMembers => _currentTeamMembers;
  
  bool get isLoading => _isLoading.value;
  bool get isCreatingTeam => _isCreatingTeam.value;
  bool get isUpdatingTeam => _isUpdatingTeam.value;
  bool get isLoadingMembers => _isLoadingMembers.value;
  String get error => _error.value;
  
  String get searchQuery => _searchQuery.value;
  List<TeamModel> get searchResults => _searchResults;
  bool get isSearching => _isSearching.value;
  
  // Form getters
  String get teamName => _teamName.value;
  String get teamDescription => _teamDescription.value;
  TeamVisibility get teamVisibility => _teamVisibility.value;
  List<String> get teamTags => _teamTags;
  String get teamWebsite => _teamWebsite.value;
  String get teamLocation => _teamLocation.value;
  int get maxMembers => _maxMembers.value;
  
  // Computed properties
  bool get hasCurrentTeam => currentTeam != null;
  bool get canCurrentUserManageTeam => 
      currentTeam?.canUserManageTeam(_authService.currentUser?.id ?? '') ?? false;
  bool get canCurrentUserManageMembers => 
      currentTeam?.canUserManageMembers(_authService.currentUser?.id ?? '') ?? false;
  bool get canCurrentUserCreateProjects => 
      currentTeam?.canUserCreateProjects(_authService.currentUser?.id ?? '') ?? false;
  bool get canCurrentUserViewAnalytics => 
      currentTeam?.canUserViewAnalytics(_authService.currentUser?.id ?? '') ?? false;
  
  TeamMemberModel? get currentUserMembership {
    final userId = _authService.currentUser?.id;
    if (userId == null) return null;
    return _currentTeamMembers.where((m) => m.userId == userId).firstOrNull;
  }
  
  TeamRole? get currentUserRole => currentUserMembership?.role;
  
  // Team statistics
  int get totalTeams => _userTeams.length;
  int get activeTeams => _userTeams.where((t) => t.isActive && !t.isArchived).length;
  int get ownedTeams => _userTeams.where((t) => t.createdBy == _authService.currentUser?.id).length;
  
  // Dashboard-specific getters
  List<Map<String, dynamic>> get teamProjects => []; // TODO: Implement project loading
  int get activeTasksCount => 0; // TODO: Implement task counting
  int get completedTasksCount => 0; // TODO: Implement completed task counting
  List<Map<String, dynamic>> get performanceData => []; // TODO: Implement performance data
  
  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }
  
  @override
  void onClose() {
    _currentTeamSubscription?.cancel();
    _currentTeamMembersSubscription?.cancel();
    super.onClose();
  }
  
  // ==================== INITIALIZATION ====================
  
  void _initializeController() {
    // Load user's teams on initialization
    loadUserTeams();
    
    // Listen to auth state changes
    ever(_authService.isAuthenticated, (bool isAuthenticated) {
      if (isAuthenticated) {
        loadUserTeams();
      } else {
        _clearState();
      }
    });
  }
  
  void _clearState() {
    _currentTeam.value = null;
    _userTeams.clear();
    _currentTeamMembers.clear();
    _searchResults.clear();
    _clearError();
    _clearFormState();
    
    _currentTeamSubscription?.cancel();
    _currentTeamMembersSubscription?.cancel();
  }
  
  void _clearError() {
    _error.value = '';
  }
  
  void _setError(String message) {
    _error.value = message;
  }
  
  // ==================== TEAM OPERATIONS ====================
  
  /// Load user's teams
  Future<void> loadUserTeams() async {
    if (_authService.currentUser == null) return;
    
    try {
      _isLoading.value = true;
      _clearError();
      
      final teams = await _teamService.getUserTeams(_authService.currentUser!.id);
      _userTeams.assignAll(teams);
      
    } catch (e) {
      _setError('Failed to load teams: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Create a new team
  Future<bool> createTeam() async {
    if (_authService.currentUser == null) return false;
    
    try {
      _isCreatingTeam.value = true;
      _clearError();
      
      // Validate form
      if (_teamName.value.trim().isEmpty) {
        _setError('Team name is required');
        return false;
      }
      
      if (_teamDescription.value.trim().isEmpty) {
        _setError('Team description is required');
        return false;
      }
      
      // Create team model
      final team = TeamModel.create(
        name: _teamName.value.trim(),
        description: _teamDescription.value.trim(),
        createdBy: _authService.currentUser!.id,
        visibility: _teamVisibility.value,
        tags: _teamTags.toList(),
        website: _teamWebsite.value.trim().isEmpty ? null : _teamWebsite.value.trim(),
        location: _teamLocation.value.trim().isEmpty ? null : _teamLocation.value.trim(),
        maxMembers: _maxMembers.value,
      );
      
      // Create team
      final createdTeam = await _teamService.createTeam(team);
      if (createdTeam == null) {
        _setError('Failed to create team');
        return false;
      }
      
      // Add to user teams and set as current
      _userTeams.add(createdTeam);
      await setCurrentTeam(createdTeam.id);
      
      // Clear form
      _clearFormState();
      
      Get.snackbar(
        'Success',
        'Team "${createdTeam.name}" created successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } catch (e) {
      _setError('Failed to create team: ${e.toString()}');
      return false;
    } finally {
      _isCreatingTeam.value = false;
    }
  }
  
  /// Update current team
  Future<bool> updateTeam(Map<String, dynamic> updates) async {
    if (currentTeam == null) return false;
    
    try {
      _isUpdatingTeam.value = true;
      _clearError();
      
      final updatedTeam = await _teamService.updateTeam(currentTeam!.id, updates);
      if (updatedTeam == null) {
        _setError('Failed to update team');
        return false;
      }
      
      // Update in user teams list
      final index = _userTeams.indexWhere((t) => t.id == updatedTeam.id);
      if (index != -1) {
        _userTeams[index] = updatedTeam;
      }
      
      Get.snackbar(
        'Success',
        'Team updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } catch (e) {
      _setError('Failed to update team: ${e.toString()}');
      return false;
    } finally {
      _isUpdatingTeam.value = false;
    }
  }
  
  /// Delete team
  Future<bool> deleteTeam(String teamId) async {
    try {
      _isLoading.value = true;
      _clearError();
      
      final success = await _teamService.deleteTeam(teamId);
      if (!success) {
        _setError('Failed to delete team');
        return false;
      }
      
      // Remove from user teams
      _userTeams.removeWhere((t) => t.id == teamId);
      
      // Clear current team if it was deleted
      if (currentTeam?.id == teamId) {
        await clearCurrentTeam();
      }
      
      Get.snackbar(
        'Success',
        'Team deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } catch (e) {
      _setError('Failed to delete team: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Archive team
  Future<bool> archiveTeam(String teamId) async {
    try {
      _isLoading.value = true;
      _clearError();
      
      final success = await _teamService.archiveTeam(teamId);
      if (!success) {
        _setError('Failed to archive team');
        return false;
      }
      
      // Refresh user teams
      await loadUserTeams();
      
      Get.snackbar(
        'Success',
        'Team archived successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } catch (e) {
      _setError('Failed to archive team: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  // ==================== CURRENT TEAM MANAGEMENT ====================
  
  /// Set current team and start listening to updates
  Future<void> setCurrentTeam(String teamId) async {
    try {
      _isLoading.value = true;
      _clearError();
      
      // Cancel existing subscriptions
      _currentTeamSubscription?.cancel();
      _currentTeamMembersSubscription?.cancel();
      
      // Get team details
      final team = await _teamService.getTeamById(teamId);
      if (team == null) {
        _setError('Team not found');
        return;
      }
      
      _currentTeam.value = team;
      
      // Start listening to team updates
      _currentTeamSubscription = _teamService.listenToTeam(teamId).listen(
        (updatedTeam) {
          if (updatedTeam != null) {
            _currentTeam.value = updatedTeam;
            
            // Update in user teams list
            final index = _userTeams.indexWhere((t) => t.id == updatedTeam.id);
            if (index != -1) {
              _userTeams[index] = updatedTeam;
            }
          }
        },
        onError: (error) {
          _setError('Failed to listen to team updates: ${error.toString()}');
        },
      );
      
      // Load and listen to team members
      await _loadCurrentTeamMembers();
      
    } catch (e) {
      _setError('Failed to set current team: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Clear current team
  Future<void> clearCurrentTeam() async {
    _currentTeam.value = null;
    _currentTeamMembers.clear();
    
    _currentTeamSubscription?.cancel();
    _currentTeamMembersSubscription?.cancel();
  }
  
  /// Load current team members
  Future<void> _loadCurrentTeamMembers() async {
    if (currentTeam == null) return;
    
    try {
      _isLoadingMembers.value = true;
      
      // Start listening to team members
      _currentTeamMembersSubscription = _teamService.listenToTeamMembers(currentTeam!.id).listen(
        (members) {
          _currentTeamMembers.assignAll(members);
        },
        onError: (error) {
          _setError('Failed to listen to team members: ${error.toString()}');
        },
      );
      
    } catch (e) {
      _setError('Failed to load team members: ${e.toString()}');
    } finally {
      _isLoadingMembers.value = false;
    }
  }
  
  // ==================== MEMBER MANAGEMENT ====================
  
  /// Add member to current team
  Future<bool> addTeamMember({
    required String userId,
    required TeamRole role,
    String? displayName,
    String? email,
    String? photoUrl,
  }) async {
    if (currentTeam == null) return false;
    
    try {
      _isLoading.value = true;
      _clearError();
      
      final member = await _teamService.addTeamMember(
        teamId: currentTeam!.id,
        userId: userId,
        role: role,
        displayName: displayName,
        email: email,
        photoUrl: photoUrl,
      );
      
      if (member == null) {
        _setError('Failed to add team member');
        return false;
      }
      
      Get.snackbar(
        'Success',
        'Member added to team successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } catch (e) {
      _setError('Failed to add team member: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Remove member from current team
  Future<bool> removeTeamMember(String userId) async {
    if (currentTeam == null) return false;
    
    try {
      _isLoading.value = true;
      _clearError();
      
      final success = await _teamService.removeTeamMember(currentTeam!.id, userId);
      if (!success) {
        _setError('Failed to remove team member');
        return false;
      }
      
      Get.snackbar(
        'Success',
        'Member removed from team successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } catch (e) {
      _setError('Failed to remove team member: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Update member role
  Future<bool> updateMemberRole(String userId, TeamRole newRole) async {
    if (currentTeam == null) return false;
    
    try {
      _isLoading.value = true;
      _clearError();
      
      final updatedMember = await _teamService.updateMemberRole(currentTeam!.id, userId, newRole);
      if (updatedMember == null) {
        _setError('Failed to update member role');
        return false;
      }
      
      Get.snackbar(
        'Success',
        'Member role updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } catch (e) {
      _setError('Failed to update member role: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Invite member to team by email
  Future<bool> inviteMember(String teamId, String email) async {
    try {
      _isLoading.value = true;
      _clearError();
      
      // TODO: Implement actual invitation logic
      // This is a placeholder implementation
      
      Get.snackbar(
        'Success',
        'Invitation sent to $email successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } catch (e) {
      _setError('Failed to send invitation: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  // ==================== SEARCH FUNCTIONALITY ====================
  
  /// Search teams
  Future<void> searchTeams(String query) async {
    _searchQuery.value = query;
    
    if (query.trim().isEmpty) {
      _searchResults.clear();
      return;
    }
    
    try {
      _isSearching.value = true;
      _clearError();
      
      final results = await _teamService.searchTeams(query.trim());
      _searchResults.assignAll(results);
      
    } catch (e) {
      _setError('Failed to search teams: ${e.toString()}');
    } finally {
      _isSearching.value = false;
    }
  }
  
  /// Clear search
  void clearSearch() {
    _searchQuery.value = '';
    _searchResults.clear();
  }
  
  // ==================== FORM STATE MANAGEMENT ====================
  
  void setTeamName(String name) => _teamName.value = name;
  void setTeamDescription(String description) => _teamDescription.value = description;
  void setTeamVisibility(TeamVisibility visibility) => _teamVisibility.value = visibility;
  void setTeamWebsite(String website) => _teamWebsite.value = website;
  void setTeamLocation(String location) => _teamLocation.value = location;
  void setMaxMembers(int maxMembers) => _maxMembers.value = maxMembers;
  
  void addTeamTag(String tag) {
    if (!_teamTags.contains(tag)) {
      _teamTags.add(tag);
    }
  }
  
  void removeTeamTag(String tag) {
    _teamTags.remove(tag);
  }
  
  void _clearFormState() {
    _teamName.value = '';
    _teamDescription.value = '';
    _teamVisibility.value = TeamVisibility.private;
    _teamTags.clear();
    _teamWebsite.value = '';
    _teamLocation.value = '';
    _maxMembers.value = 50;
  }
  
  // ==================== UTILITY METHODS ====================
  
  /// Get team by ID from user teams
  TeamModel? getTeamById(String teamId) {
    return _userTeams.where((t) => t.id == teamId).firstOrNull;
  }
  
  /// Check if user is member of team
  bool isUserMemberOfTeam(String teamId, String userId) {
    final team = getTeamById(teamId);
    return team?.isMember(userId) ?? false;
  }
  
  /// Get user's role in team
  TeamRole? getUserRoleInTeam(String teamId, String userId) {
    final team = getTeamById(teamId);
    return team?.getUserRole(userId);
  }
  
  /// Refresh current team data
  Future<void> refreshCurrentTeam() async {
    if (currentTeam != null) {
      await setCurrentTeam(currentTeam!.id);
    }
  }
  
  /// Refresh user teams
  Future<void> refreshUserTeams() async {
    await loadUserTeams();
  }
}
