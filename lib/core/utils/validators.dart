import 'dart:io';

/// Comprehensive validation utilities for the Iris Analysis app
class Validators {
  
  // Private constructor to prevent instantiation
  Validators._();

  // Regular expressions for common validations
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _phoneRegex = RegExp(
    r'^\+?1?[2-9]\d{2}[2-9]\d{2}\d{4}$',
  );

  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]',
  );

  static final RegExp _nameRegex = RegExp(
    r"^[a-zA-Z\s\-\.\']+$",
  );

  static final RegExp _alphanumericRegex = RegExp(
    r'^[a-zA-Z0-9]+$',
  );

  static final RegExp _numericRegex = RegExp(
    r'^[0-9]+$',
  );

  static final RegExp _urlRegex = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  // ========================================
  // EMAIL VALIDATION
  // ========================================

  /// Validates email address format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }

    final email = value.trim().toLowerCase();
    
    if (!_emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    if (email.length > 254) {
      return 'Email address is too long';
    }

    // Check for common typos
    final commonDomains = ['gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com'];
    final domain = email.split('@').last;
    
    // Suggest corrections for common typos
    if (domain == 'gmial.com' || domain == 'gmai.com') {
      return 'Did you mean gmail.com?';
    }
    if (domain == 'yaho.com' || domain == 'yahooo.com') {
      return 'Did you mean yahoo.com?';
    }

    return null;
  }

  /// Validates email for medical/professional use
  static String? validateProfessionalEmail(String? value) {
    final basicValidation = validateEmail(value);
    if (basicValidation != null) return basicValidation;

    final email = value!.trim().toLowerCase();
    final blockedDomains = ['tempmail.com', '10minutemail.com', 'guerrillamail.com'];
    final domain = email.split('@').last;

    if (blockedDomains.contains(domain)) {
      return 'Please use a professional email address';
    }

    return null;
  }

  // ========================================
  // PASSWORD VALIDATION
  // ========================================

  /// Validates password strength with customizable requirements
  static String? validatePassword(String? value, {
    int minLength = 8,
    int maxLength = 128,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumbers = true,
    bool requireSymbols = true,
  }) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters long';
    }

    if (value.length > maxLength) {
      return 'Password must not exceed $maxLength characters';
    }

    final List<String> requirements = [];

    if (requireUppercase && !RegExp(r'[A-Z]').hasMatch(value)) {
      requirements.add('uppercase letter');
    }

    if (requireLowercase && !RegExp(r'[a-z]').hasMatch(value)) {
      requirements.add('lowercase letter');
    }

    if (requireNumbers && !RegExp(r'[0-9]').hasMatch(value)) {
      requirements.add('number');
    }

    if (requireSymbols && !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      requirements.add('special character');
    }

    if (requirements.isNotEmpty) {
      return 'Password must contain: ${requirements.join(', ')}';
    }

    // Check for common weak passwords
    final weakPasswords = [
      'password', '123456', 'password123', 'admin', 'qwerty',
      'letmein', 'welcome', 'monkey', '1234567890'
    ];

    if (weakPasswords.contains(value.toLowerCase())) {
      return 'This password is too common. Please choose a stronger one';
    }

    return null;
  }

  /// Validates password confirmation match
  static String? validatePasswordConfirmation(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Gets password strength score (0-100)
  static int getPasswordStrength(String password) {
    if (password.isEmpty) return 0;
    
    int score = 0;
    
    // Length bonus
    if (password.length >= 8) score += 25;
    if (password.length >= 12) score += 15;
    if (password.length >= 16) score += 10;
    
    // Character variety bonus
    if (RegExp(r'[a-z]').hasMatch(password)) score += 10;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 10;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 10;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score += 15;
    
    // Complexity bonus
    if (RegExp(r'[a-z].*[A-Z]|[A-Z].*[a-z]').hasMatch(password)) score += 5;
    
    return score > 100 ? 100 : score;
  }

  // ========================================
  // PHONE NUMBER VALIDATION
  // ========================================

  /// Validates phone number format
  static String? validatePhoneNumber(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Phone number is required' : null;
    }

    // Remove all non-digit characters
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      return 'Please enter a valid phone number';
    }

    // Check US phone number format
    if (digits.length == 10) {
      // Standard US number
      if (!RegExp(r'^[2-9]\d{2}[2-9]\d{2}\d{4}$').hasMatch(digits)) {
        return 'Please enter a valid US phone number';
      }
    } else if (digits.length == 11 && digits.startsWith('1')) {
      // US number with country code
      final withoutCountryCode = digits.substring(1);
      if (!RegExp(r'^[2-9]\d{2}[2-9]\d{2}\d{4}$').hasMatch(withoutCountryCode)) {
        return 'Please enter a valid US phone number';
      }
    } else {
      return 'Phone number must be 10 digits';
    }

    return null;
  }

  /// Validates international phone number
  static String? validateInternationalPhone(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Phone number is required' : null;
    }

    final digits = value.replaceAll(RegExp(r'\D'), '');
    
    if (digits.length < 7 || digits.length > 15) {
      return 'Phone number must be between 7 and 15 digits';
    }

    return null;
  }

  // ========================================
  // NAME VALIDATION
  // ========================================

  /// Validates person's name
  static String? validateName(String? value, {
    bool required = true,
    int minLength = 2,
    int maxLength = 50,
    String fieldName = 'Name',
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName is required' : null;
    }

    final name = value.trim();

    if (name.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    if (name.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }

    if (!_nameRegex.hasMatch(name)) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }

    // Check for repeated characters (likely spam)
    if (RegExp(r'(.)\1{4,}').hasMatch(name)) {
      return 'Please enter a valid $fieldName';
    }

    return null;
  }

  /// Validates first name
  static String? validateFirstName(String? value, {bool required = true}) {
    return validateName(value, required: required, fieldName: 'First name');
  }

  /// Validates last name
  static String? validateLastName(String? value, {bool required = true}) {
    return validateName(value, required: required, fieldName: 'Last name');
  }

  /// Validates full name
  static String? validateFullName(String? value, {bool required = true}) {
    final nameValidation = validateName(value, required: required, fieldName: 'Full name');
    if (nameValidation != null) return nameValidation;

    if (value != null && value.trim().isNotEmpty) {
      final parts = value.trim().split(RegExp(r'\s+'));
      if (parts.length < 2) {
        return 'Please enter both first and last name';
      }
    }

    return null;
  }

  // ========================================
  // DATE VALIDATION
  // ========================================

  /// Validates date of birth
  static String? validateDateOfBirth(DateTime? value, {bool required = true}) {
    if (value == null) {
      return required ? 'Date of birth is required' : null;
    }

    final now = DateTime.now();
    final age = now.year - value.year;

    if (value.isAfter(now)) {
      return 'Date of birth cannot be in the future';
    }

    if (age > 150) {
      return 'Please enter a valid date of birth';
    }

    if (age < 13) {
      return 'You must be at least 13 years old to use this app';
    }

    return null;
  }

  /// Validates age
  static String? validateAge(String? value, {
    bool required = true,
    int minAge = 13,
    int maxAge = 120,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Age is required' : null;
    }

    final age = int.tryParse(value.trim());
    if (age == null) {
      return 'Please enter a valid age';
    }

    if (age < minAge) {
      return 'Age must be at least $minAge';
    }

    if (age > maxAge) {
      return 'Please enter a valid age';
    }

    return null;
  }

  // ========================================
  // MEDICAL VALIDATION
  // ========================================

  /// Validates medical record number
  static String? validateMedicalRecordNumber(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Medical record number is required' : null;
    }

    final mrn = value.trim();

    if (mrn.length < 6 || mrn.length > 20) {
      return 'Medical record number must be between 6 and 20 characters';
    }

    if (!_alphanumericRegex.hasMatch(mrn)) {
      return 'Medical record number can only contain letters and numbers';
    }

    return null;
  }

  /// Validates height in feet and inches
  static String? validateHeight(String? feet, String? inches) {
    if (feet == null || feet.trim().isEmpty) {
      return 'Height is required';
    }

    final feetValue = int.tryParse(feet.trim());
    if (feetValue == null || feetValue < 3 || feetValue > 8) {
      return 'Please enter a valid height (3-8 feet)';
    }

    if (inches != null && inches.trim().isNotEmpty) {
      final inchesValue = int.tryParse(inches.trim());
      if (inchesValue == null || inchesValue < 0 || inchesValue >= 12) {
        return 'Inches must be between 0 and 11';
      }
    }

    return null;
  }

  /// Validates weight
  static String? validateWeight(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Weight is required' : null;
    }

    final weight = double.tryParse(value.trim());
    if (weight == null) {
      return 'Please enter a valid weight';
    }

    if (weight < 50 || weight > 800) {
      return 'Please enter a realistic weight (50-800 lbs)';
    }

    return null;
  }

  // ========================================
  // FILE VALIDATION
  // ========================================

  /// Validates file upload
  static String? validateFile(File? file, {
    bool required = true,
    List<String>? allowedExtensions,
    int? maxSizeInMB,
  }) {
    if (file == null) {
      return required ? 'File is required' : null;
    }

    if (!file.existsSync()) {
      return 'Selected file does not exist';
    }

    // Check file extension
    if (allowedExtensions != null && allowedExtensions.isNotEmpty) {
      final extension = file.path.split('.').last.toLowerCase();
      if (!allowedExtensions.contains(extension)) {
        return 'File must be one of: ${allowedExtensions.join(', ')}';
      }
    }

    // Check file size
    if (maxSizeInMB != null) {
      final fileSizeInMB = file.lengthSync() / (1024 * 1024);
      if (fileSizeInMB > maxSizeInMB) {
        return 'File size must not exceed ${maxSizeInMB}MB';
      }
    }

    return null;
  }

  /// Validates image file for iris analysis
  static String? validateIrisImage(File? file) {
    return validateFile(
      file,
      required: true,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      maxSizeInMB: 10,
    );
  }

  // ========================================
  // GENERAL VALIDATION
  // ========================================

  /// Validates required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates minimum length
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Validates maximum length
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    return null;
  }

  /// Validates numeric input
  static String? validateNumeric(String? value, String fieldName, {
    bool required = true,
    double? min,
    double? max,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName is required' : null;
    }

    final number = double.tryParse(value.trim());
    if (number == null) {
      return '$fieldName must be a valid number';
    }

    if (min != null && number < min) {
      return '$fieldName must be at least $min';
    }

    if (max != null && number > max) {
      return '$fieldName must not exceed $max';
    }

    return null;
  }

  /// Validates URL format
  static String? validateUrl(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'URL is required' : null;
    }

    if (!_urlRegex.hasMatch(value.trim())) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Validates credit card number using Luhn algorithm
  static String? validateCreditCard(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Credit card number is required';
    }

    final digits = value.replaceAll(RegExp(r'\D'), '');
    
    if (digits.length < 13 || digits.length > 19) {
      return 'Please enter a valid credit card number';
    }

    // Luhn algorithm
    int sum = 0;
    bool alternate = false;
    
    for (int i = digits.length - 1; i >= 0; i--) {
      int digit = int.parse(digits[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    if (sum % 10 != 0) {
      return 'Please enter a valid credit card number';
    }

    return null;
  }

  /// Validates CVV code
  static String? validateCVV(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CVV is required';
    }

    if (!RegExp(r'^\d{3,4}$').hasMatch(value.trim())) {
      return 'CVV must be 3 or 4 digits';
    }

    return null;
  }

  // ========================================
  // COMPOSITE VALIDATORS
  // ========================================

  /// Combines multiple validators
  static String? Function(String?) combineValidators(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }

  /// Creates a conditional validator
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

/// Extension methods for common validation patterns
extension StringValidation on String? {
  /// Checks if string is null or empty
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;
  
  /// Checks if string is a valid email
  bool get isValidEmail => this != null && Validators._emailRegex.hasMatch(this!);
  
  /// Checks if string contains only digits
  bool get isNumeric => this != null && Validators._numericRegex.hasMatch(this!);
  
  /// Checks if string is alphanumeric
  bool get isAlphanumeric => this != null && Validators._alphanumericRegex.hasMatch(this!);
}
