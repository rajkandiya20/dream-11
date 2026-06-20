import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/providers/wallet_provider.dart';

/// Deposit flow screen with amount input and payment method selection.
class DepositScreen extends ConsumerStatefulWidget {
  const DepositScreen({super.key});

  @override
  ConsumerState<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends ConsumerState<DepositScreen> {
  final _amountController = TextEditingController();
  final _quickAmounts = [100, 250, 500, 1000, 2000, 5000];
  String _selectedMethod = 'upi';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);

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
          'Add Money',
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
            // Current Balance
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.05),
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(color: AppColors.info.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined,
                      color: AppColors.info),
                  AppSpacing.gapW12,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Balance',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '\u20B9${walletState.totalBalance.toStringAsFixed(2)}',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
            AppSpacing.gapH16,
            // Quick Amounts
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _quickAmounts.map((amount) {
                return InkWell(
                  onTap: () {
                    _amountController.text = amount.toString();
                    setState(() {});
                  },
                  borderRadius: AppSpacing.borderRadiusSm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: AppSpacing.borderRadiusSm,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      '\u20B9$amount',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            AppSpacing.gapH32,
            // Payment Method
            Text('Payment Method', style: AppTypography.titleMedium),
            AppSpacing.gapH12,
            _PaymentMethodOption(
              icon: Icons.account_balance_wallet,
              title: 'UPI',
              subtitle: 'Pay using any UPI app',
              isSelected: _selectedMethod == 'upi',
              onTap: () => setState(() => _selectedMethod = 'upi'),
            ),
            AppSpacing.gapH8,
            _PaymentMethodOption(
              icon: Icons.account_balance,
              title: 'Net Banking',
              subtitle: 'Pay using bank account',
              isSelected: _selectedMethod == 'bank_account',
              onTap: () => setState(() => _selectedMethod = 'bank_account'),
            ),
            AppSpacing.gapH8,
            _PaymentMethodOption(
              icon: Icons.phone_android,
              title: 'PhonePe',
              subtitle: 'Pay using PhonePe wallet',
              isSelected: _selectedMethod == 'phonepe',
              onTap: () => setState(() => _selectedMethod = 'phonepe'),
            ),
            AppSpacing.gapH32,
            // Deposit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: walletState.isTransacting
                    ? null
                    : () async {
                        final amount =
                            double.tryParse(_amountController.text) ?? 0;
                        if (amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid amount'),
                            ),
                          );
                          return;
                        }
                        final success = await ref
                            .read(walletProvider.notifier)
                            .deposit(
                              amount: amount,
                              paymentMethod: _selectedMethod,
                            );
                        if (success && mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Deposit request submitted successfully!'),
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
                  elevation: 2,
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
                        'Proceed to Pay',
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodOption({
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
                child: Icon(
                  icon,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                ),
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
