import 'package:flutter/material.dart';

/// Material 3 Color System for TaskMaster Pro
/// Following Material Design 3 guidelines with custom brand colors
class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF1976D2); // Blue 700
  static const Color primaryContainer = Color(0xFFE3F2FD); // Blue 50
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF0D47A1);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF455A64); // Blue Grey 700
  static const Color secondaryContainer = Color(0xFFECEFF1); // Blue Grey 50
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF263238);
  
  // Tertiary Colors
  static const Color tertiary = Color(0xFF7B1FA2); // Purple 700
  static const Color tertiaryContainer = Color(0xFFF3E5F5); // Purple 50
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF4A148C);
  
  // Error Colors
  static const Color error = Color(0xFFD32F2F); // Red 700
  static const Color errorContainer = Color(0xFFFFEBEE); // Red 50
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFFB71C1C);
  
  // Surface Colors (Light Theme)
  static const Color surface = Color(0xFFFFFBFE);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onSurfaceVariant = Color(0xFF49454F);
  
  // Background Colors (Light Theme)
  static const Color background = Color(0xFFFFFBFE);
  static const Color onBackground = Color(0xFF1C1B1F);
  
  // Outline Colors
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);
  
  // Dark Theme Colors
  static const Color surfaceDark = Color(0xFF121212);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);
  static const Color onSurfaceDark = Color(0xFFE6E1E5);
  static const Color onSurfaceVariantDark = Color(0xFFCAC4D0);
  
  static const Color backgroundDark = Color(0xFF121212);
  static const Color onBackgroundDark = Color(0xFFE6E1E5);
  
  // Task Status Colors
  static const Color todoColor = Color(0xFF9E9E9E); // Grey 500
  static const Color inProgressColor = Color(0xFF2196F3); // Blue 500
  static const Color reviewColor = Color(0xFFFF9800); // Orange 500
  static const Color completedColor = Color(0xFF4CAF50); // Green 500
  static const Color cancelledColor = Color(0xFFF44336); // Red 500
  
  // Priority Colors
  static const Color lowPriority = Color(0xFF4CAF50); // Green 500
  static const Color mediumPriority = Color(0xFFFF9800); // Orange 500
  static const Color highPriority = Color(0xFFFF5722); // Deep Orange 500
  static const Color urgentPriority = Color(0xFFF44336); // Red 500
  
  // Role Colors
  static const Color superAdminColor = Color(0xFF9C27B0); // Purple 500
  static const Color adminColor = Color(0xFF3F51B5); // Indigo 500
  static const Color teamMemberColor = Color(0xFF2196F3); // Blue 500
  static const Color viewerColor = Color(0xFF607D8B); // Blue Grey 500
  
  // Category Colors
  static const Color personalCategory = Color(0xFF00BCD4); // Cyan 500
  static const Color teamCategory = Color(0xFF4CAF50); // Green 500
  static const Color projectCategory = Color(0xFF9C27B0); // Purple 500
  
  // Semantic Colors
  static const Color success = Color(0xFF4CAF50); // Green 500
  static const Color warning = Color(0xFFFF9800); // Orange 500
  static const Color info = Color(0xFF2196F3); // Blue 500
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
  
  // Grey Scale
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
  
  // Shadow Colors
  static const Color shadowLight = Color(0x1F000000);
  static const Color shadowMedium = Color(0x3D000000);
  static const Color shadowDark = Color(0x66000000);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [warning, Color(0xFFF57C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, Color(0xFFC62828)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Chart Colors (for analytics)
  static const List<Color> chartColors = [
    Color(0xFF1976D2), // Blue
    Color(0xFF388E3C), // Green
    Color(0xFFF57C00), // Orange
    Color(0xFFD32F2F), // Red
    Color(0xFF7B1FA2), // Purple
    Color(0xFF00796B), // Teal
    Color(0xFFFBC02D), // Yellow
    Color(0xFF5D4037), // Brown
  ];
  
  // Helper Methods
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'todo':
        return todoColor;
      case 'in_progress':
        return inProgressColor;
      case 'review':
        return reviewColor;
      case 'completed':
        return completedColor;
      case 'cancelled':
        return cancelledColor;
      default:
        return grey500;
    }
  }
  
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return lowPriority;
      case 'medium':
        return mediumPriority;
      case 'high':
        return highPriority;
      case 'urgent':
        return urgentPriority;
      default:
        return grey500;
    }
  }
  
  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'super_admin':
        return superAdminColor;
      case 'admin':
        return adminColor;
      case 'team_member':
        return teamMemberColor;
      case 'viewer':
        return viewerColor;
      default:
        return grey500;
    }
  }
  
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'personal':
        return personalCategory;
      case 'team_collaboration':
        return teamCategory;
      case 'project_management':
        return projectCategory;
      default:
        return grey500;
    }
  }
}
