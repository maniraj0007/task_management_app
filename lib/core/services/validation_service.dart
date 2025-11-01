import 'package:get/get.dart';

/// Data Validation Service
/// Provides comprehensive input validation and error handling
class ValidationService extends GetxService {
  
  // ==================== EMAIL VALIDATION ====================
  
  /// Validate email address
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  /// Check if email is valid
  static bool isValidEmail(String? email) {
    return validateEmail(email) == null;
  }
  
  // ==================== PASSWORD VALIDATION ====================
  
  /// Validate password with comprehensive rules
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    if (password.length > 128) {
      return 'Password must be less than 128 characters';
    }
    
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    
    // Check for at least one digit
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    
    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }
  
  /// Validate password confirmation
  static String? validatePasswordConfirmation(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Password confirmation is required';
    }
    
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  /// Check password strength
  static PasswordStrength getPasswordStrength(String? password) {
    if (password == null || password.isEmpty) {
      return PasswordStrength.none;
    }
    
    int score = 0;
    
    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    
    // Character variety checks
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    
    // Common patterns check (negative score)
    if (RegExp(r'(123|abc|password|qwerty)', caseSensitive: false).hasMatch(password)) {
      score -= 2;
    }
    
    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }
  
  // ==================== NAME VALIDATION ====================
  
  /// Validate name (first name, last name, etc.)
  static String? validateName(String? name, {String fieldName = 'Name'}) {
    if (name == null || name.isEmpty) {
      return '$fieldName is required';
    }
    
    if (name.length < 2) {
      return '$fieldName must be at least 2 characters long';
    }
    
    if (name.length > 50) {
      return '$fieldName must be less than 50 characters';
    }
    
    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(name)) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }
  
  // ==================== TASK VALIDATION ====================
  
  /// Validate task title
  static String? validateTaskTitle(String? title) {
    if (title == null || title.isEmpty) {
      return 'Task title is required';
    }
    
    if (title.length < 3) {
      return 'Task title must be at least 3 characters long';
    }
    
    if (title.length > 100) {
      return 'Task title must be less than 100 characters';
    }
    
    return null;
  }
  
  /// Validate task description
  static String? validateTaskDescription(String? description) {
    if (description != null && description.length > 1000) {
      return 'Task description must be less than 1000 characters';
    }
    
    return null;
  }
  
  /// Validate task priority
  static String? validateTaskPriority(String? priority) {
    const validPriorities = ['low', 'medium', 'high', 'urgent'];
    
    if (priority != null && !validPriorities.contains(priority.toLowerCase())) {
      return 'Invalid task priority';
    }
    
    return null;
  }
  
  /// Validate task status
  static String? validateTaskStatus(String? status) {
    const validStatuses = ['todo', 'in_progress', 'review', 'completed', 'cancelled'];
    
    if (status != null && !validStatuses.contains(status.toLowerCase())) {
      return 'Invalid task status';
    }
    
    return null;
  }
  
  /// Validate due date
  static String? validateDueDate(DateTime? dueDate) {
    if (dueDate != null && dueDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return 'Due date cannot be in the past';
    }
    
    return null;
  }
  
  // ==================== TEAM VALIDATION ====================
  
  /// Validate team name
  static String? validateTeamName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Team name is required';
    }
    
    if (name.length < 3) {
      return 'Team name must be at least 3 characters long';
    }
    
    if (name.length > 50) {
      return 'Team name must be less than 50 characters';
    }
    
    // Check for valid characters
    if (!RegExp(r"^[a-zA-Z0-9\s\-_]+$").hasMatch(name)) {
      return 'Team name can only contain letters, numbers, spaces, hyphens, and underscores';
    }
    
    return null;
  }
  
  /// Validate team description
  static String? validateTeamDescription(String? description) {
    if (description != null && description.length > 500) {
      return 'Team description must be less than 500 characters';
    }
    
    return null;
  }
  
  // ==================== PROJECT VALIDATION ====================
  
  /// Validate project name
  static String? validateProjectName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Project name is required';
    }
    
    if (name.length < 3) {
      return 'Project name must be at least 3 characters long';
    }
    
    if (name.length > 100) {
      return 'Project name must be less than 100 characters';
    }
    
    return null;
  }
  
  /// Validate project description
  static String? validateProjectDescription(String? description) {
    if (description != null && description.length > 1000) {
      return 'Project description must be less than 1000 characters';
    }
    
    return null;
  }
  
  /// Validate project dates
  static String? validateProjectDates(DateTime? startDate, DateTime? endDate) {
    if (startDate != null && endDate != null) {
      if (endDate.isBefore(startDate)) {
        return 'End date cannot be before start date';
      }
      
      if (startDate.isBefore(DateTime.now().subtract(const Duration(days: 365)))) {
        return 'Start date cannot be more than a year in the past';
      }
      
      if (endDate.isAfter(DateTime.now().add(const Duration(days: 365 * 5)))) {
        return 'End date cannot be more than 5 years in the future';
      }
    }
    
    return null;
  }
  
  // ==================== SEARCH VALIDATION ====================
  
  /// Validate search query
  static String? validateSearchQuery(String? query) {
    if (query != null && query.length > 200) {
      return 'Search query must be less than 200 characters';
    }
    
    // Check for potentially harmful characters
    if (query != null && RegExp(r'[<>]').hasMatch(query)) {
      return 'Search query contains invalid characters';
    }
    
    return null;
  }
  
  // ==================== FILE VALIDATION ====================
  
  /// Validate file size
  static String? validateFileSize(int? fileSizeBytes, {int maxSizeMB = 10}) {
    if (fileSizeBytes == null) return null;
    
    final maxSizeBytes = maxSizeMB * 1024 * 1024;
    if (fileSizeBytes > maxSizeBytes) {
      return 'File size must be less than ${maxSizeMB}MB';
    }
    
    return null;
  }
  
  /// Validate file type
  static String? validateFileType(String? fileName, List<String> allowedExtensions) {
    if (fileName == null || fileName.isEmpty) return null;
    
    final extension = fileName.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return 'File type not allowed. Allowed types: ${allowedExtensions.join(', ')}';
    }
    
    return null;
  }
  
  // ==================== URL VALIDATION ====================
  
  /// Validate URL
  static String? validateUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    
    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return 'Please enter a valid URL starting with http:// or https://';
      }
    } catch (e) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }
  
  // ==================== PHONE VALIDATION ====================
  
  /// Validate phone number
  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return null;
    
    // Remove all non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  
  // ==================== GENERAL VALIDATION ====================
  
  /// Validate required field
  static String? validateRequired(dynamic value, String fieldName) {
    if (value == null || 
        (value is String && value.isEmpty) ||
        (value is List && value.isEmpty)) {
      return '$fieldName is required';
    }
    
    return null;
  }
  
  /// Validate minimum length
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value != null && value.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }
    
    return null;
  }
  
  /// Validate maximum length
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }
    
    return null;
  }
  
  /// Validate numeric range
  static String? validateNumericRange(num? value, num min, num max, String fieldName) {
    if (value != null && (value < min || value > max)) {
      return '$fieldName must be between $min and $max';
    }
    
    return null;
  }
  
  // ==================== FORM VALIDATION ====================
  
  /// Validate entire form
  static Map<String, String> validateForm(Map<String, dynamic> formData, Map<String, List<String Function(dynamic)>> validators) {
    final errors = <String, String>{};
    
    for (final entry in validators.entries) {
      final fieldName = entry.key;
      final fieldValidators = entry.value;
      final fieldValue = formData[fieldName];
      
      for (final validator in fieldValidators) {
        final error = validator(fieldValue);
        if (error != null) {
          errors[fieldName] = error;
          break; // Stop at first error for this field
        }
      }
    }
    
    return errors;
  }
  
  /// Check if form is valid
  static bool isFormValid(Map<String, String> errors) {
    return errors.isEmpty;
  }
}

/// Password strength enum
enum PasswordStrength {
  none,
  weak,
  medium,
  strong,
}

/// Extension for password strength
extension PasswordStrengthExtension on PasswordStrength {
  String get displayName {
    switch (this) {
      case PasswordStrength.none:
        return 'None';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }
  
  double get strengthValue {
    switch (this) {
      case PasswordStrength.none:
        return 0.0;
      case PasswordStrength.weak:
        return 0.25;
      case PasswordStrength.medium:
        return 0.5;
      case PasswordStrength.strong:
        return 1.0;
    }
  }
}
