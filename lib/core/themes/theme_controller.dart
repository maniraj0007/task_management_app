import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../constants/app_constants.dart';

/// Theme Controller
/// Manages app theme state and persistence
class ThemeController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  // Observable theme mode
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  
  /// Current theme mode
  ThemeMode get themeMode => _themeMode.value;
  
  /// Is dark mode active
  bool get isDarkMode => _themeMode.value == ThemeMode.dark;
  
  /// Is light mode active
  bool get isLightMode => _themeMode.value == ThemeMode.light;
  
  /// Is system mode active
  bool get isSystemMode => _themeMode.value == ThemeMode.system;
  
  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }
  
  /// Load theme mode from storage
  void _loadThemeMode() {
    final savedTheme = _storageService.getThemeMode();
    if (savedTheme != null) {
      _themeMode.value = _getThemeModeFromString(savedTheme);
    }
  }
  
  /// Change theme mode
  Future<void> changeThemeMode(ThemeMode themeMode) async {
    _themeMode.value = themeMode;
    await _storageService.setThemeMode(_getStringFromThemeMode(themeMode));
    Get.changeThemeMode(themeMode);
  }
  
  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newTheme = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await changeThemeMode(newTheme);
  }
  
  /// Set light theme
  Future<void> setLightTheme() async {
    await changeThemeMode(ThemeMode.light);
  }
  
  /// Set dark theme
  Future<void> setDarkTheme() async {
    await changeThemeMode(ThemeMode.dark);
  }
  
  /// Set system theme
  Future<void> setSystemTheme() async {
    await changeThemeMode(ThemeMode.system);
  }
  
  /// Convert ThemeMode to string
  String _getStringFromThemeMode(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
  
  /// Convert string to ThemeMode
  ThemeMode _getThemeModeFromString(String themeString) {
    switch (themeString.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }
}
