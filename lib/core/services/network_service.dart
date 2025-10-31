import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart' hide Response;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/app_constants.dart';
import 'error_handler_service.dart';
import 'storage_service.dart';

/// Centralized network service using Dio for HTTP requests
/// Includes connectivity checking, token management, and error handling
class NetworkService extends GetxService {
  static NetworkService get instance => Get.find<NetworkService>();
  
  late final dio.Dio _dio;
  late final Connectivity _connectivity;
  
  final RxBool _isConnected = true.obs;
  bool get isConnected => _isConnected.value;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeNetworkService();
    _setupConnectivityListener();
  }
  
  /// Initialize Dio and network configurations
  Future<void> _initializeNetworkService() async {
    try {
      _connectivity = Connectivity();
      
      // Initialize Dio with base configuration
      _dio = dio.Dio(dio.BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));
      
      // Add interceptors
      _setupInterceptors();
      
      // Check initial connectivity
      await _checkConnectivity();
      
      ErrorHandlerService.instance.logInfo('Network service initialized successfully');
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Network Service Initialization',
        severity: ErrorSeverity.critical,
      );
      rethrow;
    }
  }
  
  /// Setup Dio interceptors for request/response handling
  void _setupInterceptors() {
    // Request interceptor
    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add authentication token if available
        final token = StorageService.instance.getUserToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // Log request in debug mode
        ErrorHandlerService.instance.logDebug(
          'HTTP Request: ${options.method} ${options.path}',
          data: {
            'headers': options.headers,
            'data': options.data,
            'queryParameters': options.queryParameters,
          },
        );
        
        handler.next(options);
      },
      
      onResponse: (response, handler) {
        // Log response in debug mode
        ErrorHandlerService.instance.logDebug(
          'HTTP Response: ${response.statusCode} ${response.requestOptions.path}',
          data: {
            'statusCode': response.statusCode,
            'data': response.data,
          },
        );
        
        handler.next(response);
      },
      
      onError: (error, handler) async {
        // Handle different types of errors
        final processedError = await _handleDioError(error);
        handler.next(processedError);
      },
    ));
    
    // Add retry interceptor for failed requests
    _dio.interceptors.add(RetryInterceptor());
  }
  
  /// Handle Dio errors and convert to custom exceptions
  Future<dio.DioException> _handleDioError(dio.DioException error) async {
    String message;
    
    switch (error.type) {
      case dio.DioExceptionType.connectionTimeout:
      case dio.DioExceptionType.sendTimeout:
      case dio.DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case dio.DioExceptionType.badResponse:
        message = _handleHttpError(error.response?.statusCode, error.response?.data);
        break;
      case dio.DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case dio.DioExceptionType.connectionError:
        message = 'Connection error. Please check your internet connection.';
        break;
      case dio.DioExceptionType.badCertificate:
        message = 'Certificate error. Please check your connection security.';
        break;
      case dio.DioExceptionType.unknown:
      default:
        message = 'An unexpected network error occurred.';
        break;
    }
    
    // Log the error
    ErrorHandlerService.instance.handleError(
      NetworkException(message, statusCode: error.response?.statusCode),
      stackTrace: error.stackTrace,
      context: 'Network Request: ${error.requestOptions.method} ${error.requestOptions.path}',
      severity: ErrorSeverity.medium,
      showToUser: false, // We'll handle this in the calling code
    );
    
    return error;
  }
  
  /// Handle HTTP status code errors
  String _handleHttpError(int? statusCode, dynamic responseData) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access forbidden. You don\'t have permission.';
      case 404:
        return 'Resource not found.';
      case 422:
        return 'Validation error. Please check your input.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. Server is temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'Server error occurred. Please try again.';
    }
  }
  
  /// Setup connectivity listener
  void _setupConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _isConnected.value = result != ConnectivityResult.none;
      
      if (_isConnected.value) {
        ErrorHandlerService.instance.logInfo('Internet connection restored');
      } else {
        ErrorHandlerService.instance.logWarning('Internet connection lost');
      }
    });
  }
  
  /// Check current connectivity status
  Future<bool> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isConnected.value = result != ConnectivityResult.none;
      return _isConnected.value;
    } catch (e) {
      _isConnected.value = false;
      return false;
    }
  }
  
  /// Ensure internet connectivity before making requests
  Future<void> _ensureConnectivity() async {
    if (!_isConnected.value) {
      await _checkConnectivity();
    }
    
    if (!_isConnected.value) {
      throw NetworkException('No internet connection available');
    }
  }
  
  // ==================== HTTP METHODS ====================
  
  /// GET request
  Future<dio.Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
  }) async {
    await _ensureConnectivity();
    
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  /// POST request
  Future<dio.Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
  }) async {
    await _ensureConnectivity();
    
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  /// PUT request
  Future<dio.Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
  }) async {
    await _ensureConnectivity();
    
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  /// PATCH request
  Future<dio.Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
  }) async {
    await _ensureConnectivity();
    
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  /// DELETE request
  Future<dio.Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
  }) async {
    await _ensureConnectivity();
    
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Upload file
  Future<dio.Response<T>> uploadFile<T>(
    String path,
    File file, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    dio.ProgressCallback? onSendProgress,
    dio.CancelToken? cancelToken,
  }) async {
    await _ensureConnectivity();
    
    try {
      final fileName = file.path.split('/').last;
      final formData = dio.FormData.fromMap({
        fieldName: await dio.MultipartFile.fromFile(file.path, filename: fileName),
        ...?additionalData,
      });
      
      final response = await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Download file
  Future<dio.Response> downloadFile(
    String url,
    String savePath, {
    dio.ProgressCallback? onReceiveProgress,
    dio.CancelToken? cancelToken,
  }) async {
    await _ensureConnectivity();
    
    try {
      final response = await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // ==================== UTILITY METHODS ====================
  
  /// Update base URL
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
    ErrorHandlerService.instance.logInfo('Base URL updated to: $baseUrl');
  }
  
  /// Update authentication token
  void updateAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    ErrorHandlerService.instance.logInfo('Auth token updated');
  }
  
  /// Remove authentication token
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
    ErrorHandlerService.instance.logInfo('Auth token removed');
  }
  
  /// Add custom header
  void addHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }
  
  /// Remove custom header
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }
  
  /// Clear all custom headers
  void clearHeaders() {
    _dio.options.headers.clear();
    _dio.options.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });
  }
  
  /// Cancel all pending requests
  void cancelAllRequests([String? reason]) {
    _dio.close(force: true);
    ErrorHandlerService.instance.logInfo('All network requests cancelled: ${reason ?? 'No reason provided'}');
  }
}

/// Retry interceptor for failed requests
class RetryInterceptor extends dio.Interceptor {
  final int maxRetries;
  final Duration retryDelay;
  
  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });
  
  @override
  void onError(dio.DioException err, dio.ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err) && err.requestOptions.extra['retryCount'] == null) {
      err.requestOptions.extra['retryCount'] = 0;
    }
    
    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
    
    if (retryCount < maxRetries && _shouldRetry(err)) {
      err.requestOptions.extra['retryCount'] = retryCount + 1;
      
      // Wait before retrying
      await Future.delayed(retryDelay * (retryCount + 1));
      
      try {
        final response = await Dio().fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // Continue with the original error if retry fails
      }
    }
    
    handler.next(err);
  }
  
  bool _shouldRetry(dio.DioException err) {
    return err.type == dio.DioExceptionType.connectionTimeout ||
           err.type == dio.DioExceptionType.sendTimeout ||
           err.type == dio.DioExceptionType.receiveTimeout ||
           err.type == dio.DioExceptionType.connectionError ||
           (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}
