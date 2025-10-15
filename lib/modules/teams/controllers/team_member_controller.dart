import 'dart:async';
import 'package:get/get.dart';
import '../../../core/enums/team_enums.dart';
import '../models/team_member_model.dart';
import '../models/team_invitation_model.dart';
import '../services/team_invitation_service.dart';
import '../../auth/services/auth_service.dart';
import 'team_controller.dart';

/// Team Member Controller
/// Manages team member operations and invitations with GetX reactive programming
class TeamMemberController extends GetxController {
  static TeamMemberController get instance => Get.find<TeamMemberController>();
  
  final TeamInvitationService _invitationService = Get.find<TeamInvitationService>();
  final AuthService _authService = Get.find<AuthService>();
  final TeamController _teamController = Get.find<TeamController>();
  
  // ==================== REACTIVE STATE ====================
  
  // Team invitations state
  final RxList<TeamInvitationModel> _teamInvitations = <TeamInvitationModel>[].obs;
  final RxList<TeamInvitationModel> _userInvitations = <TeamInvitationModel>[].obs;
  final RxList<TeamInvitationModel> _pendingInvitations = <TeamInvitationModel>[].obs;
  
  // UI state
  final RxBool _isLoading = false.obs;
  final RxBool _isCreatingInvitation = false.obs;
  final RxBool _isProcessingInvitation = false.obs;
  final RxBool _isLoadingInvitations = false.obs;
  final RxBool _isUpdatingMember = false.obs;
  final RxString _error = ''.obs;
  
  // Search and filtering
  final RxString _searchQuery = ''.obs;
  final RxList<TeamMemberModel> _searchResults = <TeamMemberModel>[].obs;
  final RxBool _isSearching = false.obs;
  final Rx<TeamRole?> _roleFilter = Rx<TeamRole?>(null);
  final Rx<InvitationStatus?> _invitationStatusFilter = Rx<InvitationStatus?>(null);
  
  // Invitation form state
  final RxString _inviteeEmail = ''.obs;
  final Rx<TeamRole> _proposedRole = TeamRole.member.obs;
  final RxString _invitationMessage = ''.obs;
  final RxString _welcomeMessage = ''.obs;
  final RxBool _requiresVerification = false.obs;
  final RxInt _expirationDays = 7.obs;
  
  // Member management state
  final RxString _selectedMemberId = ''.obs;
  final Rx<TeamRole?> _newMemberRole = Rx<TeamRole?>(null);
  
  // Stream subscriptions
  StreamSubscription<List<TeamInvitationModel>>? _teamInvitationsSubscription;
  StreamSubscription<List<TeamInvitationModel>>? _userInvitationsSubscription;
  
  // ==================== GETTERS ====================
  
  List<TeamInvitationModel> get teamInvitations => _teamInvitations;
  List<TeamInvitationModel> get userInvitations => _userInvitations;
  List<TeamInvitationModel> get pendingInvitations => _pendingInvitations;
  
  bool get isLoading => _isLoading.value;
  bool get isCreatingInvitation => _isCreatingInvitation.value;
  bool get isProcessingInvitation => _isProcessingInvitation.value;
  bool get isLoadingInvitations => _isLoadingInvitations.value;
  bool get isUpdatingMember => _isUpdatingMember.value;
  String get error => _error.value;
  
  String get searchQuery => _searchQuery.value;
  List<TeamMemberModel> get searchResults => _searchResults;
  bool get isSearching => _isSearching.value;
  TeamRole? get roleFilter => _roleFilter.value;
  InvitationStatus? get invitationStatusFilter => _invitationStatusFilter.value;
  
  // Form getters
  String get inviteeEmail => _inviteeEmail.value;
  TeamRole get proposedRole => _proposedRole.value;
  String get invitationMessage => _invitationMessage.value;
  String get welcomeMessage => _welcomeMessage.value;
  bool get requiresVerification => _requiresVerification.value;
  int get expirationDays => _expirationDays.value;
  
  // Member management getters
  String get selectedMemberId => _selectedMemberId.value;
  TeamRole? get newMemberRole => _newMemberRole.value;
  
  // Computed properties
  bool get canCurrentUserInviteMembers => _teamController.canCurrentUserManageMembers;
  bool get canCurrentUserManageMembers => _teamController.canCurrentUserManageMembers;
  
  // Statistics
  int get totalInvitations => _teamInvitations.length;
  int get pendingInvitationsCount => _pendingInvitations.length;
  int get acceptedInvitations => _teamInvitations.where((i) => i.isAccepted).length;
  int get declinedInvitations => _teamInvitations.where((i) => i.isDeclined).length;
  
  // Filtered members
  List<TeamMemberModel> get filteredMembers {
    var members = _teamController.currentTeamMembers.toList();
    
    if (_roleFilter.value != null) {
      members = members.where((m) => m.role == _roleFilter.value).toList();
    }
    
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      members = members.where((m) {
        return (m.displayName?.toLowerCase().contains(query) ?? false) ||
               (m.email?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    
    return members;
  }
  
  // Filtered invitations
  List<TeamInvitationModel> get filteredInvitations {
    var invitations = _teamInvitations.toList();
    
    if (_invitationStatusFilter.value != null) {
      invitations = invitations.where((i) => i.status == _invitationStatusFilter.value).toList();
    }
    
    return invitations;
  }
  
  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }
  
  @override
  void onClose() {
    _teamInvitationsSubscription?.cancel();
    _userInvitationsSubscription?.cancel();
    super.onClose();
  }
  
  // ==================== INITIALIZATION ====================
  
  void _initializeController() {
    // Load user's invitations on initialization
    loadUserInvitations();
    
    // Listen to auth state changes
    ever(_authService.isAuthenticated, (bool isAuthenticated) {
      if (isAuthenticated) {
        loadUserInvitations();
      } else {
        _clearState();
      }
    });
    
    // Listen to current team changes
    ever(_teamController.currentTeam, (team) {
      if (team != null) {
        loadTeamInvitations(team.id);
      } else {
        _teamInvitations.clear();
        _teamInvitationsSubscription?.cancel();
      }
    });
  }
  
  void _clearState() {
    _teamInvitations.clear();
    _userInvitations.clear();
    _pendingInvitations.clear();
    _searchResults.clear();
    _clearError();
    _clearFormState();
    _clearFilters();
    
    _teamInvitationsSubscription?.cancel();
    _userInvitationsSubscription?.cancel();
  }
  
  void _clearError() {
    _error.value = '';
  }
  
  void _setError(String message) {
    _error.value = message;
  }
  
  // ==================== INVITATION OPERATIONS ====================
  
  /// Load team invitations
  Future<void> loadTeamInvitations(String teamId) async {
    try {
      _isLoadingInvitations.value = true;
      _clearError();
      
      // Cancel existing subscription
      _teamInvitationsSubscription?.cancel();
      
      // Start listening to team invitations
      _teamInvitationsSubscription = _invitationService.listenToTeamInvitations(teamId).listen(
        (invitations) {
          _teamInvitations.assignAll(invitations);
          _updatePendingInvitations();
        },
        onError: (error) {
          _setError('Failed to listen to team invitations: ${error.toString()}');
        },
      );
      
    } catch (e) {
      _setError('Failed to load team invitations: ${e.toString()}');
    } finally {
      _isLoadingInvitations.value = false;
    }
  }
  
  /// Load user invitations
  Future<void> loadUserInvitations() async {
    if (_authService.currentUser?.email == null) return;
    
    try {
      _isLoadingInvitations.value = true;
      _clearError();
      
      // Cancel existing subscription
      _userInvitationsSubscription?.cancel();
      
      // Start listening to user invitations
      _userInvitationsSubscription = _invitationService.listenToUserInvitations(_authService.currentUser!.email!).listen(
        (invitations) {
          _userInvitations.assignAll(invitations);
        },
        onError: (error) {
          _setError('Failed to listen to user invitations: ${error.toString()}');
        },
      );
      
    } catch (e) {
      _setError('Failed to load user invitations: ${e.toString()}');
    } finally {
      _isLoadingInvitations.value = false;
    }
  }
  
  /// Update pending invitations list
  void _updatePendingInvitations() {
    _pendingInvitations.assignAll(
      _teamInvitations.where((i) => i.isPending).toList(),
    );
  }
  
  /// Create team invitation
  Future<bool> createInvitation() async {
    if (_teamController.currentTeam == null) return false;
    
    try {
      _isCreatingInvitation.value = true;
      _clearError();
      
      // Validate form
      if (_inviteeEmail.value.trim().isEmpty) {
        _setError('Email is required');
        return false;
      }
      
      if (!GetUtils.isEmail(_inviteeEmail.value.trim())) {
        _setError('Please enter a valid email address');
        return false;
      }
      
      // Create invitation model
      final invitation = TeamInvitationModel.create(
        teamId: _teamController.currentTeam!.id,
        teamName: _teamController.currentTeam!.name,
        invitedBy: _authService.currentUser!.id,
        invitedByName: _authService.currentUser!.name,
        inviteeEmail: _inviteeEmail.value.trim(),
        proposedRole: _proposedRole.value,
        invitedByPhotoUrl: _authService.currentUser!.photoUrl,
        message: _invitationMessage.value.trim().isEmpty ? null : _invitationMessage.value.trim(),
        welcomeMessage: _welcomeMessage.value.trim().isEmpty ? null : _welcomeMessage.value.trim(),
        expirationDuration: Duration(days: _expirationDays.value),
        requiresVerification: _requiresVerification.value,
      );
      
      // Create invitation
      final createdInvitation = await _invitationService.createInvitation(invitation);
      if (createdInvitation == null) {
        _setError('Failed to create invitation');
        return false;
      }
      
      // Clear form
      _clearFormState();
      
      Get.snackbar(
        'Success',
        'Invitation sent to ${createdInvitation.inviteeEmail}!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } catch (e) {
      _setError('Failed to create invitation: ${e.toString()}');
      return false;
    } finally {
      _isCreatingInvitation.value = false;
    }
  }
  
  /// Accept invitation
  Future<bool> acceptInvitation(String invitationId, {String? verificationCode}) async {
    try {
      _isProcessingInvitation.value = true;
      _clearError();
      
      final success = await _invitationService.acceptInvitation(invitationId, verificationCode: verificationCode);
      if (!success) {
        _setError('Failed to accept invitation');
        return false;
      }
      
      // Refresh team data if user joined current team
      await _teamController.refreshCurrentTeam();
      
      Get.snackbar(
        'Success',
        'Invitation accepted! Welcome to the team!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } catch (e) {
      _setError('Failed to accept invitation: ${e.toString()}');
      return false;
    } finally {
      _isProcessingInvitation.value = false;
    }
  }
  
  /// Decline invitation
  Future<bool> declineInvitation(String invitationId, {String? reason}) async {
    try {
      _isProcessingInvitation.value = true;
      _clearError();
      
      final success = await _invitationService.declineInvitation(invitationId, reason: reason);
      if (!success) {
        _setError('Failed to decline invitation');
        return false;
      }
      
      Get.snackbar(
        'Success',
        'Invitation declined',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } catch (e) {
      _setError('Failed to decline invitation: ${e.toString()}');
      return false;
    } finally {
      _isProcessingInvitation.value = false;
    }
  }
  
  /// Cancel invitation
  Future<bool> cancelInvitation(String invitationId, {String? reason}) async {
    try {
      _isProcessingInvitation.value = true;
      _clearError();
      
      final success = await _invitationService.cancelInvitation(invitationId, reason: reason);
      if (!success) {
        _setError('Failed to cancel invitation');
        return false;
      }
      
      Get.snackbar(
        'Success',
        'Invitation cancelled',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } catch (e) {
      _setError('Failed to cancel invitation: ${e.toString()}');
      return false;
    } finally {
      _isProcessingInvitation.value = false;
    }
  }
  
  /// Send invitation reminder
  Future<bool> sendInvitationReminder(String invitationId) async {
    try {
      _isLoading.value = true;
      _clearError();
      
      final success = await _invitationService.sendInvitationReminder(invitationId);
      if (!success) {
        _setError('Failed to send reminder');
        return false;
      }
      
      Get.snackbar(
        'Success',
        'Reminder sent successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } catch (e) {
      _setError('Failed to send reminder: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  // ==================== MEMBER MANAGEMENT ====================
  
  /// Update member role
  Future<bool> updateMemberRole(String userId, TeamRole newRole) async {
    try {
      _isUpdatingMember.value = true;
      _clearError();
      
      final success = await _teamController.updateMemberRole(userId, newRole);
      if (!success) {
        _setError('Failed to update member role');
        return false;
      }
      
      return true;
      
    } catch (e) {
      _setError('Failed to update member role: ${e.toString()}');
      return false;
    } finally {
      _isUpdatingMember.value = false;
    }
  }
  
  /// Remove team member
  Future<bool> removeMember(String userId) async {
    try {
      _isUpdatingMember.value = true;
      _clearError();
      
      final success = await _teamController.removeTeamMember(userId);
      if (!success) {
        _setError('Failed to remove member');
        return false;
      }
      
      return true;
      
    } catch (e) {
      _setError('Failed to remove member: ${e.toString()}');
      return false;
    } finally {
      _isUpdatingMember.value = false;
    }
  }
  
  // ==================== SEARCH AND FILTERING ====================
  
  /// Search members
  void searchMembers(String query) {
    _searchQuery.value = query;
    
    if (query.trim().isEmpty) {
      _searchResults.clear();
      return;
    }
    
    final results = _teamController.currentTeamMembers.where((member) {
      final searchTerm = query.toLowerCase();
      return (member.displayName?.toLowerCase().contains(searchTerm) ?? false) ||
             (member.email?.toLowerCase().contains(searchTerm) ?? false) ||
             (member.title?.toLowerCase().contains(searchTerm) ?? false) ||
             (member.department?.toLowerCase().contains(searchTerm) ?? false);
    }).toList();
    
    _searchResults.assignAll(results);
  }
  
  /// Clear search
  void clearSearch() {
    _searchQuery.value = '';
    _searchResults.clear();
  }
  
  /// Set role filter
  void setRoleFilter(TeamRole? role) {
    _roleFilter.value = role;
  }
  
  /// Set invitation status filter
  void setInvitationStatusFilter(InvitationStatus? status) {
    _invitationStatusFilter.value = status;
  }
  
  /// Clear all filters
  void _clearFilters() {
    _roleFilter.value = null;
    _invitationStatusFilter.value = null;
  }
  
  /// Clear all filters (public method)
  void clearFilters() {
    _clearFilters();
  }
  
  // ==================== FORM STATE MANAGEMENT ====================
  
  void setInviteeEmail(String email) => _inviteeEmail.value = email;
  void setProposedRole(TeamRole role) => _proposedRole.value = role;
  void setInvitationMessage(String message) => _invitationMessage.value = message;
  void setWelcomeMessage(String message) => _welcomeMessage.value = message;
  void setRequiresVerification(bool requires) => _requiresVerification.value = requires;
  void setExpirationDays(int days) => _expirationDays.value = days;
  
  void setSelectedMemberId(String memberId) => _selectedMemberId.value = memberId;
  void setNewMemberRole(TeamRole? role) => _newMemberRole.value = role;
  
  void _clearFormState() {
    _inviteeEmail.value = '';
    _proposedRole.value = TeamRole.member;
    _invitationMessage.value = '';
    _welcomeMessage.value = '';
    _requiresVerification.value = false;
    _expirationDays.value = 7;
    _selectedMemberId.value = '';
    _newMemberRole.value = null;
  }
  
  // ==================== UTILITY METHODS ====================
  
  /// Get member by ID
  TeamMemberModel? getMemberById(String memberId) {
    return _teamController.currentTeamMembers.where((m) => m.userId == memberId).firstOrNull;
  }
  
  /// Get invitation by ID
  TeamInvitationModel? getInvitationById(String invitationId) {
    return _teamInvitations.where((i) => i.id == invitationId).firstOrNull;
  }
  
  /// Check if user can manage member
  bool canManageMember(TeamMemberModel member) {
    final currentMembership = _teamController.currentUserMembership;
    if (currentMembership == null) return false;
    
    return currentMembership.canManageMember(member);
  }
  
  /// Check if invitation can be cancelled
  bool canCancelInvitation(TeamInvitationModel invitation) {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return false;
    
    return invitation.canCancel && 
           (invitation.invitedBy == currentUser.id || canCurrentUserInviteMembers);
  }
  
  /// Check if invitation can have reminder sent
  bool canSendReminder(TeamInvitationModel invitation) {
    return invitation.canSendReminder && canCurrentUserInviteMembers;
  }
  
  /// Get members by role
  List<TeamMemberModel> getMembersByRole(TeamRole role) {
    return _teamController.currentTeamMembers.where((m) => m.role == role).toList();
  }
  
  /// Get active members count
  int get activeMembersCount {
    return _teamController.currentTeamMembers.where((m) => m.isCurrentlyActive).length;
  }
  
  /// Get members needing attention (inactive for too long)
  List<TeamMemberModel> get membersNeedingAttention {
    return _teamController.currentTeamMembers.where((m) => m.needsAttention).toList();
  }
  
  /// Get high-performing members
  List<TeamMemberModel> get highPerformingMembers {
    return _teamController.currentTeamMembers.where((m) => m.performanceScore >= 80).toList();
  }
  
  /// Get members available for assignments
  List<TeamMemberModel> get availableMembers {
    return _teamController.currentTeamMembers.where((m) => m.isAvailableForAssignments).toList();
  }
  
  /// Refresh invitations
  Future<void> refreshInvitations() async {
    if (_teamController.currentTeam != null) {
      await loadTeamInvitations(_teamController.currentTeam!.id);
    }
    await loadUserInvitations();
  }
  
  /// Get invitation statistics
  Map<String, int> get invitationStats {
    return {
      'total': totalInvitations,
      'pending': pendingInvitationsCount,
      'accepted': acceptedInvitations,
      'declined': declinedInvitations,
      'expired': _teamInvitations.where((i) => i.status == InvitationStatus.expired).length,
      'cancelled': _teamInvitations.where((i) => i.status == InvitationStatus.cancelled).length,
    };
  }
  
  /// Get member statistics
  Map<String, int> get memberStats {
    final members = _teamController.currentTeamMembers;
    return {
      'total': members.length,
      'active': members.where((m) => m.isCurrentlyActive).length,
      'owners': members.where((m) => m.role == TeamRole.owner).length,
      'admins': members.where((m) => m.role == TeamRole.admin).length,
      'managers': members.where((m) => m.role == TeamRole.manager).length,
      'members': members.where((m) => m.role == TeamRole.member).length,
      'guests': members.where((m) => m.role == TeamRole.guest).length,
      'needingAttention': membersNeedingAttention.length,
      'highPerforming': highPerformingMembers.length,
      'available': availableMembers.length,
    };
  }
}
