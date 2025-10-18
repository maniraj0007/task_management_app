import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/performance_service.dart';
import '../../../core/models/task_model.dart';
import '../models/task_dependency_model.dart';

/// Project Management Service
/// Handles task dependencies, milestones, and project timeline management
class ProjectManagementService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();
  final PerformanceService _performanceService = Get.find<PerformanceService>();

  // Dependencies and milestones streams
  final Map<String, StreamSubscription> _dependencySubscriptions = {};
  final Map<String, StreamSubscription> _milestoneSubscriptions = {};
  final Map<String, RxList<TaskDependencyModel>> _projectDependencies = {};
  final Map<String, RxList<ProjectMilestoneModel>> _projectMilestones = {};
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeProjectManagementService();
  }

  /// Initialize project management service
  Future<void> _initializeProjectManagementService() async {
    try {
      _isLoading.value = true;
      _error.value = '';
      
      // Service is ready
    } catch (e) {
      _error.value = 'Failed to initialize project management service: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  // ==================== DEPENDENCY MANAGEMENT ====================

  /// Get dependencies stream for a project
  RxList<TaskDependencyModel> getProjectDependenciesStream(String projectId) {
    if (!_projectDependencies.containsKey(projectId)) {
      _projectDependencies[projectId] = <TaskDependencyModel>[].obs;
      _startDependenciesStream(projectId);
    }
    return _projectDependencies[projectId]!;
  }

  /// Start dependencies stream for a project
  void _startDependenciesStream(String projectId) {
    final subscription = _firestore
        .collection('task_dependencies')
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .listen(
          (snapshot) => _handleDependenciesSnapshot(projectId, snapshot),
          onError: (error) => _handleStreamError('Dependencies stream error', error),
        );
    
    _dependencySubscriptions[projectId] = subscription;
  }

  /// Handle dependencies snapshot updates
  void _handleDependenciesSnapshot(String projectId, QuerySnapshot snapshot) {
    try {
      final dependencies = snapshot.docs
          .map((doc) => TaskDependencyModel.fromFirestore(doc))
          .toList();

      _projectDependencies[projectId]?.value = dependencies;
      _error.value = '';
    } catch (e) {
      _handleStreamError('Failed to process dependencies for project $projectId', e);
    }
  }

  /// Create a task dependency
  Future<TaskDependencyModel?> createDependency({
    required String dependentTaskId,
    required String dependsOnTaskId,
    required String projectId,
    String dependencyType = 'finish_to_start',
    int lagDays = 0,
  }) async {
    return await _performanceService.timeOperation('create_dependency', () async {
      try {
        _isLoading.value = true;
        _error.value = '';

        final currentUser = _authService.currentUser;
        if (currentUser == null) {
          throw Exception('User not authenticated');
        }

        // Validate dependency
        if (dependentTaskId == dependsOnTaskId) {
          throw Exception('A task cannot depend on itself');
        }

        // Check for circular dependencies
        final existingDependencies = await getProjectDependencies(projectId);
        final newDependency = TaskDependencyModel(
          id: '',
          dependentTaskId: dependentTaskId,
          dependsOnTaskId: dependsOnTaskId,
          dependencyType: dependencyType,
          lagDays: lagDays,
          projectId: projectId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: currentUser.id,
        );

        if (!newDependency.isValidDependency(existingDependencies)) {
          throw Exception('This dependency would create a circular reference');
        }

        // Save to Firestore
        final docRef = await _firestore
            .collection('task_dependencies')
            .add(newDependency.toFirestore());

        final savedDependency = newDependency.copyWith(id: docRef.id);
        return savedDependency;
      } catch (e) {
        _error.value = 'Failed to create dependency: $e';
        return null;
      } finally {
        _isLoading.value = false;
      }
    });
  }

  /// Update a task dependency
  Future<TaskDependencyModel?> updateDependency({
    required String dependencyId,
    String? dependencyType,
    int? lagDays,
  }) async {
    return await _performanceService.timeOperation('update_dependency', () async {
      try {
        _isLoading.value = true;
        _error.value = '';

        final currentUser = _authService.currentUser;
        if (currentUser == null) {
          throw Exception('User not authenticated');
        }

        // Get existing dependency
        final dependencyDoc = await _firestore
            .collection('task_dependencies')
            .doc(dependencyId)
            .get();

        if (!dependencyDoc.exists) {
          throw Exception('Dependency not found');
        }

        final existingDependency = TaskDependencyModel.fromFirestore(dependencyDoc);

        // Update dependency
        final updatedData = <String, dynamic>{
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        };

        if (dependencyType != null) {
          updatedData['dependencyType'] = dependencyType;
        }

        if (lagDays != null) {
          updatedData['lagDays'] = lagDays;
        }

        await _firestore
            .collection('task_dependencies')
            .doc(dependencyId)
            .update(updatedData);

        final updatedDependency = existingDependency.copyWith(
          dependencyType: dependencyType,
          lagDays: lagDays,
          updatedAt: DateTime.now(),
        );

        return updatedDependency;
      } catch (e) {
        _error.value = 'Failed to update dependency: $e';
        return null;
      } finally {
        _isLoading.value = false;
      }
    });
  }

  /// Delete a task dependency
  Future<bool> deleteDependency(String dependencyId) async {
    return await _performanceService.timeOperation('delete_dependency', () async {
      try {
        _isLoading.value = true;
        _error.value = '';

        await _firestore
            .collection('task_dependencies')
            .doc(dependencyId)
            .delete();

        return true;
      } catch (e) {
        _error.value = 'Failed to delete dependency: $e';
        return false;
      } finally {
        _isLoading.value = false;
      }
    });
  }

  /// Get dependencies for a project (one-time fetch)
  Future<List<TaskDependencyModel>> getProjectDependencies(String projectId) async {
    try {
      final snapshot = await _firestore
          .collection('task_dependencies')
          .where('projectId', isEqualTo: projectId)
          .get();

      return snapshot.docs
          .map((doc) => TaskDependencyModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      _error.value = 'Failed to get project dependencies: $e';
      return [];
    }
  }

  /// Get dependencies for a specific task
  Future<List<TaskDependencyModel>> getTaskDependencies(String taskId) async {
    try {
      final snapshot = await _firestore
          .collection('task_dependencies')
          .where('dependentTaskId', isEqualTo: taskId)
          .get();

      return snapshot.docs
          .map((doc) => TaskDependencyModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      _error.value = 'Failed to get task dependencies: $e';
      return [];
    }
  }

  /// Get tasks that depend on a specific task
  Future<List<TaskDependencyModel>> getTaskDependents(String taskId) async {
    try {
      final snapshot = await _firestore
          .collection('task_dependencies')
          .where('dependsOnTaskId', isEqualTo: taskId)
          .get();

      return snapshot.docs
          .map((doc) => TaskDependencyModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      _error.value = 'Failed to get task dependents: $e';
      return [];
    }
  }

  // ==================== MILESTONE MANAGEMENT ====================

  /// Get milestones stream for a project
  RxList<ProjectMilestoneModel> getProjectMilestonesStream(String projectId) {
    if (!_projectMilestones.containsKey(projectId)) {
      _projectMilestones[projectId] = <ProjectMilestoneModel>[].obs;
      _startMilestonesStream(projectId);
    }
    return _projectMilestones[projectId]!;
  }

  /// Start milestones stream for a project
  void _startMilestonesStream(String projectId) {
    final subscription = _firestore
        .collection('project_milestones')
        .where('projectId', isEqualTo: projectId)
        .orderBy('dueDate')
        .snapshots()
        .listen(
          (snapshot) => _handleMilestonesSnapshot(projectId, snapshot),
          onError: (error) => _handleStreamError('Milestones stream error', error),
        );
    
    _milestoneSubscriptions[projectId] = subscription;
  }

  /// Handle milestones snapshot updates
  void _handleMilestonesSnapshot(String projectId, QuerySnapshot snapshot) {
    try {
      final milestones = snapshot.docs
          .map((doc) => ProjectMilestoneModel.fromFirestore(doc))
          .toList();

      _projectMilestones[projectId]?.value = milestones;
      _error.value = '';
    } catch (e) {
      _handleStreamError('Failed to process milestones for project $projectId', e);
    }
  }

  /// Create a project milestone
  Future<ProjectMilestoneModel?> createMilestone({
    required String projectId,
    required String title,
    String? description,
    required DateTime dueDate,
    List<String>? associatedTasks,
  }) async {
    return await _performanceService.timeOperation('create_milestone', () async {
      try {
        _isLoading.value = true;
        _error.value = '';

        final currentUser = _authService.currentUser;
        if (currentUser == null) {
          throw Exception('User not authenticated');
        }

        // Create milestone model
        final milestone = ProjectMilestoneModel(
          id: '',
          projectId: projectId,
          title: title,
          description: description,
          dueDate: dueDate,
          associatedTasks: associatedTasks ?? [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: currentUser.id,
        );

        // Save to Firestore
        final docRef = await _firestore
            .collection('project_milestones')
            .add(milestone.toFirestore());

        final savedMilestone = milestone.copyWith(id: docRef.id);
        return savedMilestone;
      } catch (e) {
        _error.value = 'Failed to create milestone: $e';
        return null;
      } finally {
        _isLoading.value = false;
      }
    });
  }

  /// Update a project milestone
  Future<ProjectMilestoneModel?> updateMilestone({
    required String milestoneId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
    List<String>? associatedTasks,
    int? completionPercentage,
  }) async {
    return await _performanceService.timeOperation('update_milestone', () async {
      try {
        _isLoading.value = true;
        _error.value = '';

        // Get existing milestone
        final milestoneDoc = await _firestore
            .collection('project_milestones')
            .doc(milestoneId)
            .get();

        if (!milestoneDoc.exists) {
          throw Exception('Milestone not found');
        }

        final existingMilestone = ProjectMilestoneModel.fromFirestore(milestoneDoc);

        // Update milestone
        final updatedData = <String, dynamic>{
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        };

        if (title != null) updatedData['title'] = title;
        if (description != null) updatedData['description'] = description;
        if (dueDate != null) updatedData['dueDate'] = Timestamp.fromDate(dueDate);
        if (status != null) updatedData['status'] = status;
        if (associatedTasks != null) updatedData['associatedTasks'] = associatedTasks;
        if (completionPercentage != null) updatedData['completionPercentage'] = completionPercentage;

        await _firestore
            .collection('project_milestones')
            .doc(milestoneId)
            .update(updatedData);

        final updatedMilestone = existingMilestone.copyWith(
          title: title,
          description: description,
          dueDate: dueDate,
          status: status,
          associatedTasks: associatedTasks,
          completionPercentage: completionPercentage,
          updatedAt: DateTime.now(),
        );

        return updatedMilestone;
      } catch (e) {
        _error.value = 'Failed to update milestone: $e';
        return null;
      } finally {
        _isLoading.value = false;
      }
    });
  }

  /// Delete a project milestone
  Future<bool> deleteMilestone(String milestoneId) async {
    return await _performanceService.timeOperation('delete_milestone', () async {
      try {
        _isLoading.value = true;
        _error.value = '';

        await _firestore
            .collection('project_milestones')
            .doc(milestoneId)
            .delete();

        return true;
      } catch (e) {
        _error.value = 'Failed to delete milestone: $e';
        return false;
      } finally {
        _isLoading.value = false;
      }
    });
  }

  // ==================== PROJECT TIMELINE ANALYSIS ====================

  /// Calculate project timeline based on dependencies
  Future<Map<String, DateTime>> calculateProjectTimeline(
    String projectId,
    List<TaskModel> tasks,
  ) async {
    try {
      final dependencies = await getProjectDependencies(projectId);
      final timeline = <String, DateTime>{};
      
      // Simple timeline calculation (can be enhanced with more sophisticated algorithms)
      for (final task in tasks) {
        final taskDependencies = dependencies.where((dep) => dep.dependentTaskId == task.id).toList();
        
        if (taskDependencies.isEmpty) {
          // No dependencies, can start immediately
          timeline[task.id] = DateTime.now();
        } else {
          // Calculate start date based on dependencies
          DateTime latestDependencyEnd = DateTime.now();
          
          for (final dependency in taskDependencies) {
            final dependsOnTask = tasks.firstWhereOrNull((t) => t.id == dependency.dependsOnTaskId);
            if (dependsOnTask != null && timeline.containsKey(dependsOnTask.id)) {
              final dependencyEndDate = timeline[dependsOnTask.id]!.add(Duration(days: 7)); // Assume 7 days duration
              final adjustedDate = dependencyEndDate.add(Duration(days: dependency.lagDays));
              
              if (adjustedDate.isAfter(latestDependencyEnd)) {
                latestDependencyEnd = adjustedDate;
              }
            }
          }
          
          timeline[task.id] = latestDependencyEnd;
        }
      }
      
      return timeline;
    } catch (e) {
      _error.value = 'Failed to calculate project timeline: $e';
      return {};
    }
  }

  /// Get critical path for a project
  Future<List<String>> getCriticalPath(String projectId, List<TaskModel> tasks) async {
    try {
      final dependencies = await getProjectDependencies(projectId);
      final timeline = await calculateProjectTimeline(projectId, tasks);
      
      // Simple critical path calculation (can be enhanced)
      final criticalPath = <String>[];
      
      // Find the task with the latest end date
      String? latestTask;
      DateTime latestEndDate = DateTime(1970);
      
      for (final entry in timeline.entries) {
        final endDate = entry.value.add(const Duration(days: 7)); // Assume 7 days duration
        if (endDate.isAfter(latestEndDate)) {
          latestEndDate = endDate;
          latestTask = entry.key;
        }
      }
      
      // Trace back through dependencies to find critical path
      if (latestTask != null) {
        criticalPath.add(latestTask);
        _traceCriticalPath(latestTask, dependencies, timeline, criticalPath);
      }
      
      return criticalPath.reversed.toList();
    } catch (e) {
      _error.value = 'Failed to calculate critical path: $e';
      return [];
    }
  }

  /// Helper method to trace critical path
  void _traceCriticalPath(
    String taskId,
    List<TaskDependencyModel> dependencies,
    Map<String, DateTime> timeline,
    List<String> criticalPath,
  ) {
    final taskDependencies = dependencies.where((dep) => dep.dependentTaskId == taskId).toList();
    
    for (final dependency in taskDependencies) {
      final dependsOnTaskId = dependency.dependsOnTaskId;
      if (!criticalPath.contains(dependsOnTaskId)) {
        criticalPath.add(dependsOnTaskId);
        _traceCriticalPath(dependsOnTaskId, dependencies, timeline, criticalPath);
      }
    }
  }

  // ==================== HELPER METHODS ====================

  /// Handle stream errors
  void _handleStreamError(String message, dynamic error) {
    print('ProjectManagementService Error: $message - $error');
    _error.value = message;
  }

  /// Stop dependencies stream for a project
  void stopDependenciesStream(String projectId) {
    _dependencySubscriptions[projectId]?.cancel();
    _dependencySubscriptions.remove(projectId);
    _projectDependencies.remove(projectId);
  }

  /// Stop milestones stream for a project
  void stopMilestonesStream(String projectId) {
    _milestoneSubscriptions[projectId]?.cancel();
    _milestoneSubscriptions.remove(projectId);
    _projectMilestones.remove(projectId);
  }

  @override
  void onClose() {
    // Cancel all subscriptions
    for (final subscription in _dependencySubscriptions.values) {
      subscription.cancel();
    }
    for (final subscription in _milestoneSubscriptions.values) {
      subscription.cancel();
    }
    _dependencySubscriptions.clear();
    _milestoneSubscriptions.clear();
    _projectDependencies.clear();
    _projectMilestones.clear();
    super.onClose();
  }
}
