import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';

/// Premium card widget with elevation, shadows, and design system integration.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final LinearGradient? gradient;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.onTap,
    this.width,
    this.height,
    this.gradient,
  });

  /// Elevated card with medium shadow.
  factory AppCard.elevated({
    Key? key,
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    VoidCallback? onTap,
    double? width,
    double? height,
  }) {
    return AppCard(
      key: key,
      padding: padding ?? AppSpacing.cardPadding,
      margin: margin,
      boxShadow: AppTheme.shadowMd,
      onTap: onTap,
      width: width,
      height: height,
      child: child,
    );
  }

  /// Gradient card with custom gradient or primary gradient.
  factory AppCard.gradient({
    Key? key,
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    VoidCallback? onTap,
    LinearGradient? gradient,
    double? width,
    double? height,
  }) {
    return AppCard(
      key: key,
      padding: padding ?? AppSpacing.cardPadding,
      margin: margin,
      gradient: gradient ?? AppColors.primaryGradient,
      boxShadow: AppTheme.shadowMd,
      onTap: onTap,
      width: width,
      height: height,
      child: child,
    );
  }

  /// Outlined card with border and no shadow.
  factory AppCard.outlined({
    Key? key,
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    VoidCallback? onTap,
    double? width,
    double? height,
  }) {
    return AppCard(
      key: key,
      padding: padding ?? AppSpacing.cardPadding,
      margin: margin,
      border: Border.all(color: AppColors.border, width: 1),
      onTap: onTap,
      width: width,
      height: height,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: width,
      height: height,
      padding: padding ?? AppSpacing.cardPadding,
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null
            ? (backgroundColor ?? AppColors.card)
            : null,
        gradient: gradient,
        borderRadius: borderRadius ?? AppSpacing.borderRadiusMd,
        border: border,
        boxShadow: boxShadow ?? AppTheme.shadowSm,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
