import '../constants/app_constants.dart';
import '../constants/strings.dart';

/// Validation utilities for form inputs and data validation
class Validators {
  // ==================== EMAIL VALIDATION ====================
  
  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredFieldError;
    }
    
    final emailRegex = RegExp(AppConstants.emailPattern);
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.emailInvalidError;
    }
    
    return null;
  }
  
  /// Check if email is valid (returns boolean)
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(AppConstants.emailPattern);
    return emailRegex.hasMatch(email);
  }
  
  // ==================== PASSWORD VALIDATION ====================
  
  /// Validate password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredFieldError;
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return AppStrings.passwordTooShortError;
    }
    
    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    // Check for at least one digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    // Check for at least one special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }
  
  /// Validate password confirmation
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredFieldError;
    }
    
    if (value != password) {
      return AppStrings.passwordMismatchError;
    }
    
    return null;
  }
  
  /// Check password strength level (0-4)
  static int getPasswordStrength(String password) {
    int strength = 0;
    
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    return strength;
  }
  
  /// Get password strength description
  static String getPasswordStrengthText(String password) {
    final strength = getPasswordStrength(password);
    switch (strength) {
      case 0:
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Medium';
      case 4:
        return 'Strong';
      case 5:
        return 'Very Strong';
      default:
        return 'Unknown';
    }
  }
  
  // ==================== PHONE VALIDATION ====================
  
  /// Validate phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredFieldError;
    }
    
    final phoneRegex = RegExp(AppConstants.phonePattern);
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  
  /// Check if phone number is valid
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(AppConstants.phonePattern);
    return phoneRegex.hasMatch(phone);
  }
  
  // ==================== NAME VALIDATION ====================
  
  /// Validate name (first name, last name, etc.)
  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredFieldError;
    }
    
    if (value.length < 2) {
      return '$fieldName must be at least 2 characters long';
    }
    
    if (value.length > 50) {
      return '$fieldName must be less than 50 characters';
    }
    
    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value)) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }
  
  // ==================== TASK VALIDATION ====================
  
  /// Validate task title
  static String? validateTaskTitle(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredFieldError;
    }
    
    if (value.length > AppConstants.maxTaskTitleLength) {
      return 'Task title must be less than ${AppConstants.maxTaskTitleLength} characters';
    }
    
    return null;
  }
  
  /// Validate task description
  static String? validateTaskDescription(String? value) {
    if (value != null && value.length > AppConstants.maxTaskDescriptionLength) {
      return 'Task description must be less than ${AppConstants.maxTaskDescriptionLength} characters';
    }
    
    return null;
  }
  
  // ==================== TEAM VALIDATION ====================
  
  /// Validate team name
  static String? validateTeamName(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredFieldError;
    }
    
    if (value.length < 3) {
      return 'Team name must be at least 3 characters long';
    }
    
    if (value.length > AppConstants.maxTeamNameLength) {
      return 'Team name must be less than ${AppConstants.maxTeamNameLength} characters';
    }
    
    return null;
  }
  
  // ==================== PROJECT VALIDATION ====================
  
  /// Validate project name
  static String? validateProjectName(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredFieldError;
    }
    
    if (value.length < 3) {
      return 'Project name must be at least 3 characters long';
    }
    
    if (value.length > AppConstants.maxProjectNameLength) {
      return 'Project name must be less than ${AppConstants.maxProjectNameLength} characters';
    }
    
    return null;
  }
  
  // ==================== DATE VALIDATION ====================
  
  /// Validate date is not in the past
  static String? validateFutureDate(DateTime? value) {
    if (value == null) {
      return AppStrings.requiredFieldError;
    }
    
    final now = DateTime.now();
    if (value.isBefore(DateTime(now.year, now.month, now.day))) {
      return 'Date cannot be in the past';
    }
    
    return null;
  }
  
  /// Validate date range (start date before end date)
  static String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return AppStrings.requiredFieldError;
    }
    
    if (startDate.isAfter(endDate)) {
      return 'Start date must be before end date';
    }
    
    return null;
  }
  
  // ==================== GENERAL VALIDATION ====================
  
  /// Validate required field
  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  /// Validate minimum length
  static String? validateMinLength(String? value, int minLength, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredFieldError;
    }
    
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }
    
    return null;
  }
  
  /// Validate maximum length
  static String? validateMaxLength(String? value, int maxLength, {String fieldName = 'Field'}) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }
    
    return null;
  }
  
  /// Validate numeric input
  static String? validateNumeric(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredFieldError;
    }
    
    if (double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    
    return null;
  }
  
  /// Validate integer input
  static String? validateInteger(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredFieldError;
    }
    
    if (int.tryParse(value) == null) {
      return '$fieldName must be a valid integer';
    }
    
    return null;
  }
  
  /// Validate positive number
  static String? validatePositiveNumber(String? value, {String fieldName = 'Field'}) {
    final numericValidation = validateNumeric(value, fieldName: fieldName);
    if (numericValidation != null) return numericValidation;
    
    final number = double.parse(value!);
    if (number <= 0) {
      return '$fieldName must be a positive number';
    }
    
    return null;
  }
  
  /// Validate URL format
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredFieldError;
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }
  
  // ==================== FILE VALIDATION ====================
  
  /// Validate file size
  static String? validateFileSize(int fileSizeInBytes, {int? maxSizeInBytes}) {
    final maxSize = maxSizeInBytes ?? AppConstants.maxFileSize;
    
    if (fileSizeInBytes > maxSize) {
      final maxSizeMB = (maxSize / (1024 * 1024)).toStringAsFixed(1);
      return 'File size must be less than ${maxSizeMB}MB';
    }
    
    return null;
  }
  
  /// Validate file type
  static String? validateFileType(String fileName, List<String> allowedTypes) {
    final extension = fileName.split('.').last.toLowerCase();
    
    if (!allowedTypes.contains(extension)) {
      return 'File type not supported. Allowed types: ${allowedTypes.join(', ')}';
    }
    
    return null;
  }
  
  /// Validate image file
  static String? validateImageFile(String fileName) {
    return validateFileType(fileName, AppConstants.allowedImageTypes);
  }
  
  /// Validate document file
  static String? validateDocumentFile(String fileName) {
    return validateFileType(fileName, AppConstants.allowedDocumentTypes);
  }
  
  // ==================== COMPOSITE VALIDATORS ====================
  
  /// Combine multiple validators
  static String? Function(String?) combineValidators(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
  
  /// Create conditional validator
  static String? Function(String?) conditionalValidator(
    bool Function() condition,
    String? Function(String?) validator,
  ) {
    return (String? value) {
      if (condition()) {
        return validator(value);
      }
      return null;
    };
  }
}
