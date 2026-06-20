import 'package:flutter/material.dart';

/// Application color palette based on the design system.
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFFE11D48);
  static const Color primaryLight = Color(0xFFFB7185);
  static const Color primaryDark = Color(0xFFBE123C);

  // Secondary Colors
  static const Color secondary = Color(0xFF0F172A);
  static const Color secondaryLight = Color(0xFF1E293B);
  static const Color secondaryDark = Color(0xFF020617);

  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFF86EFAC);
  static const Color successDark = Color(0xFF16A34A);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFCD34D);
  static const Color warningDark = Color(0xFFD97706);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF93C5FD);
  static const Color infoDark = Color(0xFF2563EB);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFCA5A5);
  static const Color errorDark = Color(0xFFDC2626);

  // Background Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = Color(0xFFF8FAFC);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Border Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, successDark],
  );

  // Match Status Colors
  static const Color liveMatch = Color(0xFFEF4444);
  static const Color upcomingMatch = Color(0xFF3B82F6);
  static const Color completedMatch = Color(0xFF22C55E);

  // Shimmer Colors
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);
}
