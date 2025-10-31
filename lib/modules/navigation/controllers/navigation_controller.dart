import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../routes/app_routes.dart';

/// Navigation Controller
/// Manages main app navigation and screen transitions
class NavigationController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Current navigation index
  final RxInt _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;

  // Navigation history for back button handling
  final RxList<int> _navigationHistory = <int>[0].obs;
  List<int> get navigationHistory => _navigationHistory;

  // Screen titles for app bar
  final List<String> _screenTitles = [
    'Dashboard',
    'Tasks',
    'Teams',
    'Projects',
    'Search',
    'Analytics',
    'Notifications',
    'Profile',
  ];

  String get currentScreenTitle => _screenTitles[_currentIndex.value];

  @override
  void onInit() {
    super.onInit();
    _setupNavigationListeners();
  }

  /// Setup navigation listeners
  void _setupNavigationListeners() {
    // Listen to auth state changes
    ever(_authService.isAuthenticated, (isAuthenticated) {
      if (!isAuthenticated) {
        // Redirect to login if user is not authenticated
        Get.offAllNamed(AppRoutes.login);
      }
    });
  }

  /// Change current page
  void changePage(int index) {
    if (index == _currentIndex.value) return;

    // Check if user has permission to access the screen
    if (!_canAccessScreen(index)) {
      _showAccessDeniedMessage(index);
      return;
    }

    // Update navigation history
    if (_navigationHistory.last != index) {
      _navigationHistory.add(index);
      
      // Limit history size
      if (_navigationHistory.length > 10) {
        _navigationHistory.removeAt(0);
      }
    }

    _currentIndex.value = index;
  }

  /// Go back to previous screen
  bool goBack() {
    if (_navigationHistory.length > 1) {
      _navigationHistory.removeLast();
      _currentIndex.value = _navigationHistory.last;
      return true;
    }
    return false;
  }

  /// Reset navigation to dashboard
  void resetToHome() {
    _currentIndex.value = 0;
    _navigationHistory.clear();
    _navigationHistory.add(0);
  }

  /// Check if user can access screen
  bool _canAccessScreen(int index) {
    final userRole = _authService.currentUser?.role;
    
    switch (index) {
      case 5: // Analytics
        // Only admins and super admins can access analytics
        return userRole == 'admin' || userRole == 'super_admin';
      case 6: // Notifications
        // All authenticated users can access notifications
        return true;
      case 7: // Profile
        // All authenticated users can access profile
        return true;
      default:
        // All other screens are accessible to authenticated users
        return true;
    }
  }

  /// Show access denied message
  void _showAccessDeniedMessage(int index) {
    final screenName = _screenTitles[index];
    Get.snackbar(
      'Access Denied',
      'You don\'t have permission to access $screenName',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ==================== FLOATING ACTION BUTTON ACTIONS ====================

  /// Create new task
  void createNewTask() {
    Get.toNamed(AppRoutes.taskCreate);
  }

  /// Create new team
  void createNewTeam() {
    Get.toNamed(AppRoutes.teamCreate);
  }

  /// Create new project
  void createNewProject() {
    Get.toNamed(AppRoutes.projectCreate);
  }

  // ==================== NAVIGATION HELPERS ====================

  /// Navigate to specific screen by name
  void navigateToScreen(String screenName) {
    int? index;
    
    switch (screenName.toLowerCase()) {
      case 'dashboard':
        index = 0;
        break;
      case 'tasks':
        index = 1;
        break;
      case 'teams':
        index = 2;
        break;
      case 'projects':
        index = 3;
        break;
      case 'search':
        index = 4;
        break;
      case 'analytics':
        index = 5;
        break;
      case 'notifications':
        index = 6;
        break;
      case 'profile':
        index = 7;
        break;
    }
    
    if (index != null) {
      changePage(index);
    }
  }

  /// Get current screen route
  String getCurrentRoute() {
    switch (_currentIndex.value) {
      case 0:
        return AppRoutes.dashboard;
      case 1:
        return AppRoutes.tasks;
      case 2:
        return AppRoutes.teams;
      case 3:
        return AppRoutes.projects;
      case 4:
        return AppRoutes.search;
      case 5:
        return AppRoutes.analytics;
      case 6:
        return AppRoutes.notifications;
      case 7:
        return AppRoutes.userProfile;
      default:
        return AppRoutes.dashboard;
    }
  }

  /// Check if current screen has FAB
  bool get hasFAB {
    return _currentIndex.value >= 1 && _currentIndex.value <= 3;
  }

  /// Get FAB icon for current screen
  String get fabIcon {
    switch (_currentIndex.value) {
      case 1: // Tasks
        return 'add';
      case 2: // Teams
        return 'group_add';
      case 3: // Projects
        return 'create_new_folder';
      default:
        return 'add';
    }
  }

  /// Get FAB tooltip for current screen
  String get fabTooltip {
    switch (_currentIndex.value) {
      case 1: // Tasks
        return 'Create New Task';
      case 2: // Teams
        return 'Create New Team';
      case 3: // Projects
        return 'Create New Project';
      default:
        return 'Create New';
    }
  }

  // ==================== BADGE COUNTS ====================

  /// Get notification badge count
  int get notificationBadgeCount {
    // This would typically come from a notification service
    return 0; // Placeholder
  }

  /// Get task badge count (pending tasks)
  int get taskBadgeCount {
    // This would typically come from a task service
    return 0; // Placeholder
  }

  /// Check if screen has badge
  bool hasBadge(int index) {
    switch (index) {
      case 1: // Tasks
        return taskBadgeCount > 0;
      case 6: // Notifications
        return notificationBadgeCount > 0;
      default:
        return false;
    }
  }

  /// Get badge count for screen
  int getBadgeCount(int index) {
    switch (index) {
      case 1: // Tasks
        return taskBadgeCount;
      case 6: // Notifications
        return notificationBadgeCount;
      default:
        return 0;
    }
  }

  // ==================== DEEP LINKING ====================

  /// Handle deep link navigation
  void handleDeepLink(String route) {
    // Parse route and navigate accordingly
    if (route.startsWith('/tasks')) {
      changePage(1);
    } else if (route.startsWith('/teams')) {
      changePage(2);
    } else if (route.startsWith('/projects')) {
      changePage(3);
    } else if (route.startsWith('/search')) {
      changePage(4);
    } else if (route.startsWith('/analytics')) {
      changePage(5);
    } else if (route.startsWith('/notifications')) {
      changePage(6);
    } else if (route.startsWith('/profile')) {
      changePage(7);
    } else {
      changePage(0); // Default to dashboard
    }
  }

  // ==================== LIFECYCLE ====================

  @override
  void onClose() {
    // Clean up any listeners or resources
    super.onClose();
  }
}
