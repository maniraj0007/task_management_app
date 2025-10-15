import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../core/enums/team_enums.dart';
import '../../../core/services/error_handler_service.dart';
import '../models/team_model.dart';
import '../models/team_member_model.dart';
import '../../auth/services/auth_service.dart';

/// Team Service
/// Handles all team-related operations with Firestore integration
class TeamService extends GetxService {
  static TeamService get instance => Get.find<TeamService>();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();
  final ErrorHandlerService _errorHandler = Get.find<ErrorHandlerService>();
  
  // Collection references
  CollectionReference get _teamsCollection => _firestore.collection('teams');
  CollectionReference get _teamMembersCollection => _firestore.collection('team_members');
  
  // Cache for frequently accessed data
  final Map<String, TeamModel> _teamCache = {};
  final Map<String, List<TeamMemberModel>> _memberCache = {};
  
  // Stream controllers for real-time updates
  final Map<String, StreamController<TeamModel?>> _teamStreamControllers = {};
  final Map<String, StreamController<List<TeamMemberModel>>> _memberStreamControllers = {};
  
  @override
  void onClose() {
    // Clean up stream controllers
    for (final controller in _teamStreamControllers.values) {
      controller.close();
    }
    for (final controller in _memberStreamControllers.values) {
      controller.close();
    }
    super.onClose();
  }
  
  // ==================== TEAM CRUD OPERATIONS ====================
  
  /// Create a new team
  Future<TeamModel?> createTeam(TeamModel team) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Check if user can create teams
      if (!currentUser.role.canManageTeams) {
        throw Exception('Insufficient permissions to create teams');
      }
      
      // Create team document
      final docRef = await _teamsCollection.add(team.toJson());
      final createdTeam = team.copyWith(id: docRef.id);
      
      // Update cache
      _teamCache[docRef.id] = createdTeam;
      
      // Create team member record for creator
      final creatorMember = TeamMemberModel.create(
        userId: currentUser.id,
        teamId: docRef.id,
        addedBy: currentUser.id,
        role: TeamRole.owner,
        displayName: currentUser.name,
        email: currentUser.email,
        photoUrl: currentUser.photoUrl,
      );
      
      await _createTeamMember(creatorMember);
      
      // Log activity
      await _logTeamActivity(docRef.id, 'team_created', currentUser.id, {
        'teamName': team.name,
        'createdBy': currentUser.name,
      });
      
      return createdTeam;
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'TeamService.createTeam');
      return null;
    }
  }
  
  /// Get team by ID
  Future<TeamModel?> getTeamById(String teamId) async {
    try {
      // Check cache first
      if (_teamCache.containsKey(teamId)) {
        return _teamCache[teamId];
      }
      
      final doc = await _teamsCollection.doc(teamId).get();
      if (!doc.exists) return null;
      
      final team = TeamModel.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
      
      // Update cache
      _teamCache[teamId] = team;
      
      return team;
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'TeamService.getTeamById');
      return null;
    }
  }
  
  /// Update team
  Future<TeamModel?> updateTeam(String teamId, Map<String, dynamic> updates) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Check permissions
      if (!await _canUserManageTeam(teamId, currentUser.id)) {
        throw Exception('Insufficient permissions to update team');
      }
      
      // Add metadata
      updates['updatedAt'] = Timestamp.now();
      updates['lastActivityAt'] = Timestamp.now();
      updates['lastActivityBy'] = currentUser.id;
      
      // Update document
      await _teamsCollection.doc(teamId).update(updates);
      
      // Get updated team
      final updatedTeam = await getTeamById(teamId);
      
      // Log activity
      await _logTeamActivity(teamId, 'team_updated', currentUser.id, {
        'updatedFields': updates.keys.toList(),
      });
      
      return updatedTeam;
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'TeamService.updateTeam');
      return null;
    }
  }
  
  /// Delete team
  Future<bool> deleteTeam(String teamId) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Check permissions (only team owner can delete)
      final team = await getTeamById(teamId);
      if (team == null) return false;
      
      if (team.createdBy != currentUser.id && !currentUser.role.canDeleteTeams) {
        throw Exception('Only team owner can delete team');
      }
      
      // Use batch to delete team and all related data
      final batch = _firestore.batch();
      
      // Delete team document
      batch.delete(_teamsCollection.doc(teamId));
      
      // Delete all team members
      final membersQuery = await _teamMembersCollection
          .where('teamId', isEqualTo: teamId)
          .get();
      
      for (final doc in membersQuery.docs) {
        batch.delete(doc.reference);
      }
      
      // Commit batch
      await batch.commit();
      
      // Clear cache
      _teamCache.remove(teamId);
      _memberCache.remove(teamId);
      
      // Log activity
      await _logTeamActivity(teamId, 'team_deleted', currentUser.id, {
        'teamName': team.name,
        'deletedBy': currentUser.name,
      });
      
      return true;
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'TeamService.deleteTeam');
      return false;
    }
  }
  
  /// Archive team
  Future<bool> archiveTeam(String teamId) async {
    try {
      final updates = {
        'isArchived': true,
        'archivedAt': Timestamp.now(),
        'archivedBy': _authService.currentUser?.id,
        'updatedAt': Timestamp.now(),
      };
      
      final updatedTeam = await updateTeam(teamId, updates);
      return updatedTeam != null;
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'TeamService.archiveTeam');
      return false;
    }
  }
  
  // ==================== TEAM MEMBER MANAGEMENT ====================
  
  /// Add member to team
  Future<TeamMemberModel?> addTeamMember({
    required String teamId,
    required String userId,
    required TeamRole role,
    String? displayName,
    String? email,
    String? photoUrl,
  }) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Check permissions
      if (!await _canUserManageMembers(teamId, currentUser.id)) {
        throw Exception('Insufficient permissions to add team members');
      }
      
      // Check if user is already a member
      if (await _isUserTeamMember(teamId, userId)) {
        throw Exception('User is already a team member');
      }
      
      // Check team capacity
      final team = await getTeamById(teamId);
      if (team == null) throw Exception('Team not found');
      
      if (!team.canAcceptNewMembers) {
        throw Exception('Team cannot accept new members');
      }
      
      // Create team member
      final member = TeamMemberModel.create(
        userId: userId,
        teamId: teamId,
        addedBy: currentUser.id,
        role: role,
        displayName: displayName,
        email: email,
        photoUrl: photoUrl,
      );
      
      final createdMember = await _createTeamMember(member);
      if (createdMember == null) return null;
      
      // Update team statistics
      await _updateTeamMemberCount(teamId);
      
      // Log activity
      await _logTeamActivity(teamId, 'member_added', currentUser.id, {
        'addedUserId': userId,
        'addedUserName': displayName ?? 'Unknown',
        'role': role.displayName,
      });
      
      return createdMember;
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'TeamService.addTeamMember');
      return null;
    }
  }
  
  /// Remove member from team
  Future<bool> removeTeamMember(String teamId, String userId) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Check permissions
      if (!await _canUserManageMembers(teamId, currentUser.id)) {
        throw Exception('Insufficient permissions to remove team members');
      }
      
      // Get member to remove
      final member = await _getTeamMember(teamId, userId);
      if (member == null) {
        throw Exception('Team member not found');
      }
      
      // Cannot remove team owner
      if (member.role == TeamRole.owner) {
        throw Exception('Cannot remove team owner');
      }
      
      // Update member record (soft delete)
      final updates = {
        'isActive': false,
        'leftAt': Timestamp.now(),
        'removedBy': currentUser.id,
      };
      
      await _updateTeamMember(teamId, userId, updates);
      
      // Update team statistics
      await _updateTeamMemberCount(teamId);
      
      // Clear cache
      _memberCache.remove(teamId);
      
      // Log activity
      await _logTeamActivity(teamId, 'member_removed', currentUser.id, {
        'removedUserId': userId,
        'removedUserName': member.displayName ?? 'Unknown',
        'role': member.role.displayName,
      });
      
      return true;
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'TeamService.removeTeamMember');
      return false;
    }
  }
  
  /// Update team member role
  Future<TeamMemberModel?> updateMemberRole(String teamId, String userId, TeamRole newRole) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Check permissions
      if (!await _canUserManageMembers(teamId, currentUser.id)) {
        throw Exception('Insufficient permissions to update member roles');
      }
      
      // Get current member
      final member = await _getTeamMember(teamId, userId);
      if (member == null) {
        throw Exception('Team member not found');
      }
      
      // Cannot change owner role
      if (member.role == TeamRole.owner) {
        throw Exception('Cannot change team owner role');
      }
      
      // Update member role
      final updates = {
        'role': newRole.value,
      };
      
      await _updateTeamMember(teamId, userId, updates);
      
      // Get updated member
      final updatedMember = await _getTeamMember(teamId, userId);
      
      // Log activity
      await _logTeamActivity(teamId, 'member_role_updated', currentUser.id, {
        'userId': userId,
        'userName': member.displayName ?? 'Unknown',
        'oldRole': member.role.displayName,
        'newRole': newRole.displayName,
      });
      
      return updatedMember;
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'TeamService.updateMemberRole');
      return null;
    }
  }
  
  /// Get team members
  Future<List<TeamMemberModel>> getTeamMembers(String teamId, {bool activeOnly = true}) async {
    try {
      // Check cache first
      if (_memberCache.containsKey(teamId)) {
        final cached = _memberCache[teamId]!;
        return activeOnly ? cached.where((m) => m.isActive).toList() : cached;
      }
      
      Query query = _teamMembersCollection.where('teamId', isEqualTo: teamId);
      
      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }
      
      final snapshot = await query.get();
      final members = snapshot.docs.map((doc) {
        return TeamMemberModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
      
      // Update cache
      _memberCache[teamId] = members;
      
      return members;
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'TeamService.getTeamMembers');
      return [];
    }
  }
  
  // ==================== TEAM QUERIES ====================
  
  /// Get user's teams
  Future<List<TeamModel>> getUserTeams(String userId, {bool activeOnly = true}) async {
    try {
      // Get user's team memberships
      Query memberQuery = _teamMembersCollection.where('userId', isEqualTo: userId);
      
      if (activeOnly) {
        memberQuery = memberQuery.where('isActive', isEqualTo: true);
      }
      
      final memberSnapshot = await memberQuery.get();
      final teamIds = memberSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>)
          .map((data) => data['teamId'] as String)
          .toList();
      
      if (teamIds.isEmpty) return [];
      
      // Get teams (Firestore 'in' query limit is 10)
      final teams = <TeamModel>[];
      for (int i = 0; i < teamIds.length; i += 10) {
        final batch = teamIds.skip(i).take(10).toList();
        final teamQuery = _teamsCollection.where(FieldPath.documentId, whereIn: batch);
        
        if (activeOnly) {
          // Note: This filter might not work with whereIn, consider restructuring if needed
        }
        
        final teamSnapshot = await teamQuery.get();
        final batchTeams = teamSnapshot.docs.map((doc) {
          return TeamModel.fromJson({
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          });
        }).toList();
        
        teams.addAll(batchTeams);
      }
      
      return teams;
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'TeamService.getUserTeams');
      return [];
    }
  }
  
  /// Search teams
  Future<List<TeamModel>> searchTeams(String searchTerm, {int limit = 20}) async {
    try {
      if (searchTerm.trim().isEmpty) return [];
      
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation - consider using Algolia or similar for production
      final query = _teamsCollection
          .where('name', isGreaterThanOrEqualTo: searchTerm)
          .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .limit(limit);
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        return TeamModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'TeamService.searchTeams');
      return [];
    }
  }
  
  // ==================== REAL-TIME LISTENERS ====================
  
  /// Listen to team updates
  Stream<TeamModel?> listenToTeam(String teamId) {
    if (!_teamStreamControllers.containsKey(teamId)) {
      _teamStreamControllers[teamId] = StreamController<TeamModel?>.broadcast();
      
      _teamsCollection.doc(teamId).snapshots().listen(
        (snapshot) {
          if (snapshot.exists) {
            final team = TeamModel.fromJson({
              'id': snapshot.id,
              ...snapshot.data() as Map<String, dynamic>,
            });
            _teamCache[teamId] = team;
            _teamStreamControllers[teamId]?.add(team);
          } else {
            _teamStreamControllers[teamId]?.add(null);
          }
        },
        onError: (error) {
          _errorHandler.logError(error, null, context: 'TeamService.listenToTeam');
          _teamStreamControllers[teamId]?.addError(error);
        },
      );
    }
    
    return _teamStreamControllers[teamId]!.stream;
  }
  
  /// Listen to team members
  Stream<List<TeamMemberModel>> listenToTeamMembers(String teamId) {
    if (!_memberStreamControllers.containsKey(teamId)) {
      _memberStreamControllers[teamId] = StreamController<List<TeamMemberModel>>.broadcast();
      
      _teamMembersCollection
          .where('teamId', isEqualTo: teamId)
          .where('isActive', isEqualTo: true)
          .snapshots()
          .listen(
        (snapshot) {
          final members = snapshot.docs.map((doc) {
            return TeamMemberModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            });
          }).toList();
          
          _memberCache[teamId] = members;
          _memberStreamControllers[teamId]?.add(members);
        },
        onError: (error) {
          _errorHandler.logError(error, null, context: 'TeamService.listenToTeamMembers');
          _memberStreamControllers[teamId]?.addError(error);
        },
      );
    }
    
    return _memberStreamControllers[teamId]!.stream;
  }
  
  // ==================== HELPER METHODS ====================
  
  /// Create team member document
  Future<TeamMemberModel?> _createTeamMember(TeamMemberModel member) async {
    try {
      final docRef = await _teamMembersCollection.add(member.toJson());
      return member.copyWith(id: docRef.id);
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'TeamService._createTeamMember');
      return null;
    }
  }
  
  /// Get team member
  Future<TeamMemberModel?> _getTeamMember(String teamId, String userId) async {
    try {
      final query = await _teamMembersCollection
          .where('teamId', isEqualTo: teamId)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      
      if (query.docs.isEmpty) return null;
      
      final doc = query.docs.first;
      return TeamMemberModel.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'TeamService._getTeamMember');
      return null;
    }
  }
  
  /// Update team member
  Future<void> _updateTeamMember(String teamId, String userId, Map<String, dynamic> updates) async {
    final query = await _teamMembersCollection
        .where('teamId', isEqualTo: teamId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    
    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update(updates);
      _memberCache.remove(teamId); // Clear cache
    }
  }
  
  /// Check if user is team member
  Future<bool> _isUserTeamMember(String teamId, String userId) async {
    final member = await _getTeamMember(teamId, userId);
    return member != null;
  }
  
  /// Check if user can manage team
  Future<bool> _canUserManageTeam(String teamId, String userId) async {
    final member = await _getTeamMember(teamId, userId);
    return member?.role.canManageTeam ?? false;
  }
  
  /// Check if user can manage members
  Future<bool> _canUserManageMembers(String teamId, String userId) async {
    final member = await _getTeamMember(teamId, userId);
    return member?.role.canManageMembers ?? false;
  }
  
  /// Update team member count
  Future<void> _updateTeamMemberCount(String teamId) async {
    final members = await getTeamMembers(teamId);
    await _teamsCollection.doc(teamId).update({
      'totalMembers': members.length,
      'updatedAt': Timestamp.now(),
    });
    
    // Clear cache to force refresh
    _teamCache.remove(teamId);
  }
  
  /// Log team activity
  Future<void> _logTeamActivity(String teamId, String action, String userId, Map<String, dynamic> metadata) async {
    try {
      await _firestore.collection('team_activities').add({
        'teamId': teamId,
        'action': action,
        'userId': userId,
        'metadata': metadata,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      // Log activity errors shouldn't break the main operation
      _errorHandler.logError(e, null, context: 'TeamService._logTeamActivity');
    }
  }
}
