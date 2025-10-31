import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../constants/app_constants.dart';
import '../constants/strings.dart';

/// Centralized error handling service for the application
/// Handles logging, crash reporting, and user-friendly error messages
class ErrorHandlerService extends GetxService {
  static ErrorHandlerService get instance => Get.find<ErrorHandlerService>();
  
  late final Logger _logger;
  late final FirebaseCrashlytics _crashlytics;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeLogger();
    await _initializeCrashlytics();
  }
  
  /// Initialize logger with custom configuration
  Future<void> _initializeLogger() async {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      level: kDebugMode ? Level.debug : Level.info,
    );
  }
  
  /// Initialize Firebase Crashlytics
  Future<void> _initializeCrashlytics() async {
    _crashlytics = FirebaseCrashlytics.instance;
    
    // Enable crashlytics collection in release mode
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
    
    // Set up Flutter error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      recordFlutterError(details);
    };
    
    // Set up platform error handling
    PlatformDispatcher.instance.onError = (error, stack) {
      recordError(error, stack, context: 'Platform Error');
      return true;
    };
  }
  
  /// Log and handle different types of errors
  void handleError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? additionalData,
    bool showToUser = true,
    ErrorSeverity severity = ErrorSeverity.medium,
  }) {
    final errorInfo = _processError(error, stackTrace, context, additionalData);
    
    // Log error based on severity
    switch (severity) {
      case ErrorSeverity.low:
        _logger.i(errorInfo.message, errorInfo.error, errorInfo.stackTrace);
        break;
      case ErrorSeverity.medium:
        _logger.w(errorInfo.message, errorInfo.error, errorInfo.stackTrace);
        break;
      case ErrorSeverity.high:
        _logger.e(errorInfo.message, errorInfo.error, errorInfo.stackTrace);
        break;
      case ErrorSeverity.critical:
        _logger.f(errorInfo.message, errorInfo.error, errorInfo.stackTrace);
        break;
    }
    
    // Record to crashlytics for medium and above
    if (severity.index >= ErrorSeverity.medium.index) {
      recordError(errorInfo.error, errorInfo.stackTrace, context: errorInfo.context);
    }
    
    // Show user-friendly message
    if (showToUser) {
      _showUserFriendlyError(errorInfo);
    }
  }
  
  /// Process error and extract relevant information
  ErrorInfo _processError(
    dynamic error,
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? additionalData,
  ) {
    String message;
    String userMessage;
    
    if (error is NetworkException) {
      message = 'Network Error: ${error.message}';
      userMessage = AppStrings.networkError;
    } else if (error is AuthException) {
      message = 'Auth Error: ${error.message}';
      userMessage = AppStrings.authError;
    } else if (error is ValidationException) {
      message = 'Validation Error: ${error.message}';
      userMessage = error.message;
    } else if (error is PermissionException) {
      message = 'Permission Error: ${error.message}';
      userMessage = AppStrings.permissionError;
    } else if (error is ServerException) {
      message = 'Server Error: ${error.message}';
      userMessage = AppStrings.serverError;
    } else {
      message = 'Unexpected Error: ${error.toString()}';
      userMessage = 'An unexpected error occurred. Please try again.';
    }
    
    return ErrorInfo(
      error: error,
      stackTrace: stackTrace ?? StackTrace.current,
      message: message,
      userMessage: userMessage,
      context: context ?? 'Unknown Context',
      additionalData: additionalData ?? {},
      timestamp: DateTime.now(),
    );
  }
  
  /// Show user-friendly error message
  void _showUserFriendlyError(ErrorInfo errorInfo) {
    Get.snackbar(
      'Error',
      errorInfo.userMessage,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.errorContainer,
      colorText: Get.theme.colorScheme.onErrorContainer,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      isDismissible: true,
    );
  }
  
  /// Record error to Firebase Crashlytics
  void recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    try {
      _crashlytics.recordError(
        error,
        stackTrace,
        reason: context,
        information: additionalData?.entries.map((e) => '${e.key}: ${e.value}').toList() ?? [],
        fatal: false,
      );
    } catch (e) {
      _logger.e('Failed to record error to Crashlytics: $e');
    }
  }
  
  /// Record Flutter-specific errors
  void recordFlutterError(FlutterErrorDetails details) {
    try {
      _crashlytics.recordFlutterFatalError(details);
    } catch (e) {
      _logger.e('Failed to record Flutter error to Crashlytics: $e');
    }
  }
  
  /// Set user identifier for crash reports
  void setUserIdentifier(String userId, {String? email, String? name}) {
    try {
      _crashlytics.setUserIdentifier(userId);
      if (email != null) _crashlytics.setCustomKey('user_email', email);
      if (name != null) _crashlytics.setCustomKey('user_name', name);
    } catch (e) {
      _logger.e('Failed to set user identifier: $e');
    }
  }
  
  /// Set custom key-value pairs for crash reports
  void setCustomKey(String key, dynamic value) {
    try {
      _crashlytics.setCustomKey(key, value);
    } catch (e) {
      _logger.e('Failed to set custom key: $e');
    }
  }
  
  /// Log custom events for analytics
  void logEvent(String event, {Map<String, dynamic>? parameters}) {
    try {
      _crashlytics.log('Event: $event ${parameters != null ? '- $parameters' : ''}');
      _logger.i('Event logged: $event', null, null);
    } catch (e) {
      _logger.e('Failed to log event: $e');
    }
  }
  
  /// Debug logging methods
  void logDebug(String message, {dynamic data}) {
    if (kDebugMode) {
      _logger.d(message, data, null);
    }
  }
  
  void logInfo(String message, {dynamic data}) {
    _logger.i(message, data, null);
  }
  
  void logWarning(String message, {dynamic data}) {
    _logger.w(message, data, null);
  }
  
  void logError(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error, stackTrace);
  }
}

/// Error severity levels
enum ErrorSeverity { low, medium, high, critical }

/// Error information container
class ErrorInfo {
  final dynamic error;
  final StackTrace stackTrace;
  final String message;
  final String userMessage;
  final String context;
  final Map<String, dynamic> additionalData;
  final DateTime timestamp;
  
  ErrorInfo({
    required this.error,
    required this.stackTrace,
    required this.message,
    required this.userMessage,
    required this.context,
    required this.additionalData,
    required this.timestamp,
  });
}

/// Custom exception classes
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  
  NetworkException(this.message, {this.statusCode});
  
  @override
  String toString() => 'NetworkException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class AuthException implements Exception {
  final String message;
  final String? code;
  
  AuthException(this.message, {this.code});
  
  @override
  String toString() => 'AuthException: $message${code != null ? ' (Code: $code)' : ''}';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;
  
  ValidationException(this.message, {this.fieldErrors});
  
  @override
  String toString() => 'ValidationException: $message';
}

class PermissionException implements Exception {
  final String message;
  final String? requiredPermission;
  
  PermissionException(this.message, {this.requiredPermission});
  
  @override
  String toString() => 'PermissionException: $message';
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final String? serverMessage;
  
  ServerException(this.message, {this.statusCode, this.serverMessage});
  
  @override
  String toString() => 'ServerException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
