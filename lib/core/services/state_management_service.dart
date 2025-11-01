import 'dart:async';
import 'package:get/get.dart';
import 'data_sync_service.dart';
import '../../modules/analytics/controllers/analytics_controller.dart';
import '../../modules/search/controllers/search_controller.dart';
import '../../modules/notifications/controllers/notification_controller.dart';
import '../../modules/navigation/controllers/navigation_controller.dart';

/// State Management Service
/// Coordinates state synchronization between different controllers
class StateManagementService extends GetxService {
  final DataSyncService _dataSyncService = Get.find<DataSyncService>();

  // Controller references (lazy loaded)
  AnalyticsController? _analyticsController;
  SearchController? _searchController;
  NotificationController? _notificationController;
  NavigationController? _navigationController;

  // State synchronization flags
  final RxBool _isInitialized = false.obs;
  final RxBool _isSynchronizing = false.obs;
  final RxMap<String, DateTime> _lastSyncTimes = <String, DateTime>{}.obs;

  bool get isInitialized => _isInitialized.value;
  bool get isSynchronizing => _isSynchronizing.value;
  Map<String, DateTime> get lastSyncTimes => _lastSyncTimes;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeStateManagement();
  }

  /// Initialize state management
  Future<void> _initializeStateManagement() async {
    try {
      _isSynchronizing.value = true;

      // Setup data sync listeners
      _setupDataSyncListeners();

      // Initialize controller references
      _initializeControllerReferences();

      // Setup cross-controller communication
      _setupCrossControllerCommunication();

      _isInitialized.value = true;
    } catch (e) {
      _handleError('Failed to initialize state management', e);
    } finally {
      _isSynchronizing.value = false;
    }
  }

  /// Setup data sync listeners
  void _setupDataSyncListeners() {
    // Listen to task changes
    ever(_dataSyncService.tasksStream, (tasks) {
      _syncTasksToControllers(tasks);
      _updateLastSyncTime('tasks');
    });

    // Listen to team changes
    ever(_dataSyncService.teamsStream, (teams) {
      _syncTeamsToControllers(teams);
      _updateLastSyncTime('teams');
    });

    // Listen to project changes
    ever(_dataSyncService.projectsStream, (projects) {
      _syncProjectsToControllers(projects);
      _updateLastSyncTime('projects');
    });

    // Listen to notification changes
    ever(_dataSyncService.notificationsStream, (notifications) {
      _syncNotificationsToControllers(notifications);
      _updateLastSyncTime('notifications');
    });

    // Listen to user changes
    ever(_dataSyncService.usersStream, (users) {
      _syncUsersToControllers(users);
      _updateLastSyncTime('users');
    });
  }

  /// Initialize controller references
  void _initializeControllerReferences() {
    // Use try-catch to handle cases where controllers might not be initialized yet
    try {
      _analyticsController = Get.find<AnalyticsController>();
    } catch (e) {
      // Controller not initialized yet
    }

    try {
      _searchController = Get.find<SearchController>();
    } catch (e) {
      // Controller not initialized yet
    }

    try {
      _notificationController = Get.find<NotificationController>();
    } catch (e) {
      // Controller not initialized yet
    }

    try {
      _navigationController = Get.find<NavigationController>();
    } catch (e) {
      // Controller not initialized yet
    }
  }

  /// Setup cross-controller communication
  void _setupCrossControllerCommunication() {
    // Setup periodic controller reference updates
    Timer.periodic(const Duration(seconds: 5), (timer) {
      _initializeControllerReferences();
    });
  }

  /// Sync tasks to relevant controllers
  void _syncTasksToControllers(List<dynamic> tasks) {
    // Update analytics controller
    _analyticsController?.updateTaskData(tasks);

    // Update search controller with task data
    _searchController?.updateTaskSearchData(tasks);

    // Update navigation badge counts
    _updateNavigationBadges();
  }

  /// Sync teams to relevant controllers
  void _syncTeamsToControllers(List<dynamic> teams) {
    // Update analytics controller
    _analyticsController?.updateTeamData(teams);

    // Update search controller with team data
    _searchController?.updateTeamSearchData(teams);
  }

  /// Sync projects to relevant controllers
  void _syncProjectsToControllers(List<dynamic> projects) {
    // Update analytics controller
    _analyticsController?.updateProjectData(projects);

    // Update search controller with project data
    _searchController?.updateProjectSearchData(projects);
  }

  /// Sync notifications to relevant controllers
  void _syncNotificationsToControllers(List<dynamic> notifications) {
    // Update notification controller
    _notificationController?.updateNotificationData(notifications);

    // Update navigation badge counts
    _updateNavigationBadges();
  }

  /// Sync users to relevant controllers
  void _syncUsersToControllers(List<dynamic> users) {
    // Update analytics controller
    _analyticsController?.updateUserData(users);

    // Update search controller with user data
    _searchController?.updateUserSearchData(users);
  }

  /// Update navigation badge counts
  void _updateNavigationBadges() {
    if (_navigationController != null) {
      // This would update badge counts in the navigation controller
      // The actual implementation would depend on the navigation controller's API
    }
  }

  /// Update last sync time
  void _updateLastSyncTime(String dataType) {
    _lastSyncTimes[dataType] = DateTime.now();
  }

  /// Handle errors
  void _handleError(String message, dynamic error) {
    print('StateManagementService Error: $message - $error');
  }

  // ==================== PUBLIC API ====================

  /// Force sync all data to controllers
  Future<void> forceSyncAll() async {
    if (!_isInitialized.value) return;

    _isSynchronizing.value = true;

    try {
      // Re-initialize controller references
      _initializeControllerReferences();

      // Sync all current data
      _syncTasksToControllers(_dataSyncService.tasks);
      _syncTeamsToControllers(_dataSyncService.teams);
      _syncProjectsToControllers(_dataSyncService.projects);
      _syncNotificationsToControllers(_dataSyncService.notifications);
      _syncUsersToControllers(_dataSyncService.users);

    } catch (e) {
      _handleError('Failed to force sync all data', e);
    } finally {
      _isSynchronizing.value = false;
    }
  }

  /// Get sync status for a specific data type
  String getSyncStatus(String dataType) {
    final lastSync = _lastSyncTimes[dataType];
    if (lastSync == null) return 'Never synced';

    final now = DateTime.now();
    final difference = now.difference(lastSync);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Check if data type is recently synced
  bool isRecentlySynced(String dataType, {Duration threshold = const Duration(minutes: 5)}) {
    final lastSync = _lastSyncTimes[dataType];
    if (lastSync == null) return false;

    final now = DateTime.now();
    return now.difference(lastSync) < threshold;
  }

  /// Get overall sync health
  Map<String, dynamic> getSyncHealth() {
    final dataTypes = ['tasks', 'teams', 'projects', 'notifications', 'users'];
    final health = <String, dynamic>{};

    for (final type in dataTypes) {
      health[type] = {
        'lastSync': _lastSyncTimes[type]?.toIso8601String(),
        'isHealthy': isRecentlySynced(type),
        'status': getSyncStatus(type),
      };
    }

    health['overall'] = {
      'isHealthy': dataTypes.every((type) => isRecentlySynced(type, threshold: const Duration(minutes: 10))),
      'syncingStatus': _dataSyncService.syncStatus,
      'isOffline': _dataSyncService.isOffline,
      'pendingOperations': _dataSyncService.pendingOperations.length,
    };

    return health;
  }

  /// Register a controller for state synchronization
  void registerController(String controllerType, GetxController controller) {
    switch (controllerType) {
      case 'analytics':
        _analyticsController = controller as AnalyticsController;
        break;
      case 'search':
        _searchController = controller as SearchController;
        break;
      case 'notification':
        _notificationController = controller as NotificationController;
        break;
      case 'navigation':
        _navigationController = controller as NavigationController;
        break;
    }

    // Immediately sync current data to the newly registered controller
    _syncCurrentDataToController(controllerType);
  }

  /// Sync current data to a specific controller
  void _syncCurrentDataToController(String controllerType) {
    switch (controllerType) {
      case 'analytics':
        _syncTasksToControllers(_dataSyncService.tasks);
        _syncTeamsToControllers(_dataSyncService.teams);
        _syncProjectsToControllers(_dataSyncService.projects);
        _syncUsersToControllers(_dataSyncService.users);
        break;
      case 'search':
        _syncTasksToControllers(_dataSyncService.tasks);
        _syncTeamsToControllers(_dataSyncService.teams);
        _syncProjectsToControllers(_dataSyncService.projects);
        _syncUsersToControllers(_dataSyncService.users);
        break;
      case 'notification':
        _syncNotificationsToControllers(_dataSyncService.notifications);
        break;
      case 'navigation':
        _updateNavigationBadges();
        break;
    }
  }

  /// Unregister a controller
  void unregisterController(String controllerType) {
    switch (controllerType) {
      case 'analytics':
        _analyticsController = null;
        break;
      case 'search':
        _searchController = null;
        break;
      case 'notification':
        _notificationController = null;
        break;
      case 'navigation':
        _navigationController = null;
        break;
    }
  }
}
