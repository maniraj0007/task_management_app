import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Helper utilities for common operations and formatting
class Helpers {
  // ==================== DATE & TIME HELPERS ====================
  
  /// Format date to readable string
  static String formatDate(DateTime date, {String? format}) {
    final formatter = DateFormat(format ?? AppConstants.dateFormat);
    return formatter.format(date);
  }
  
  /// Format time to readable string
  static String formatTime(DateTime time, {String? format}) {
    final formatter = DateFormat(format ?? AppConstants.timeFormat);
    return formatter.format(time);
  }
  
  /// Format date and time to readable string
  static String formatDateTime(DateTime dateTime, {String? format}) {
    final formatter = DateFormat(format ?? AppConstants.dateTimeFormat);
    return formatter.format(dateTime);
  }
  
  /// Get relative time (e.g., "2 hours ago", "just now")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return formatDate(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
  
  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }
  
  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }
  
  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
  
  /// Get days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }
  
  // ==================== STRING HELPERS ====================
  
  /// Capitalize first letter of string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  /// Capitalize first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }
  
  /// Truncate string with ellipsis
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }
  
  /// Remove extra whitespace
  static String cleanWhitespace(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
  
  /// Generate initials from name
  static String getInitials(String name, {int maxLength = 2}) {
    final words = name.trim().split(RegExp(r'\s+'));
    final initials = words.take(maxLength).map((word) => word.isNotEmpty ? word[0].toUpperCase() : '').join();
    return initials;
  }
  
  /// Check if string is null or empty
  static bool isNullOrEmpty(String? text) {
    return text == null || text.trim().isEmpty;
  }
  
  /// Check if string is valid email
  static bool isValidEmail(String? email) {
    if (email == null || email.trim().isEmpty) return false;
    
    // Email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    return emailRegex.hasMatch(email.trim());
  }
  
  /// Check if string is valid phone number
  static bool isValidPhoneNumber(String? phone) {
    if (phone == null || phone.trim().isEmpty) return false;
    
    // Remove all non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Phone number should have 10-15 digits
    return digitsOnly.length >= 10 && digitsOnly.length <= 15;
  }
  
  /// Generate random string
  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
  
  /// Generate random ID
  static String generateId({int length = 12}) {
    return generateRandomString(length);
  }
  
  // ==================== NUMBER HELPERS ====================
  
  /// Format number with commas
  static String formatNumber(num number, {int decimalPlaces = 0}) {
    final formatter = NumberFormat('#,##0${decimalPlaces > 0 ? '.' + '0' * decimalPlaces : ''}');
    return formatter.format(number);
  }
  
  /// Format currency
  static String formatCurrency(double amount, {String symbol = '\$', int decimalPlaces = 2}) {
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: decimalPlaces);
    return formatter.format(amount);
  }
  
  /// Format percentage
  static String formatPercentage(double value, {int decimalPlaces = 1}) {
    final formatter = NumberFormat.percentPattern();
    formatter.maximumFractionDigits = decimalPlaces;
    return formatter.format(value);
  }
  
  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  /// Clamp number between min and max
  static T clamp<T extends num>(T value, T min, T max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
  
  /// Generate random number between min and max
  static int randomInt(int min, int max) {
    final random = Random();
    return min + random.nextInt(max - min + 1);
  }
  
  /// Generate random double between min and max
  static double randomDouble(double min, double max) {
    final random = Random();
    return min + random.nextDouble() * (max - min);
  }
  
  // ==================== COLOR HELPERS ====================
  
  /// Generate random color
  static Color randomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }
  
  /// Generate color from string (consistent)
  static Color colorFromString(String text) {
    final hash = text.hashCode;
    final random = Random(hash);
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }
  
  /// Lighten color
  static Color lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = clamp(hsl.lightness + amount, 0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  /// Darken color
  static Color darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = clamp(hsl.lightness - amount, 0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  /// Get contrast color (black or white)
  static Color getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
  
  // ==================== LIST HELPERS ====================
  
  /// Check if list is null or empty
  static bool isListNullOrEmpty<T>(List<T>? list) {
    return list == null || list.isEmpty;
  }
  
  /// Get safe element from list
  static T? safeGet<T>(List<T>? list, int index) {
    if (list == null || index < 0 || index >= list.length) return null;
    return list[index];
  }
  
  /// Chunk list into smaller lists
  static List<List<T>> chunk<T>(List<T> list, int size) {
    final chunks = <List<T>>[];
    for (int i = 0; i < list.length; i += size) {
      chunks.add(list.sublist(i, i + size > list.length ? list.length : i + size));
    }
    return chunks;
  }
  
  /// Remove duplicates from list
  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }
  
  /// Shuffle list
  static List<T> shuffle<T>(List<T> list) {
    final shuffled = List<T>.from(list);
    shuffled.shuffle();
    return shuffled;
  }
  
  // ==================== MAP HELPERS ====================
  
  /// Check if map is null or empty
  static bool isMapNullOrEmpty<K, V>(Map<K, V>? map) {
    return map == null || map.isEmpty;
  }
  
  /// Get safe value from map
  static V? safeGetFromMap<K, V>(Map<K, V>? map, K key) {
    if (map == null) return null;
    return map[key];
  }
  
  /// Merge two maps
  static Map<K, V> mergeMaps<K, V>(Map<K, V> map1, Map<K, V> map2) {
    return {...map1, ...map2};
  }
  
  // ==================== DEVICE HELPERS ====================
  
  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }
  
  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }
  
  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }
  
  /// Get screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return ScreenSize.mobile;
    if (width < 1200) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }
  
  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
  
  // ==================== UTILITY HELPERS ====================
  
  /// Debounce function calls
  static void debounce(VoidCallback callback, Duration delay) {
    Timer? timer;
    timer?.cancel();
    timer = Timer(delay, callback);
  }
  
  /// Throttle function calls
  static void throttle(VoidCallback callback, Duration delay) {
    bool canExecute = true;
    if (canExecute) {
      canExecute = false;
      callback();
      Timer(delay, () => canExecute = true);
    }
  }
  
  /// Delay execution
  static Future<void> delay(Duration duration) {
    return Future.delayed(duration);
  }
  
  /// Try-catch wrapper with error handling
  static T? tryCatch<T>(T Function() function, {T? defaultValue}) {
    try {
      return function();
    } catch (e) {
      return defaultValue;
    }
  }
  
  /// Async try-catch wrapper
  static Future<T?> tryAsync<T>(Future<T> Function() function, {T? defaultValue}) async {
    try {
      return await function();
    } catch (e) {
      return defaultValue;
    }
  }
  
  /// Check if value is between min and max
  static bool isBetween<T extends Comparable>(T value, T min, T max) {
    return value.compareTo(min) >= 0 && value.compareTo(max) <= 0;
  }
  
  /// Get enum from string
  static T? enumFromString<T>(Iterable<T> values, String value) {
    try {
      return values.firstWhere((type) => type.toString().split('.').last == value);
    } catch (e) {
      return null;
    }
  }
  
  /// Convert enum to string
  static String enumToString<T>(T enumValue) {
    return enumValue.toString().split('.').last;
  }
}

/// Screen size categories
enum ScreenSize { mobile, tablet, desktop }

/// Timer class for debouncing and throttling
class Timer {
  static void Function()? _callback;
  static Duration? _delay;
  
  Timer(Duration delay, void Function() callback) {
    _delay = delay;
    _callback = callback;
    Future.delayed(delay, () {
      if (_callback != null) {
        _callback!();
        _callback = null;
      }
    });
  }
  
  void cancel() {
    _callback = null;
  }
}
