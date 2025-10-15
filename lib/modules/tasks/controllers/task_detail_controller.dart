import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/enums/task_enums.dart';
import '../models/task_model.dart';
import '../models/task_comment_model.dart';
import '../models/task_attachment_model.dart';
import '../services/task_service.dart';
import '../../auth/services/auth_service.dart';

/// Task Detail Controller
/// Manages individual task details, comments, and attachments
class TaskDetailController extends GetxController {
  final TaskService _taskService = Get.find<TaskService>();
  final AuthService _authService = Get.find<AuthService>();
  
  // Task ID from route parameters
  late final String taskId;
  
  // Reactive state
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingComments = false.obs;
  final RxBool _isLoadingAttachments = false.obs;
  final Rx<TaskModel?> _task = Rx<TaskModel?>(null);
  final RxList<TaskCommentModel> _comments = <TaskCommentModel>[].obs;
  final RxList<TaskAttachmentModel> _attachments = <TaskAttachmentModel>[].obs;
  final RxBool _showCompletedSubtasks = false.obs;
  final RxInt _selectedTabIndex = 0.obs;
  
  // Comment form
  final commentController = TextEditingController();
  final RxBool _isAddingComment = false.obs;
  
  // Getters
  bool get isLoading => _isLoading.value;
  bool get isLoadingComments => _isLoadingComments.value;
  bool get isLoadingAttachments => _isLoadingAttachments.value;
  TaskModel? get task => _task.value;
  List<TaskCommentModel> get comments => _comments;
  List<TaskAttachmentModel> get attachments => _attachments;
  bool get showCompletedSubtasks => _showCompletedSubtasks.value;
  int get selectedTabIndex => _selectedTabIndex.value;
  bool get isAddingComment => _isAddingComment.value;
  
  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }
  
  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
  
  /// Initialize controller with task ID
  void _initializeController() {
    // Get task ID from route parameters or arguments
    final args = Get.arguments as Map<String, dynamic>?;
    final routeParams = Get.parameters;
    
    if (args != null && args.containsKey('taskId')) {
      taskId = args['taskId'] as String;
    } else if (routeParams.containsKey('taskId')) {
      taskId = routeParams['taskId']!;
    } else {
      Get.snackbar('Error', 'Task ID not provided');
      Get.back();
      return;
    }
    
    _loadTaskDetails();
    _setupRealtimeListener();
  }
  
  /// Load task details
  Future<void> _loadTaskDetails() async {
    try {
      _isLoading.value = true;
      
      await Future.wait([
        _loadTask(),
        _loadComments(),
        _loadAttachments(),
      ]);
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load task details: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Load task data
  Future<void> _loadTask() async {
    final task = await _taskService.getTaskById(taskId);
    if (task != null) {
      _task.value = task;
    } else {
      Get.snackbar('Error', 'Task not found');
      Get.back();
    }
  }
  
  /// Load task comments
  Future<void> _loadComments() async {
    try {
      _isLoadingComments.value = true;
      // TODO: Implement comment loading from service
      // final comments = await _taskService.getTaskComments(taskId);
      // _comments.assignAll(comments);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load comments');
    } finally {
      _isLoadingComments.value = false;
    }
  }
  
  /// Load task attachments
  Future<void> _loadAttachments() async {
    try {
      _isLoadingAttachments.value = true;
      // TODO: Implement attachment loading from service
      // final attachments = await _taskService.getTaskAttachments(taskId);
      // _attachments.assignAll(attachments);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load attachments');
    } finally {
      _isLoadingAttachments.value = false;
    }
  }
  
  /// Setup real-time listener for task updates
  void _setupRealtimeListener() {
    _taskService.listenToTask(taskId).listen(
      (updatedTask) {
        if (updatedTask != null) {
          _task.value = updatedTask;
        }
      },
      onError: (error) {
        Get.snackbar('Sync Error', 'Failed to sync task updates');
      },
    );
  }
  
  // ==================== TASK ACTIONS ====================
  
  /// Update task status
  Future<void> updateTaskStatus(TaskStatus newStatus) async {
    if (_task.value == null) return;
    
    try {
      final updatedTask = await _taskService.updateTaskStatus(taskId, newStatus);
      if (updatedTask != null) {
        _task.value = updatedTask;
        Get.snackbar(
          'Success',
          'Task status updated to ${newStatus.displayName}',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update task status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  /// Complete task
  Future<void> completeTask() async {
    await updateTaskStatus(TaskStatus.completed);
  }
  
  /// Start task
  Future<void> startTask() async {
    await updateTaskStatus(TaskStatus.inProgress);
  }
  
  /// Move task to review
  Future<void> reviewTask() async {
    await updateTaskStatus(TaskStatus.review);
  }
  
  /// Cancel task
  Future<void> cancelTask() async {
    await updateTaskStatus(TaskStatus.cancelled);
  }
  
  /// Reopen task
  Future<void> reopenTask() async {
    await updateTaskStatus(TaskStatus.todo);
  }
  
  /// Edit task
  void editTask() {
    if (_task.value == null) return;
    
    Get.toNamed('/tasks/edit', arguments: {
      'task': _task.value,
    })?.then((result) {
      if (result is TaskModel) {
        _task.value = result;
      }
    });
  }
  
  /// Delete task
  Future<void> deleteTask() async {
    if (_task.value == null) return;
    
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final success = await _taskService.deleteTask(taskId);
        if (success) {
          Get.back(); // Go back to task list
          Get.snackbar(
            'Success',
            'Task deleted successfully',
            snackPosition: SnackPosition.TOP,
          );
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete task: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
  
  /// Archive task
  Future<void> archiveTask() async {
    if (_task.value == null) return;
    
    try {
      final success = await _taskService.archiveTask(taskId);
      if (success) {
        Get.back(); // Go back to task list
        Get.snackbar(
          'Success',
          'Task archived successfully',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to archive task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  /// Assign task to user
  Future<void> assignTask(String userId) async {
    if (_task.value == null) return;
    
    try {
      final updatedTask = await _taskService.assignTask(taskId, userId);
      if (updatedTask != null) {
        _task.value = updatedTask;
        Get.snackbar(
          'Success',
          'Task assigned successfully',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to assign task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // ==================== COMMENT MANAGEMENT ====================
  
  /// Add comment
  Future<void> addComment() async {
    if (commentController.text.trim().isEmpty) return;
    
    try {
      _isAddingComment.value = true;
      
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      final comment = TaskCommentModel.create(
        taskId: taskId,
        content: commentController.text.trim(),
        authorId: currentUser.id,
        authorName: currentUser.name,
        authorPhotoUrl: currentUser.photoUrl,
      );
      
      // TODO: Implement comment creation in service
      // final createdComment = await _taskService.addComment(comment);
      // if (createdComment != null) {
      //   _comments.insert(0, createdComment);
      //   commentController.clear();
      // }
      
      commentController.clear();
      Get.snackbar(
        'Success',
        'Comment added successfully',
        snackPosition: SnackPosition.TOP,
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add comment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isAddingComment.value = false;
    }
  }
  
  /// Edit comment
  Future<void> editComment(String commentId, String newContent) async {
    try {
      // TODO: Implement comment editing in service
      // final updatedComment = await _taskService.updateComment(commentId, newContent);
      // if (updatedComment != null) {
      //   final index = _comments.indexWhere((c) => c.id == commentId);
      //   if (index != -1) {
      //     _comments[index] = updatedComment;
      //   }
      // }
      
      Get.snackbar(
        'Success',
        'Comment updated successfully',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update comment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  /// Delete comment
  Future<void> deleteComment(String commentId) async {
    try {
      // TODO: Implement comment deletion in service
      // final success = await _taskService.deleteComment(commentId);
      // if (success) {
      //   _comments.removeWhere((c) => c.id == commentId);
      // }
      
      _comments.removeWhere((c) => c.id == commentId);
      Get.snackbar(
        'Success',
        'Comment deleted successfully',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete comment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // ==================== ATTACHMENT MANAGEMENT ====================
  
  /// Add attachment
  Future<void> addAttachment() async {
    // TODO: Implement file picker and upload
    Get.snackbar(
      'Coming Soon',
      'File attachment feature will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  /// Download attachment
  Future<void> downloadAttachment(TaskAttachmentModel attachment) async {
    try {
      // TODO: Implement file download
      Get.snackbar(
        'Success',
        'Downloading ${attachment.fileName}',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download attachment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  /// Delete attachment
  Future<void> deleteAttachment(String attachmentId) async {
    try {
      // TODO: Implement attachment deletion in service
      // final success = await _taskService.deleteAttachment(attachmentId);
      // if (success) {
      //   _attachments.removeWhere((a) => a.id == attachmentId);
      // }
      
      _attachments.removeWhere((a) => a.id == attachmentId);
      Get.snackbar(
        'Success',
        'Attachment deleted successfully',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete attachment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // ==================== UI MANAGEMENT ====================
  
  /// Set selected tab index
  void setSelectedTabIndex(int index) {
    _selectedTabIndex.value = index;
  }
  
  /// Toggle completed subtasks visibility
  void toggleCompletedSubtasks() {
    _showCompletedSubtasks.value = !_showCompletedSubtasks.value;
  }
  
  /// Share task
  void shareTask() {
    if (_task.value == null) return;
    
    // TODO: Implement task sharing
    Get.snackbar(
      'Coming Soon',
      'Task sharing feature will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  /// Copy task link
  void copyTaskLink() {
    if (_task.value == null) return;
    
    // TODO: Implement link copying
    Get.snackbar(
      'Success',
      'Task link copied to clipboard',
      snackPosition: SnackPosition.TOP,
    );
  }
  
  /// Refresh task details
  Future<void> refreshTask() async {
    await _loadTaskDetails();
  }
  
  // ==================== PERMISSION CHECKS ====================
  
  /// Check if current user can edit task
  bool get canEditTask {
    final task = _task.value;
    final currentUser = _authService.currentUser;
    
    if (task == null || currentUser == null) return false;
    
    return task.canBeEditedByUser(currentUser.id) || 
           currentUser.role.canAccessAdmin;
  }
  
  /// Check if current user can delete task
  bool get canDeleteTask {
    final task = _task.value;
    final currentUser = _authService.currentUser;
    
    if (task == null || currentUser == null) return false;
    
    return task.createdBy == currentUser.id || 
           currentUser.role.canDeleteTasks;
  }
  
  /// Check if current user can assign task
  bool get canAssignTask {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return false;
    
    return currentUser.role.canManageTeams || canEditTask;
  }
  
  /// Check if current user can change task status
  bool get canChangeStatus {
    final task = _task.value;
    final currentUser = _authService.currentUser;
    
    if (task == null || currentUser == null) return false;
    
    return task.isAssignedToUser(currentUser.id) || 
           task.createdBy == currentUser.id ||
           currentUser.role.canAccessAdmin;
  }
  
  /// Check if current user can add comments
  bool get canAddComments {
    final task = _task.value;
    final currentUser = _authService.currentUser;
    
    if (task == null || currentUser == null) return false;
    
    // Users can comment if they can view the task
    return true; // Assuming if they can view, they can comment
  }
  
  /// Check if current user can add attachments
  bool get canAddAttachments {
    return canEditTask;
  }
  
  // ==================== UTILITY METHODS ====================
  
  /// Get available status transitions
  List<TaskStatus> get availableStatusTransitions {
    final task = _task.value;
    if (task == null || !canChangeStatus) return [];
    
    return task.status.nextStatuses;
  }
  
  /// Get task progress percentage
  double get taskProgress {
    final task = _task.value;
    if (task == null) return 0.0;
    
    return task.completionPercentage;
  }
  
  /// Get task urgency level
  String get taskUrgencyLevel {
    final task = _task.value;
    if (task == null) return 'Normal';
    
    final score = task.urgencyScore;
    if (score >= 10) return 'Critical';
    if (score >= 7) return 'High';
    if (score >= 4) return 'Medium';
    return 'Normal';
  }
  
  /// Get time until due date
  String get timeUntilDue {
    final task = _task.value;
    if (task == null || task.dueDate == null) return '';
    
    final now = DateTime.now();
    final dueDate = task.dueDate!;
    final difference = dueDate.difference(now);
    
    if (difference.isNegative) {
      final days = difference.inDays.abs();
      return days == 0 ? 'Overdue' : '$days days overdue';
    } else {
      final days = difference.inDays;
      if (days == 0) return 'Due today';
      if (days == 1) return 'Due tomorrow';
      return 'Due in $days days';
    }
  }
}
