import 'package:get/get.dart';
import '../../auth/services/auth_service.dart';
import '../../tasks/services/task_service.dart';
import '../../tasks/models/task_model.dart';

/// Dashboard Controller
/// Manages the main dashboard state and data
class DashboardController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final TaskService _taskService = Get.find<TaskService>();

  // Observable properties
  final RxBool isLoading = false.obs;
  final RxList<TaskModel> recentTasks = <TaskModel>[].obs;
  final RxList<TaskModel> upcomingTasks = <TaskModel>[].obs;
  final RxInt totalTasks = 0.obs;
  final RxInt completedTasks = 0.obs;
  final RxInt pendingTasks = 0.obs;
  final RxInt overdueTasks = 0.obs;

  // User info
  String get userName => _authService.currentUser?.firstName ?? 'User';
  String get userEmail => _authService.currentUser?.email ?? '';

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  /// Load dashboard data
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      
      // Load user's tasks
      await _loadUserTasks();
      
      // Calculate statistics
      _calculateTaskStatistics();
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load dashboard data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load user's tasks
  Future<void> _loadUserTasks() async {
    final userId = _authService.currentUser?.id;
    if (userId == null) return;

    // Get all user tasks
    final allTasks = await _taskService.getUserTasks(userId);
    
    // Filter recent tasks (last 7 days)
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    
    recentTasks.value = allTasks
        .where((task) => task.createdAt.isAfter(sevenDaysAgo))
        .take(5)
        .toList();
    
    // Filter upcoming tasks (due in next 7 days)
    final sevenDaysFromNow = now.add(const Duration(days: 7));
    
    upcomingTasks.value = allTasks
        .where((task) => 
            task.dueDate != null && 
            task.dueDate!.isAfter(now) && 
            task.dueDate!.isBefore(sevenDaysFromNow))
        .take(5)
        .toList();
  }

  /// Calculate task statistics
  void _calculateTaskStatistics() {
    final userId = _authService.currentUser?.id;
    if (userId == null) return;

    // This would typically come from a service call
    // For now, we'll use mock data
    totalTasks.value = 24;
    completedTasks.value = 18;
    pendingTasks.value = 4;
    overdueTasks.value = 2;
  }

  /// Navigate to tasks screen
  void navigateToTasks() {
    Get.toNamed('/tasks');
  }

  /// Navigate to teams screen
  void navigateToTeams() {
    Get.toNamed('/teams');
  }

  /// Navigate to profile screen
  void navigateToProfile() {
    Get.toNamed('/profile');
  }

  /// Navigate to create task screen
  void navigateToCreateTask() {
    Get.toNamed('/tasks/create');
  }

  /// Refresh dashboard data
  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }

  /// Get completion percentage
  double get completionPercentage {
    if (totalTasks.value == 0) return 0.0;
    return (completedTasks.value / totalTasks.value) * 100;
  }

  /// Get productivity status
  String get productivityStatus {
    final percentage = completionPercentage;
    if (percentage >= 80) return 'Excellent';
    if (percentage >= 60) return 'Good';
    if (percentage >= 40) return 'Average';
    return 'Needs Improvement';
  }

  /// Get productivity color
  String get productivityColor {
    final percentage = completionPercentage;
    if (percentage >= 80) return '#4CAF50'; // Green
    if (percentage >= 60) return '#2196F3'; // Blue
    if (percentage >= 40) return '#FF9800'; // Orange
    return '#F44336'; // Red
  }
}
