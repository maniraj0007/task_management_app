import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'helpers.dart';

/// Extension methods for common Flutter types
/// Provides convenient methods for enhanced functionality

// ==================== STRING EXTENSIONS ====================

extension StringExtensions on String {
  /// Check if string is null or empty
  bool get isNullOrEmpty => isEmpty;
  
  /// Check if string is not null and not empty
  bool get isNotNullOrEmpty => isNotEmpty;
  
  /// Capitalize first letter
  String get capitalize => Helpers.capitalize(this);
  
  /// Capitalize each word
  String get capitalizeWords => Helpers.capitalizeWords(this);
  
  /// Remove extra whitespace
  String get cleanWhitespace => Helpers.cleanWhitespace(this);
  
  /// Get initials from name
  String getInitials({int maxLength = 2}) => Helpers.getInitials(this, maxLength: maxLength);
  
  /// Truncate with ellipsis
  String truncate(int maxLength, {String suffix = '...'}) => Helpers.truncate(this, maxLength, suffix: suffix);
  
  /// Check if string is valid email
  bool get isValidEmail => Helpers.isValidEmail(this);
  
  /// Check if string is valid phone number
  bool get isValidPhoneNumber => Helpers.isValidPhoneNumber(this);
  
  /// Convert string to Color (consistent hash-based)
  Color get toColor => Helpers.colorFromString(this);
  
  /// Parse string to DateTime
  DateTime? get toDateTime {
    try {
      return DateTime.parse(this);
    } catch (e) {
      return null;
    }
  }
  
  /// Parse string to int
  int? get toInt => int.tryParse(this);
  
  /// Parse string to double
  double? get toDouble => double.tryParse(this);
  
  /// Parse string to bool
  bool? get toBool {
    final lower = toLowerCase();
    if (lower == 'true' || lower == '1') return true;
    if (lower == 'false' || lower == '0') return false;
    return null;
  }
  
  /// Remove HTML tags
  String get removeHtmlTags => replaceAll(RegExp(r'<[^>]*>'), '');
  
  /// Convert to snake_case
  String get toSnakeCase => replaceAllMapped(
    RegExp(r'[A-Z]'),
    (match) => '_${match.group(0)!.toLowerCase()}',
  ).replaceFirst(RegExp(r'^_'), '');
  
  /// Convert to camelCase
  String get toCamelCase {
    final words = split('_');
    if (words.isEmpty) return this;
    return words.first + words.skip(1).map((word) => word.capitalize).join();
  }
  
  /// Convert to PascalCase
  String get toPascalCase => split('_').map((word) => word.capitalize).join();
  
  /// Check if string contains only digits
  bool get isNumeric => RegExp(r'^[0-9]+$').hasMatch(this);
  
  /// Check if string contains only letters
  bool get isAlpha => RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  
  /// Check if string contains only letters and digits
  bool get isAlphaNumeric => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  
  /// Reverse string
  String get reverse => split('').reversed.join();
  
  /// Count occurrences of substring
  int countOccurrences(String substring) => split(substring).length - 1;
  
  /// Check if string is palindrome
  bool get isPalindrome {
    final cleaned = toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return cleaned == cleaned.reverse;
  }
}

// ==================== NULLABLE STRING EXTENSIONS ====================

extension NullableStringExtensions on String? {
  /// Check if string is null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  
  /// Check if string is not null and not empty
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
  
  /// Get string or default value
  String orDefault(String defaultValue) => this ?? defaultValue;
  
  /// Get string or empty string
  String get orEmpty => this ?? '';
}

// ==================== DATETIME EXTENSIONS ====================

extension DateTimeExtensions on DateTime {
  /// Format to readable date string
  String formatDate({String? format}) => Helpers.formatDate(this, format: format);
  
  /// Format to readable time string
  String formatTime({String? format}) => Helpers.formatTime(this, format: format);
  
  /// Format to readable date-time string
  String formatDateTime({String? format}) => Helpers.formatDateTime(this, format: format);
  
  /// Get relative time string
  String get relativeTime => Helpers.getRelativeTime(this);
  
  /// Check if date is today
  bool get isToday => Helpers.isToday(this);
  
  /// Check if date is yesterday
  bool get isYesterday => Helpers.isYesterday(this);
  
  /// Check if date is tomorrow
  bool get isTomorrow => Helpers.isTomorrow(this);
  
  /// Get start of day
  DateTime get startOfDay => Helpers.startOfDay(this);
  
  /// Get end of day
  DateTime get endOfDay => Helpers.endOfDay(this);
  
  /// Get start of week (Monday)
  DateTime get startOfWeek {
    final daysFromMonday = weekday - 1;
    return subtract(Duration(days: daysFromMonday)).startOfDay;
  }
  
  /// Get end of week (Sunday)
  DateTime get endOfWeek {
    final daysToSunday = 7 - weekday;
    return add(Duration(days: daysToSunday)).endOfDay;
  }
  
  /// Get start of month
  DateTime get startOfMonth => DateTime(year, month, 1);
  
  /// Get end of month
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);
  
  /// Get start of year
  DateTime get startOfYear => DateTime(year, 1, 1);
  
  /// Get end of year
  DateTime get endOfYear => DateTime(year, 12, 31, 23, 59, 59, 999);
  
  /// Check if date is in the past
  bool get isPast => isBefore(DateTime.now());
  
  /// Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());
  
  /// Check if date is same day as another date
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
  
  /// Get days between this date and another
  int daysBetween(DateTime other) => Helpers.daysBetween(this, other);
  
  /// Add business days (excluding weekends)
  DateTime addBusinessDays(int days) {
    DateTime result = this;
    int addedDays = 0;
    
    while (addedDays < days) {
      result = result.add(const Duration(days: 1));
      if (result.weekday < 6) { // Monday = 1, Friday = 5
        addedDays++;
      }
    }
    
    return result;
  }
  
  /// Check if date is weekend
  bool get isWeekend => weekday == DateTime.saturday || weekday == DateTime.sunday;
  
  /// Check if date is weekday
  bool get isWeekday => !isWeekend;
  
  /// Get age from this date to now
  int get age {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }
}

// ==================== NUMBER EXTENSIONS ====================

extension IntExtensions on int {
  /// Format number with commas
  String get formatted => Helpers.formatNumber(this);
  
  /// Convert to ordinal string (1st, 2nd, 3rd, etc.)
  String get ordinal {
    if (this >= 11 && this <= 13) return '${this}th';
    switch (this % 10) {
      case 1: return '${this}st';
      case 2: return '${this}nd';
      case 3: return '${this}rd';
      default: return '${this}th';
    }
  }
  
  /// Check if number is even
  bool get isEven => this % 2 == 0;
  
  /// Check if number is odd
  bool get isOdd => this % 2 != 0;
  
  /// Check if number is positive
  bool get isPositive => this > 0;
  
  /// Check if number is negative
  bool get isNegative => this < 0;
  
  /// Check if number is zero
  bool get isZero => this == 0;
  
  /// Get absolute value
  int get abs => this < 0 ? -this : this;
  
  /// Convert to Duration in milliseconds
  Duration get milliseconds => Duration(milliseconds: this);
  
  /// Convert to Duration in seconds
  Duration get seconds => Duration(seconds: this);
  
  /// Convert to Duration in minutes
  Duration get minutes => Duration(minutes: this);
  
  /// Convert to Duration in hours
  Duration get hours => Duration(hours: this);
  
  /// Convert to Duration in days
  Duration get days => Duration(days: this);
  
  /// Repeat action n times
  void times(void Function(int index) action) {
    for (int i = 0; i < this; i++) {
      action(i);
    }
  }
  
  /// Generate list of numbers from 0 to this-1
  List<int> get range => List.generate(this, (index) => index);
  
  /// Generate list of numbers from this to end
  List<int> to(int end) => List.generate(end - this + 1, (index) => this + index);
}

extension DoubleExtensions on double {
  /// Format number with commas and decimal places
  String formatted({int decimalPlaces = 2}) => Helpers.formatNumber(this, decimalPlaces: decimalPlaces);
  
  /// Format as currency
  String currency({String symbol = '\$', int decimalPlaces = 2}) => 
    Helpers.formatCurrency(this, symbol: symbol, decimalPlaces: decimalPlaces);
  
  /// Format as percentage
  String percentage({int decimalPlaces = 1}) => Helpers.formatPercentage(this, decimalPlaces: decimalPlaces);
  
  /// Check if number is positive
  bool get isPositive => this > 0;
  
  /// Check if number is negative
  bool get isNegative => this < 0;
  
  /// Check if number is zero
  bool get isZero => this == 0;
  
  /// Get absolute value
  double get abs => this < 0 ? -this : this;
  
  /// Clamp between min and max
  double clamp(double min, double max) => Helpers.clamp(this, min, max);
  
  /// Round to specified decimal places
  double roundToDecimalPlaces(int decimalPlaces) {
    final factor = pow(10, decimalPlaces);
    return (this * factor).round() / factor;
  }
}

// ==================== LIST EXTENSIONS ====================

extension ListExtensions<T> on List<T> {
  /// Check if list is null or empty
  bool get isNullOrEmpty => isEmpty;
  
  /// Check if list is not null and not empty
  bool get isNotNullOrEmpty => isNotEmpty;
  
  /// Get safe element at index
  T? safeGet(int index) => Helpers.safeGet(this, index);
  
  /// Get first element or null
  T? get firstOrNull => isEmpty ? null : first;
  
  /// Get last element or null
  T? get lastOrNull => isEmpty ? null : last;
  
  /// Chunk list into smaller lists
  List<List<T>> chunk(int size) => Helpers.chunk(this, size);
  
  /// Remove duplicates
  List<T> get removeDuplicates => Helpers.removeDuplicates(this);
  
  /// Shuffle list
  List<T> get shuffled => Helpers.shuffle(this);
  
  /// Get random element
  T? get random {
    if (isEmpty) return null;
    return this[Helpers.randomInt(0, length - 1)];
  }
  
  /// Split list into two based on predicate
  ({List<T> matching, List<T> notMatching}) partition(bool Function(T) predicate) {
    final matching = <T>[];
    final notMatching = <T>[];
    
    for (final item in this) {
      if (predicate(item)) {
        matching.add(item);
      } else {
        notMatching.add(item);
      }
    }
    
    return (matching: matching, notMatching: notMatching);
  }
  
  /// Group elements by key
  Map<K, List<T>> groupBy<K>(K Function(T) keySelector) {
    final map = <K, List<T>>{};
    for (final item in this) {
      final key = keySelector(item);
      map.putIfAbsent(key, () => <T>[]).add(item);
    }
    return map;
  }
  
  /// Get distinct elements by key
  List<T> distinctBy<K>(K Function(T) keySelector) {
    final seen = <K>{};
    final result = <T>[];
    
    for (final item in this) {
      final key = keySelector(item);
      if (seen.add(key)) {
        result.add(item);
      }
    }
    
    return result;
  }
}

// ==================== NULLABLE LIST EXTENSIONS ====================

extension NullableListExtensions<T> on List<T>? {
  /// Check if list is null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  
  /// Check if list is not null and not empty
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
  
  /// Get list or empty list
  List<T> get orEmpty => this ?? <T>[];
  
  /// Get safe element at index
  T? safeGet(int index) => Helpers.safeGet(this, index);
}

// ==================== COLOR EXTENSIONS ====================

extension ColorExtensions on Color {
  /// Lighten color
  Color lighten(double amount) => Helpers.lightenColor(this, amount);
  
  /// Darken color
  Color darken(double amount) => Helpers.darkenColor(this, amount);
  
  /// Get contrast color (black or white)
  Color get contrastColor => Helpers.getContrastColor(this);
  
  /// Convert to hex string
  String get toHex => '#${value.toRadixString(16).padLeft(8, '0').substring(2)}';
  
  /// Get luminance
  double get luminance => computeLuminance();
  
  /// Check if color is light
  bool get isLight => luminance > 0.5;
  
  /// Check if color is dark
  bool get isDark => luminance <= 0.5;
  
  /// Blend with another color
  Color blend(Color other, double ratio) {
    return Color.lerp(this, other, ratio) ?? this;
  }
  
  /// Get complementary color
  Color get complementary {
    final hsl = HSLColor.fromColor(this);
    return hsl.withHue((hsl.hue + 180) % 360).toColor();
  }
  
  /// Adjust opacity
  Color withOpacity(double opacity) => Color.fromRGBO(red, green, blue, opacity);
}

// ==================== BUILDCONTEXT EXTENSIONS ====================

extension BuildContextExtensions on BuildContext {
  /// Get theme data
  ThemeData get theme => Theme.of(this);
  
  /// Get color scheme
  ColorScheme get colorScheme => theme.colorScheme;
  
  /// Get text theme
  TextTheme get textTheme => theme.textTheme;
  
  /// Get media query data
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  
  /// Get screen size
  Size get screenSize => mediaQuery.size;
  
  /// Get screen width
  double get screenWidth => screenSize.width;
  
  /// Get screen height
  double get screenHeight => screenSize.height;
  
  /// Check if device is mobile
  bool get isMobile => Helpers.isMobile(this);
  
  /// Check if device is tablet
  bool get isTablet => Helpers.isTablet(this);
  
  /// Check if device is desktop
  bool get isDesktop => Helpers.isDesktop(this);
  
  /// Get screen size category
  ScreenSize get screenSizeCategory => Helpers.getScreenSize(this);
  
  /// Check if device is in landscape mode
  bool get isLandscape => Helpers.isLandscape(this);
  
  /// Check if device is in portrait mode
  bool get isPortrait => Helpers.isPortrait(this);
  
  /// Get safe area padding
  EdgeInsets get padding => mediaQuery.padding;
  
  /// Get view insets (keyboard height)
  EdgeInsets get viewInsets => mediaQuery.viewInsets;
  
  /// Check if keyboard is visible
  bool get isKeyboardVisible => viewInsets.bottom > 0;
  
  /// Get keyboard height
  double get keyboardHeight => viewInsets.bottom;
  
  /// Get status bar height
  double get statusBarHeight => padding.top;
  
  /// Get bottom safe area height
  double get bottomSafeArea => padding.bottom;
  
  /// Show snackbar
  void showSnackBar(String message, {Duration? duration, Color? backgroundColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
        backgroundColor: backgroundColor,
      ),
    );
  }
  
  /// Hide keyboard
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
  
  /// Navigate to route
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }
  
  /// Navigate and replace current route
  Future<T?> pushReplacementNamed<T extends Object?>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushReplacementNamed<T, T>(routeName, arguments: arguments);
  }
  
  /// Pop current route
  void pop<T>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }
  
  /// Pop until route
  void popUntil(String routeName) {
    Navigator.of(this).popUntil(ModalRoute.withName(routeName));
  }
}

// ==================== DURATION EXTENSIONS ====================

extension DurationExtensions on Duration {
  /// Format duration to readable string
  String get formatted {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
  
  /// Get duration in milliseconds
  int get inMilliseconds => inMicroseconds ~/ 1000;
  
  /// Check if duration is positive
  bool get isPositive => inMicroseconds > 0;
  
  /// Check if duration is negative
  bool get isNegative => inMicroseconds < 0;
  
  /// Check if duration is zero
  bool get isZero => inMicroseconds == 0;
  
  /// Get absolute duration
  Duration get abs => Duration(microseconds: inMicroseconds.abs());
}

// ==================== HELPER FUNCTIONS ====================

/// Power function for extensions
num pow(num base, num exponent) {
  if (exponent == 0) return 1;
  if (exponent == 1) return base;
  
  num result = 1;
  for (int i = 0; i < exponent; i++) {
    result *= base;
  }
  return result;
}
