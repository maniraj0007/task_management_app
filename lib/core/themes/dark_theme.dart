import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'app_theme.dart';

/// Dark theme configuration following Material 3 design system
class DarkTheme {
  // Private constructor to prevent instantiation
  DarkTheme._();
  
  /// Dark theme data
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Color scheme
    colorScheme: const ColorScheme.dark(
      // Primary colors
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: Color(0xFF004A77),
      onPrimaryContainer: Color(0xFFB8E6FF),
      
      // Secondary colors
      secondary: Color(0xFF90CAF9),
      onSecondary: Color(0xFF003258),
      secondaryContainer: Color(0xFF004A77),
      onSecondaryContainer: Color(0xFFCAE6FF),
      
      // Tertiary colors
      tertiary: Color(0xFFCE93D8),
      onTertiary: Color(0xFF4A148C),
      tertiaryContainer: Color(0xFF6A1B9A),
      onTertiaryContainer: Color(0xFFE1BEE7),
      
      // Error colors
      error: Color(0xFFFF6B6B),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      
      // Surface colors
      surface: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
      surfaceVariant: AppColors.surfaceVariantDark,
      onSurfaceVariant: AppColors.onSurfaceVariantDark,
      
      // Background colors
      background: AppColors.backgroundDark,
      onBackground: AppColors.onBackgroundDark,
      
      // Outline colors
      outline: Color(0xFF8C9197),
      outlineVariant: Color(0xFF42474E),
      
      // Shadow and scrim
      shadow: AppColors.shadowDark,
      scrim: AppColors.black,
      
      // Inverse colors
      inverseSurface: AppColors.grey100,
      onInverseSurface: AppColors.grey800,
      inversePrimary: AppColors.primary,
    ),
    
    // Typography
    textTheme: AppTheme.textTheme.apply(
      bodyColor: AppColors.onSurfaceDark,
      displayColor: AppColors.onSurfaceDark,
    ),
    
    // Component themes
    appBarTheme: AppTheme.appBarTheme.copyWith(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.onSurfaceDark,
      surfaceTintColor: AppColors.surfaceDark,
      shadowColor: AppColors.shadowDark,
      titleTextStyle: AppTheme.appBarTheme.titleTextStyle?.copyWith(
        color: AppColors.onSurfaceDark,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.onSurfaceDark,
      ),
    ),
    
    // Scaffold
    scaffoldBackgroundColor: AppColors.backgroundDark,
    
    // Cards
    cardTheme: AppTheme.cardTheme.copyWith(
      color: AppColors.surfaceDark,
      surfaceTintColor: AppColors.surfaceDark,
      shadowColor: AppColors.shadowDark,
    ),
    
    // Input decoration
    inputDecorationTheme: AppTheme.inputDecorationTheme.copyWith(
      fillColor: AppColors.surfaceVariantDark,
      hintStyle: AppTheme.inputDecorationTheme.hintStyle?.copyWith(
        color: AppColors.onSurfaceVariantDark,
      ),
      labelStyle: AppTheme.inputDecorationTheme.labelStyle?.copyWith(
        color: AppColors.onSurfaceVariantDark,
      ),
      prefixIconColor: AppColors.onSurfaceVariantDark,
      suffixIconColor: AppColors.onSurfaceVariantDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF8C9197)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF8C9197)),
      ),
    ),
    
    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppTheme.elevatedButtonTheme.style?.copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.grey700;
          }
          return AppColors.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.grey500;
          }
          return AppColors.onPrimary;
        }),
        overlayColor: WidgetStateProperty.all(const Color(0xFF004A77)),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: AppTheme.outlinedButtonTheme.style?.copyWith(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.grey500;
          }
          return AppColors.primary;
        }),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return const BorderSide(color: AppColors.grey700);
          }
          return const BorderSide(color: Color(0xFF8C9197));
        }),
        overlayColor: WidgetStateProperty.all(const Color(0xFF004A77)),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: AppTheme.textButtonTheme.style?.copyWith(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.grey500;
          }
          return AppColors.primary;
        }),
        overlayColor: WidgetStateProperty.all(const Color(0xFF004A77)),
      ),
    ),
    
    // Floating Action Button
    floatingActionButtonTheme: AppTheme.floatingActionButtonTheme.copyWith(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
    ),
    
    // Chips
    chipTheme: AppTheme.chipTheme.copyWith(
      backgroundColor: AppColors.surfaceVariantDark,
      selectedColor: const Color(0xFF004A77),
      disabledColor: AppColors.grey800,
      labelStyle: const TextStyle(color: AppColors.onSurfaceVariantDark),
      secondaryLabelStyle: const TextStyle(color: Color(0xFFB8E6FF)),
      side: const BorderSide(color: Color(0xFF8C9197)),
    ),
    
    // Dialogs
    dialogTheme: AppTheme.dialogTheme.copyWith(
      backgroundColor: AppColors.surfaceDark,
      surfaceTintColor: AppColors.surfaceDark,
      shadowColor: AppColors.shadowDark,
      titleTextStyle: AppTheme.dialogTheme.titleTextStyle?.copyWith(
        color: AppColors.onSurfaceDark,
      ),
      contentTextStyle: AppTheme.dialogTheme.contentTextStyle?.copyWith(
        color: AppColors.onSurfaceDark,
      ),
    ),
    
    // Bottom sheets
    bottomSheetTheme: AppTheme.bottomSheetTheme.copyWith(
      backgroundColor: AppColors.surfaceDark,
      surfaceTintColor: AppColors.surfaceDark,
      shadowColor: AppColors.shadowDark,
    ),
    
    // Tab bar
    tabBarTheme: AppTheme.tabBarTheme.copyWith(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.onSurfaceVariantDark,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    
    // List tiles
    listTileTheme: AppTheme.listTileTheme.copyWith(
      textColor: AppColors.onSurfaceDark,
      iconColor: AppColors.onSurfaceVariantDark,
      tileColor: AppColors.surfaceDark,
      selectedTileColor: const Color(0xFF004A77),
      selectedColor: const Color(0xFFB8E6FF),
    ),
    
    // Switches
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.grey600;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF004A77);
        }
        return AppColors.grey800;
      }),
    ),
    
    // Checkboxes
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.surfaceDark;
      }),
      checkColor: WidgetStateProperty.all(AppColors.onPrimary),
    ),
    
    // Radio buttons
    radioTheme: const RadioThemeData(
      fillColor: WidgetStatePropertyAll(AppColors.primary),
    ),
    
    // Sliders
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.grey700,
      thumbColor: AppColors.primary,
      overlayColor: Color(0xFF004A77),
      trackHeight: 4,
    ),
    
    // Progress indicators
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.grey800,
      circularTrackColor: AppColors.grey800,
    ),
    
    // Snackbars
    snackBarTheme: AppTheme.snackBarTheme.copyWith(
      backgroundColor: AppColors.grey200,
      contentTextStyle: AppTheme.snackBarTheme.contentTextStyle?.copyWith(
        color: AppColors.grey900,
      ),
      actionTextColor: AppColors.primary,
    ),
    
    // Tooltips
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.grey900,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    
    // Dividers
    dividerColor: const Color(0xFF42474E),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF42474E),
      thickness: 1,
      space: 1,
    ),
    
    // Icons
    iconTheme: const IconThemeData(
      color: AppColors.onSurfaceDark,
    ),
    primaryIconTheme: const IconThemeData(
      color: AppColors.onPrimary,
    ),
    
    // Navigation bar
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      surfaceTintColor: AppColors.surfaceDark,
      indicatorColor: const Color(0xFF004A77),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFFB8E6FF),
          );
        }
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurfaceVariantDark,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Color(0xFFB8E6FF));
        }
        return const IconThemeData(color: AppColors.onSurfaceVariantDark);
      }),
    ),
    
    // Navigation drawer
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.surfaceDark,
      surfaceTintColor: AppColors.surfaceDark,
      shadowColor: AppColors.shadowDark,
    ),
    
    // Menu
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.surfaceDark),
        surfaceTintColor: WidgetStateProperty.all(AppColors.surfaceDark),
        shadowColor: WidgetStateProperty.all(AppColors.shadowDark),
        elevation: WidgetStateProperty.all(3),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ),
    
    // Popup menu
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.surfaceDark,
      surfaceTintColor: AppColors.surfaceDark,
      shadowColor: AppColors.shadowDark,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: AppColors.onSurfaceDark,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
    
    // Search bar
    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStateProperty.all(AppColors.surfaceVariantDark),
      surfaceTintColor: WidgetStateProperty.all(AppColors.surfaceVariantDark),
      overlayColor: WidgetStateProperty.all(const Color(0xFF004A77)),
      shadowColor: WidgetStateProperty.all(AppColors.shadowDark),
      elevation: WidgetStateProperty.all(1),
      textStyle: WidgetStateProperty.all(
        const TextStyle(
          color: AppColors.onSurfaceDark,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      hintStyle: WidgetStateProperty.all(
        const TextStyle(
          color: AppColors.onSurfaceVariantDark,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
    
    // Badge
    badgeTheme: const BadgeThemeData(
      backgroundColor: Color(0xFFFF6B6B),
      textColor: Color(0xFF690005),
      textStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    ),
    
    // Date picker
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.surfaceDark,
      surfaceTintColor: AppColors.surfaceDark,
      shadowColor: AppColors.shadowDark,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      headerBackgroundColor: const Color(0xFF004A77),
      headerForegroundColor: const Color(0xFFB8E6FF),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return null;
      }),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.onPrimary;
        }
        return AppColors.onSurfaceDark;
      }),
      todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return const Color(0xFF004A77);
      }),
      todayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.onPrimary;
        }
        return const Color(0xFFB8E6FF);
      }),
    ),
    
    // Time picker
    timePickerTheme: TimePickerThemeData(
      backgroundColor: AppColors.surfaceDark,
      dialBackgroundColor: AppColors.surfaceVariantDark,
      dialHandColor: AppColors.primary,
      dialTextColor: AppColors.onSurfaceVariantDark,
      entryModeIconColor: AppColors.onSurfaceVariantDark,
      hourMinuteColor: AppColors.surfaceVariantDark,
      hourMinuteTextColor: AppColors.onSurfaceVariantDark,
      dayPeriodColor: const Color(0xFF004A77),
      dayPeriodTextColor: const Color(0xFFB8E6FF),
    ),
    
    // Expansion tile
    expansionTileTheme: const ExpansionTileThemeData(
      backgroundColor: AppColors.surfaceDark,
      collapsedBackgroundColor: AppColors.surfaceDark,
      textColor: AppColors.onSurfaceDark,
      collapsedTextColor: AppColors.onSurfaceDark,
      iconColor: AppColors.onSurfaceVariantDark,
      collapsedIconColor: AppColors.onSurfaceVariantDark,
    ),
  );
}
