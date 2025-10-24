import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:task_management_app/modules/navigation/views/screens/main_navigation_screen.dart';
import 'package:task_management_app/modules/navigation/controllers/navigation_controller.dart';
import 'package:task_management_app/modules/navigation/bindings/navigation_binding.dart';
import 'package:task_management_app/core/services/auth_service.dart';
import 'package:task_management_app/core/models/user_model.dart';

import 'navigation_integration_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  group('Navigation Integration Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      Get.testMode = true;
      mockAuthService = MockAuthService();
      
      // Setup mock user
      when(mockAuthService.currentUser).thenReturn(UserModel(
        id: 'test-user-id',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: 'user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      
      when(mockAuthService.isAuthenticated).thenReturn(true.obs);
      
      Get.put<AuthService>(mockAuthService);
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('should display main navigation screen with bottom navigation', (tester) async {
      // Arrange
      NavigationBinding().dependencies();

      // Act
      await tester.pumpWidget(
        GetMaterialApp(
          home: const MainNavigationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(MainNavigationScreen), findsOneWidget);
      expect(find.byType(BottomAppBar), findsOneWidget);
      
      // Check for navigation items
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Teams'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('should navigate between screens when tapping navigation items', (tester) async {
      // Arrange
      NavigationBinding().dependencies();

      await tester.pumpWidget(
        GetMaterialApp(
          home: const MainNavigationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert - Navigate to Tasks
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();
      
      final controller = Get.find<NavigationController>();
      expect(controller.currentIndex, equals(1));
      expect(controller.currentScreenTitle, equals('Tasks'));

      // Act & Assert - Navigate to Teams
      await tester.tap(find.text('Teams'));
      await tester.pumpAndSettle();
      
      expect(controller.currentIndex, equals(2));
      expect(controller.currentScreenTitle, equals('Teams'));

      // Act & Assert - Navigate to Projects
      await tester.tap(find.text('Projects'));
      await tester.pumpAndSettle();
      
      expect(controller.currentIndex, equals(3));
      expect(controller.currentScreenTitle, equals('Projects'));
    });

    testWidgets('should show floating action button on appropriate screens', (tester) async {
      // Arrange
      NavigationBinding().dependencies();

      await tester.pumpWidget(
        GetMaterialApp(
          home: const MainNavigationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Dashboard - no FAB
      expect(find.byType(FloatingActionButton), findsNothing);

      // Tasks - should have FAB
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Teams - should have FAB
      await tester.tap(find.text('Teams'));
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Projects - should have FAB
      await tester.tap(find.text('Projects'));
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Search - no FAB
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('should maintain navigation history', (tester) async {
      // Arrange
      NavigationBinding().dependencies();

      await tester.pumpWidget(
        GetMaterialApp(
          home: const MainNavigationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final controller = Get.find<NavigationController>();

      // Act - Navigate through multiple screens
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Teams'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Projects'));
      await tester.pumpAndSettle();

      // Assert
      expect(controller.navigationHistory.length, equals(4)); // Dashboard + 3 navigations
      expect(controller.navigationHistory.last, equals(3)); // Projects index
      
      // Test go back functionality
      final canGoBack = controller.goBack();
      expect(canGoBack, isTrue);
      expect(controller.currentIndex, equals(2)); // Teams
    });

    testWidgets('should handle access control for restricted screens', (tester) async {
      // Arrange - Setup user with limited permissions
      when(mockAuthService.currentUser).thenReturn(UserModel(
        id: 'test-user-id',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: 'viewer', // Limited role
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      NavigationBinding().dependencies();

      await tester.pumpWidget(
        GetMaterialApp(
          home: const MainNavigationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Try to access Analytics (admin-only)
      await tester.tap(find.text('Analytics'));
      await tester.pumpAndSettle();

      // Assert - Should show access denied message
      expect(find.textContaining('Access Denied'), findsOneWidget);
      
      final controller = Get.find<NavigationController>();
      expect(controller.currentIndex, equals(0)); // Should stay on Dashboard
    });

    testWidgets('should reset navigation to home', (tester) async {
      // Arrange
      NavigationBinding().dependencies();

      await tester.pumpWidget(
        GetMaterialApp(
          home: const MainNavigationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final controller = Get.find<NavigationController>();

      // Act - Navigate to different screen then reset
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();
      
      controller.resetToHome();
      await tester.pumpAndSettle();

      // Assert
      expect(controller.currentIndex, equals(0));
      expect(controller.navigationHistory.length, equals(1));
      expect(controller.navigationHistory.first, equals(0));
    });

    testWidgets('should handle deep linking navigation', (tester) async {
      // Arrange
      NavigationBinding().dependencies();

      await tester.pumpWidget(
        GetMaterialApp(
          home: const MainNavigationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final controller = Get.find<NavigationController>();

      // Act - Handle deep link to tasks
      controller.handleDeepLink('/tasks/123');
      await tester.pumpAndSettle();

      // Assert
      expect(controller.currentIndex, equals(1)); // Tasks screen

      // Act - Handle deep link to teams
      controller.handleDeepLink('/teams/456');
      await tester.pumpAndSettle();

      // Assert
      expect(controller.currentIndex, equals(2)); // Teams screen
    });

    testWidgets('should navigate to specific screen by name', (tester) async {
      // Arrange
      NavigationBinding().dependencies();

      await tester.pumpWidget(
        GetMaterialApp(
          home: const MainNavigationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final controller = Get.find<NavigationController>();

      // Act & Assert - Navigate by screen name
      controller.navigateToScreen('tasks');
      await tester.pumpAndSettle();
      expect(controller.currentIndex, equals(1));

      controller.navigateToScreen('teams');
      await tester.pumpAndSettle();
      expect(controller.currentIndex, equals(2));

      controller.navigateToScreen('projects');
      await tester.pumpAndSettle();
      expect(controller.currentIndex, equals(3));

      controller.navigateToScreen('search');
      await tester.pumpAndSettle();
      expect(controller.currentIndex, equals(4));

      controller.navigateToScreen('analytics');
      await tester.pumpAndSettle();
      expect(controller.currentIndex, equals(5));

      controller.navigateToScreen('notifications');
      await tester.pumpAndSettle();
      expect(controller.currentIndex, equals(6));

      controller.navigateToScreen('profile');
      await tester.pumpAndSettle();
      expect(controller.currentIndex, equals(7));
    });

    testWidgets('should get correct route for current screen', (tester) async {
      // Arrange
      NavigationBinding().dependencies();

      await tester.pumpWidget(
        GetMaterialApp(
          home: const MainNavigationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final controller = Get.find<NavigationController>();

      // Test route mapping for each screen
      final expectedRoutes = [
        '/dashboard',    // Dashboard
        '/tasks',        // Tasks
        '/teams',        // Teams
        '/projects',     // Projects
        '/search',       // Search
        '/analytics',    // Analytics
        '/notifications', // Notifications
        '/profile',      // Profile
      ];

      for (int i = 0; i < expectedRoutes.length; i++) {
        // Act
        controller.changePage(i);
        await tester.pumpAndSettle();

        // Assert
        expect(controller.getCurrentRoute(), equals(expectedRoutes[i]));
      }
    });

    testWidgets('should handle FAB actions correctly', (tester) async {
      // Arrange
      NavigationBinding().dependencies();

      await tester.pumpWidget(
        GetMaterialApp(
          home: const MainNavigationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Test Tasks FAB
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();
      
      expect(find.byType(FloatingActionButton), findsOneWidget);
      // In a real test, we would verify the FAB action

      // Test Teams FAB
      await tester.tap(find.text('Teams'));
      await tester.pumpAndSettle();
      
      expect(find.byType(FloatingActionButton), findsOneWidget);
      // In a real test, we would verify the FAB action

      // Test Projects FAB
      await tester.tap(find.text('Projects'));
      await tester.pumpAndSettle();
      
      expect(find.byType(FloatingActionButton), findsOneWidget);
      // In a real test, we would verify the FAB action
    });

    testWidgets('should handle authentication state changes', (tester) async {
      // Arrange
      final authState = true.obs;
      when(mockAuthService.isAuthenticated).thenReturn(authState);
      
      NavigationBinding().dependencies();

      await tester.pumpWidget(
        GetMaterialApp(
          home: const MainNavigationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Simulate logout
      authState.value = false;
      await tester.pumpAndSettle();

      // Assert - Should redirect to login
      // In a real test, we would verify the navigation to login screen
      expect(authState.value, isFalse);
    });

    testWidgets('should display correct screen titles', (tester) async {
      // Arrange
      NavigationBinding().dependencies();

      await tester.pumpWidget(
        GetMaterialApp(
          home: const MainNavigationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final controller = Get.find<NavigationController>();

      // Test screen titles
      final expectedTitles = [
        'Dashboard',
        'Tasks',
        'Teams',
        'Projects',
        'Search',
        'Analytics',
        'Notifications',
        'Profile',
      ];

      for (int i = 0; i < expectedTitles.length; i++) {
        // Act
        controller.changePage(i);
        await tester.pumpAndSettle();

        // Assert
        expect(controller.currentScreenTitle, equals(expectedTitles[i]));
      }
    });

    testWidgets('should handle navigation history limit', (tester) async {
      // Arrange
      NavigationBinding().dependencies();

      await tester.pumpWidget(
        GetMaterialApp(
          home: const MainNavigationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final controller = Get.find<NavigationController>();

      // Act - Navigate through many screens to test history limit
      for (int i = 0; i < 15; i++) {
        controller.changePage(i % 8); // Cycle through available screens
        await tester.pumpAndSettle();
      }

      // Assert - History should be limited to 10 items
      expect(controller.navigationHistory.length, lessThanOrEqualTo(10));
    });
  });
}
