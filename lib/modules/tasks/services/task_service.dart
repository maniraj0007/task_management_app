import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../core/services/error_handler_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/enums/task_enums.dart';
import '../../../core/enums/user_roles.dart';
import '../models/task_model.dart';
import '../models/task_comment_model.dart';
import '../models/task_attachment_model.dart';
import '../../auth/services/auth_service.dart';

/// Task Service for Firestore operations
/// Handles all task-related database operations with role-based access control
class TaskService extends GetxService {
  static TaskService get instance => Get.find<TaskService>();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();
  
  late final CollectionReference<Map<String, dynamic>> _tasksCollection;
  late final CollectionReference<Map<String, dynamic>> _commentsCollection;
  late final CollectionReference<Map<String, dynamic>> _attachmentsCollection;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    _initializeTaskService();
  }
  
  /// Initialize task service
  void _initializeTaskService() {
    try {
      _tasksCollection = _firestore.collection(AppConstants.tasksCollection);
      _commentsCollection = _firestore.collection('task_comments');
      _attachmentsCollection = _firestore.collection('task_attachments');
      ErrorHandlerService.instance.logInfo('Task service initialized successfully');
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Task Service Initialization',
        severity: ErrorSeverity.critical,
      );
    }
  }
  
  // ==================== TASK CRUD OPERATIONS ====================
  
  /// Create a new task
  Future<TaskModel?> createTask(TaskModel task) async {
    try {
      // Check permissions
      if (!_canCreateTask(task)) {
        throw Exception('Insufficient permissions to create this task');
      }
      
      // Generate new document reference
      final docRef = _tasksCollection.doc();
      final taskWithId = task.copyWith(id: docRef.id);
      
      // Create task in Firestore
      await docRef.set(taskWithId.toJson());
      
      // Create system comment for task creation
      await _createSystemComment(
        taskId: taskWithId.id,
        type: TaskCommentType.statusUpdate,
        content: 'Task created',
        authorId: taskWithId.createdBy,
        metadata: {'status': taskWithId.status.value},
      );
      
      ErrorHandlerService.instance.logInfo('Task created successfully: ${taskWithId.id}');
      return taskWithId;
      
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Create Task',
        severity: ErrorSeverity.high,
      );
      return null;
    }
  }
  
  /// Get task by ID
  Future<TaskModel?> getTaskById(String taskId) async {
    try {
      final doc = await _tasksCollection.doc(taskId).get();
      
      if (!doc.exists) {
        ErrorHandlerService.instance.logWarning('Task not found: $taskId');
        return null;
      }
      
      final task = TaskModel.fromJson(doc.data()!);
      
      // Check if user can view this task
      if (!_canViewTask(task)) {
        throw Exception('Insufficient permissions to view this task');
      }
      
      return task;
      
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Get Task By ID',
        severity: ErrorSeverity.medium,
      );
      return null;
    }
  }
  
  /// Update task
  Future<TaskModel?> updateTask(String taskId, Map<String, dynamic> updates) async {
    try {
      // Get current task to check permissions
      final currentTask = await getTaskById(taskId);
      if (currentTask == null) {
        throw Exception('Task not found');
      }
      
      // Check permissions
      if (!_canEditTask(currentTask)) {
        throw Exception('Insufficient permissions to edit this task');
      }
      
      // Add updated timestamp
      updates['updatedAt'] = FieldValue.serverTimestamp();
      updates['lastActivityAt'] = FieldValue.serverTimestamp();
      updates['lastActivityBy'] = _authService.currentUser?.id;
      
      // Update task in Firestore
      await _tasksCollection.doc(taskId).update(updates);
      
      // Create system comments for significant changes
      await _createSystemCommentsForUpdates(currentTask, updates);
      
      // Get updated task
      final updatedTask = await getTaskById(taskId);
      
      ErrorHandlerService.instance.logInfo('Task updated successfully: $taskId');
      return updatedTask;
      
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Update Task',
        severity: ErrorSeverity.medium,
      );
      return null;
    }
  }
  
  /// Delete task (soft delete)
  Future<bool> deleteTask(String taskId) async {
    try {
      // Get current task to check permissions
      final currentTask = await getTaskById(taskId);
      if (currentTask == null) {
        throw Exception('Task not found');
      }
      
      // Check permissions
      if (!_canDeleteTask(currentTask)) {
        throw Exception('Insufficient permissions to delete this task');
      }
      
      // Soft delete the task
      await _tasksCollection.doc(taskId).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': _authService.currentUser?.id,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      ErrorHandlerService.instance.logInfo('Task deleted successfully: $taskId');
      return true;
      
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Delete Task',
        severity: ErrorSeverity.high,
      );
      return false;
    }
  }
  
  /// Archive task
  Future<bool> archiveTask(String taskId) async {
    try {
      // Get current task to check permissions
      final currentTask = await getTaskById(taskId);
      if (currentTask == null) {
        throw Exception('Task not found');
      }
      
      // Check permissions
      if (!_canEditTask(currentTask)) {
        throw Exception('Insufficient permissions to archive this task');
      }
      
      // Archive the task
      await _tasksCollection.doc(taskId).update({
        'isArchived': true,
        'archivedAt': FieldValue.serverTimestamp(),
        'archivedBy': _authService.currentUser?.id,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      ErrorHandlerService.instance.logInfo('Task archived successfully: $taskId');
      return true;
      
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Archive Task',
        severity: ErrorSeverity.medium,
      );
      return false;
    }
  }
  
  // ==================== TASK QUERIES ====================
  
  /// Get tasks for current user
  Future<List<TaskModel>> getMyTasks({
    int limit = 20,
    DocumentSnapshot? startAfter,
    TaskStatus? status,
    TaskPriority? priority,
    TaskCategory? category,
  }) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      Query<Map<String, dynamic>> query = _tasksCollection
          .where('isDeleted', isEqualTo: false)
          .where('isArchived', isEqualTo: false);
      
      // Filter by user involvement (created by, assigned to, or collaborating)
      query = query.where(Filter.or(
        Filter('createdBy', isEqualTo: currentUser.id),
        Filter('assignedTo', isEqualTo: currentUser.id),
        Filter('assignedUsers', arrayContains: currentUser.id),
        Filter('collaborators', arrayContains: currentUser.id),
      ));
      
      // Apply filters
      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      }
      if (priority != null) {
        query = query.where('priority', isEqualTo: priority.value);
      }
      if (category != null) {
        query = query.where('category', isEqualTo: category.value);
      }
      
      // Apply pagination
      query = query.orderBy('updatedAt', descending: true).limit(limit);
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .where((task) => _canViewTask(task))
          .toList();
          
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Get My Tasks',
        severity: ErrorSeverity.medium,
      );
      return [];
    }
  }
  
  /// Get tasks by category
  Future<List<TaskModel>> getTasksByCategory(
    TaskCategory category, {
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _tasksCollection
          .where('category', isEqualTo: category.value)
          .where('isDeleted', isEqualTo: false)
          .where('isArchived', isEqualTo: false)
          .orderBy('updatedAt', descending: true)
          .limit(limit);
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .where((task) => _canViewTask(task))
          .toList();
          
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Get Tasks By Category',
        severity: ErrorSeverity.medium,
      );
      return [];
    }
  }
  
  /// Get overdue tasks
  Future<List<TaskModel>> getOverdueTasks({int limit = 20}) async {
    try {
      final now = Timestamp.now();
      
      Query<Map<String, dynamic>> query = _tasksCollection
          .where('isDeleted', isEqualTo: false)
          .where('isArchived', isEqualTo: false)
          .where('dueDate', isLessThan: now)
          .where('status', whereNotIn: ['completed', 'cancelled'])
          .orderBy('dueDate')
          .limit(limit);
      
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .where((task) => _canViewTask(task))
          .toList();
          
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Get Overdue Tasks',
        severity: ErrorSeverity.medium,
      );
      return [];
    }
  }
  
  /// Search tasks
  Future<List<TaskModel>> searchTasks(String searchTerm, {int limit = 20}) async {
    try {
      final searchTermLower = searchTerm.toLowerCase();
      
      // Search by title
      final titleQuery = await _tasksCollection
          .where('isDeleted', isEqualTo: false)
          .where('title', isGreaterThanOrEqualTo: searchTermLower)
          .where('title', isLessThanOrEqualTo: '$searchTermLower\uf8ff')
          .limit(limit)
          .get();
      
      // Search by tags
      final tagsQuery = await _tasksCollection
          .where('isDeleted', isEqualTo: false)
          .where('tags', arrayContains: searchTermLower)
          .limit(limit)
          .get();
      
      // Combine results and remove duplicates
      final allDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[
        ...titleQuery.docs,
        ...tagsQuery.docs,
      ];
      
      final uniqueTasks = <String, TaskModel>{};
      for (final doc in allDocs) {
        final task = TaskModel.fromJson(doc.data());
        if (_canViewTask(task)) {
          uniqueTasks[task.id] = task;
        }
      }
      
      return uniqueTasks.values.toList();
      
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Search Tasks',
        severity: ErrorSeverity.medium,
      );
      return [];
    }
  }
  
  // ==================== TASK STATUS MANAGEMENT ====================
  
  /// Update task status
  Future<TaskModel?> updateTaskStatus(String taskId, TaskStatus newStatus) async {
    try {
      final currentTask = await getTaskById(taskId);
      if (currentTask == null) {
        throw Exception('Task not found');
      }
      
      // Check if status transition is valid
      if (!currentTask.status.nextStatuses.contains(newStatus)) {
        throw Exception('Invalid status transition');
      }
      
      final updates = <String, dynamic>{
        'status': newStatus.value,
      };
      
      // Set completion date if completing task
      if (newStatus.isCompleted) {
        updates['completedAt'] = FieldValue.serverTimestamp();
      }
      
      return await updateTask(taskId, updates);
      
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Update Task Status',
        severity: ErrorSeverity.medium,
      );
      return null;
    }
  }
  
  /// Assign task to user
  Future<TaskModel?> assignTask(String taskId, String userId) async {
    try {
      final updates = <String, dynamic>{
        'assignedTo': userId,
        'assignmentType': TaskAssignmentType.managerAssigned.value,
      };
      
      return await updateTask(taskId, updates);
      
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Assign Task',
        severity: ErrorSeverity.medium,
      );
      return null;
    }
  }
  
  // ==================== REAL-TIME LISTENERS ====================
  
  /// Listen to task changes
  Stream<TaskModel?> listenToTask(String taskId) {
    try {
      return _tasksCollection
          .doc(taskId)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) return null;
        final task = TaskModel.fromJson(snapshot.data()!);
        return _canViewTask(task) ? task : null;
      });
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Listen To Task',
        severity: ErrorSeverity.medium,
      );
      return Stream.value(null);
    }
  }
  
  /// Listen to user's tasks
  Stream<List<TaskModel>> listenToMyTasks() {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        return Stream.value([]);
      }
      
      return _tasksCollection
          .where('isDeleted', isEqualTo: false)
          .where('isArchived', isEqualTo: false)
          .where(Filter.or(
            Filter('createdBy', isEqualTo: currentUser.id),
            Filter('assignedTo', isEqualTo: currentUser.id),
            Filter('assignedUsers', arrayContains: currentUser.id),
            Filter('collaborators', arrayContains: currentUser.id),
          ))
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => TaskModel.fromJson(doc.data()))
              .where((task) => _canViewTask(task))
              .toList());
              
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Listen To My Tasks',
        severity: ErrorSeverity.medium,
      );
      return Stream.value([]);
    }
  }
  
  // ==================== PERMISSION HELPERS ====================
  
  /// Check if current user can create a task
  bool _canCreateTask(TaskModel task) {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return false;
    
    // Users can always create personal tasks
    if (task.category == TaskCategory.personal) {
      return true;
    }
    
    // Team collaboration and project management tasks require appropriate permissions
    if (task.category.requiresTeamMembership) {
      return currentUser.role.canManageTeams || currentUser.role.canManageProjects;
    }
    
    return true;
  }
  
  /// Check if current user can view a task
  bool _canViewTask(TaskModel task) {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return false;
    
    // Admins can view all tasks
    if (currentUser.role.canAccessAdmin) {
      return true;
    }
    
    // Check if user is involved in the task
    if (task.createdBy == currentUser.id ||
        task.isAssignedToUser(currentUser.id) ||
        task.isCollaboratedByUser(currentUser.id) ||
        task.isWatchedByUser(currentUser.id)) {
      return true;
    }
    
    // Check visibility settings
    switch (task.visibility) {
      case TaskVisibility.private:
        return false;
      case TaskVisibility.team:
        return task.teamId != null && currentUser.teamIds.contains(task.teamId);
      case TaskVisibility.project:
        return task.projectId != null && currentUser.projectIds.contains(task.projectId);
      case TaskVisibility.public:
        return true;
    }
  }
  
  /// Check if current user can edit a task
  bool _canEditTask(TaskModel task) {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return false;
    
    // Admins can edit all tasks
    if (currentUser.role.canAccessAdmin) {
      return true;
    }
    
    // Task creator and assigned users can edit
    return task.canBeEditedByUser(currentUser.id);
  }
  
  /// Check if current user can delete a task
  bool _canDeleteTask(TaskModel task) {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return false;
    
    // Only admins and task creators can delete tasks
    return currentUser.role.canDeleteTasks || task.createdBy == currentUser.id;
  }
  
  // ==================== HELPER METHODS ====================
  
  /// Create system comment for task updates
  Future<void> _createSystemComment({
    required String taskId,
    required TaskCommentType type,
    required String content,
    required String authorId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;
      
      final comment = TaskCommentModel.systemComment(
        taskId: taskId,
        content: content,
        type: type,
        authorId: authorId,
        authorName: currentUser.name,
        metadata: metadata,
      );
      
      final docRef = _commentsCollection.doc();
      await docRef.set(comment.copyWith(id: docRef.id).toJson());
      
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Create System Comment',
        severity: ErrorSeverity.low,
      );
    }
  }
  
  /// Create system comments for task updates
  Future<void> _createSystemCommentsForUpdates(
    TaskModel currentTask,
    Map<String, dynamic> updates,
  ) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;
    
    // Status change
    if (updates.containsKey('status')) {
      final newStatus = TaskStatus.fromString(updates['status']);
      if (newStatus != currentTask.status) {
        await _createSystemComment(
          taskId: currentTask.id,
          type: TaskCommentType.statusUpdate,
          content: 'Status changed from ${currentTask.status.displayName} to ${newStatus.displayName}',
          authorId: currentUser.id,
          metadata: {
            'oldStatus': currentTask.status.value,
            'newStatus': newStatus.value,
          },
        );
      }
    }
    
    // Priority change
    if (updates.containsKey('priority')) {
      final newPriority = TaskPriority.fromString(updates['priority']);
      if (newPriority != currentTask.priority) {
        await _createSystemComment(
          taskId: currentTask.id,
          type: TaskCommentType.priorityChange,
          content: 'Priority changed from ${currentTask.priority.displayName} to ${newPriority.displayName}',
          authorId: currentUser.id,
          metadata: {
            'oldPriority': currentTask.priority.value,
            'newPriority': newPriority.value,
          },
        );
      }
    }
    
    // Assignment change
    if (updates.containsKey('assignedTo')) {
      final newAssignee = updates['assignedTo'] as String?;
      if (newAssignee != currentTask.assignedTo) {
        await _createSystemComment(
          taskId: currentTask.id,
          type: TaskCommentType.assignmentChange,
          content: newAssignee != null ? 'Task assigned' : 'Task unassigned',
          authorId: currentUser.id,
          metadata: {
            'oldAssignee': currentTask.assignedTo,
            'newAssignee': newAssignee,
          },
        );
      }
    }
  }
}
