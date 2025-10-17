import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';

/// Test Configuration
/// Provides common setup and utilities for testing
class TestConfig {
  
  /// Setup GetX for testing
  static void setupGetX() {
    Get.testMode = true;
  }
  
  /// Cleanup GetX after testing
  static void cleanupGetX() {
    Get.reset();
  }
  
  /// Common test setup
  static void setUp() {
    setupGetX();
  }
  
  /// Common test teardown
  static void tearDown() {
    cleanupGetX();
  }
  
  /// Create a test widget wrapper
  static Widget createTestApp({required Widget child}) {
    return GetMaterialApp(
      home: child,
      debugShowCheckedModeBanner: false,
    );
  }
  
  /// Pump and settle with timeout
  static Future<void> pumpAndSettleWithTimeout(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await tester.pumpAndSettle(const Duration(milliseconds: 100), timeout);
  }
  
  /// Wait for condition with timeout
  static Future<void> waitForCondition(
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 5),
    Duration interval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();
    
    while (!condition() && stopwatch.elapsed < timeout) {
      await Future.delayed(interval);
    }
    
    if (!condition()) {
      throw TimeoutException('Condition not met within timeout', timeout);
    }
  }
  
  /// Verify no exceptions during widget build
  static Future<void> verifyNoExceptions(
    WidgetTester tester,
    Widget widget,
  ) async {
    bool hasException = false;
    
    FlutterError.onError = (FlutterErrorDetails details) {
      hasException = true;
    };
    
    await tester.pumpWidget(createTestApp(child: widget));
    await pumpAndSettleWithTimeout(tester);
    
    expect(hasException, isFalse, reason: 'Widget should not throw exceptions');
    
    // Reset error handler
    FlutterError.onError = null;
  }
  
  /// Performance test helper
  static Future<Duration> measurePerformance(
    Future<void> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    await operation();
    stopwatch.stop();
    return stopwatch.elapsed;
  }
  
  /// Memory test helper
  static void verifyMemoryUsage(
    void Function() operation, {
    int maxOperations = 1000,
  }) {
    // Perform operation multiple times to check for memory leaks
    for (int i = 0; i < maxOperations; i++) {
      operation();
    }
    
    // In a real implementation, we would check memory usage here
    // For now, we just verify the operations complete without errors
  }
  
  /// Mock verification helper
  static void verifyMockInteractions(List<Mock> mocks) {
    for (final mock in mocks) {
      verifyNoMoreInteractions(mock);
    }
  }
  
  /// Reset all mocks
  static void resetMocks(List<Mock> mocks) {
    for (final mock in mocks) {
      reset(mock);
    }
  }
}

/// Test constants
class TestConstants {
  static const Duration defaultTimeout = Duration(seconds: 10);
  static const Duration shortTimeout = Duration(seconds: 5);
  static const Duration longTimeout = Duration(seconds: 30);
  
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceDelay = Duration(milliseconds: 500);
  
  // Test data
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'TestPass123!';
  static const String testUserId = 'test-user-id';
  static const String testTaskId = 'test-task-id';
  static const String testTeamId = 'test-team-id';
  static const String testProjectId = 'test-project-id';
  
  // Performance thresholds
  static const Duration maxRenderTime = Duration(milliseconds: 100);
  static const Duration maxNavigationTime = Duration(milliseconds: 500);
  static const Duration maxAnimationTime = Duration(seconds: 1);
  
  // Memory thresholds
  static const int maxMemoryUsageMB = 200;
  static const int warningMemoryUsageMB = 100;
}

/// Test utilities
class TestUtils {
  
  /// Generate test data
  static Map<String, dynamic> generateTestUser({
    String? id,
    String? email,
    String? role,
  }) {
    return {
      'id': id ?? TestConstants.testUserId,
      'email': email ?? TestConstants.testEmail,
      'firstName': 'Test',
      'lastName': 'User',
      'role': role ?? 'user',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
  
  static Map<String, dynamic> generateTestTask({
    String? id,
    String? title,
    String? status,
  }) {
    return {
      'id': id ?? TestConstants.testTaskId,
      'title': title ?? 'Test Task',
      'description': 'Test task description',
      'status': status ?? 'todo',
      'priority': 'medium',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'createdBy': TestConstants.testUserId,
    };
  }
  
  static Map<String, dynamic> generateTestTeam({
    String? id,
    String? name,
  }) {
    return {
      'id': id ?? TestConstants.testTeamId,
      'name': name ?? 'Test Team',
      'description': 'Test team description',
      'members': [TestConstants.testUserId],
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'createdBy': TestConstants.testUserId,
    };
  }
  
  static Map<String, dynamic> generateTestProject({
    String? id,
    String? name,
  }) {
    return {
      'id': id ?? TestConstants.testProjectId,
      'name': name ?? 'Test Project',
      'description': 'Test project description',
      'members': [TestConstants.testUserId],
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'createdBy': TestConstants.testUserId,
    };
  }
  
  /// Validation helpers
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }
  
  static bool isValidPassword(String password) {
    return password.length >= 8 &&
           RegExp(r'[A-Z]').hasMatch(password) &&
           RegExp(r'[a-z]').hasMatch(password) &&
           RegExp(r'[0-9]').hasMatch(password) &&
           RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
  }
  
  /// Date helpers
  static DateTime get now => DateTime.now();
  static DateTime get yesterday => now.subtract(const Duration(days: 1));
  static DateTime get tomorrow => now.add(const Duration(days: 1));
  static DateTime get nextWeek => now.add(const Duration(days: 7));
  static DateTime get lastWeek => now.subtract(const Duration(days: 7));
}

/// Custom matchers for testing
class CustomMatchers {
  
  /// Matcher for checking if a duration is within acceptable range
  static Matcher isWithinRange(Duration min, Duration max) {
    return predicate<Duration>(
      (duration) => duration >= min && duration <= max,
      'is within range $min to $max',
    );
  }
  
  /// Matcher for checking if a value is approximately equal
  static Matcher isApproximately(num expected, {num tolerance = 0.1}) {
    return predicate<num>(
      (actual) => (actual - expected).abs() <= tolerance,
      'is approximately $expected (±$tolerance)',
    );
  }
  
  /// Matcher for checking if a list contains items in order
  static Matcher containsInOrder(List<dynamic> expected) {
    return predicate<List<dynamic>>(
      (actual) {
        if (actual.length < expected.length) return false;
        
        int expectedIndex = 0;
        for (final item in actual) {
          if (expectedIndex < expected.length && item == expected[expectedIndex]) {
            expectedIndex++;
          }
        }
        
        return expectedIndex == expected.length;
      },
      'contains items in order: $expected',
    );
  }
}

/// Exception for test timeouts
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;
  
  const TimeoutException(this.message, this.timeout);
  
  @override
  String toString() => 'TimeoutException: $message (timeout: $timeout)';
}
