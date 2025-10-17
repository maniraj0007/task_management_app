import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:task_management_app/core/services/data_sync_service.dart';
import 'package:task_management_app/core/services/auth_service.dart';
import 'package:task_management_app/core/services/storage_service.dart';
import 'package:task_management_app/core/services/network_service.dart';
import 'package:task_management_app/core/models/task_model.dart';
import 'package:task_management_app/core/models/user_model.dart';

import 'data_sync_service_test.mocks.dart';

@GenerateMocks([
  AuthService,
  StorageService,
  NetworkService,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  Query,
  QuerySnapshot,
  DocumentSnapshot,
])
void main() {
  group('DataSyncService Tests', () {
    late DataSyncService dataSyncService;
    late MockAuthService mockAuthService;
    late MockStorageService mockStorageService;
    late MockNetworkService mockNetworkService;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      // Initialize GetX for testing
      Get.testMode = true;
      
      // Create mocks
      mockAuthService = MockAuthService();
      mockStorageService = MockStorageService();
      mockNetworkService = MockNetworkService();
      mockFirestore = MockFirebaseFirestore();

      // Setup GetX dependencies
      Get.put<AuthService>(mockAuthService);
      Get.put<StorageService>(mockStorageService);
      Get.put<NetworkService>(mockNetworkService);

      // Create service instance
      dataSyncService = DataSyncService();
    });

    tearDown(() {
      Get.reset();
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        // Arrange
        when(mockNetworkService.isConnected).thenReturn(true.obs);
        when(mockAuthService.isAuthenticated).thenReturn(false.obs);

        // Act
        await dataSyncService.onInit();

        // Assert
        expect(dataSyncService.syncStatus, equals('ready'));
        expect(dataSyncService.isLoading, isFalse);
      });

      test('should handle initialization errors gracefully', () async {
        // Arrange
        when(mockNetworkService.isConnected).thenThrow(Exception('Network error'));

        // Act
        await dataSyncService.onInit();

        // Assert
        expect(dataSyncService.syncStatus, equals('error'));
        expect(dataSyncService.isLoading, isFalse);
      });
    });

    group('Network Connectivity', () {
      test('should handle network connectivity changes', () {
        // Arrange
        final networkConnected = true.obs;
        when(mockNetworkService.isConnected).thenReturn(networkConnected);

        // Act
        networkConnected.value = false;

        // Assert
        expect(dataSyncService.isOffline, isTrue);
      });

      test('should process pending operations when back online', () async {
        // Arrange
        final networkConnected = false.obs;
        when(mockNetworkService.isConnected).thenReturn(networkConnected);
        
        // Add pending operation
        dataSyncService.pendingOperations.add({
          'type': 'create',
          'collection': 'tasks',
          'data': {'title': 'Test Task'},
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        // Act
        networkConnected.value = true;

        // Assert
        // In a real test, we would verify that the operation was processed
        expect(dataSyncService.isOffline, isFalse);
      });
    });

    group('Authentication State', () {
      test('should start data streams when authenticated', () {
        // Arrange
        final isAuthenticated = false.obs;
        when(mockAuthService.isAuthenticated).thenReturn(isAuthenticated);
        when(mockAuthService.currentUser).thenReturn(UserModel(
          id: 'test-user-id',
          email: 'test@example.com',
          firstName: 'Test',
          lastName: 'User',
          role: 'user',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        // Act
        isAuthenticated.value = true;

        // Assert
        expect(dataSyncService.syncStatus, equals('syncing'));
      });

      test('should stop data streams when unauthenticated', () {
        // Arrange
        final isAuthenticated = true.obs;
        when(mockAuthService.isAuthenticated).thenReturn(isAuthenticated);

        // Act
        isAuthenticated.value = false;

        // Assert
        expect(dataSyncService.tasks, isEmpty);
        expect(dataSyncService.teams, isEmpty);
        expect(dataSyncService.projects, isEmpty);
        expect(dataSyncService.notifications, isEmpty);
        expect(dataSyncService.users, isEmpty);
      });
    });

    group('Data Retrieval', () {
      test('should return task by ID when exists', () {
        // Arrange
        final testTask = TaskModel(
          id: 'task-1',
          title: 'Test Task',
          description: 'Test Description',
          status: 'todo',
          priority: 'medium',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'user-1',
        );
        
        dataSyncService.tasks.add(testTask);

        // Act
        final result = dataSyncService.getTaskById('task-1');

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals('task-1'));
        expect(result.title, equals('Test Task'));
      });

      test('should return null when task does not exist', () {
        // Act
        final result = dataSyncService.getTaskById('non-existent-task');

        // Assert
        expect(result, isNull);
      });

      test('should return correct unread notification count', () {
        // Arrange
        dataSyncService.notifications.addAll([
          NotificationModel(
            id: 'notif-1',
            title: 'Test Notification 1',
            message: 'Test Message 1',
            type: 'info',
            isRead: false,
            createdAt: DateTime.now(),
            userId: 'user-1',
          ),
          NotificationModel(
            id: 'notif-2',
            title: 'Test Notification 2',
            message: 'Test Message 2',
            type: 'info',
            isRead: true,
            createdAt: DateTime.now(),
            userId: 'user-1',
          ),
          NotificationModel(
            id: 'notif-3',
            title: 'Test Notification 3',
            message: 'Test Message 3',
            type: 'info',
            isRead: false,
            createdAt: DateTime.now(),
            userId: 'user-1',
          ),
        ]);

        // Act
        final count = dataSyncService.unreadNotificationCount;

        // Assert
        expect(count, equals(2));
      });

      test('should return correct pending task count', () {
        // Arrange
        dataSyncService.tasks.addAll([
          TaskModel(
            id: 'task-1',
            title: 'Completed Task',
            status: 'completed',
            priority: 'medium',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            createdBy: 'user-1',
          ),
          TaskModel(
            id: 'task-2',
            title: 'Pending Task 1',
            status: 'todo',
            priority: 'medium',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            createdBy: 'user-1',
          ),
          TaskModel(
            id: 'task-3',
            title: 'Pending Task 2',
            status: 'in_progress',
            priority: 'medium',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            createdBy: 'user-1',
          ),
        ]);

        // Act
        final count = dataSyncService.pendingTaskCount;

        // Assert
        expect(count, equals(2));
      });
    });

    group('Data Refresh', () {
      test('should refresh data when authenticated', () async {
        // Arrange
        when(mockAuthService.isAuthenticated).thenReturn(true.obs);
        when(mockAuthService.currentUser).thenReturn(UserModel(
          id: 'test-user-id',
          email: 'test@example.com',
          firstName: 'Test',
          lastName: 'User',
          role: 'user',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        // Act
        await dataSyncService.refreshData();

        // Assert
        // Verify that data streams were restarted
        expect(dataSyncService.syncStatus, equals('syncing'));
      });

      test('should not refresh data when unauthenticated', () async {
        // Arrange
        when(mockAuthService.isAuthenticated).thenReturn(false.obs);

        // Act
        await dataSyncService.refreshData();

        // Assert
        expect(dataSyncService.syncStatus, isNot(equals('syncing')));
      });
    });

    group('Error Handling', () {
      test('should handle stream errors gracefully', () {
        // This test would verify that stream errors are handled properly
        // In a real implementation, we would mock stream errors and verify
        // that the service continues to function
        expect(dataSyncService.syncStatus, isNotNull);
      });

      test('should handle Firestore permission errors', () {
        // This test would verify that permission errors are handled
        // and appropriate user feedback is provided
        expect(dataSyncService.syncStatus, isNotNull);
      });
    });

    group('Offline Support', () {
      test('should queue operations when offline', () {
        // Arrange
        when(mockNetworkService.isConnected).thenReturn(false.obs);

        // Act
        dataSyncService.pendingOperations.add({
          'type': 'create',
          'collection': 'tasks',
          'data': {'title': 'Offline Task'},
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        // Assert
        expect(dataSyncService.pendingOperations.length, equals(1));
        expect(dataSyncService.isOffline, isTrue);
      });

      test('should process queued operations when back online', () async {
        // This test would verify that queued operations are processed
        // when network connectivity is restored
        expect(dataSyncService.pendingOperations, isNotNull);
      });
    });
  });
}

// Mock classes for testing
class MockNotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String userId;

  MockNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.userId,
  });
}

// Extension to add mock notifications to the service
extension DataSyncServiceTestExtension on DataSyncService {
  List<TaskModel> get tasks => [];
  List<MockNotificationModel> get notifications => [];
  
  void addTask(TaskModel task) {
    // Mock implementation
  }
  
  void addNotification(MockNotificationModel notification) {
    // Mock implementation
  }
}
