/// Input Validators
/// Common validation functions for form inputs

class Validators {
  /// Validate required field
  static String? required(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate phone number
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^\d{10}$').hasMatch(cleaned)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  /// Validate patient ID
  static String? patientId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Patient ID is required';
    }
    if (value.length < 3) {
      return 'Patient ID must be at least 3 characters';
    }
    return null;
  }

  /// Validate doctor ID
  static String? doctorId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Doctor ID is required';
    }
    if (value.length < 3) {
      return 'Doctor ID must be at least 3 characters';
    }
    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int min, [String fieldName = 'Field']) {
    if (value == null || value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  /// Validate maximum length
  static String? maxLength(String? value, int max, [String fieldName = 'Field']) {
    if (value != null && value.length > max) {
      return '$fieldName must be at most $max characters';
    }
    return null;
  }

  /// Validate SSN format (for detection, not input)
  static bool isSSN(String value) {
    return RegExp(r'^\d{3}-\d{2}-\d{4}$').hasMatch(value);
  }

  /// Validate MRN (Medical Record Number)
  static String? mrn(String? value) {
    if (value == null || value.isEmpty) {
      return 'MRN is required';
    }
    if (!RegExp(r'^[A-Z0-9]{6,10}$').hasMatch(value.toUpperCase())) {
      return 'Please enter a valid MRN (6-10 alphanumeric characters)';
    }
    return null;
  }

  /// Combine multiple validators
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
