import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/core/services/validation_service.dart';

void main() {
  group('ValidationService Tests', () {
    
    group('Email Validation', () {
      test('should return null for valid email addresses', () {
        // Valid email addresses
        final validEmails = [
          'test@example.com',
          'user.name@domain.co.uk',
          'user+tag@example.org',
          'user123@test-domain.com',
          'a@b.co',
        ];

        for (final email in validEmails) {
          expect(ValidationService.validateEmail(email), isNull, 
                 reason: 'Email $email should be valid');
        }
      });

      test('should return error for invalid email addresses', () {
        // Invalid email addresses
        final invalidEmails = [
          'invalid-email',
          '@example.com',
          'user@',
          'user@.com',
          'user..name@example.com',
          'user@example',
          '',
        ];

        for (final email in invalidEmails) {
          expect(ValidationService.validateEmail(email), isNotNull,
                 reason: 'Email $email should be invalid');
        }
      });

      test('should return error for null email', () {
        expect(ValidationService.validateEmail(null), equals('Email is required'));
      });

      test('should return error for empty email', () {
        expect(ValidationService.validateEmail(''), equals('Email is required'));
      });

      test('isValidEmail should return correct boolean values', () {
        expect(ValidationService.isValidEmail('test@example.com'), isTrue);
        expect(ValidationService.isValidEmail('invalid-email'), isFalse);
        expect(ValidationService.isValidEmail(null), isFalse);
      });
    });

    group('Password Validation', () {
      test('should return null for strong passwords', () {
        final strongPasswords = [
          'StrongPass123!',
          'MySecure@Password1',
          'Complex#Pass2023',
          'Secure\$123Password',
        ];

        for (final password in strongPasswords) {
          expect(ValidationService.validatePassword(password), isNull,
                 reason: 'Password $password should be valid');
        }
      });

      test('should return error for weak passwords', () {
        final weakPasswords = [
          'weak',           // Too short
          'password',       // No uppercase, numbers, special chars
          'PASSWORD',       // No lowercase, numbers, special chars
          '12345678',       // No letters, special chars
          'Password',       // No numbers, special chars
          'Password123',    // No special chars
          'Password!',      // No numbers
        ];

        for (final password in weakPasswords) {
          expect(ValidationService.validatePassword(password), isNotNull,
                 reason: 'Password $password should be invalid');
        }
      });

      test('should return error for null or empty password', () {
        expect(ValidationService.validatePassword(null), equals('Password is required'));
        expect(ValidationService.validatePassword(''), equals('Password is required'));
      });

      test('should return error for too long password', () {
        final longPassword = 'A' * 129 + '1!';
        expect(ValidationService.validatePassword(longPassword), 
               equals('Password must be less than 128 characters'));
      });

      test('should validate password confirmation correctly', () {
        expect(ValidationService.validatePasswordConfirmation('password', 'password'), isNull);
        expect(ValidationService.validatePasswordConfirmation('password', 'different'), 
               equals('Passwords do not match'));
        expect(ValidationService.validatePasswordConfirmation('password', null), 
               equals('Password confirmation is required'));
        expect(ValidationService.validatePasswordConfirmation('password', ''), 
               equals('Password confirmation is required'));
      });

      test('should assess password strength correctly', () {
        expect(ValidationService.getPasswordStrength(null), equals(PasswordStrength.none));
        expect(ValidationService.getPasswordStrength(''), equals(PasswordStrength.none));
        expect(ValidationService.getPasswordStrength('weak'), equals(PasswordStrength.weak));
        expect(ValidationService.getPasswordStrength('StrongPass123!'), equals(PasswordStrength.strong));
        expect(ValidationService.getPasswordStrength('password123'), equals(PasswordStrength.weak));
      });
    });

    group('Name Validation', () {
      test('should return null for valid names', () {
        final validNames = [
          'John',
          'Mary Jane',
          'O\'Connor',
          'Jean-Pierre',
          'Smith Jr',
        ];

        for (final name in validNames) {
          expect(ValidationService.validateName(name), isNull,
                 reason: 'Name $name should be valid');
        }
      });

      test('should return error for invalid names', () {
        expect(ValidationService.validateName(null), equals('Name is required'));
        expect(ValidationService.validateName(''), equals('Name is required'));
        expect(ValidationService.validateName('A'), equals('Name must be at least 2 characters long'));
        expect(ValidationService.validateName('A' * 51), equals('Name must be less than 50 characters'));
        expect(ValidationService.validateName('John123'), 
               contains('can only contain letters, spaces, hyphens, and apostrophes'));
      });

      test('should use custom field name in error messages', () {
        expect(ValidationService.validateName(null, fieldName: 'First Name'), 
               equals('First Name is required'));
        expect(ValidationService.validateName('A', fieldName: 'Last Name'), 
               equals('Last Name must be at least 2 characters long'));
      });
    });

    group('Task Validation', () {
      test('should validate task title correctly', () {
        expect(ValidationService.validateTaskTitle('Valid Task Title'), isNull);
        expect(ValidationService.validateTaskTitle(null), equals('Task title is required'));
        expect(ValidationService.validateTaskTitle(''), equals('Task title is required'));
        expect(ValidationService.validateTaskTitle('AB'), 
               equals('Task title must be at least 3 characters long'));
        expect(ValidationService.validateTaskTitle('A' * 101), 
               equals('Task title must be less than 100 characters'));
      });

      test('should validate task description correctly', () {
        expect(ValidationService.validateTaskDescription('Valid description'), isNull);
        expect(ValidationService.validateTaskDescription(null), isNull);
        expect(ValidationService.validateTaskDescription(''), isNull);
        expect(ValidationService.validateTaskDescription('A' * 1001), 
               equals('Task description must be less than 1000 characters'));
      });

      test('should validate task priority correctly', () {
        expect(ValidationService.validateTaskPriority('low'), isNull);
        expect(ValidationService.validateTaskPriority('medium'), isNull);
        expect(ValidationService.validateTaskPriority('high'), isNull);
        expect(ValidationService.validateTaskPriority('urgent'), isNull);
        expect(ValidationService.validateTaskPriority('LOW'), isNull); // Case insensitive
        expect(ValidationService.validateTaskPriority('invalid'), equals('Invalid task priority'));
        expect(ValidationService.validateTaskPriority(null), isNull);
      });

      test('should validate task status correctly', () {
        final validStatuses = ['todo', 'in_progress', 'review', 'completed', 'cancelled'];
        for (final status in validStatuses) {
          expect(ValidationService.validateTaskStatus(status), isNull);
          expect(ValidationService.validateTaskStatus(status.toUpperCase()), isNull);
        }
        expect(ValidationService.validateTaskStatus('invalid'), equals('Invalid task status'));
        expect(ValidationService.validateTaskStatus(null), isNull);
      });

      test('should validate due date correctly', () {
        final futureDate = DateTime.now().add(const Duration(days: 1));
        final pastDate = DateTime.now().subtract(const Duration(days: 2));
        
        expect(ValidationService.validateDueDate(futureDate), isNull);
        expect(ValidationService.validateDueDate(null), isNull);
        expect(ValidationService.validateDueDate(pastDate), 
               equals('Due date cannot be in the past'));
      });
    });

    group('Team Validation', () {
      test('should validate team name correctly', () {
        expect(ValidationService.validateTeamName('Valid Team'), isNull);
        expect(ValidationService.validateTeamName('Team-123'), isNull);
        expect(ValidationService.validateTeamName('Team_Name'), isNull);
        expect(ValidationService.validateTeamName(null), equals('Team name is required'));
        expect(ValidationService.validateTeamName(''), equals('Team name is required'));
        expect(ValidationService.validateTeamName('AB'), 
               equals('Team name must be at least 3 characters long'));
        expect(ValidationService.validateTeamName('A' * 51), 
               equals('Team name must be less than 50 characters'));
        expect(ValidationService.validateTeamName('Team@Name'), 
               contains('can only contain letters, numbers, spaces, hyphens, and underscores'));
      });

      test('should validate team description correctly', () {
        expect(ValidationService.validateTeamDescription('Valid description'), isNull);
        expect(ValidationService.validateTeamDescription(null), isNull);
        expect(ValidationService.validateTeamDescription(''), isNull);
        expect(ValidationService.validateTeamDescription('A' * 501), 
               equals('Team description must be less than 500 characters'));
      });
    });

    group('Project Validation', () {
      test('should validate project name correctly', () {
        expect(ValidationService.validateProjectName('Valid Project'), isNull);
        expect(ValidationService.validateProjectName(null), equals('Project name is required'));
        expect(ValidationService.validateProjectName(''), equals('Project name is required'));
        expect(ValidationService.validateProjectName('AB'), 
               equals('Project name must be at least 3 characters long'));
        expect(ValidationService.validateProjectName('A' * 101), 
               equals('Project name must be less than 100 characters'));
      });

      test('should validate project description correctly', () {
        expect(ValidationService.validateProjectDescription('Valid description'), isNull);
        expect(ValidationService.validateProjectDescription(null), isNull);
        expect(ValidationService.validateProjectDescription(''), isNull);
        expect(ValidationService.validateProjectDescription('A' * 1001), 
               equals('Project description must be less than 1000 characters'));
      });

      test('should validate project dates correctly', () {
        final now = DateTime.now();
        final startDate = now.add(const Duration(days: 1));
        final endDate = now.add(const Duration(days: 30));
        final pastStartDate = now.subtract(const Duration(days: 400));
        final futureEndDate = now.add(const Duration(days: 365 * 6));

        expect(ValidationService.validateProjectDates(startDate, endDate), isNull);
        expect(ValidationService.validateProjectDates(null, null), isNull);
        expect(ValidationService.validateProjectDates(endDate, startDate), 
               equals('End date cannot be before start date'));
        expect(ValidationService.validateProjectDates(pastStartDate, endDate), 
               equals('Start date cannot be more than a year in the past'));
        expect(ValidationService.validateProjectDates(startDate, futureEndDate), 
               equals('End date cannot be more than 5 years in the future'));
      });
    });

    group('File Validation', () {
      test('should validate file size correctly', () {
        expect(ValidationService.validateFileSize(null), isNull);
        expect(ValidationService.validateFileSize(1024 * 1024 * 5), isNull); // 5MB
        expect(ValidationService.validateFileSize(1024 * 1024 * 15), 
               equals('File size must be less than 10MB'));
        expect(ValidationService.validateFileSize(1024 * 1024 * 25, maxSizeMB: 20), isNull);
        expect(ValidationService.validateFileSize(1024 * 1024 * 25, maxSizeMB: 20), isNull);
      });

      test('should validate file type correctly', () {
        final allowedExtensions = ['jpg', 'png', 'pdf'];
        
        expect(ValidationService.validateFileType('image.jpg', allowedExtensions), isNull);
        expect(ValidationService.validateFileType('document.PDF', allowedExtensions), isNull);
        expect(ValidationService.validateFileType('file.txt', allowedExtensions), 
               contains('File type not allowed'));
        expect(ValidationService.validateFileType(null, allowedExtensions), isNull);
        expect(ValidationService.validateFileType('', allowedExtensions), isNull);
      });
    });

    group('URL Validation', () {
      test('should validate URLs correctly', () {
        final validUrls = [
          'https://example.com',
          'http://test.org',
          'https://subdomain.example.com/path',
          'http://localhost:3000',
        ];

        for (final url in validUrls) {
          expect(ValidationService.validateUrl(url), isNull,
                 reason: 'URL $url should be valid');
        }

        final invalidUrls = [
          'not-a-url',
          'ftp://example.com',
          'example.com',
          'https://',
        ];

        for (final url in invalidUrls) {
          expect(ValidationService.validateUrl(url), isNotNull,
                 reason: 'URL $url should be invalid');
        }

        expect(ValidationService.validateUrl(null), isNull);
        expect(ValidationService.validateUrl(''), isNull);
      });
    });

    group('Phone Number Validation', () {
      test('should validate phone numbers correctly', () {
        final validPhones = [
          '+1234567890',
          '(555) 123-4567',
          '555.123.4567',
          '5551234567',
          '+44 20 7946 0958',
        ];

        for (final phone in validPhones) {
          expect(ValidationService.validatePhoneNumber(phone), isNull,
                 reason: 'Phone $phone should be valid');
        }

        final invalidPhones = [
          '123',
          '12345678901234567890', // Too long
          'not-a-phone',
        ];

        for (final phone in invalidPhones) {
          expect(ValidationService.validatePhoneNumber(phone), isNotNull,
                 reason: 'Phone $phone should be invalid');
        }

        expect(ValidationService.validatePhoneNumber(null), isNull);
        expect(ValidationService.validatePhoneNumber(''), isNull);
      });
    });

    group('General Validation', () {
      test('should validate required fields correctly', () {
        expect(ValidationService.validateRequired('value', 'Field'), isNull);
        expect(ValidationService.validateRequired(null, 'Field'), equals('Field is required'));
        expect(ValidationService.validateRequired('', 'Field'), equals('Field is required'));
        expect(ValidationService.validateRequired([], 'Field'), equals('Field is required'));
        expect(ValidationService.validateRequired(['item'], 'Field'), isNull);
      });

      test('should validate minimum length correctly', () {
        expect(ValidationService.validateMinLength('hello', 3, 'Field'), isNull);
        expect(ValidationService.validateMinLength('hi', 3, 'Field'), 
               equals('Field must be at least 3 characters long'));
        expect(ValidationService.validateMinLength(null, 3, 'Field'), isNull);
      });

      test('should validate maximum length correctly', () {
        expect(ValidationService.validateMaxLength('hello', 10, 'Field'), isNull);
        expect(ValidationService.validateMaxLength('hello world!', 10, 'Field'), 
               equals('Field must be less than 10 characters'));
        expect(ValidationService.validateMaxLength(null, 10, 'Field'), isNull);
      });

      test('should validate numeric range correctly', () {
        expect(ValidationService.validateNumericRange(5, 1, 10, 'Field'), isNull);
        expect(ValidationService.validateNumericRange(0, 1, 10, 'Field'), 
               equals('Field must be between 1 and 10'));
        expect(ValidationService.validateNumericRange(15, 1, 10, 'Field'), 
               equals('Field must be between 1 and 10'));
        expect(ValidationService.validateNumericRange(null, 1, 10, 'Field'), isNull);
      });
    });

    group('Form Validation', () {
      test('should validate entire form correctly', () {
        final formData = {
          'email': 'test@example.com',
          'password': 'StrongPass123!',
          'name': 'John Doe',
        };

        final validators = {
          'email': [ValidationService.validateEmail],
          'password': [ValidationService.validatePassword],
          'name': [(value) => ValidationService.validateName(value)],
        };

        final errors = ValidationService.validateForm(formData, validators);
        expect(errors, isEmpty);
      });

      test('should return errors for invalid form data', () {
        final formData = {
          'email': 'invalid-email',
          'password': 'weak',
          'name': '',
        };

        final validators = {
          'email': [ValidationService.validateEmail],
          'password': [ValidationService.validatePassword],
          'name': [(value) => ValidationService.validateName(value)],
        };

        final errors = ValidationService.validateForm(formData, validators);
        expect(errors, isNotEmpty);
        expect(errors['email'], isNotNull);
        expect(errors['password'], isNotNull);
        expect(errors['name'], isNotNull);
      });

      test('should check form validity correctly', () {
        expect(ValidationService.isFormValid({}), isTrue);
        expect(ValidationService.isFormValid({'field': 'error'}), isFalse);
      });
    });
  });

  group('PasswordStrength Extension Tests', () {
    test('should return correct display names', () {
      expect(PasswordStrength.none.displayName, equals('None'));
      expect(PasswordStrength.weak.displayName, equals('Weak'));
      expect(PasswordStrength.medium.displayName, equals('Medium'));
      expect(PasswordStrength.strong.displayName, equals('Strong'));
    });

    test('should return correct strength values', () {
      expect(PasswordStrength.none.strengthValue, equals(0.0));
      expect(PasswordStrength.weak.strengthValue, equals(0.25));
      expect(PasswordStrength.medium.strengthValue, equals(0.5));
      expect(PasswordStrength.strong.strengthValue, equals(1.0));
    });
  });
}
