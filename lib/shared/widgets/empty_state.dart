import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'app_button.dart';

/// Empty state widget with illustration, message, and optional retry action.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionText;
  final VoidCallback? onAction;
  final double iconSize;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionText,
    this.onAction,
    this.iconSize = 80,
  });

  /// Empty state for no data.
  factory EmptyState.noData({
    Key? key,
    String title = 'No Data Found',
    String? message,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.inbox_outlined,
      title: title,
      message: message,
      actionText: actionText,
      onAction: onAction,
    );
  }

  /// Empty state for network errors.
  factory EmptyState.error({
    Key? key,
    String title = 'Something Went Wrong',
    String? message = 'Please check your connection and try again.',
    String actionText = 'Retry',
    VoidCallback? onAction,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.error_outline,
      title: title,
      message: message,
      actionText: actionText,
      onAction: onAction,
    );
  }

  /// Empty state for no search results.
  factory EmptyState.noResults({
    Key? key,
    String title = 'No Results',
    String? message = 'Try adjusting your search or filters.',
  }) {
    return EmptyState(
      key: key,
      icon: Icons.search_off_outlined,
      title: title,
      message: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXxl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconSize + 40,
              height: iconSize + 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: AppColors.primary.withOpacity(0.4),
              ),
            ),
            AppSpacing.gapH24,
            Text(
              title,
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              AppSpacing.gapH8,
              Text(
                message!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              AppSpacing.gapH24,
              AppButton(
                text: actionText!,
                onPressed: onAction,
                variant: AppButtonVariant.outline,
                size: AppButtonSize.medium,
                width: 180,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
