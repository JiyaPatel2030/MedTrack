import 'constants.dart';

/// Form input validators for MedTrack application

class Validators {
  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }

    const emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(emailRegex);

    if (!regex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirm(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate full name
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }

    final trimmed = value.trim();

    if (trimmed.length < AppConstants.minNameLength ||
        trimmed.length > AppConstants.maxNameLength) {
      return 'Name must be between ${AppConstants.minNameLength} and ${AppConstants.maxNameLength} characters';
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(trimmed)) {
      return 'Name can only contain letters and spaces';
    }

    return null;
  }

  /// Validate medicine name
  static String? validateMedicineName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter medicine name';
    }

    final trimmed = value.trim();

    if (trimmed.length < 2 || trimmed.length > 50) {
      return 'Medicine name must be between 2 and 50 characters';
    }

    return null;
  }

  /// Validate quantity
  static String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter quantity';
    }

    final quantity = int.tryParse(value.trim());

    if (quantity == null || quantity <= 0 || quantity > 10000) {
      return 'Please enter a valid quantity (1-10000)';
    }

    return null;
  }

  /// Validate expiry date
  static String? validateExpiryDate(DateTime? selectedDate) {
    if (selectedDate == null) {
      return 'Please select an expiry date';
    }

    return null;
  }
}