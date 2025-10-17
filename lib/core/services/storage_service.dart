import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'error_handler_service.dart';

/// Centralized storage service for local data persistence
/// Supports both GetStorage (fast) and SharedPreferences (reliable)
class StorageService extends GetxService {
  static StorageService get instance => Get.find<StorageService>();
  
  late final GetStorage _getStorage;
  late final SharedPreferences _sharedPreferences;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeStorage();
  }
  
  /// Initialize storage systems
  Future<void> _initializeStorage() async {
    try {
      // Initialize GetStorage
      await GetStorage.init();
      _getStorage = GetStorage();
      
      // Initialize SharedPreferences
      _sharedPreferences = await SharedPreferences.getInstance();
      
      ErrorHandlerService.instance.logInfo('Storage services initialized successfully');
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Storage Initialization',
        severity: ErrorSeverity.critical,
      );
      rethrow;
    }
  }
  
  // ==================== STRING OPERATIONS ====================
  
  /// Store string value
  Future<bool> setString(String key, String value, {bool persistent = false}) async {
    try {
      if (persistent) {
        return await _sharedPreferences.setString(key, value);
      } else {
        _getStorage.write(key, value);
        return true;
      }
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Storage - Set String: $key',
        severity: ErrorSeverity.medium,
      );
      return false;
    }
  }
  
  /// Get string value
  String? getString(String key, {bool persistent = false}) {
    try {
      if (persistent) {
        return _sharedPreferences.getString(key);
      } else {
        return _getStorage.read<String>(key);
      }
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Storage - Get String: $key',
        severity: ErrorSeverity.low,
      );
      return null;
    }
  }
  
  // ==================== INTEGER OPERATIONS ====================
  
  /// Store integer value
  Future<bool> setInt(String key, int value, {bool persistent = false}) async {
    try {
      if (persistent) {
        return await _sharedPreferences.setInt(key, value);
      } else {
        _getStorage.write(key, value);
        return true;
      }
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Storage - Set Int: $key',
        severity: ErrorSeverity.medium,
      );
      return false;
    }
  }
  
  /// Get integer value
  int? getInt(String key, {bool persistent = false}) {
    try {
      if (persistent) {
        return _sharedPreferences.getInt(key);
      } else {
        return _getStorage.read<int>(key);
      }
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Storage - Get Int: $key',
        severity: ErrorSeverity.low,
      );
      return null;
    }
  }
  
  // ==================== BOOLEAN OPERATIONS ====================
  
  /// Store boolean value
  Future<bool> setBool(String key, bool value, {bool persistent = false}) async {
    try {
      if (persistent) {
        return await _sharedPreferences.setBool(key, value);
      } else {
        _getStorage.write(key, value);
        return true;
      }
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Storage - Set Bool: $key',
        severity: ErrorSeverity.medium,
      );
      return false;
    }
  }
  
  /// Get boolean value
  bool? getBool(String key, {bool persistent = false}) {
    try {
      if (persistent) {
        return _sharedPreferences.getBool(key);
      } else {
        return _getStorage.read<bool>(key);
      }
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Storage - Get Bool: $key',
        severity: ErrorSeverity.low,
      );
      return null;
    }
  }
  
  // ==================== DOUBLE OPERATIONS ====================
  
  /// Store double value
  Future<bool> setDouble(String key, double value, {bool persistent = false}) async {
    try {
      if (persistent) {
        return await _sharedPreferences.setDouble(key, value);
      } else {
        _getStorage.write(key, value);
        return true;
      }
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Storage - Set Double: $key',
        severity: ErrorSeverity.medium,
      );
      return false;
    }
  }
  
  /// Get double value
  double? getDouble(String key, {bool persistent = false}) {
    try {
      if (persistent) {
        return _sharedPreferences.getDouble(key);
      } else {
        return _getStorage.read<double>(key);
      }
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Storage - Get Double: $key',
        severity: ErrorSeverity.low,
      );
      return null;
    }
  }
  
  // ==================== LIST OPERATIONS ====================
  
  /// Store list of strings
  Future<bool> setStringList(String key, List<String> value, {bool persistent = false}) async {
    try {
      if (persistent) {
        return await _sharedPreferences.setStringList(key, value);
      } else {
        _getStorage.write(key, value);
        return true;
      }
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Storage - Set String List: $key',
        severity: ErrorSeverity.medium,
      );
      return false;
    }
  }
  
  /// Get list of strings
  List<String>? getStringList(String key, {bool persistent = false}) {
    try {
      if (persistent) {
        return _sharedPreferences.getStringList(key);
      } else {
        final value = _getStorage.read<List>(key);
        return value?.cast<String>();
      }
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Storage - Get String List: $key',
        severity: ErrorSeverity.low,
      );
      return null;
    }
  }
  
  // ==================== JSON OPERATIONS ====================
  
  /// Store JSON object
  Future<bool> setJson(String key, Map<String, dynamic> value, {bool persistent = false}) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString, persistent: persistent);
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Storage - Set JSON: $key',
        severity: ErrorSeverity.medium,
      );
      return false;
    }
  }
  
  /// Get JSON object
  Map<String, dynamic>? getJson(String key, {bool persistent = false}) {
    try {
      final jsonString = getString(key, persistent: persistent);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Storage - Get JSON: $key',
        severity: ErrorSeverity.low,
      );
      return null;
    }
  }
  
  /// Store JSON list
  Future<bool> setJsonList(String key, List<Map<String, dynamic>> value, {bool persistent = false}) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString, persistent: persistent);
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Storage - Set JSON List: $key',
        severity: ErrorSeverity.medium,
      );
      return false;
    }
  }
  
  /// Get JSON list
  List<Map<String, dynamic>>? getJsonList(String key, {bool persistent = false}) {
    try {
      final jsonString = getString(key, persistent: persistent);
      if (jsonString == null) return null;
      final decoded = jsonDecode(jsonString) as List;
      return decoded.cast<Map<String, dynamic>>();
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Storage - Get JSON List: $key',
        severity: ErrorSeverity.low,
      );
      return null;
    }
  }
  
  // ==================== UTILITY OPERATIONS ====================
  
  /// Check if key exists
  bool hasKey(String key, {bool persistent = false}) {
    try {
      if (persistent) {
        return _sharedPreferences.containsKey(key);
      } else {
        return _getStorage.hasData(key);
      }
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Storage - Has Key: $key',
        severity: ErrorSeverity.low,
      );
      return false;
    }
  }
  
  /// Remove specific key
  Future<bool> remove(String key, {bool persistent = false}) async {
    try {
      if (persistent) {
        return await _sharedPreferences.remove(key);
      } else {
        _getStorage.remove(key);
        return true;
      }
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Storage - Remove: $key',
        severity: ErrorSeverity.medium,
      );
      return false;
    }
  }
  
  /// Clear all data
  Future<bool> clear({bool persistent = false}) async {
    try {
      if (persistent) {
        return await _sharedPreferences.clear();
      } else {
        _getStorage.erase();
        return true;
      }
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Storage - Clear All',
        severity: ErrorSeverity.medium,
      );
      return false;
    }
  }
  
  /// Get all keys
  Set<String> getAllKeys({bool persistent = false}) {
    try {
      if (persistent) {
        return _sharedPreferences.getKeys();
      } else {
        return _getStorage.getKeys().cast<String>().toSet();
      }
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Storage - Get All Keys',
        severity: ErrorSeverity.low,
      );
      return <String>{};
    }
  }
  
  // ==================== APP-SPECIFIC METHODS ====================
  
  /// User authentication token
  Future<bool> setUserToken(String token) async {
    return await setString(AppConstants.userTokenKey, token, persistent: true);
  }
  
  String? getUserToken() {
    return getString(AppConstants.userTokenKey, persistent: true);
  }
  
  Future<bool> removeUserToken() async {
    return await remove(AppConstants.userTokenKey, persistent: true);
  }
  
  /// User data
  Future<bool> setUserData(Map<String, dynamic> userData) async {
    return await setJson(AppConstants.userDataKey, userData, persistent: true);
  }
  
  Map<String, dynamic>? getUserData() {
    return getJson(AppConstants.userDataKey, persistent: true);
  }
  
  Future<bool> removeUserData() async {
    return await remove(AppConstants.userDataKey, persistent: true);
  }
  
  /// Theme mode
  Future<bool> setThemeMode(String themeMode) async {
    return await setString(AppConstants.themeKey, themeMode, persistent: true);
  }
  
  String? getThemeMode() {
    return getString(AppConstants.themeKey, persistent: true);
  }
  
  /// Language
  Future<bool> setLanguage(String language) async {
    return await setString(AppConstants.languageKey, language, persistent: true);
  }
  
  String? getLanguage() {
    return getString(AppConstants.languageKey, persistent: true);
  }
  
  /// Onboarding status
  Future<bool> setOnboardingCompleted(bool completed) async {
    return await setBool(AppConstants.onboardingKey, completed, persistent: true);
  }
  
  bool isOnboardingCompleted() {
    return getBool(AppConstants.onboardingKey, persistent: true) ?? false;
  }
  
  /// Clear user session data
  Future<bool> clearUserSession() async {
    try {
      await removeUserToken();
      await removeUserData();
      return true;
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Storage - Clear User Session',
        severity: ErrorSeverity.medium,
      );
      return false;
    }
  }
}
