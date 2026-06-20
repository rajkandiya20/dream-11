import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Complete application theme with Material 3 configuration.
class AppTheme {
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      appBarTheme: _appBarTheme,
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      bottomNavigationBarTheme: _bottomNavBarTheme,
      chipTheme: _chipTheme,
      dividerTheme: _dividerTheme,
      snackBarTheme: _snackBarTheme,
      dialogTheme: _dialogTheme,
      bottomSheetTheme: _bottomSheetTheme,
      textTheme: _textTheme,
      floatingActionButtonTheme: _fabTheme,
      tabBarTheme: _tabBarTheme,
    );
  }

  // Color Scheme
  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.textOnPrimary,
    primaryContainer: AppColors.primaryLight,
    secondary: AppColors.secondary,
    onSecondary: AppColors.textOnSecondary,
    secondaryContainer: AppColors.secondaryLight,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    error: AppColors.error,
    onError: AppColors.textOnPrimary,
    outline: AppColors.border,
  );

  // AppBar Theme
  static final AppBarTheme _appBarTheme = AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 0.5,
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    surfaceTintColor: Colors.transparent,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    titleTextStyle: AppTypography.headlineSmall,
    centerTitle: true,
    iconTheme: const IconThemeData(
      color: AppColors.textPrimary,
      size: 24,
    ),
  );

  // Card Theme
  static final CardTheme _cardTheme = CardTheme(
    elevation: 0,
    color: AppColors.card,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: AppSpacing.borderRadiusMd,
      side: const BorderSide(color: AppColors.border, width: 1),
    ),
    margin: EdgeInsets.zero,
  );

  // Elevated Button Theme
  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      textStyle: AppTypography.buttonMedium,
      minimumSize: const Size(double.infinity, 48),
    ),
  );

  // Outlined Button Theme
  static final OutlinedButtonThemeData _outlinedButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      side: const BorderSide(color: AppColors.primary, width: 1.5),
      textStyle: AppTypography.buttonMedium.copyWith(color: AppColors.primary),
      minimumSize: const Size(double.infinity, 48),
    ),
  );

  // Text Button Theme
  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: AppTypography.buttonMedium.copyWith(color: AppColors.primary),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );

  // Input Decoration Theme
  static final InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: AppSpacing.borderRadiusMd,
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppSpacing.borderRadiusMd,
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppSpacing.borderRadiusMd,
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppSpacing.borderRadiusMd,
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppSpacing.borderRadiusMd,
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
    labelStyle: AppTypography.labelMedium,
    errorStyle: AppTypography.labelSmall.copyWith(color: AppColors.error),
  );

  // Bottom Navigation Bar Theme
  static const BottomNavigationBarThemeData _bottomNavBarTheme =
      BottomNavigationBarThemeData(
    elevation: 8,
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textTertiary,
    type: BottomNavigationBarType.fixed,
    showUnselectedLabels: true,
  );

  // Chip Theme
  static final ChipThemeData _chipTheme = ChipThemeData(
    backgroundColor: AppColors.background,
    selectedColor: AppColors.primaryLight,
    labelStyle: AppTypography.labelMedium,
    shape: RoundedRectangleBorder(
      borderRadius: AppSpacing.borderRadiusFull,
      side: const BorderSide(color: AppColors.border),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  );

  // Divider Theme
  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: AppColors.divider,
    thickness: 1,
    space: 1,
  );

  // SnackBar Theme
  static final SnackBarThemeData _snackBarTheme = SnackBarThemeData(
    backgroundColor: AppColors.secondary,
    contentTextStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.textOnSecondary,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: AppSpacing.borderRadiusMd,
    ),
    behavior: SnackBarBehavior.floating,
    elevation: 4,
  );

  // Dialog Theme
  static final DialogTheme _dialogTheme = DialogTheme(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: AppSpacing.borderRadiusXl,
    ),
    titleTextStyle: AppTypography.headlineSmall,
    contentTextStyle: AppTypography.bodyMedium,
  );

  // Bottom Sheet Theme
  static final BottomSheetThemeData _bottomSheetTheme = BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusXl),
      ),
    ),
    showDragHandle: true,
    dragHandleColor: AppColors.border,
  );

  // Text Theme
  static final TextTheme _textTheme = TextTheme(
    displayLarge: AppTypography.displayLarge,
    displayMedium: AppTypography.displayMedium,
    displaySmall: AppTypography.displaySmall,
    headlineLarge: AppTypography.headlineLarge,
    headlineMedium: AppTypography.headlineMedium,
    headlineSmall: AppTypography.headlineSmall,
    titleLarge: AppTypography.titleLarge,
    titleMedium: AppTypography.titleMedium,
    titleSmall: AppTypography.titleSmall,
    bodyLarge: AppTypography.bodyLarge,
    bodyMedium: AppTypography.bodyMedium,
    bodySmall: AppTypography.bodySmall,
    labelLarge: AppTypography.labelLarge,
    labelMedium: AppTypography.labelMedium,
    labelSmall: AppTypography.labelSmall,
  );

  // FAB Theme
  static const FloatingActionButtonThemeData _fabTheme =
      FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textOnPrimary,
    elevation: 4,
    shape: CircleBorder(),
  );

  // Tab Bar Theme
  static final TabBarTheme _tabBarTheme = TabBarTheme(
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.textTertiary,
    labelStyle: AppTypography.labelLarge,
    unselectedLabelStyle: AppTypography.labelMedium,
    indicatorColor: AppColors.primary,
    indicatorSize: TabBarIndicatorSize.label,
    dividerColor: AppColors.border,
  );

  // Shadows
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get shadowXl => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];
}
