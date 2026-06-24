import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../wallet/domain/providers/wallet_provider.dart';

/// Dialog shown when the user's wallet balance is insufficient to join a contest.
///
/// Shows current balance, required entry fee, and a shortfall amount.
/// Has two actions: "Add Money" (opens wallet screen) and "Cancel".
class DepositPromptDialog extends ConsumerWidget {
  final double entryFee;
  final double currentBalance;

  const DepositPromptDialog({
    super.key,
    required this.entryFee,
    required this.currentBalance,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortfall = (entryFee - currentBalance).clamp(0.0, double.infinity);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLg),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.account_balance_wallet_outlined,
                  size: 30, color: AppColors.warning),
            ),
            AppSpacing.gapH16,

            // Title
            Text('Insufficient Balance',
                style: AppTypography.titleLarge
                    .copyWith(fontWeight: FontWeight.w700)),
            AppSpacing.gapH8,
            Text(
              'You don\'t have enough balance to join this contest.',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapH20,

            // Balance breakdown card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _BalanceRow(
                    label: 'Entry Fee',
                    value: '₹${entryFee.toStringAsFixed(0)}',
                    valueColor: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  const Divider(height: 16),
                  _BalanceRow(
                    label: 'Your Balance',
                    value: '₹${currentBalance.toStringAsFixed(0)}',
                    valueColor: AppColors.textSecondary,
                  ),
                  AppSpacing.gapH8,
                  _BalanceRow(
                    label: 'Amount Needed',
                    value: '₹${shortfall.toStringAsFixed(0)}',
                    valueColor: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ],
              ),
            ),
            AppSpacing.gapH24,

            // Add Money button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderRadiusMd),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  context.push('/wallet');     // open wallet screen
                },
                child: Text('ADD ₹${shortfall.toStringAsFixed(0)} TO WALLET',
                    style: AppTypography.labelLarge
                        .copyWith(color: Colors.white)),
              ),
            ),
            AppSpacing.gapH8,

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('CANCEL',
                    style: AppTypography.labelLarge
                        .copyWith(color: AppColors.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final FontWeight fontWeight;

  const _BalanceRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.fontWeight = FontWeight.w500,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textSecondary)),
        Text(value,
            style: AppTypography.bodyMedium.copyWith(
                color: valueColor, fontWeight: fontWeight)),
      ],
    );
  }
}

/// Convenience function to show the deposit prompt dialog.
Future<void> showDepositPrompt(
  BuildContext context, {
  required double entryFee,
  required double currentBalance,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => DepositPromptDialog(
      entryFee: entryFee,
      currentBalance: currentBalance,
    ),
  );
}
