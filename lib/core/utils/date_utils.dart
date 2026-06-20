import 'package:intl/intl.dart';

/// Utility class for date and time operations.
class AppDateUtils {
  AppDateUtils._();

  // Date Formats
  static final DateFormat _fullDate = DateFormat('dd MMM yyyy');
  static final DateFormat _shortDate = DateFormat('dd MMM');
  static final DateFormat _time = DateFormat('hh:mm a');
  static final DateFormat _dateTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _dayMonth = DateFormat('dd MMM');
  static final DateFormat _monthYear = DateFormat('MMM yyyy');
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');
  static final DateFormat _dayOfWeek = DateFormat('EEEE');

  /// Format a DateTime to full date string (e.g., "15 Jan 2024").
  static String formatFullDate(DateTime date) => _fullDate.format(date);

  /// Format a DateTime to short date string (e.g., "15 Jan").
  static String formatShortDate(DateTime date) => _shortDate.format(date);

  /// Format a DateTime to time string (e.g., "03:30 PM").
  static String formatTime(DateTime date) => _time.format(date);

  /// Format a DateTime to date and time string (e.g., "15 Jan 2024, 03:30 PM").
  static String formatDateTime(DateTime date) => _dateTime.format(date);

  /// Format a DateTime to day and month (e.g., "15 Jan").
  static String formatDayMonth(DateTime date) => _dayMonth.format(date);

  /// Format a DateTime to month and year (e.g., "Jan 2024").
  static String formatMonthYear(DateTime date) => _monthYear.format(date);

  /// Format a DateTime to ISO date string (e.g., "2024-01-15").
  static String formatIsoDate(DateTime date) => _isoDate.format(date);

  /// Format a DateTime to day of week (e.g., "Monday").
  static String formatDayOfWeek(DateTime date) => _dayOfWeek.format(date);

  /// Get relative time string (e.g., "2 hours ago", "Just now").
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Get countdown string for upcoming matches (e.g., "2h 30m", "3d 5h").
  static String getCountdown(DateTime targetDate) {
    final now = DateTime.now();
    final difference = targetDate.difference(now);

    if (difference.isNegative) {
      return 'Started';
    }

    if (difference.inDays > 0) {
      final hours = difference.inHours % 24;
      return '${difference.inDays}d ${hours}h';
    } else if (difference.inHours > 0) {
      final minutes = difference.inMinutes % 60;
      return '${difference.inHours}h ${minutes}m';
    } else if (difference.inMinutes > 0) {
      final seconds = difference.inSeconds % 60;
      return '${difference.inMinutes}m ${seconds}s';
    } else {
      return '${difference.inSeconds}s';
    }
  }

  /// Check if a date is today.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if a date is tomorrow.
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Check if a date is in the past.
  static bool isPast(DateTime date) => date.isBefore(DateTime.now());

  /// Check if a date is in the future.
  static bool isFuture(DateTime date) => date.isAfter(DateTime.now());

  /// Parse a date string from Supabase (ISO 8601 format).
  static DateTime? parseSupabaseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    return DateTime.tryParse(dateString);
  }

  /// Get match day label (e.g., "Today", "Tomorrow", "15 Jan").
  static String getMatchDayLabel(DateTime matchDate) {
    if (isToday(matchDate)) return 'Today';
    if (isTomorrow(matchDate)) return 'Tomorrow';
    return formatShortDate(matchDate);
  }
}
