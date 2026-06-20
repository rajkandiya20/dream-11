import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Premium gradient balance card showing total balance with breakdown.
class BalanceCard extends StatelessWidget {
  final double totalBalance;
  final double deposited;
  final double bonus;
  final double winnings;
  final VoidCallback? onDeposit;
  final VoidCallback? onWithdraw;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.deposited,
    required this.bonus,
    required this.winnings,
    this.onDeposit,
    this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
            Color(0xFF020617),
          ],
        ),
        borderRadius: AppSpacing.borderRadiusXl,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppColors.success,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Active',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapH12,
          // Total Balance
          Text(
            '\u20B9${totalBalance.toStringAsFixed(2)}',
            style: AppTypography.headlineLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 36,
            ),
          ),
          AppSpacing.gapH20,
          // Balance Breakdown
          Row(
            children: [
              _BreakdownItem(
                label: 'Deposited',
                amount: deposited,
                color: AppColors.info,
              ),
              const SizedBox(width: 24),
              _BreakdownItem(
                label: 'Bonus',
                amount: bonus,
                color: AppColors.warning,
              ),
              const SizedBox(width: 24),
              _BreakdownItem(
                label: 'Winnings',
                amount: winnings,
                color: AppColors.success,
              ),
            ],
          ),
          AppSpacing.gapH20,
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Add Money',
                  icon: Icons.add_circle_outline,
                  onTap: onDeposit,
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: 'Withdraw',
                  icon: Icons.arrow_upward_rounded,
                  onTap: onWithdraw,
                  isPrimary: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BreakdownItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _BreakdownItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '\u20B9${amount.toStringAsFixed(0)}',
          style: AppTypography.titleSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.label,
    required this.icon,
    this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isPrimary
                ? AppColors.primary
                : Colors.white.withOpacity(0.1),
            borderRadius: AppSpacing.borderRadiusMd,
            border: isPrimary
                ? null
                : Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
