import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../core/enums/team_enums.dart';
import '../../../core/services/error_handler_service.dart';
import '../models/team_invitation_model.dart';
import '../models/team_member_model.dart';
import '../../auth/services/auth_service.dart';
import 'team_service.dart';

/// Team Invitation Service
/// Handles all team invitation operations with Firestore integration
class TeamInvitationService extends GetxService {
  static TeamInvitationService get instance => Get.find<TeamInvitationService>();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();
  final TeamService _teamService = Get.find<TeamService>();
  final ErrorHandlerService _errorHandler = Get.find<ErrorHandlerService>();
  
  // Collection references
  CollectionReference get _invitationsCollection => _firestore.collection('team_invitations');
  
  // Cache for frequently accessed data
  final Map<String, TeamInvitationModel> _invitationCache = {};
  final Map<String, List<TeamInvitationModel>> _teamInvitationsCache = {};
  final Map<String, List<TeamInvitationModel>> _userInvitationsCache = {};
  
  // Stream controllers for real-time updates
  final Map<String, StreamController<List<TeamInvitationModel>>> _teamInvitationsStreamControllers = {};
  final Map<String, StreamController<List<TeamInvitationModel>>> _userInvitationsStreamControllers = {};
  
  @override
  void onClose() {
    // Clean up stream controllers
    for (final controller in _teamInvitationsStreamControllers.values) {
      controller.close();
    }
    for (final controller in _userInvitationsStreamControllers.values) {
      controller.close();
    }
    super.onClose();
  }
  
  // ==================== INVITATION CRUD OPERATIONS ====================
  
  /// Create a new team invitation
  Future<TeamInvitationModel?> createInvitation(TeamInvitationModel invitation) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Check if user can invite members to the team
      if (!await _canUserInviteMembers(invitation.teamId, currentUser.id)) {
        throw Exception('Insufficient permissions to invite team members');
      }
      
      // Check if user is already invited or a member
      if (await _isUserAlreadyInvited(invitation.teamId, invitation.inviteeEmail)) {
        throw Exception('User is already invited to this team');
      }
      
      if (await _isEmailAlreadyTeamMember(invitation.teamId, invitation.inviteeEmail)) {
        throw Exception('User is already a team member');
      }
      
      // Validate team exists and can accept new members
      final team = await _teamService.getTeamById(invitation.teamId);
      if (team == null) {
        throw Exception('Team not found');
      }
      
      if (!team.canAcceptNewMembers) {
        throw Exception('Team cannot accept new members');
      }
      
      // Create invitation document
      final docRef = await _invitationsCollection.add(invitation.toJson());
      final createdInvitation = invitation.copyWith(id: docRef.id);
      
      // Update cache
      _invitationCache[docRef.id] = createdInvitation;
      _teamInvitationsCache.remove(invitation.teamId);
      _userInvitationsCache.remove(invitation.inviteeEmail);
      
      // Send invitation email (would integrate with email service)
      await _sendInvitationEmail(createdInvitation);
      
      // Log activity
      await _logInvitationActivity(docRef.id, 'invitation_created', currentUser.id, {
        'teamId': invitation.teamId,
        'teamName': invitation.teamName,
        'inviteeEmail': invitation.inviteeEmail,
        'proposedRole': invitation.proposedRole.displayName,
      });
      
      return createdInvitation;
      
    } catch (e, stackTrace) {
      _errorHandler.logError('TeamInvitationService.createInvitation', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// Get invitation by ID
  Future<TeamInvitationModel?> getInvitationById(String invitationId) async {
    try {
      // Check cache first
      if (_invitationCache.containsKey(invitationId)) {
        return _invitationCache[invitationId];
      }
      
      final doc = await _invitationsCollection.doc(invitationId).get();
      if (!doc.exists) return null;
      
      final invitation = TeamInvitationModel.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
      
      // Update cache
      _invitationCache[invitationId] = invitation;
      
      return invitation;
      
    } catch (e, stackTrace) {
      _errorHandler.logError('TeamInvitationService.getInvitationById', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// Get invitation by token
  Future<TeamInvitationModel?> getInvitationByToken(String token) async {
    try {
      final query = await _invitationsCollection
          .where('invitationToken', isEqualTo: token)
          .where('status', isEqualTo: InvitationStatus.pending.value)
          .limit(1)
          .get();
      
      if (query.docs.isEmpty) return null;
      
      final doc = query.docs.first;
      final invitation = TeamInvitationModel.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
      
      // Check if invitation is expired
      if (invitation.isExpired) {
        await _expireInvitation(invitation.id);
        return null;
      }
      
      // Update cache
      _invitationCache[invitation.id] = invitation;
      
      return invitation;
      
    } catch (e, stackTrace) {
      _errorHandler.logError('TeamInvitationService.getInvitationByToken', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// Accept invitation
  Future<bool> acceptInvitation(String invitationId, {String? verificationCode}) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Get invitation
      final invitation = await getInvitationById(invitationId);
      if (invitation == null) {
        throw Exception('Invitation not found');
      }
      
      // Check if invitation can be accepted
      if (!invitation.canRespond) {
        throw Exception('Invitation cannot be accepted (expired or already responded)');
      }
      
      // Validate verification code if required
      if (invitation.requiresVerification && 
          !invitation.validateVerificationCode(verificationCode ?? '')) {
        throw Exception('Invalid verification code');
      }
      
      // Check if user email matches invitation
      if (currentUser.email != invitation.inviteeEmail) {
        throw Exception('Email does not match invitation');
      }
      
      // Update invitation status
      final now = DateTime.now();
      await _invitationsCollection.doc(invitationId).update({
        'status': InvitationStatus.accepted.value,
        'inviteeUserId': currentUser.id,
        'respondedAt': Timestamp.fromDate(now),
        'acceptedAt': Timestamp.fromDate(now),
      });
      
      // Add user to team
      final teamMember = await _teamService.addTeamMember(
        teamId: invitation.teamId,
        userId: currentUser.id,
        role: invitation.proposedRole,
        displayName: currentUser.name,
        email: currentUser.email,
        photoUrl: currentUser.photoUrl,
      );
      
      if (teamMember == null) {
        throw Exception('Failed to add user to team');
      }
      
      // Clear cache
      _invitationCache.remove(invitationId);
      _teamInvitationsCache.remove(invitation.teamId);
      _userInvitationsCache.remove(invitation.inviteeEmail);
      
      // Send welcome email
      await _sendWelcomeEmail(invitation, currentUser.name);
      
      // Log activity
      await _logInvitationActivity(invitationId, 'invitation_accepted', currentUser.id, {
        'teamId': invitation.teamId,
        'teamName': invitation.teamName,
        'acceptedBy': currentUser.name,
        'role': invitation.proposedRole.displayName,
      });
      
      return true;
      
    } catch (e, stackTrace) {
      _errorHandler.logError('TeamInvitationService.acceptInvitation', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  /// Decline invitation
  Future<bool> declineInvitation(String invitationId, {String? reason}) async {
    try {
      final currentUser = _authService.currentUser;
      
      // Get invitation
      final invitation = await getInvitationById(invitationId);
      if (invitation == null) {
        throw Exception('Invitation not found');
      }
      
      // Check if invitation can be declined
      if (!invitation.canRespond) {
        throw Exception('Invitation cannot be declined (expired or already responded)');
      }
      
      // Update invitation status
      final now = DateTime.now();
      await _invitationsCollection.doc(invitationId).update({
        'status': InvitationStatus.declined.value,
        'respondedAt': Timestamp.fromDate(now),
        'declinedAt': Timestamp.fromDate(now),
        'declineReason': reason,
      });
      
      // Clear cache
      _invitationCache.remove(invitationId);
      _teamInvitationsCache.remove(invitation.teamId);
      _userInvitationsCache.remove(invitation.inviteeEmail);
      
      // Log activity
      await _logInvitationActivity(invitationId, 'invitation_declined', currentUser?.id, {
        'teamId': invitation.teamId,
        'teamName': invitation.teamName,
        'declineReason': reason,
      });
      
      return true;
      
    } catch (e, stackTrace) {
      _errorHandler.logError('TeamInvitationService.declineInvitation', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  /// Cancel invitation
  Future<bool> cancelInvitation(String invitationId, {String? reason}) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Get invitation
      final invitation = await getInvitationById(invitationId);
      if (invitation == null) {
        throw Exception('Invitation not found');
      }
      
      // Check permissions
      if (!await _canUserManageInvitation(invitation.teamId, currentUser.id) &&
          invitation.invitedBy != currentUser.id) {
        throw Exception('Insufficient permissions to cancel invitation');
      }
      
      // Check if invitation can be cancelled
      if (!invitation.canCancel) {
        throw Exception('Invitation cannot be cancelled');
      }
      
      // Update invitation status
      final now = DateTime.now();
      await _invitationsCollection.doc(invitationId).update({
        'status': InvitationStatus.cancelled.value,
        'cancelledAt': Timestamp.fromDate(now),
        'cancellationReason': reason,
      });
      
      // Clear cache
      _invitationCache.remove(invitationId);
      _teamInvitationsCache.remove(invitation.teamId);
      _userInvitationsCache.remove(invitation.inviteeEmail);
      
      // Log activity
      await _logInvitationActivity(invitationId, 'invitation_cancelled', currentUser.id, {
        'teamId': invitation.teamId,
        'teamName': invitation.teamName,
        'cancelledBy': currentUser.name,
        'cancellationReason': reason,
      });
      
      return true;
      
    } catch (e, stackTrace) {
      _errorHandler.logError('TeamInvitationService.cancelInvitation', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  /// Send reminder for invitation
  Future<bool> sendInvitationReminder(String invitationId) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Get invitation
      final invitation = await getInvitationById(invitationId);
      if (invitation == null) {
        throw Exception('Invitation not found');
      }
      
      // Check permissions
      if (!await _canUserManageInvitation(invitation.teamId, currentUser.id)) {
        throw Exception('Insufficient permissions to send reminder');
      }
      
      // Check if reminder can be sent
      if (!invitation.canSendReminder) {
        throw Exception('Cannot send reminder (too many sent or too recent)');
      }
      
      // Update reminder count
      await _invitationsCollection.doc(invitationId).update({
        'remindersSent': invitation.remindersSent + 1,
        'lastReminderAt': Timestamp.now(),
      });
      
      // Send reminder email
      await _sendReminderEmail(invitation);
      
      // Clear cache
      _invitationCache.remove(invitationId);
      
      // Log activity
      await _logInvitationActivity(invitationId, 'reminder_sent', currentUser.id, {
        'teamId': invitation.teamId,
        'teamName': invitation.teamName,
        'reminderCount': invitation.remindersSent + 1,
      });
      
      return true;
      
    } catch (e, stackTrace) {
      _errorHandler.logError('TeamInvitationService.sendInvitationReminder', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  // ==================== INVITATION QUERIES ====================
  
  /// Get team invitations
  Future<List<TeamInvitationModel>> getTeamInvitations(String teamId, {
    InvitationStatus? status,
    bool activeOnly = true,
    int limit = 50,
  }) async {
    try {
      // Check cache first
      final cacheKey = '$teamId-${status?.value}-$activeOnly';
      if (_teamInvitationsCache.containsKey(cacheKey)) {
        return _teamInvitationsCache[cacheKey]!;
      }
      
      Query query = _invitationsCollection.where('teamId', isEqualTo: teamId);
      
      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      } else if (activeOnly) {
        query = query.where('status', isEqualTo: InvitationStatus.pending.value);
      }
      
      query = query.orderBy('createdAt', descending: true).limit(limit);
      
      final snapshot = await query.get();
      final invitations = snapshot.docs.map((doc) {
        return TeamInvitationModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
      
      // Update cache
      _teamInvitationsCache[cacheKey] = invitations;
      
      return invitations;
      
    } catch (e, stackTrace) {
      _errorHandler.logError('TeamInvitationService.getTeamInvitations', error: e, stackTrace: stackTrace);
      return [];
    }
  }
  
  /// Get user invitations
  Future<List<TeamInvitationModel>> getUserInvitations(String email, {
    InvitationStatus? status,
    bool activeOnly = true,
    int limit = 20,
  }) async {
    try {
      // Check cache first
      final cacheKey = '$email-${status?.value}-$activeOnly';
      if (_userInvitationsCache.containsKey(cacheKey)) {
        return _userInvitationsCache[cacheKey]!;
      }
      
      Query query = _invitationsCollection.where('inviteeEmail', isEqualTo: email);
      
      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      } else if (activeOnly) {
        query = query.where('status', isEqualTo: InvitationStatus.pending.value);
      }
      
      query = query.orderBy('createdAt', descending: true).limit(limit);
      
      final snapshot = await query.get();
      final invitations = snapshot.docs.map((doc) {
        return TeamInvitationModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
      
      // Update cache
      _userInvitationsCache[cacheKey] = invitations;
      
      return invitations;
      
    } catch (e, stackTrace) {
      _errorHandler.logError('TeamInvitationService.getUserInvitations', error: e, stackTrace: stackTrace);
      return [];
    }
  }
  
  /// Get expired invitations
  Future<List<TeamInvitationModel>> getExpiredInvitations({int limit = 100}) async {
    try {
      final query = _invitationsCollection
          .where('status', isEqualTo: InvitationStatus.pending.value)
          .where('expiresAt', isLessThan: Timestamp.now())
          .limit(limit);
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        return TeamInvitationModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
      
    } catch (e, stackTrace) {
      _errorHandler.logError('TeamInvitationService.getExpiredInvitations', error: e, stackTrace: stackTrace);
      return [];
    }
  }
  
  // ==================== REAL-TIME LISTENERS ====================
  
  /// Listen to team invitations
  Stream<List<TeamInvitationModel>> listenToTeamInvitations(String teamId) {
    if (!_teamInvitationsStreamControllers.containsKey(teamId)) {
      _teamInvitationsStreamControllers[teamId] = StreamController<List<TeamInvitationModel>>.broadcast();
      
      _invitationsCollection
          .where('teamId', isEqualTo: teamId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
        (snapshot) {
          final invitations = snapshot.docs.map((doc) {
            return TeamInvitationModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            });
          }).toList();
          
          _teamInvitationsCache[teamId] = invitations;
          _teamInvitationsStreamControllers[teamId]?.add(invitations);
        },
        onError: (error) {
          _errorHandler.logError('TeamInvitationService.listenToTeamInvitations', error: error);
          _teamInvitationsStreamControllers[teamId]?.addError(error);
        },
      );
    }
    
    return _teamInvitationsStreamControllers[teamId]!.stream;
  }
  
  /// Listen to user invitations
  Stream<List<TeamInvitationModel>> listenToUserInvitations(String email) {
    if (!_userInvitationsStreamControllers.containsKey(email)) {
      _userInvitationsStreamControllers[email] = StreamController<List<TeamInvitationModel>>.broadcast();
      
      _invitationsCollection
          .where('inviteeEmail', isEqualTo: email)
          .where('status', isEqualTo: InvitationStatus.pending.value)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
        (snapshot) {
          final invitations = snapshot.docs.map((doc) {
            return TeamInvitationModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            });
          }).toList();
          
          _userInvitationsCache[email] = invitations;
          _userInvitationsStreamControllers[email]?.add(invitations);
        },
        onError: (error) {
          _errorHandler.logError('TeamInvitationService.listenToUserInvitations', error: error);
          _userInvitationsStreamControllers[email]?.addError(error);
        },
      );
    }
    
    return _userInvitationsStreamControllers[email]!.stream;
  }
  
  // ==================== BACKGROUND TASKS ====================
  
  /// Expire old invitations (should be called periodically)
  Future<void> expireOldInvitations() async {
    try {
      final expiredInvitations = await getExpiredInvitations();
      
      final batch = _firestore.batch();
      for (final invitation in expiredInvitations) {
        batch.update(_invitationsCollection.doc(invitation.id), {
          'status': InvitationStatus.expired.value,
        });
      }
      
      if (expiredInvitations.isNotEmpty) {
        await batch.commit();
        
        // Clear cache
        _invitationCache.clear();
        _teamInvitationsCache.clear();
        _userInvitationsCache.clear();
      }
      
    } catch (e, stackTrace) {
      _errorHandler.logError('TeamInvitationService.expireOldInvitations', error: e, stackTrace: stackTrace);
    }
  }
  
  // ==================== HELPER METHODS ====================
  
  /// Check if user can invite members to team
  Future<bool> _canUserInviteMembers(String teamId, String userId) async {
    final members = await _teamService.getTeamMembers(teamId);
    final member = members.where((m) => m.userId == userId).firstOrNull;
    return member?.role.canManageMembers ?? false;
  }
  
  /// Check if user can manage invitations
  Future<bool> _canUserManageInvitation(String teamId, String userId) async {
    return await _canUserInviteMembers(teamId, userId);
  }
  
  /// Check if user is already invited
  Future<bool> _isUserAlreadyInvited(String teamId, String email) async {
    final query = await _invitationsCollection
        .where('teamId', isEqualTo: teamId)
        .where('inviteeEmail', isEqualTo: email)
        .where('status', isEqualTo: InvitationStatus.pending.value)
        .limit(1)
        .get();
    
    return query.docs.isNotEmpty;
  }
  
  /// Check if email is already a team member
  Future<bool> _isEmailAlreadyTeamMember(String teamId, String email) async {
    final members = await _teamService.getTeamMembers(teamId);
    return members.any((member) => member.email == email);
  }
  
  /// Expire invitation
  Future<void> _expireInvitation(String invitationId) async {
    await _invitationsCollection.doc(invitationId).update({
      'status': InvitationStatus.expired.value,
    });
    _invitationCache.remove(invitationId);
  }
  
  /// Send invitation email (placeholder - would integrate with email service)
  Future<void> _sendInvitationEmail(TeamInvitationModel invitation) async {
    // TODO: Integrate with email service (SendGrid, AWS SES, etc.)
    // This would send a formatted email with invitation link
    print('Sending invitation email to ${invitation.inviteeEmail}');
  }
  
  /// Send welcome email (placeholder)
  Future<void> _sendWelcomeEmail(TeamInvitationModel invitation, String userName) async {
    // TODO: Integrate with email service
    print('Sending welcome email to $userName');
  }
  
  /// Send reminder email (placeholder)
  Future<void> _sendReminderEmail(TeamInvitationModel invitation) async {
    // TODO: Integrate with email service
    print('Sending reminder email to ${invitation.inviteeEmail}');
  }
  
  /// Log invitation activity
  Future<void> _logInvitationActivity(String invitationId, String action, String? userId, Map<String, dynamic> metadata) async {
    try {
      await _firestore.collection('invitation_activities').add({
        'invitationId': invitationId,
        'action': action,
        'userId': userId,
        'metadata': metadata,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      // Log activity errors shouldn't break the main operation
      _errorHandler.logError('TeamInvitationService._logInvitationActivity', error: e);
    }
  }
}
