import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Dream11-style contest join confirmation bottom sheet.
///
/// Shows entry fee, usable cash bonus, total to pay, T&C checkbox,
/// and a Join button. Ported from Fantasy- confirmcontest.js.
class ConfirmContestBottomSheet extends StatefulWidget {
  final double entryFee;
  final double totalBalance;
  final double cashBonus;
  final String contestName;
  final VoidCallback onConfirm;

  const ConfirmContestBottomSheet({
    super.key,
    required this.entryFee,
    required this.totalBalance,
    required this.cashBonus,
    required this.contestName,
    required this.onConfirm,
  });

  @override
  State<ConfirmContestBottomSheet> createState() =>
      _ConfirmContestBottomSheetState();
}

class _ConfirmContestBottomSheetState
    extends State<ConfirmContestBottomSheet> {
  bool _acceptedTerms = false;
  bool _isJoining = false;

  // How much bonus can be used (max 25% of entry fee or available bonus)
  double get _usableBonus {
    final maxBonus = widget.entryFee * 0.25;
    return widget.cashBonus < maxBonus ? widget.cashBonus : maxBonus;
  }

  double get _toPay => (widget.entryFee - _usableBonus).clamp(0, widget.entryFee);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: AppSpacing.borderRadiusFull,
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Confirm & Join',
                        style: AppTypography.titleLarge
                            .copyWith(fontWeight: FontWeight.w700)),
                    Text(widget.contestName,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Fee breakdown
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _BreakdownRow(
                    label: 'Entry Fee',
                    value: '₹${widget.entryFee.toStringAsFixed(0)}',
                    labelStyle: AppTypography.bodySmall,
                    valueStyle: AppTypography.bodySmall
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (_usableBonus > 0) ...[
                    Divider(
                        height: 1,
                        color: AppColors.border.withOpacity(0.5)),
                    _BreakdownRow(
                      label: 'Cash Bonus (25% applied)',
                      value: '- ₹${_usableBonus.toStringAsFixed(0)}',
                      labelStyle: AppTypography.bodySmall
                          .copyWith(color: AppColors.success),
                      valueStyle: AppTypography.bodySmall
                          .copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600),
                    ),
                  ],
                  Divider(height: 1, color: AppColors.border),
                  _BreakdownRow(
                    label: 'To Pay',
                    value: widget.entryFee == 0
                        ? 'FREE'
                        : '₹${_toPay.toStringAsFixed(0)}',
                    labelStyle: AppTypography.titleSmall,
                    valueStyle: AppTypography.titleSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700),
                    highlighted: true,
                  ),
                ],
              ),
            ),
          ),

          // Wallet balance info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'Wallet Balance: ₹${widget.totalBalance.toStringAsFixed(0)}',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          AppSpacing.gapH16,

          // T&C checkbox
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _acceptedTerms,
                  activeColor: AppColors.primary,
                  onChanged: (v) =>
                      setState(() => _acceptedTerms = v ?? false),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text.rich(
                      TextSpan(
                        style: AppTypography.labelSmall
                            .copyWith(color: AppColors.textSecondary),
                        children: [
                          const TextSpan(
                              text:
                                  'By joining this contest, you accept our '),
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {/* Open T&C */},
                          ),
                          const TextSpan(
                              text:
                                  ' and confirm that you are eligible to participate.'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          AppSpacing.gapH16,

          // Join button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _acceptedTerms
                      ? AppColors.primary
                      : AppColors.border,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderRadiusMd),
                  elevation: 0,
                ),
                onPressed:
                    _acceptedTerms && !_isJoining
                        ? () async {
                            setState(() => _isJoining = true);
                            widget.onConfirm();
                            Navigator.of(context).pop();
                          }
                        : null,
                child: _isJoining
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        widget.entryFee == 0
                            ? 'JOIN FOR FREE'
                            : 'PAY ₹${_toPay.toStringAsFixed(0)} & JOIN',
                        style: AppTypography.labelLarge
                            .copyWith(color: Colors.white),
                      ),
              ),
            ),
          ),
          SafeArea(
            child: AppSpacing.gapH16,
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle labelStyle;
  final TextStyle valueStyle;
  final bool highlighted;

  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: highlighted
          ? AppColors.primary.withOpacity(0.04)
          : Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}

/// Helper to show the confirm bottom sheet.
Future<void> showConfirmContestSheet(
  BuildContext context, {
  required double entryFee,
  required double totalBalance,
  required double cashBonus,
  required String contestName,
  required VoidCallback onConfirm,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ConfirmContestBottomSheet(
      entryFee: entryFee,
      totalBalance: totalBalance,
      cashBonus: cashBonus,
      contestName: contestName,
      onConfirm: onConfirm,
    ),
  );
}
