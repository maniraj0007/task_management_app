import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';
import '../models/team_model.dart';
import '../models/project_model.dart';
import '../../modules/notifications/models/notification_model.dart';
import 'auth_service.dart';
import 'storage_service.dart';
import 'network_service.dart';

/// Data Synchronization Service
/// Manages real-time data synchronization between Firebase and local state
class DataSyncService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();
  final StorageService _storageService = Get.find<StorageService>();
  final NetworkService _networkService = Get.find<NetworkService>();

  // Stream subscriptions for cleanup
  final List<StreamSubscription> _subscriptions = [];

  // Reactive data streams
  final Rx<List<TaskModel>> _tasks = Rx<List<TaskModel>>([]);
  final Rx<List<TeamModel>> _teams = Rx<List<TeamModel>>([]);
  final Rx<List<ProjectModel>> _projects = Rx<List<ProjectModel>>([]);
  final Rx<List<NotificationModel>> _notifications = Rx<List<NotificationModel>>([]);
  final Rx<List<UserModel>> _users = Rx<List<UserModel>>([]);

  // Getters for reactive data
  List<TaskModel> get tasks => _tasks.value;
  List<TeamModel> get teams => _teams.value;
  List<ProjectModel> get projects => _projects.value;
  List<NotificationModel> get notifications => _notifications.value;
  List<UserModel> get users => _users.value;

  // Loading states
  final RxBool _isLoading = false.obs;
  final RxBool _isSyncing = false.obs;
  final RxString _syncStatus = 'idle'.obs;

  bool get isLoading => _isLoading.value;
  bool get isSyncing => _isSyncing.value;
  String get syncStatus => _syncStatus.value;

  // Offline support
  final RxBool _isOffline = false.obs;
  final RxList<Map<String, dynamic>> _pendingOperations = <Map<String, dynamic>>[].obs;

  bool get isOffline => _isOffline.value;
  List<Map<String, dynamic>> get pendingOperations => _pendingOperations;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeDataSync();
  }

  /// Initialize data synchronization
  Future<void> _initializeDataSync() async {
    try {
      _isLoading.value = true;
      _syncStatus.value = 'initializing';

      // Setup network connectivity listener
      _setupNetworkListener();

      // Setup authentication listener
      _setupAuthListener();

      // Enable offline persistence
      await _enableOfflinePersistence();

      _syncStatus.value = 'ready';
    } catch (e) {
      _syncStatus.value = 'error';
      _handleError('Failed to initialize data sync', e);
    } finally {
      _isLoading.value = false;
    }
  }

  /// Setup network connectivity listener
  void _setupNetworkListener() {
    _networkService.isConnected.listen((isConnected) {
      _isOffline.value = !isConnected;
      
      if (isConnected && _pendingOperations.isNotEmpty) {
        _processPendingOperations();
      }
    });
  }

  /// Setup authentication listener
  void _setupAuthListener() {
    _authService.isAuthenticated.listen((isAuthenticated) {
      if (isAuthenticated) {
        _startDataStreams();
      } else {
        _stopDataStreams();
        _clearLocalData();
      }
    });
  }

  /// Enable offline persistence
  Future<void> _enableOfflinePersistence() async {
    try {
      await _firestore.enablePersistence(
        const PersistenceSettings(synchronizeTabs: true),
      );
    } catch (e) {
      // Persistence might already be enabled
      print('Offline persistence setup: $e');
    }
  }

  /// Start real-time data streams
  void _startDataStreams() {
    final userId = _authService.currentUser?.id;
    if (userId == null) return;

    _syncStatus.value = 'syncing';
    _isSyncing.value = true;

    try {
      // Start task stream
      _startTaskStream(userId);
      
      // Start team stream
      _startTeamStream(userId);
      
      // Start project stream
      _startProjectStream(userId);
      
      // Start notification stream
      _startNotificationStream(userId);
      
      // Start user stream (for team members)
      _startUserStream();

      _syncStatus.value = 'active';
    } catch (e) {
      _syncStatus.value = 'error';
      _handleError('Failed to start data streams', e);
    } finally {
      _isSyncing.value = false;
    }
  }

  /// Start task stream
  void _startTaskStream(String userId) {
    // Personal tasks
    final personalTasksStream = _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .snapshots();

    // Team tasks (where user is a member)
    final teamTasksStream = _firestore
        .collectionGroup('tasks')
        .where('assignees', arrayContains: userId)
        .snapshots();

    // Combine streams
    final subscription = Rx.combineLatest2(
      personalTasksStream,
      teamTasksStream,
      (QuerySnapshot personal, QuerySnapshot team) {
        final personalTasks = personal.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList();
        
        final teamTasks = team.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList();

        // Merge and deduplicate
        final allTasks = <String, TaskModel>{};
        for (final task in [...personalTasks, ...teamTasks]) {
          allTasks[task.id] = task;
        }

        return allTasks.values.toList();
      },
    ).listen(
      (tasks) {
        _tasks.value = tasks;
        _cacheData('tasks', tasks.map((t) => t.toJson()).toList());
      },
      onError: (error) => _handleError('Task stream error', error),
    );

    _subscriptions.add(subscription);
  }

  /// Start team stream
  void _startTeamStream(String userId) {
    final subscription = _firestore
        .collection('teams')
        .where('members', arrayContains: userId)
        .snapshots()
        .listen(
          (snapshot) {
            final teams = snapshot.docs
                .map((doc) => TeamModel.fromFirestore(doc))
                .toList();
            
            _teams.value = teams;
            _cacheData('teams', teams.map((t) => t.toJson()).toList());
          },
          onError: (error) => _handleError('Team stream error', error),
        );

    _subscriptions.add(subscription);
  }

  /// Start project stream
  void _startProjectStream(String userId) {
    final subscription = _firestore
        .collection('projects')
        .where('members', arrayContains: userId)
        .snapshots()
        .listen(
          (snapshot) {
            final projects = snapshot.docs
                .map((doc) => ProjectModel.fromFirestore(doc))
                .toList();
            
            _projects.value = projects;
            _cacheData('projects', projects.map((p) => p.toJson()).toList());
          },
          onError: (error) => _handleError('Project stream error', error),
        );

    _subscriptions.add(subscription);
  }

  /// Start notification stream
  void _startNotificationStream(String userId) {
    final subscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .listen(
          (snapshot) {
            final notifications = snapshot.docs
                .map((doc) => NotificationModel.fromFirestore(doc))
                .toList();
            
            _notifications.value = notifications;
            _cacheData('notifications', notifications.map((n) => n.toJson()).toList());
          },
          onError: (error) => _handleError('Notification stream error', error),
        );

    _subscriptions.add(subscription);
  }

  /// Start user stream
  void _startUserStream() {
    // Get users from teams the current user is part of
    final subscription = _firestore
        .collection('users')
        .snapshots()
        .listen(
          (snapshot) {
            final users = snapshot.docs
                .map((doc) => UserModel.fromFirestore(doc))
                .toList();
            
            _users.value = users;
            _cacheData('users', users.map((u) => u.toJson()).toList());
          },
          onError: (error) => _handleError('User stream error', error),
        );

    _subscriptions.add(subscription);
  }

  /// Stop all data streams
  void _stopDataStreams() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _syncStatus.value = 'idle';
  }

  /// Clear local data
  void _clearLocalData() {
    _tasks.value = [];
    _teams.value = [];
    _projects.value = [];
    _notifications.value = [];
    _users.value = [];
  }

  /// Cache data locally
  Future<void> _cacheData(String key, List<Map<String, dynamic>> data) async {
    try {
      await _storageService.setData(key, data);
    } catch (e) {
      print('Failed to cache $key: $e');
    }
  }

  /// Load cached data
  Future<void> _loadCachedData() async {
    try {
      final cachedTasks = await _storageService.getData('tasks');
      if (cachedTasks != null) {
        _tasks.value = (cachedTasks as List)
            .map((json) => TaskModel.fromJson(json))
            .toList();
      }

      final cachedTeams = await _storageService.getData('teams');
      if (cachedTeams != null) {
        _teams.value = (cachedTeams as List)
            .map((json) => TeamModel.fromJson(json))
            .toList();
      }

      final cachedProjects = await _storageService.getData('projects');
      if (cachedProjects != null) {
        _projects.value = (cachedProjects as List)
            .map((json) => ProjectModel.fromJson(json))
            .toList();
      }

      final cachedNotifications = await _storageService.getData('notifications');
      if (cachedNotifications != null) {
        _notifications.value = (cachedNotifications as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }

      final cachedUsers = await _storageService.getData('users');
      if (cachedUsers != null) {
        _users.value = (cachedUsers as List)
            .map((json) => UserModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Failed to load cached data: $e');
    }
  }

  /// Process pending operations when back online
  Future<void> _processPendingOperations() async {
    if (_pendingOperations.isEmpty) return;

    _isSyncing.value = true;
    _syncStatus.value = 'syncing_offline_changes';

    try {
      final operations = List<Map<String, dynamic>>.from(_pendingOperations);
      _pendingOperations.clear();

      for (final operation in operations) {
        await _executeOperation(operation);
      }

      _syncStatus.value = 'active';
    } catch (e) {
      _syncStatus.value = 'error';
      _handleError('Failed to process pending operations', e);
    } finally {
      _isSyncing.value = false;
    }
  }

  /// Execute a pending operation
  Future<void> _executeOperation(Map<String, dynamic> operation) async {
    final type = operation['type'] as String;
    final collection = operation['collection'] as String;
    final data = operation['data'] as Map<String, dynamic>;
    final docId = operation['docId'] as String?;

    try {
      switch (type) {
        case 'create':
          await _firestore.collection(collection).add(data);
          break;
        case 'update':
          if (docId != null) {
            await _firestore.collection(collection).doc(docId).update(data);
          }
          break;
        case 'delete':
          if (docId != null) {
            await _firestore.collection(collection).doc(docId).delete();
          }
          break;
      }
    } catch (e) {
      // Re-add to pending operations if failed
      _pendingOperations.add(operation);
      rethrow;
    }
  }

  /// Add operation to pending queue (for offline support)
  void _addPendingOperation(String type, String collection, Map<String, dynamic> data, [String? docId]) {
    _pendingOperations.add({
      'type': type,
      'collection': collection,
      'data': data,
      'docId': docId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Handle errors
  void _handleError(String message, dynamic error) {
    print('DataSyncService Error: $message - $error');
    Get.snackbar(
      'Sync Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  // ==================== PUBLIC API ====================

  /// Refresh all data
  Future<void> refreshData() async {
    if (_authService.isAuthenticated.value) {
      _stopDataStreams();
      await Future.delayed(const Duration(milliseconds: 500));
      _startDataStreams();
    }
  }

  /// Get task by ID
  TaskModel? getTaskById(String taskId) {
    try {
      return _tasks.value.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  /// Get team by ID
  TeamModel? getTeamById(String teamId) {
    try {
      return _teams.value.firstWhere((team) => team.id == teamId);
    } catch (e) {
      return null;
    }
  }

  /// Get project by ID
  ProjectModel? getProjectById(String projectId) {
    try {
      return _projects.value.firstWhere((project) => project.id == projectId);
    } catch (e) {
      return null;
    }
  }

  /// Get user by ID
  UserModel? getUserById(String userId) {
    try {
      return _users.value.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  /// Get unread notification count
  int get unreadNotificationCount {
    return _notifications.value.where((n) => !n.isRead).length;
  }

  /// Get pending task count
  int get pendingTaskCount {
    return _tasks.value.where((t) => t.status != 'completed').length;
  }

  @override
  void onClose() {
    _stopDataStreams();
    super.onClose();
  }
}
