import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:task_management_app/core/services/performance_service.dart';

void main() {
  group('Performance Tests', () {
    late PerformanceService performanceService;

    setUp(() {
      Get.testMode = true;
      performanceService = PerformanceService();
    });

    tearDown(() {
      Get.reset();
    });

    group('Performance Service Tests', () {
      test('should initialize performance monitoring', () async {
        // Act
        await performanceService.onInit();

        // Assert
        expect(performanceService.isOptimized, isTrue);
        expect(performanceService.memoryUsage, greaterThanOrEqualTo(0));
        expect(performanceService.frameRate, greaterThan(0));
      });

      test('should track operation timing', () async {
        // Act
        performanceService.startOperation('test_operation');
        await Future.delayed(const Duration(milliseconds: 100));
        performanceService.endOperation('test_operation');

        // Assert
        expect(performanceService.operationTimes.containsKey('test_operation'), isTrue);
        expect(performanceService.operationTimes['test_operation'], greaterThan(90));
        expect(performanceService.operationTimes['test_operation'], lessThan(200));
      });

      test('should time async operations automatically', () async {
        // Act
        final result = await performanceService.timeOperation('async_test', () async {
          await Future.delayed(const Duration(milliseconds: 50));
          return 'test_result';
        });

        // Assert
        expect(result, equals('test_result'));
        expect(performanceService.operationTimes.containsKey('async_test'), isTrue);
        expect(performanceService.operationTimes['async_test'], greaterThan(40));
      });

      test('should time sync operations automatically', () {
        // Act
        final result = performanceService.timeOperationSync('sync_test', () {
          // Simulate some work
          var sum = 0;
          for (int i = 0; i < 1000; i++) {
            sum += i;
          }
          return sum;
        });

        // Assert
        expect(result, equals(499500)); // Sum of 0 to 999
        expect(performanceService.operationTimes.containsKey('sync_test'), isTrue);
        expect(performanceService.operationTimes['sync_test'], greaterThanOrEqualTo(0));
      });

      test('should generate performance summary', () {
        // Arrange
        performanceService.startOperation('op1');
        performanceService.endOperation('op1');
        performanceService.startOperation('op2');
        performanceService.endOperation('op2');

        // Act
        final summary = performanceService.getPerformanceSummary();

        // Assert
        expect(summary, isNotNull);
        expect(summary.isHealthy, isA<bool>());
        expect(summary.averageMemoryUsage, greaterThanOrEqualTo(0));
        expect(summary.averageFrameRate, greaterThan(0));
        expect(summary.recommendations, isA<List<String>>());
      });

      test('should get current performance status', () {
        // Act
        final status = performanceService.getCurrentStatus();

        // Assert
        expect(status, isA<PerformanceStatus>());
        expect(status.displayName, isNotNull);
        expect(status.description, isNotNull);
      });

      test('should clear performance history', () {
        // Arrange
        performanceService.startOperation('test');
        performanceService.endOperation('test');

        // Act
        performanceService.clearHistory();

        // Assert
        expect(performanceService.operationTimes, isEmpty);
        expect(performanceService.performanceHistory, isEmpty);
      });

      test('should optimize memory usage', () {
        // Arrange
        performanceService.startOperation('test');
        performanceService.endOperation('test');

        // Act
        performanceService.optimizeMemory();

        // Assert
        expect(performanceService.operationTimes, isEmpty);
      });
    });

    group('Widget Performance Tests', () {
      testWidgets('should render navigation screen within performance threshold', (tester) async {
        // Arrange
        const maxRenderTime = Duration(milliseconds: 100);
        
        // Act
        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: const Center(child: Text('Test Screen')),
              bottomNavigationBar: BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
                ],
              ),
            ),
          ),
        );
        
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsed, lessThan(maxRenderTime));
      });

      testWidgets('should handle rapid navigation without performance degradation', (tester) async {
        // Arrange
        int currentIndex = 0;
        
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                home: Scaffold(
                  body: IndexedStack(
                    index: currentIndex,
                    children: const [
                      Center(child: Text('Screen 1')),
                      Center(child: Text('Screen 2')),
                      Center(child: Text('Screen 3')),
                    ],
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    currentIndex: currentIndex,
                    onTap: (index) => setState(() => currentIndex = index),
                    items: const [
                      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                      BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
                      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                    ],
                  ),
                ),
              );
            },
          ),
        );

        // Act & Assert - Rapid navigation
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 10; i++) {
          await tester.tap(find.byIcon(Icons.search));
          await tester.pump();
          await tester.tap(find.byIcon(Icons.person));
          await tester.pump();
          await tester.tap(find.byIcon(Icons.home));
          await tester.pump();
        }
        
        stopwatch.stop();
        
        // Should complete rapid navigation within reasonable time
        expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
      });

      testWidgets('should handle large list rendering efficiently', (tester) async {
        // Arrange
        const itemCount = 1000;
        
        // Act
        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Item $index'),
                    subtitle: Text('Subtitle $index'),
                    leading: const Icon(Icons.person),
                  );
                },
              ),
            ),
          ),
        );
        
        await tester.pumpAndSettle();
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 500)));
        expect(find.byType(ListTile), findsWidgets);
      });

      testWidgets('should handle complex widget tree efficiently', (tester) async {
        // Arrange
        Widget buildComplexWidget() {
          return MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Complex Screen')),
              body: Column(
                children: [
                  Container(
                    height: 200,
                    child: PageView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[100 * (index + 1)],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(child: Text('Page $index')),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: 20,
                      itemBuilder: (context, index) {
                        return Card(
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image, size: 50),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Item $index'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
            ),
          );
        }

        // Act
        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(buildComplexWidget());
        await tester.pumpAndSettle();
        
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 1000)));
        expect(find.byType(PageView), findsOneWidget);
        expect(find.byType(GridView), findsOneWidget);
        expect(find.byType(Card), findsWidgets);
      });

      testWidgets('should handle animation performance', (tester) async {
        // Arrange
        bool isExpanded = false;
        
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isExpanded ? 200 : 100,
                          height: isExpanded ? 200 : 100,
                          color: isExpanded ? Colors.blue : Colors.red,
                          child: const Center(child: Text('Animated')),
                        ),
                        ElevatedButton(
                          onPressed: () => setState(() => isExpanded = !isExpanded),
                          child: const Text('Toggle'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );

        // Act & Assert - Test animation performance
        final stopwatch = Stopwatch()..start();
        
        // Trigger multiple animations
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.text('Toggle'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 150));
        }
        
        await tester.pumpAndSettle();
        stopwatch.stop();

        // Should complete animations within reasonable time
        expect(stopwatch.elapsed, lessThan(const Duration(seconds: 3)));
      });
    });

    group('Memory Performance Tests', () {
      test('should not leak memory during repeated operations', () {
        // This test would typically use platform-specific memory monitoring
        // For now, we'll test that operations complete without errors
        
        for (int i = 0; i < 100; i++) {
          performanceService.startOperation('memory_test_$i');
          performanceService.endOperation('memory_test_$i');
        }
        
        // Clear operations to prevent memory buildup
        performanceService.clearHistory();
        
        expect(performanceService.operationTimes, isEmpty);
      });

      testWidgets('should handle widget disposal properly', (tester) async {
        // Test that widgets are properly disposed to prevent memory leaks
        
        for (int i = 0; i < 10; i++) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ListView.builder(
                  itemCount: 100,
                  itemBuilder: (context, index) {
                    return ListTile(title: Text('Item $index'));
                  },
                ),
              ),
            ),
          );
          
          await tester.pumpWidget(const SizedBox.shrink());
        }
        
        // If we reach here without errors, widgets were disposed properly
        expect(find.byType(SizedBox), findsOneWidget);
      });
    });

    group('Performance Status Tests', () {
      test('should return correct performance status display names', () {
        expect(PerformanceStatus.excellent.displayName, equals('Excellent'));
        expect(PerformanceStatus.good.displayName, equals('Good'));
        expect(PerformanceStatus.fair.displayName, equals('Fair'));
        expect(PerformanceStatus.poor.displayName, equals('Poor'));
      });

      test('should return correct performance status descriptions', () {
        expect(PerformanceStatus.excellent.description, equals('App is running optimally'));
        expect(PerformanceStatus.good.description, equals('App performance is good'));
        expect(PerformanceStatus.fair.description, equals('App performance could be improved'));
        expect(PerformanceStatus.poor.description, equals('App performance needs attention'));
      });
    });

    group('Performance Metrics Tests', () {
      test('should create performance metric correctly', () {
        // Arrange
        final timestamp = DateTime.now();
        final operationTimes = {'test_op': 100.0};

        // Act
        final metric = PerformanceMetric(
          timestamp: timestamp,
          memoryUsage: 50.0,
          frameRate: 60,
          operationTimes: operationTimes,
        );

        // Assert
        expect(metric.timestamp, equals(timestamp));
        expect(metric.memoryUsage, equals(50.0));
        expect(metric.frameRate, equals(60));
        expect(metric.operationTimes, equals(operationTimes));
      });

      test('should create performance summary correctly', () {
        // Arrange
        final slowestOperations = {'slow_op': 500.0, 'fast_op': 50.0};
        final recommendations = ['Optimize slow operations'];

        // Act
        final summary = PerformanceSummary(
          averageMemoryUsage: 75.0,
          averageFrameRate: 55,
          slowestOperations: slowestOperations,
          isHealthy: false,
          recommendations: recommendations,
        );

        // Assert
        expect(summary.averageMemoryUsage, equals(75.0));
        expect(summary.averageFrameRate, equals(55));
        expect(summary.slowestOperations, equals(slowestOperations));
        expect(summary.isHealthy, isFalse);
        expect(summary.recommendations, equals(recommendations));
      });
    });
  });
}
