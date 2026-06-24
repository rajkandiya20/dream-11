import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/providers/wallet_provider.dart';

/// Withdrawal screen — collects amount + UPI/bank details so admin can process.
class WithdrawalScreen extends ConsumerStatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  ConsumerState<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends ConsumerState<WithdrawalScreen> {
  final _amountCtrl  = TextEditingController();
  final _upiCtrl     = TextEditingController();
  final _accNoCtrl   = TextEditingController();
  final _ifscCtrl    = TextEditingController();
  final _accNameCtrl = TextEditingController();
  String _selectedMethod = 'upi';

  @override
  void dispose() {
    _amountCtrl.dispose();
    _upiCtrl.dispose();
    _accNoCtrl.dispose();
    _ifscCtrl.dispose();
    _accNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletState  = ref.watch(walletProvider);
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
        title: Text('Withdraw',
            style: AppTypography.titleLarge
                .copyWith(color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Withdrawable balance
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.05),
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(
                    color: AppColors.success.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Withdrawable Balance',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                  AppSpacing.gapH4,
                  Text('₹${withdrawable.toStringAsFixed(2)}',
                      style: AppTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.success)),
                  AppSpacing.gapH8,
                  Text('Bonus is non-withdrawable',
                      style: AppTypography.labelSmall
                          .copyWith(color: AppColors.textTertiary)),
                ],
              ),
            ),
            AppSpacing.gapH24,

            // Amount
            Text('Enter Amount', style: AppTypography.titleMedium),
            AppSpacing.gapH12,
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              style: AppTypography.headlineMedium.copyWith(fontSize: 28),
              decoration: InputDecoration(
                prefixText: '₹ ',
                hintText: '0',
                suffixIcon: TextButton(
                  onPressed: () => _amountCtrl.text =
                      withdrawable.toStringAsFixed(0),
                  child: Text('MAX',
                      style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                ),
                border: OutlineInputBorder(
                    borderRadius: AppSpacing.borderRadiusMd),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMd,
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
            AppSpacing.gapH24,

            // Method selection
            Text('Withdraw To', style: AppTypography.titleMedium),
            AppSpacing.gapH12,
            _MethodTile(
              icon: Icons.account_balance_wallet,
              title: 'UPI',
              subtitle: 'Instant transfer',
              isSelected: _selectedMethod == 'upi',
              onTap: () => setState(() => _selectedMethod = 'upi'),
            ),
            AppSpacing.gapH8,
            _MethodTile(
              icon: Icons.account_balance,
              title: 'Bank Account',
              subtitle: '1-3 business days',
              isSelected: _selectedMethod == 'bank_account',
              onTap: () =>
                  setState(() => _selectedMethod = 'bank_account'),
            ),
            AppSpacing.gapH20,

            // UPI field
            if (_selectedMethod == 'upi') ...[
              Text('Your UPI ID', style: AppTypography.titleSmall),
              AppSpacing.gapH8,
              TextField(
                controller: _upiCtrl,
                decoration: InputDecoration(
                  hintText: 'yourname@ybl / 9876543210@upi',
                  prefixIcon: const Icon(Icons.payment_outlined,
                      color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusMd),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppSpacing.borderRadiusMd,
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ],

            // Bank fields
            if (_selectedMethod == 'bank_account') ...[
              Text('Account Holder Name',
                  style: AppTypography.titleSmall),
              AppSpacing.gapH8,
              TextField(
                controller: _accNameCtrl,
                decoration: InputDecoration(
                  hintText: 'As per bank records',
                  border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusMd),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppSpacing.borderRadiusMd,
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              AppSpacing.gapH12,
              Text('Account Number', style: AppTypography.titleSmall),
              AppSpacing.gapH8,
              TextField(
                controller: _accNoCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '00001234567890',
                  border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusMd),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppSpacing.borderRadiusMd,
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              AppSpacing.gapH12,
              Text('IFSC Code', style: AppTypography.titleSmall),
              AppSpacing.gapH8,
              TextField(
                controller: _ifscCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'SBIN0001234',
                  border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusMd),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppSpacing.borderRadiusMd,
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ],
            AppSpacing.gapH16,

            // Min/max info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.05),
                borderRadius: AppSpacing.borderRadiusSm,
                border: Border.all(
                    color: AppColors.warning.withOpacity(0.2)),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline,
                    color: AppColors.warning, size: 18),
                AppSpacing.gapW8,
                Expanded(
                  child: Text(
                    'Min ₹100 · Max ₹1,00,000 per request. Processing: UPI instant, Bank 1-3 days.',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.warningDark),
                  ),
                ),
              ]),
            ),
            AppSpacing.gapH24,

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: walletState.isTransacting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderRadiusMd),
                ),
                child: walletState.isTransacting
                    ? const SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text('SUBMIT WITHDRAWAL REQUEST',
                        style: AppTypography.titleSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
              ),
            ),
            if (walletState.errorMessage != null) ...[
              AppSpacing.gapH12,
              Text(walletState.errorMessage!,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.error)),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    if (amount < 100) {
      _snack('Minimum withdrawal is ₹100');
      return;
    }
    if (amount >
        ref.read(walletProvider).withdrawableBalance) {
      _snack('Amount exceeds withdrawable balance',
          isError: true);
      return;
    }
    // Validate payment details
    if (_selectedMethod == 'upi' && _upiCtrl.text.trim().isEmpty) {
      _snack('Please enter your UPI ID', isError: true);
      return;
    }
    if (_selectedMethod == 'bank_account') {
      if (_accNoCtrl.text.trim().isEmpty ||
          _ifscCtrl.text.trim().isEmpty) {
        _snack('Please enter account number and IFSC code',
            isError: true);
        return;
      }
    }

    final success = await ref.read(walletProvider.notifier).withdraw(
      amount: amount,
      paymentMethod: _selectedMethod,
      upiId: _selectedMethod == 'upi'
          ? _upiCtrl.text.trim()
          : null,
      accountNo: _selectedMethod == 'bank_account'
          ? _accNoCtrl.text.trim()
          : null,
      ifscCode: _selectedMethod == 'bank_account'
          ? _ifscCtrl.text.trim()
          : null,
      accountName: _selectedMethod == 'bank_account'
          ? _accNameCtrl.text.trim()
          : null,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            '✅ Withdrawal request submitted! Admin will process within 24 hours.'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 4),
      ));
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : null,
    ));
  }
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodTile({
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
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: (isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary)
                      .withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Center(
              child: Icon(icon,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 20),
            ),
          ),
          AppSpacing.gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleSmall),
                Text(subtitle,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle,
                color: AppColors.primary, size: 22),
        ]),
      ),
    );
  }
}
