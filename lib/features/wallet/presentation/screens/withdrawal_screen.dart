import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/providers/wallet_provider.dart';

/// Withdrawal flow screen with amount input and payment method.
class WithdrawalScreen extends ConsumerStatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  ConsumerState<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends ConsumerState<WithdrawalScreen> {
  final _amountController = TextEditingController();
  String _selectedMethod = 'upi';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    final withdrawable = walletState.withdrawableBalance;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text(
          'Withdraw',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Withdrawable Balance
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.05),
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(color: AppColors.success.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Withdrawable Balance',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  AppSpacing.gapH4,
                  Text(
                    '\u20B9${withdrawable.toStringAsFixed(2)}',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                  AppSpacing.gapH8,
                  Text(
                    'Bonus amount is non-withdrawable',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapH24,
            // Amount Input
            Text('Enter Amount', style: AppTypography.titleMedium),
            AppSpacing.gapH12,
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: AppTypography.headlineMedium.copyWith(fontSize: 28),
              decoration: InputDecoration(
                prefixText: '\u20B9 ',
                prefixStyle: AppTypography.headlineMedium.copyWith(fontSize: 28),
                hintText: '0',
                hintStyle: AppTypography.headlineMedium.copyWith(
                  fontSize: 28,
                  color: AppColors.textTertiary,
                ),
                suffixIcon: TextButton(
                  onPressed: () {
                    _amountController.text = withdrawable.toStringAsFixed(0);
                    setState(() {});
                  },
                  child: Text(
                    'MAX',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMd,
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMd,
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
            AppSpacing.gapH32,
            // Withdraw To
            Text('Withdraw to', style: AppTypography.titleMedium),
            AppSpacing.gapH12,
            _WithdrawMethodTile(
              icon: Icons.account_balance_wallet,
              title: 'UPI',
              subtitle: 'Instant transfer',
              isSelected: _selectedMethod == 'upi',
              onTap: () => setState(() => _selectedMethod = 'upi'),
            ),
            AppSpacing.gapH8,
            _WithdrawMethodTile(
              icon: Icons.account_balance,
              title: 'Bank Account',
              subtitle: '1-3 business days',
              isSelected: _selectedMethod == 'bank_account',
              onTap: () => setState(() => _selectedMethod = 'bank_account'),
            ),
            AppSpacing.gapH32,
            // Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.05),
                borderRadius: AppSpacing.borderRadiusSm,
                border: Border.all(color: AppColors.warning.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                  AppSpacing.gapW8,
                  Expanded(
                    child: Text(
                      'Minimum withdrawal amount is \u20B9100. Processing time may vary.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.warningDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapH24,
            // Withdraw Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: walletState.isTransacting
                    ? null
                    : () async {
                        final amount =
                            double.tryParse(_amountController.text) ?? 0;
                        if (amount < 100) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Minimum withdrawal is \u20B9100'),
                            ),
                          );
                          return;
                        }
                        if (amount > withdrawable) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Amount exceeds withdrawable balance'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }
                        final success = await ref
                            .read(walletProvider.notifier)
                            .withdraw(
                              amount: amount,
                              paymentMethod: _selectedMethod,
                            );
                        if (success && mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Withdrawal request submitted!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                ),
                child: walletState.isTransacting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Confirm Withdrawal',
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            if (walletState.errorMessage != null) ...[
              AppSpacing.gapH12,
              Text(
                walletState.errorMessage!,
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WithdrawMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _WithdrawMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (isSelected ? AppColors.primary : AppColors.textSecondary)
                    .withOpacity(0.1),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Center(
                child: Icon(icon,
                    color:
                        isSelected ? AppColors.primary : AppColors.textSecondary,
                    size: 20),
              ),
            ),
            AppSpacing.gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleSmall),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
