/// Input validation utilities for forms.
class Validators {
  Validators._();

  /// Validate email address.
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password (minimum 6 characters).
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validate strong password with requirements.
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  /// Validate password confirmation matches.
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate username.
  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.length > 20) {
      return 'Username must be at most 20 characters';
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  /// Validate phone number.
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validate required field.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate minimum length.
  static String? minLength(String? value, int min, [String fieldName = 'This field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  /// Validate maximum length.
  static String? maxLength(String? value, int max, [String fieldName = 'This field']) {
    if (value != null && value.length > max) {
      return '$fieldName must be at most $max characters';
    }
    return null;
  }

  /// Validate amount (positive number).
  static String? amount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  /// Validate minimum deposit amount.
  static String? minDeposit(String? value, double minAmount) {
    final amountError = amount(value);
    if (amountError != null) return amountError;

    final parsed = double.parse(value!);
    if (parsed < minAmount) {
      return 'Minimum deposit amount is ${minAmount.toStringAsFixed(0)}';
    }
    return null;
  }

  /// Validate team name for fantasy team.
  static String? teamName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Team name is required';
    }
    if (value.length < 3) {
      return 'Team name must be at least 3 characters';
    }
    if (value.length > 30) {
      return 'Team name must be at most 30 characters';
    }
    return null;
  }
}
