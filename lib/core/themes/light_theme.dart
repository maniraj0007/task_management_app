import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'app_theme.dart';

/// Light theme configuration following Material 3 design system
class LightTheme {
  // Private constructor to prevent instantiation
  LightTheme._();
  
  /// Light theme data
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Color scheme
    colorScheme: const ColorScheme.light(
      // Primary colors
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      
      // Secondary colors
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      
      // Tertiary colors
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      
      // Error colors
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      
      // Surface colors
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceVariant: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      
      // Background colors
      background: AppColors.background,
      onBackground: AppColors.onBackground,
      
      // Outline colors
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      
      // Shadow and scrim
      shadow: AppColors.shadowMedium,
      scrim: AppColors.black,
      
      // Inverse colors
      inverseSurface: AppColors.grey800,
      onInverseSurface: AppColors.grey100,
      inversePrimary: AppColors.primary,
    ),
    
    // Typography
    textTheme: AppTheme.textTheme.apply(
      bodyColor: AppColors.onSurface,
      displayColor: AppColors.onSurface,
    ),
    
    // Component themes
    appBarTheme: AppTheme.appBarTheme.copyWith(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      surfaceTintColor: AppColors.surface,
      shadowColor: AppColors.shadowLight,
      titleTextStyle: AppTheme.appBarTheme.titleTextStyle?.copyWith(
        color: AppColors.onSurface,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.onSurface,
      ),
    ),
    
    // Scaffold
    scaffoldBackgroundColor: AppColors.background,
    
    // Cards
    cardTheme: AppTheme.cardTheme.copyWith(
      color: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      shadowColor: AppColors.shadowLight,
    ),
    
    // Input decoration
    inputDecorationTheme: AppTheme.inputDecorationTheme.copyWith(
      fillColor: AppColors.surfaceVariant,
      hintStyle: AppTheme.inputDecorationTheme.hintStyle?.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
      labelStyle: AppTheme.inputDecorationTheme.labelStyle?.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
      prefixIconColor: AppColors.onSurfaceVariant,
      suffixIconColor: AppColors.onSurfaceVariant,
    ),
    
    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppTheme.elevatedButtonTheme.style?.copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.grey300;
          }
          return AppColors.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.grey500;
          }
          return AppColors.onPrimary;
        }),
        overlayColor: WidgetStateProperty.all(AppColors.primaryContainer),
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
            return const BorderSide(color: AppColors.grey300);
          }
          return const BorderSide(color: AppColors.outline);
        }),
        overlayColor: WidgetStateProperty.all(AppColors.primaryContainer),
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
        overlayColor: WidgetStateProperty.all(AppColors.primaryContainer),
      ),
    ),
    
    // Floating Action Button
    floatingActionButtonTheme: AppTheme.floatingActionButtonTheme.copyWith(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
    ),
    
    // Chips
    chipTheme: AppTheme.chipTheme.copyWith(
      backgroundColor: AppColors.surfaceVariant,
      selectedColor: AppColors.primaryContainer,
      disabledColor: AppColors.grey200,
      labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
      secondaryLabelStyle: const TextStyle(color: AppColors.onPrimaryContainer),
      side: const BorderSide(color: AppColors.outline),
    ),
    
    // Dialogs
    dialogTheme: AppTheme.dialogTheme.copyWith(
      backgroundColor: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      shadowColor: AppColors.shadowMedium,
      titleTextStyle: AppTheme.dialogTheme.titleTextStyle?.copyWith(
        color: AppColors.onSurface,
      ),
      contentTextStyle: AppTheme.dialogTheme.contentTextStyle?.copyWith(
        color: AppColors.onSurface,
      ),
    ),
    
    // Bottom sheets
    bottomSheetTheme: AppTheme.bottomSheetTheme.copyWith(
      backgroundColor: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      shadowColor: AppColors.shadowMedium,
    ),
    
    // Tab bar
    tabBarTheme: AppTheme.tabBarTheme.copyWith(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.onSurfaceVariant,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    
    // List tiles
    listTileTheme: AppTheme.listTileTheme.copyWith(
      textColor: AppColors.onSurface,
      iconColor: AppColors.onSurfaceVariant,
      tileColor: AppColors.surface,
      selectedTileColor: AppColors.primaryContainer,
      selectedColor: AppColors.onPrimaryContainer,
    ),
    
    // Switches
    switchTheme: AppTheme.switchTheme,
    
    // Checkboxes
    checkboxTheme: AppTheme.checkboxTheme,
    
    // Radio buttons
    radioTheme: AppTheme.radioTheme,
    
    // Sliders
    sliderTheme: AppTheme.sliderTheme,
    
    // Progress indicators
    progressIndicatorTheme: AppTheme.progressIndicatorTheme,
    
    // Snackbars
    snackBarTheme: AppTheme.snackBarTheme.copyWith(
      backgroundColor: AppColors.grey800,
      contentTextStyle: AppTheme.snackBarTheme.contentTextStyle?.copyWith(
        color: AppColors.white,
      ),
      actionTextColor: AppColors.primary,
    ),
    
    // Tooltips
    tooltipTheme: AppTheme.tooltipTheme,
    
    // Dividers
    dividerColor: AppColors.outlineVariant,
    dividerTheme: const DividerThemeData(
      color: AppColors.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    
    // Icons
    iconTheme: const IconThemeData(
      color: AppColors.onSurface,
    ),
    primaryIconTheme: const IconThemeData(
      color: AppColors.onPrimary,
    ),
    
    // Navigation bar
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      indicatorColor: AppColors.primaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.onPrimaryContainer,
          );
        }
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.onPrimaryContainer);
        }
        return const IconThemeData(color: AppColors.onSurfaceVariant);
      }),
    ),
    
    // Navigation drawer
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      shadowColor: AppColors.shadowMedium,
    ),
    
    // Menu
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.surface),
        surfaceTintColor: WidgetStateProperty.all(AppColors.surface),
        shadowColor: WidgetStateProperty.all(AppColors.shadowMedium),
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
      color: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      shadowColor: AppColors.shadowMedium,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: AppColors.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
    
    // Search bar
    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStateProperty.all(AppColors.surfaceVariant),
      surfaceTintColor: WidgetStateProperty.all(AppColors.surfaceVariant),
      overlayColor: WidgetStateProperty.all(AppColors.primaryContainer),
      shadowColor: WidgetStateProperty.all(AppColors.shadowLight),
      elevation: WidgetStateProperty.all(1),
      textStyle: WidgetStateProperty.all(
        const TextStyle(
          color: AppColors.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      hintStyle: WidgetStateProperty.all(
        const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
    
    // Badge
    badgeTheme: const BadgeThemeData(
      backgroundColor: AppColors.error,
      textColor: AppColors.onError,
      textStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    ),
    
    // Date picker
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      shadowColor: AppColors.shadowMedium,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      headerBackgroundColor: AppColors.primaryContainer,
      headerForegroundColor: AppColors.onPrimaryContainer,
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
        return AppColors.onSurface;
      }),
      todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.primaryContainer;
      }),
      todayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.onPrimary;
        }
        return AppColors.onPrimaryContainer;
      }),
    ),
    
    // Time picker
    timePickerTheme: TimePickerThemeData(
      backgroundColor: AppColors.surface,
      dialBackgroundColor: AppColors.surfaceVariant,
      dialHandColor: AppColors.primary,
      dialTextColor: AppColors.onSurfaceVariant,
      entryModeIconColor: AppColors.onSurfaceVariant,
      hourMinuteColor: AppColors.surfaceVariant,
      hourMinuteTextColor: AppColors.onSurfaceVariant,
      dayPeriodColor: AppColors.primaryContainer,
      dayPeriodTextColor: AppColors.onPrimaryContainer,
    ),
    
    // Expansion tile
    expansionTileTheme: const ExpansionTileThemeData(
      backgroundColor: AppColors.surface,
      collapsedBackgroundColor: AppColors.surface,
      textColor: AppColors.onSurface,
      collapsedTextColor: AppColors.onSurface,
      iconColor: AppColors.onSurfaceVariant,
      collapsedIconColor: AppColors.onSurfaceVariant,
    ),
  );
}
