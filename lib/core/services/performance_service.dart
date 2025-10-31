import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Performance Optimization Service
/// Manages app performance, memory usage, and optimization
class PerformanceService extends GetxService {
  
  // Performance metrics
  final RxDouble _memoryUsage = 0.0.obs;
  final RxInt _frameRate = 60.obs;
  final RxBool _isOptimized = true.obs;
  final RxMap<String, double> _operationTimes = <String, double>{}.obs;
  
  // Performance monitoring
  Timer? _performanceTimer;
  final Map<String, Stopwatch> _activeOperations = {};
  final List<PerformanceMetric> _performanceHistory = [];
  
  // Getters
  double get memoryUsage => _memoryUsage.value;
  int get frameRate => _frameRate.value;
  bool get isOptimized => _isOptimized.value;
  Map<String, double> get operationTimes => _operationTimes;
  List<PerformanceMetric> get performanceHistory => _performanceHistory;
  
  // Configuration
  static const int maxHistorySize = 100;
  static const Duration monitoringInterval = Duration(seconds: 5);
  static const double memoryWarningThreshold = 100.0; // MB
  static const double memoryErrorThreshold = 200.0; // MB
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializePerformanceMonitoring();
  }
  
  /// Initialize performance monitoring
  Future<void> _initializePerformanceMonitoring() async {
    if (kDebugMode) {
      _startPerformanceMonitoring();
    }
  }
  
  /// Start performance monitoring
  void _startPerformanceMonitoring() {
    _performanceTimer = Timer.periodic(monitoringInterval, (timer) {
      _collectPerformanceMetrics();
    });
  }
  
  /// Collect performance metrics
  void _collectPerformanceMetrics() {
    try {
      // Collect memory usage (simplified - in real app would use platform channels)
      final memoryUsage = _estimateMemoryUsage();
      _memoryUsage.value = memoryUsage;
      
      // Create performance metric
      final metric = PerformanceMetric(
        timestamp: DateTime.now(),
        memoryUsage: memoryUsage,
        frameRate: _frameRate.value,
        operationTimes: Map.from(_operationTimes),
      );
      
      // Add to history
      _performanceHistory.add(metric);
      
      // Limit history size
      if (_performanceHistory.length > maxHistorySize) {
        _performanceHistory.removeAt(0);
      }
      
      // Check performance health
      _checkPerformanceHealth(metric);
      
    } catch (e) {
      developer.log('Error collecting performance metrics: $e');
    }
  }
  
  /// Estimate memory usage (simplified implementation)
  double _estimateMemoryUsage() {
    // In a real implementation, this would use platform-specific APIs
    // For now, return a simulated value
    return 50.0 + (DateTime.now().millisecondsSinceEpoch % 100);
  }
  
  /// Check performance health
  void _checkPerformanceHealth(PerformanceMetric metric) {
    bool isHealthy = true;
    
    // Check memory usage
    if (metric.memoryUsage > memoryErrorThreshold) {
      isHealthy = false;
      _handlePerformanceIssue('Critical memory usage: ${metric.memoryUsage.toStringAsFixed(1)}MB');
    } else if (metric.memoryUsage > memoryWarningThreshold) {
      _handlePerformanceWarning('High memory usage: ${metric.memoryUsage.toStringAsFixed(1)}MB');
    }
    
    // Check frame rate
    if (metric.frameRate < 30) {
      isHealthy = false;
      _handlePerformanceIssue('Low frame rate: ${metric.frameRate}fps');
    } else if (metric.frameRate < 45) {
      _handlePerformanceWarning('Reduced frame rate: ${metric.frameRate}fps');
    }
    
    // Check operation times
    for (final entry in metric.operationTimes.entries) {
      if (entry.value > 1000) { // 1 second
        isHealthy = false;
        _handlePerformanceIssue('Slow operation: ${entry.key} took ${entry.value.toStringAsFixed(0)}ms');
      } else if (entry.value > 500) { // 500ms
        _handlePerformanceWarning('Slow operation: ${entry.key} took ${entry.value.toStringAsFixed(0)}ms');
      }
    }
    
    _isOptimized.value = isHealthy;
  }
  
  /// Handle performance issue
  void _handlePerformanceIssue(String message) {
    developer.log('Performance Issue: $message', level: 1000);
    
    if (kDebugMode) {
      print('🔴 Performance Issue: $message');
    }
  }
  
  /// Handle performance warning
  void _handlePerformanceWarning(String message) {
    developer.log('Performance Warning: $message', level: 900);
    
    if (kDebugMode) {
      print('🟡 Performance Warning: $message');
    }
  }
  
  // ==================== PUBLIC API ====================
  
  /// Start timing an operation
  void startOperation(String operationName) {
    final stopwatch = Stopwatch()..start();
    _activeOperations[operationName] = stopwatch;
  }
  
  /// End timing an operation
  void endOperation(String operationName) {
    final stopwatch = _activeOperations.remove(operationName);
    if (stopwatch != null) {
      stopwatch.stop();
      final duration = stopwatch.elapsedMilliseconds.toDouble();
      _operationTimes[operationName] = duration;
      
      if (kDebugMode && duration > 100) {
        print('⏱️ Operation "$operationName" took ${duration.toStringAsFixed(0)}ms');
      }
    }
  }
  
  /// Time an operation with automatic cleanup
  Future<T> timeOperation<T>(String operationName, Future<T> Function() operation) async {
    startOperation(operationName);
    try {
      final result = await operation();
      return result;
    } finally {
      endOperation(operationName);
    }
  }
  
  /// Time a synchronous operation
  T timeOperationSync<T>(String operationName, T Function() operation) {
    startOperation(operationName);
    try {
      final result = operation();
      return result;
    } finally {
      endOperation(operationName);
    }
  }
  
  /// Get performance summary
  PerformanceSummary getPerformanceSummary() {
    if (_performanceHistory.isEmpty) {
      return PerformanceSummary(
        averageMemoryUsage: 0,
        averageFrameRate: 60,
        slowestOperations: {},
        isHealthy: true,
        recommendations: [],
      );
    }
    
    final recentMetrics = _performanceHistory.take(20).toList();
    
    final avgMemory = recentMetrics
        .map((m) => m.memoryUsage)
        .reduce((a, b) => a + b) / recentMetrics.length;
    
    final avgFrameRate = recentMetrics
        .map((m) => m.frameRate)
        .reduce((a, b) => a + b) / recentMetrics.length;
    
    // Find slowest operations
    final allOperations = <String, List<double>>{};
    for (final metric in recentMetrics) {
      for (final entry in metric.operationTimes.entries) {
        allOperations.putIfAbsent(entry.key, () => []).add(entry.value);
      }
    }
    
    final slowestOperations = <String, double>{};
    for (final entry in allOperations.entries) {
      final avgTime = entry.value.reduce((a, b) => a + b) / entry.value.length;
      slowestOperations[entry.key] = avgTime;
    }
    
    // Sort by time
    final sortedOperations = Map.fromEntries(
      slowestOperations.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
    );
    
    // Generate recommendations
    final recommendations = <String>[];
    
    if (avgMemory > memoryWarningThreshold) {
      recommendations.add('Consider reducing memory usage by optimizing data structures');
    }
    
    if (avgFrameRate < 50) {
      recommendations.add('Optimize UI rendering to improve frame rate');
    }
    
    if (sortedOperations.isNotEmpty && sortedOperations.values.first > 200) {
      recommendations.add('Optimize slow operations: ${sortedOperations.keys.first}');
    }
    
    final isHealthy = avgMemory < memoryWarningThreshold && 
                     avgFrameRate >= 50 && 
                     (sortedOperations.isEmpty || sortedOperations.values.first < 500);
    
    return PerformanceSummary(
      averageMemoryUsage: avgMemory,
      averageFrameRate: avgFrameRate.round(),
      slowestOperations: Map.fromEntries(sortedOperations.entries.take(5)),
      isHealthy: isHealthy,
      recommendations: recommendations,
    );
  }
  
  /// Clear performance history
  void clearHistory() {
    _performanceHistory.clear();
    _operationTimes.clear();
  }
  
  /// Force garbage collection (if available)
  void forceGarbageCollection() {
    if (kDebugMode) {
      // In debug mode, we can suggest garbage collection
      developer.log('Suggesting garbage collection');
    }
  }
  
  /// Optimize memory usage
  void optimizeMemory() {
    // Clear caches and temporary data
    _operationTimes.clear();
    
    // Limit performance history
    if (_performanceHistory.length > 50) {
      _performanceHistory.removeRange(0, _performanceHistory.length - 50);
    }
    
    // Force garbage collection
    forceGarbageCollection();
    
    developer.log('Memory optimization completed');
  }
  
  /// Get current performance status
  PerformanceStatus getCurrentStatus() {
    final summary = getPerformanceSummary();
    
    if (!summary.isHealthy) {
      return PerformanceStatus.poor;
    } else if (summary.averageMemoryUsage > memoryWarningThreshold * 0.7 || 
               summary.averageFrameRate < 55) {
      return PerformanceStatus.fair;
    } else {
      return PerformanceStatus.excellent;
    }
  }
  
  @override
  void onClose() {
    _performanceTimer?.cancel();
    _activeOperations.clear();
    super.onClose();
  }
}

/// Performance metric data class
class PerformanceMetric {
  final DateTime timestamp;
  final double memoryUsage;
  final int frameRate;
  final Map<String, double> operationTimes;
  
  PerformanceMetric({
    required this.timestamp,
    required this.memoryUsage,
    required this.frameRate,
    required this.operationTimes,
  });
}

/// Performance summary data class
class PerformanceSummary {
  final double averageMemoryUsage;
  final int averageFrameRate;
  final Map<String, double> slowestOperations;
  final bool isHealthy;
  final List<String> recommendations;
  
  PerformanceSummary({
    required this.averageMemoryUsage,
    required this.averageFrameRate,
    required this.slowestOperations,
    required this.isHealthy,
    required this.recommendations,
  });
}

/// Performance status enum
enum PerformanceStatus {
  excellent,
  good,
  fair,
  poor,
}

/// Extension for performance status
extension PerformanceStatusExtension on PerformanceStatus {
  String get displayName {
    switch (this) {
      case PerformanceStatus.excellent:
        return 'Excellent';
      case PerformanceStatus.good:
        return 'Good';
      case PerformanceStatus.fair:
        return 'Fair';
      case PerformanceStatus.poor:
        return 'Poor';
    }
  }
  
  String get description {
    switch (this) {
      case PerformanceStatus.excellent:
        return 'App is running optimally';
      case PerformanceStatus.good:
        return 'App performance is good';
      case PerformanceStatus.fair:
        return 'App performance could be improved';
      case PerformanceStatus.poor:
        return 'App performance needs attention';
    }
  }
}
