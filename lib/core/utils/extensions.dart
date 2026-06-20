import 'package:flutter/material.dart';

/// Extension methods for common operations.

/// String extensions.
extension StringExtensions on String {
  /// Capitalize the first letter.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize each word.
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Convert to initials (e.g., "John Doe" -> "JD").
  String get initials {
    if (isEmpty) return '';
    final words = trim().split(RegExp(r'\s+'));
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }

  /// Check if the string is a valid email.
  bool get isValidEmail {
    return RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    ).hasMatch(this);
  }

  /// Truncate string to a maximum length with ellipsis.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}

/// Number extensions.
extension NumberExtensions on num {
  /// Format as currency (Indian Rupee).
  String get toCurrency {
    if (this >= 10000000) {
      return '${(this / 10000000).toStringAsFixed(1)} Cr';
    } else if (this >= 100000) {
      return '${(this / 100000).toStringAsFixed(1)} L';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)} K';
    }
    return toStringAsFixed(0);
  }

  /// Format as exact currency with symbol.
  String get toExactCurrency => '\u20B9${toStringAsFixed(toInt() == this ? 0 : 2)}';

  /// Format as points.
  String get toPoints => '${toStringAsFixed(1)} pts';

  /// Format as credits.
  String get toCredits => '${toStringAsFixed(1)} Cr';
}

/// DateTime extensions.
extension DateTimeExtensions on DateTime {
  /// Check if this date is the same day as another.
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Check if this date is today.
  bool get isToday => isSameDay(DateTime.now());

  /// Check if this date is tomorrow.
  bool get isTomorrow =>
      isSameDay(DateTime.now().add(const Duration(days: 1)));

  /// Check if this date is in the past.
  bool get isPast => isBefore(DateTime.now());

  /// Check if this date is in the future.
  bool get isFuture => isAfter(DateTime.now());
}

/// BuildContext extensions.
extension ContextExtensions on BuildContext {
  /// Get the current theme.
  ThemeData get theme => Theme.of(this);

  /// Get the color scheme.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get the text theme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get screen width.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Get screen height.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Get screen padding (safe area).
  EdgeInsets get screenPadding => MediaQuery.paddingOf(this);

  /// Show a snackbar with a message.
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : Theme.of(this).colorScheme.secondary,
      ),
    );
  }

  /// Show a success snackbar.
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}

/// List extensions.
extension ListExtensions<T> on List<T> {
  /// Safely get element at index, returning null if out of bounds.
  T? safeGet(int index) {
    if (index >= 0 && index < length) return this[index];
    return null;
  }

  /// Split list into chunks of specified size.
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
}
