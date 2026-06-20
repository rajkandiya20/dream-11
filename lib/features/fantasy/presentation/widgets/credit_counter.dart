import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Animated credit counter bar showing used/remaining credits out of 100.
class CreditCounter extends StatelessWidget {
  final double creditsUsed;
  final double maxCredits;

  const CreditCounter({
    super.key,
    required this.creditsUsed,
    this.maxCredits = 100.0,
  });

  double get creditsRemaining => maxCredits - creditsUsed;
  double get fillPercentage => creditsUsed / maxCredits;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Credits used
              Row(
                children: [
                  Icon(
                    Icons.monetization_on_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  AppSpacing.gapW4,
                  Text(
                    'Credits Used',
                    style: AppTypography.labelSmall,
                  ),
                ],
              ),
              // Credits value
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: creditsUsed.toStringAsFixed(1),
                      style: AppTypography.titleMedium.copyWith(
                        color: fillPercentage > 0.9
                            ? AppColors.error
                            : AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: ' / ${maxCredits.toStringAsFixed(0)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapH8,
          // Animated progress bar
          ClipRRect(
            borderRadius: AppSpacing.borderRadiusFull,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: 6,
              child: LinearProgressIndicator(
                value: fillPercentage.clamp(0.0, 1.0),
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  fillPercentage > 0.9
                      ? AppColors.error
                      : fillPercentage > 0.7
                          ? AppColors.warning
                          : AppColors.primary,
                ),
              ),
            ),
          ),
          AppSpacing.gapH4,
          // Remaining credits text
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${creditsRemaining.toStringAsFixed(1)} credits remaining',
              style: AppTypography.labelSmall.copyWith(
                color: creditsRemaining < 5
                    ? AppColors.error
                    : AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
