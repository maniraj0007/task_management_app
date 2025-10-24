import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/colors.dart';
import '../constants/dimensions.dart';
import '../services/storage_service.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

/// Theme controller for managing app themes
/// Supports light, dark, and system theme modes
class ThemeController extends GetxController {
  static ThemeController get instance => Get.find<ThemeController>();
  
  final RxString _themeMode = 'system'.obs;
  String get themeMode => _themeMode.value;
  
  final RxBool _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;
  
  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
    _updateThemeBasedOnSystem();
  }
  
  /// Load theme preference from storage
  void _loadThemeFromStorage() {
    final savedTheme = StorageService.instance.getThemeMode() ?? 'system';
    _themeMode.value = savedTheme;
    _updateThemeMode();
  }
  
  /// Update theme based on system settings
  void _updateThemeBasedOnSystem() {
    if (_themeMode.value == 'system') {
      final brightness = Get.context?.mediaQuery.platformBrightness ?? Brightness.light;
      _isDarkMode.value = brightness == Brightness.dark;
    }
  }
  
  /// Set theme mode
  Future<void> setThemeMode(String mode) async {
    _themeMode.value = mode;
    await StorageService.instance.setThemeMode(mode);
    _updateThemeMode();
  }
  
  /// Update theme mode based on current setting
  void _updateThemeMode() {
    switch (_themeMode.value) {
      case 'light':
        _isDarkMode.value = false;
        Get.changeThemeMode(ThemeMode.light);
        break;
      case 'dark':
        _isDarkMode.value = true;
        Get.changeThemeMode(ThemeMode.dark);
        break;
      case 'system':
      default:
        Get.changeThemeMode(ThemeMode.system);
        _updateThemeBasedOnSystem();
        break;
    }
  }
  
  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final newMode = _isDarkMode.value ? 'light' : 'dark';
    await setThemeMode(newMode);
  }
  
  /// Get current theme data
  ThemeData get currentTheme => _isDarkMode.value ? AppTheme.darkTheme : AppTheme.lightTheme;
  
  /// Get current color scheme
  ColorScheme get currentColorScheme => currentTheme.colorScheme;
}

/// Main theme configuration class
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();
  
  /// Light theme configuration
  static ThemeData get lightTheme => LightTheme.theme;
  
  /// Dark theme configuration
  static ThemeData get darkTheme => DarkTheme.theme;
  
  /// Common text theme for both light and dark themes
  static TextTheme get textTheme => const TextTheme(
    // Display styles
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 1.12,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.16,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.22,
    ),
    
    // Headline styles
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.29,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.33,
    ),
    
    // Title styles
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 1.27,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.50,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
    ),
    
    // Label styles
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.33,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.45,
    ),
    
    // Body styles
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      height: 1.50,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
    ),
  );
  
  /// Common input decoration theme
  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    filled: true,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.paddingM,
      vertical: AppDimensions.paddingM,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    labelStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    hintStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.grey500,
    ),
    errorStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.error,
    ),
  );
  
  /// Common elevated button theme
  static ElevatedButtonThemeData get elevatedButtonTheme => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: AppDimensions.elevation1,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingM,
      ),
      minimumSize: const Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
    ),
  );
  
  /// Common outlined button theme
  static OutlinedButtonThemeData get outlinedButtonTheme => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingM,
      ),
      minimumSize: const Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      side: const BorderSide(color: AppColors.outline),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
    ),
  );
  
  /// Common text button theme
  static TextButtonThemeData get textButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      minimumSize: const Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeightSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
    ),
  );
  
  /// Common floating action button theme
  static FloatingActionButtonThemeData get floatingActionButtonTheme => const FloatingActionButtonThemeData(
    elevation: AppDimensions.elevation3,
    highlightElevation: AppDimensions.elevation4,
    shape: CircleBorder(),
  );
  
  /// Common app bar theme
  static AppBarTheme get appBarTheme => const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    ),
    toolbarHeight: AppDimensions.appBarHeight,
  );
  
  /// Common card theme
  static CardTheme get cardTheme => CardTheme(
    elevation: AppDimensions.elevation1,
    margin: const EdgeInsets.all(AppDimensions.marginS),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
    ),
  );
  
  /// Common chip theme
  static ChipThemeData get chipTheme => ChipThemeData(
    padding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.paddingM,
      vertical: AppDimensions.paddingXS,
    ),
    labelPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXS),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
    ),
    showCheckmark: false,
    elevation: 0,
    pressElevation: AppDimensions.elevation1,
  );
  
  /// Common dialog theme
  static DialogTheme get dialogTheme => DialogTheme(
    elevation: AppDimensions.elevation5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
    ),
    titleTextStyle: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    contentTextStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
    ),
  );
  
  /// Common bottom sheet theme
  static BottomSheetThemeData get bottomSheetTheme => const BottomSheetThemeData(
    elevation: AppDimensions.elevation5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusL),
      ),
    ),
  );
  
  /// Common tab bar theme
  static TabBarTheme get tabBarTheme => const TabBarTheme(
    labelStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.1,
    ),
    indicatorSize: TabBarIndicatorSize.label,
  );
  
  /// Common list tile theme
  static ListTileThemeData get listTileTheme => const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(
      horizontal: AppDimensions.paddingM,
      vertical: AppDimensions.paddingXS,
    ),
    minVerticalPadding: AppDimensions.paddingXS,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppDimensions.radiusS)),
    ),
  );
  
  /// Common switch theme
  static SwitchThemeData get switchTheme => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return AppColors.grey400;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryContainer;
      }
      return AppColors.grey200;
    }),
  );
  
  /// Common checkbox theme
  static CheckboxThemeData get checkboxTheme => CheckboxThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
    ),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return AppColors.surface;
    }),
  );
  
  /// Common radio theme
  static RadioThemeData get radioTheme => const RadioThemeData(
    fillColor: WidgetStatePropertyAll(AppColors.primary),
  );
  
  /// Common slider theme
  static SliderThemeData get sliderTheme => const SliderThemeData(
    activeTrackColor: AppColors.primary,
    inactiveTrackColor: AppColors.grey300,
    thumbColor: AppColors.primary,
    overlayColor: AppColors.primaryContainer,
    trackHeight: 4,
  );
  
  /// Common progress indicator theme
  static ProgressIndicatorThemeData get progressIndicatorTheme => const ProgressIndicatorThemeData(
    color: AppColors.primary,
    linearTrackColor: AppColors.grey200,
    circularTrackColor: AppColors.grey200,
  );
  
  /// Common snackbar theme
  static SnackBarThemeData get snackBarTheme => SnackBarThemeData(
    elevation: AppDimensions.elevation3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
    ),
    behavior: SnackBarBehavior.floating,
    contentTextStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
  );
  
  /// Common tooltip theme
  static TooltipThemeData get tooltipTheme => TooltipThemeData(
    decoration: BoxDecoration(
      color: AppColors.grey800,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
    ),
    textStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.white,
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.paddingS,
      vertical: AppDimensions.paddingXS,
    ),
  );
}
