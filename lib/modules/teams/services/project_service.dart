import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../core/enums/team_enums.dart';
import '../../../core/services/error_handler_service.dart';
import '../models/project_model.dart';
import '../models/team_model.dart';
import '../../auth/services/auth_service.dart';
import 'team_service.dart';

/// Project Service
/// Handles all project-related operations with Firestore integration
class ProjectService extends GetxService {
  static ProjectService get instance => Get.find<ProjectService>();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();
  final TeamService _teamService = Get.find<TeamService>();
  final ErrorHandlerService _errorHandler = Get.find<ErrorHandlerService>();
  
  // Collection references
  CollectionReference get _projectsCollection => _firestore.collection('projects');
  CollectionReference get _projectMembersCollection => _firestore.collection('project_members');
  CollectionReference get _milestonesCollection => _firestore.collection('milestones');
  
  // Cache for frequently accessed data
  final Map<String, ProjectModel> _projectCache = {};
  final Map<String, List<ProjectModel>> _teamProjectsCache = {};
  
  // Stream controllers for real-time updates
  final Map<String, StreamController<ProjectModel?>> _projectStreamControllers = {};
  final Map<String, StreamController<List<ProjectModel>>> _teamProjectsStreamControllers = {};
  
  @override
  void onClose() {
    // Clean up stream controllers
    for (final controller in _projectStreamControllers.values) {
      controller.close();
    }
    for (final controller in _teamProjectsStreamControllers.values) {
      controller.close();
    }
    super.onClose();
  }
  
  // ==================== PROJECT CRUD OPERATIONS ====================
  
  /// Create a new project
  Future<ProjectModel?> createProject(ProjectModel project) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Check if user can create projects in the team
      if (!await _canUserCreateProjects(project.teamId, currentUser.id)) {
        throw Exception('Insufficient permissions to create projects');
      }
      
      // Validate team exists
      final team = await _teamService.getTeamById(project.teamId);
      if (team == null) {
        throw Exception('Team not found');
      }
      
      // Create project document
      final docRef = await _projectsCollection.add(project.toJson());
      final createdProject = project.copyWith(id: docRef.id);
      
      // Update cache
      _projectCache[docRef.id] = createdProject;
      _teamProjectsCache.remove(project.teamId); // Clear team cache
      
      // Update team project count
      await _updateTeamProjectCount(project.teamId);
      
      // Log activity
      await _logProjectActivity(docRef.id, 'project_created', currentUser.id, {
        'projectName': project.name,
        'teamId': project.teamId,
        'createdBy': currentUser.name,
      });
      
      return createdProject;
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'ProjectService.createProject');
      return null;
    }
  }
  
  /// Get project by ID
  Future<ProjectModel?> getProjectById(String projectId) async {
    try {
      // Check cache first
      if (_projectCache.containsKey(projectId)) {
        return _projectCache[projectId];
      }
      
      final doc = await _projectsCollection.doc(projectId).get();
      if (!doc.exists) return null;
      
      final project = ProjectModel.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
      
      // Update cache
      _projectCache[projectId] = project;
      
      return project;
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'ProjectService.getProjectById');
      return null;
    }
  }
  
  /// Update project
  Future<ProjectModel?> updateProject(String projectId, Map<String, dynamic> updates) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Get current project to check permissions
      final project = await getProjectById(projectId);
      if (project == null) {
        throw Exception('Project not found');
      }
      
      // Check permissions
      if (!await _canUserManageProject(projectId, currentUser.id)) {
        throw Exception('Insufficient permissions to update project');
      }
      
      // Add metadata
      updates['updatedAt'] = Timestamp.now();
      updates['lastActivityAt'] = Timestamp.now();
      updates['lastActivityBy'] = currentUser.id;
      
      // Update document
      await _projectsCollection.doc(projectId).update(updates);
      
      // Get updated project
      final updatedProject = await getProjectById(projectId);
      
      // Clear team cache
      _teamProjectsCache.remove(project.teamId);
      
      // Log activity
      await _logProjectActivity(projectId, 'project_updated', currentUser.id, {
        'updatedFields': updates.keys.toList(),
      });
      
      return updatedProject;
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'ProjectService.updateProject');
      return null;
    }
  }
  
  /// Delete project
  Future<bool> deleteProject(String projectId) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Get project to check permissions
      final project = await getProjectById(projectId);
      if (project == null) return false;
      
      // Check permissions (only project creator or team owner can delete)
      if (!await _canUserDeleteProject(projectId, currentUser.id)) {
        throw Exception('Insufficient permissions to delete project');
      }
      
      // Use batch to delete project and all related data
      final batch = _firestore.batch();
      
      // Delete project document
      batch.delete(_projectsCollection.doc(projectId));
      
      // Delete all project members
      final membersQuery = await _projectMembersCollection
          .where('projectId', isEqualTo: projectId)
          .get();
      
      for (final doc in membersQuery.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete all milestones
      final milestonesQuery = await _milestonesCollection
          .where('projectId', isEqualTo: projectId)
          .get();
      
      for (final doc in milestonesQuery.docs) {
        batch.delete(doc.reference);
      }
      
      // Commit batch
      await batch.commit();
      
      // Clear cache
      _projectCache.remove(projectId);
      _teamProjectsCache.remove(project.teamId);
      
      // Update team project count
      await _updateTeamProjectCount(project.teamId);
      
      // Log activity
      await _logProjectActivity(projectId, 'project_deleted', currentUser.id, {
        'projectName': project.name,
        'teamId': project.teamId,
        'deletedBy': currentUser.name,
      });
      
      return true;
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'ProjectService.deleteProject');
      return false;
    }
  }
  
  /// Archive project
  Future<bool> archiveProject(String projectId) async {
    try {
      final updates = {
        'isArchived': true,
        'archivedAt': Timestamp.now(),
        'archivedBy': _authService.currentUser?.id,
        'updatedAt': Timestamp.now(),
      };
      
      final updatedProject = await updateProject(projectId, updates);
      return updatedProject != null;
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'ProjectService.archiveProject');
      return false;
    }
  }
  
  // ==================== PROJECT STATUS MANAGEMENT ====================
  
  /// Update project status
  Future<ProjectModel?> updateProjectStatus(String projectId, ProjectStatus newStatus) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Get current project
      final project = await getProjectById(projectId);
      if (project == null) {
        throw Exception('Project not found');
      }
      
      // Check if status transition is valid
      if (!project.nextStatuses.contains(newStatus)) {
        throw Exception('Invalid status transition');
      }
      
      // Check permissions
      if (!await _canUserManageProject(projectId, currentUser.id)) {
        throw Exception('Insufficient permissions to update project status');
      }
      
      final updates = <String, dynamic>{
        'status': newStatus.value,
      };
      
      // Add status-specific timestamps
      switch (newStatus) {
        case ProjectStatus.active:
          if (project.actualStartDate == null) {
            updates['actualStartDate'] = Timestamp.now();
          }
          break;
        case ProjectStatus.completed:
          updates['actualEndDate'] = Timestamp.now();
          break;
        case ProjectStatus.cancelled:
          updates['actualEndDate'] = Timestamp.now();
          break;
        default:
          break;
      }
      
      final updatedProject = await updateProject(projectId, updates);
      
      // Log activity
      await _logProjectActivity(projectId, 'status_updated', currentUser.id, {
        'oldStatus': project.status.displayName,
        'newStatus': newStatus.displayName,
      });
      
      return updatedProject;
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'ProjectService.updateProjectStatus');
      return null;
    }
  }
  
  /// Start project
  Future<ProjectModel?> startProject(String projectId) async {
    return await updateProjectStatus(projectId, ProjectStatus.active);
  }
  
  /// Complete project
  Future<ProjectModel?> completeProject(String projectId) async {
    return await updateProjectStatus(projectId, ProjectStatus.completed);
  }
  
  /// Put project on hold
  Future<ProjectModel?> holdProject(String projectId) async {
    return await updateProjectStatus(projectId, ProjectStatus.onHold);
  }
  
  /// Cancel project
  Future<ProjectModel?> cancelProject(String projectId) async {
    return await updateProjectStatus(projectId, ProjectStatus.cancelled);
  }
  
  // ==================== PROJECT MEMBER MANAGEMENT ====================
  
  /// Add member to project
  Future<bool> addProjectMember(String projectId, String userId, {String? role}) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Check permissions
      if (!await _canUserManageProject(projectId, currentUser.id)) {
        throw Exception('Insufficient permissions to add project members');
      }
      
      // Check if user is already a project member
      if (await _isUserProjectMember(projectId, userId)) {
        throw Exception('User is already a project member');
      }
      
      // Add project member
      await _projectMembersCollection.add({
        'projectId': projectId,
        'userId': userId,
        'role': role ?? 'member',
        'addedBy': currentUser.id,
        'addedAt': Timestamp.now(),
        'isActive': true,
      });
      
      // Update project member count
      await _updateProjectMemberCount(projectId);
      
      // Log activity
      await _logProjectActivity(projectId, 'member_added', currentUser.id, {
        'addedUserId': userId,
        'role': role ?? 'member',
      });
      
      return true;
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'ProjectService.addProjectMember');
      return false;
    }
  }
  
  /// Remove member from project
  Future<bool> removeProjectMember(String projectId, String userId) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Check permissions
      if (!await _canUserManageProject(projectId, currentUser.id)) {
        throw Exception('Insufficient permissions to remove project members');
      }
      
      // Find and update project member record
      final memberQuery = await _projectMembersCollection
          .where('projectId', isEqualTo: projectId)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      
      if (memberQuery.docs.isEmpty) {
        throw Exception('Project member not found');
      }
      
      // Update member record (soft delete)
      await memberQuery.docs.first.reference.update({
        'isActive': false,
        'removedBy': currentUser.id,
        'removedAt': Timestamp.now(),
      });
      
      // Update project member count
      await _updateProjectMemberCount(projectId);
      
      // Log activity
      await _logProjectActivity(projectId, 'member_removed', currentUser.id, {
        'removedUserId': userId,
      });
      
      return true;
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'ProjectService.removeProjectMember');
      return false;
    }
  }
  
  // ==================== PROJECT QUERIES ====================
  
  /// Get team projects
  Future<List<ProjectModel>> getTeamProjects(String teamId, {
    bool activeOnly = true,
    ProjectStatus? status,
    int limit = 50,
  }) async {
    try {
      // Check cache first
      final cacheKey = '$teamId-$activeOnly-${status?.value}';
      if (_teamProjectsCache.containsKey(cacheKey)) {
        return _teamProjectsCache[cacheKey]!;
      }
      
      Query query = _projectsCollection.where('teamId', isEqualTo: teamId);
      
      if (activeOnly) {
        query = query.where('isArchived', isEqualTo: false);
      }
      
      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      }
      
      query = query.orderBy('updatedAt', descending: true).limit(limit);
      
      final snapshot = await query.get();
      final projects = snapshot.docs.map((doc) {
        return ProjectModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
      
      // Update cache
      _teamProjectsCache[cacheKey] = projects;
      
      return projects;
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'ProjectService.getTeamProjects');
      return [];
    }
  }
  
  /// Get user's projects
  Future<List<ProjectModel>> getUserProjects(String userId, {
    bool activeOnly = true,
    int limit = 50,
  }) async {
    try {
      // Get user's project memberships
      Query memberQuery = _projectMembersCollection.where('userId', isEqualTo: userId);
      
      if (activeOnly) {
        memberQuery = memberQuery.where('isActive', isEqualTo: true);
      }
      
      final memberSnapshot = await memberQuery.get();
      final projectIds = memberSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>)
          .map((data) => data['projectId'] as String)
          .toList();
      
      if (projectIds.isEmpty) return [];
      
      // Get projects (Firestore 'in' query limit is 10)
      final projects = <ProjectModel>[];
      for (int i = 0; i < projectIds.length; i += 10) {
        final batch = projectIds.skip(i).take(10).toList();
        Query projectQuery = _projectsCollection.where(FieldPath.documentId, whereIn: batch);
        
        if (activeOnly) {
          projectQuery = projectQuery.where('isArchived', isEqualTo: false);
        }
        
        final projectSnapshot = await projectQuery.get();
        final batchProjects = projectSnapshot.docs.map((doc) {
          return ProjectModel.fromJson({
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          });
        }).toList();
        
        projects.addAll(batchProjects);
      }
      
      // Sort by updated date
      projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      return projects.take(limit).toList();
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'ProjectService.getUserProjects');
      return [];
    }
  }
  
  /// Search projects
  Future<List<ProjectModel>> searchProjects(String searchTerm, {
    String? teamId,
    int limit = 20,
  }) async {
    try {
      if (searchTerm.trim().isEmpty) return [];
      
      Query query = _projectsCollection
          .where('name', isGreaterThanOrEqualTo: searchTerm)
          .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff');
      
      if (teamId != null) {
        query = query.where('teamId', isEqualTo: teamId);
      }
      
      query = query.limit(limit);
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        return ProjectModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'ProjectService.searchProjects');
      return [];
    }
  }
  
  /// Get overdue projects
  Future<List<ProjectModel>> getOverdueProjects({String? teamId, int limit = 20}) async {
    try {
      Query query = _projectsCollection
          .where('endDate', isLessThan: Timestamp.now())
          .where('status', whereIn: [ProjectStatus.planning.value, ProjectStatus.active.value])
          .where('isArchived', isEqualTo: false);
      
      if (teamId != null) {
        query = query.where('teamId', isEqualTo: teamId);
      }
      
      query = query.orderBy('endDate').limit(limit);
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        return ProjectModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
      
    } catch (e, stackTrace) {
      _errorHandler.logError(e, stackTrace, context: 'ProjectService.getOverdueProjects');
      return [];
    }
  }
  
  // ==================== REAL-TIME LISTENERS ====================
  
  /// Listen to project updates
  Stream<ProjectModel?> listenToProject(String projectId) {
    if (!_projectStreamControllers.containsKey(projectId)) {
      _projectStreamControllers[projectId] = StreamController<ProjectModel?>.broadcast();
      
      _projectsCollection.doc(projectId).snapshots().listen(
        (snapshot) {
          if (snapshot.exists) {
            final project = ProjectModel.fromJson({
              'id': snapshot.id,
              ...snapshot.data() as Map<String, dynamic>,
            });
            _projectCache[projectId] = project;
            _projectStreamControllers[projectId]?.add(project);
          } else {
            _projectStreamControllers[projectId]?.add(null);
          }
        },
        onError: (error) {
          _errorHandler.logError(error, null, context: 'ProjectService.listenToProject');
          _projectStreamControllers[projectId]?.addError(error);
        },
      );
    }
    
    return _projectStreamControllers[projectId]!.stream;
  }
  
  /// Listen to team projects
  Stream<List<ProjectModel>> listenToTeamProjects(String teamId) {
    if (!_teamProjectsStreamControllers.containsKey(teamId)) {
      _teamProjectsStreamControllers[teamId] = StreamController<List<ProjectModel>>.broadcast();
      
      _projectsCollection
          .where('teamId', isEqualTo: teamId)
          .where('isArchived', isEqualTo: false)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .listen(
        (snapshot) {
          final projects = snapshot.docs.map((doc) {
            return ProjectModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            });
          }).toList();
          
          _teamProjectsCache[teamId] = projects;
          _teamProjectsStreamControllers[teamId]?.add(projects);
        },
        onError: (error) {
          _errorHandler.logError(error, null, context: 'ProjectService.listenToTeamProjects');
          _teamProjectsStreamControllers[teamId]?.addError(error);
        },
      );
    }
    
    return _teamProjectsStreamControllers[teamId]!.stream;
  }
  
  // ==================== HELPER METHODS ====================
  
  /// Check if user can create projects in team
  Future<bool> _canUserCreateProjects(String teamId, String userId) async {
    final members = await _teamService.getTeamMembers(teamId);
    final member = members.where((m) => m.userId == userId).firstOrNull;
    return member?.role.canCreateProjects ?? false;
  }
  
  /// Check if user can manage project
  Future<bool> _canUserManageProject(String projectId, String userId) async {
    final project = await getProjectById(projectId);
    if (project == null) return false;
    
    // Project manager or creator can manage
    if (project.projectManager == userId || project.createdBy == userId) {
      return true;
    }
    
    // Check team permissions
    return await _canUserCreateProjects(project.teamId, userId);
  }
  
  /// Check if user can delete project
  Future<bool> _canUserDeleteProject(String projectId, String userId) async {
    final project = await getProjectById(projectId);
    if (project == null) return false;
    
    // Only project creator or team owner can delete
    if (project.createdBy == userId) return true;
    
    // Check if user is team owner
    final team = await _teamService.getTeamById(project.teamId);
    return team?.createdBy == userId;
  }
  
  /// Check if user is project member
  Future<bool> _isUserProjectMember(String projectId, String userId) async {
    final query = await _projectMembersCollection
        .where('projectId', isEqualTo: projectId)
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    
    return query.docs.isNotEmpty;
  }
  
  /// Update team project count
  Future<void> _updateTeamProjectCount(String teamId) async {
    final projects = await getTeamProjects(teamId);
    await _firestore.collection('teams').doc(teamId).update({
      'totalProjects': projects.length,
      'updatedAt': Timestamp.now(),
    });
  }
  
  /// Update project member count
  Future<void> _updateProjectMemberCount(String projectId) async {
    final memberQuery = await _projectMembersCollection
        .where('projectId', isEqualTo: projectId)
        .where('isActive', isEqualTo: true)
        .get();
    
    await _projectsCollection.doc(projectId).update({
      'memberIds': memberQuery.docs.map((doc) => doc.data() as Map<String, dynamic>)
          .map((data) => data['userId'] as String)
          .toList(),
      'updatedAt': Timestamp.now(),
    });
    
    // Clear cache
    _projectCache.remove(projectId);
  }
  
  /// Log project activity
  Future<void> _logProjectActivity(String projectId, String action, String userId, Map<String, dynamic> metadata) async {
    try {
      await _firestore.collection('project_activities').add({
        'projectId': projectId,
        'action': action,
        'userId': userId,
        'metadata': metadata,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      // Log activity errors shouldn't break the main operation
      _errorHandler.logError(e, null, context: 'ProjectService._logProjectActivity');
    }
  }
}
