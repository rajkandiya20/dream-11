import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../admin/data/repositories/admin_repository.dart';
import '../../domain/providers/wallet_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Provider: load admin payment methods (UPI IDs, QR codes)
// ─────────────────────────────────────────────────────────────────────────────

final _adminPaymentMethodsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getAdminPaymentMethods();
});

// ─────────────────────────────────────────────────────────────────────────────
// Deposit Screen — 3 steps:
//   Step 1: Choose amount
//   Step 2: Show payment details (UPI ID / QR), user pays in their app
//   Step 3: Enter UTR + confirm → request goes to admin
// ─────────────────────────────────────────────────────────────────────────────

class DepositScreen extends ConsumerStatefulWidget {
  const DepositScreen({super.key});

  @override
  ConsumerState<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends ConsumerState<DepositScreen> {
  int _step = 0; // 0=amount, 1=pay, 2=confirm
  double _selectedAmount = 0;
  final _amountCtrl = TextEditingController();
  final _utrCtrl    = TextEditingController();
  bool _submitting  = false;

  static const _quickAmounts = [100, 250, 500, 1000, 2000, 5000];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _utrCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (_step > 0) {
              setState(() => _step--);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          _step == 0
              ? 'Add Money'
              : _step == 1
                  ? 'Make Payment'
                  : 'Confirm Payment',
          style: AppTypography.titleLarge.copyWith(color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_step + 1) / 3,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      body: IndexedStack(
        index: _step,
        children: [
          _StepAmount(
            amountCtrl: _amountCtrl,
            quickAmounts: _quickAmounts,
            currentBalance: walletState.totalBalance,
            onNext: () {
              final amt = double.tryParse(_amountCtrl.text.trim()) ?? 0;
              if (amt < 10) {
                _snack('Minimum deposit is ₹10');
                return;
              }
              setState(() {
                _selectedAmount = amt;
                _step = 1;
              });
            },
          ),
          _StepPay(
            amount: _selectedAmount,
            onNext: () => setState(() => _step = 2),
          ),
          _StepConfirm(
            amount: _selectedAmount,
            utrCtrl: _utrCtrl,
            submitting: _submitting,
            onSubmit: _submitDeposit,
          ),
        ],
      ),
    );
  }

  Future<void> _submitDeposit() async {
    final utr = _utrCtrl.text.trim();
    if (utr.length < 6) {
      _snack('Please enter a valid UTR/transaction reference (min 6 chars)');
      return;
    }
    setState(() => _submitting = true);
    final ok = await ref.read(walletProvider.notifier).deposit(
      amount: _selectedAmount,
      paymentMethod: 'upi_manual',
      utrNumber: utr,
    );
    setState(() => _submitting = false);
    if (!mounted) return;
    if (ok) {
      _snack('Deposit request submitted! Admin will credit within 30 min.',
          isSuccess: true);
      context.pop();
    } else {
      _snack('Failed to submit. Please try again.');
    }
  }

  void _snack(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isSuccess ? AppColors.success : AppColors.error,
    ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1: Amount Selection
// ─────────────────────────────────────────────────────────────────────────────

class _StepAmount extends StatelessWidget {
  final TextEditingController amountCtrl;
  final List<int> quickAmounts;
  final double currentBalance;
  final VoidCallback onNext;

  const _StepAmount({
    required this.amountCtrl,
    required this.quickAmounts,
    required this.currentBalance,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current balance chip
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.06),
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: AppColors.info.withOpacity(0.2)),
            ),
            child: Row(children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  color: AppColors.info, size: 20),
              AppSpacing.gapW12,
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Current Balance',
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.textSecondary)),
                Text('₹${currentBalance.toStringAsFixed(2)}',
                    style: AppTypography.titleMedium
                        .copyWith(fontWeight: FontWeight.w700)),
              ]),
            ]),
          ),
          AppSpacing.gapH20,
          Text('Enter Amount', style: AppTypography.titleMedium),
          AppSpacing.gapH10,
          TextField(
            controller: amountCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTypography.headlineMedium,
            decoration: InputDecoration(
              prefixText: '₹ ',
              hintText: '0',
              border: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMd),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusMd,
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          AppSpacing.gapH16,
          Text('Quick Select', style: AppTypography.labelMedium
              .copyWith(color: AppColors.textSecondary)),
          AppSpacing.gapH10,
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: quickAmounts.map((amt) {
              return GestureDetector(
                onTap: () =>
                    amountCtrl.text = amt.toString(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: AppSpacing.borderRadiusFull,
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4)
                    ],
                  ),
                  child: Text('₹$amt',
                      style: AppTypography.labelMedium
                          .copyWith(fontWeight: FontWeight.w700)),
                ),
              );
            }).toList(),
          ),
          AppSpacing.gapH32,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusMd),
              ),
              onPressed: onNext,
              child: Text('PROCEED TO PAY',
                  style: AppTypography.labelLarge
                      .copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2: Show payment details — user pays in their UPI app
// ─────────────────────────────────────────────────────────────────────────────

class _StepPay extends ConsumerWidget {
  final double amount;
  final VoidCallback onNext;

  const _StepPay({required this.amount, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methodsAsync = ref.watch(_adminPaymentMethodsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount to pay
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Column(children: [
              Text('Pay Exactly',
                  style: AppTypography.labelMedium
                      .copyWith(color: Colors.white70)),
              AppSpacing.gapH4,
              Text('₹${amount.toStringAsFixed(0)}',
                  style: AppTypography.displayMedium.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ]),
          ),
          AppSpacing.gapH20,

          // Warning
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.08),
              borderRadius: AppSpacing.borderRadiusSm,
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.warning, size: 18),
                AppSpacing.gapW8,
                Expanded(
                  child: Text(
                    'Pay EXACTLY ₹${amount.toStringAsFixed(0)}. Different amounts cannot be matched to your account.',
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.warningDark),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapH20,

          // Payment methods from admin
          methodsAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
            error: (_, __) => _FallbackUPI(amount: amount),
            data: (methods) {
              if (methods.isEmpty) return _FallbackUPI(amount: amount);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pay to any of these UPI IDs:',
                      style: AppTypography.titleSmall),
                  AppSpacing.gapH12,
                  ...methods.map((m) => _UPIMethodCard(method: m)),
                ],
              );
            },
          ),
          AppSpacing.gapH24,

          // Instructions
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.05),
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: AppColors.info.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How to pay:',
                    style: AppTypography.titleSmall
                        .copyWith(color: AppColors.info)),
                AppSpacing.gapH8,
                _Step('1', 'Open PhonePe / GPay / BHIM / Paytm'),
                _Step('2', 'Send ₹${amount.toStringAsFixed(0)} to the UPI ID above'),
                _Step('3', 'Note the UTR/transaction number'),
                _Step('4', 'Come back and click "I Have Paid"'),
              ],
            ),
          ),
          AppSpacing.gapH24,

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusMd),
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: Text('I HAVE PAID ₹${amount.toStringAsFixed(0)}',
                  style: AppTypography.labelLarge
                      .copyWith(color: Colors.white)),
              onPressed: onNext,
            ),
          ),
        ],
      ),
    );
  }
}

class _FallbackUPI extends StatelessWidget {
  final double amount;
  const _FallbackUPI({required this.amount});

  @override
  Widget build(BuildContext context) {
    return _UPIMethodCard(method: const {
      'upi_id': '7259293140@ybl',
      'account_name': 'Admin',
      'type': 'upi',
    });
  }
}

class _UPIMethodCard extends StatelessWidget {
  final Map<String, dynamic> method;
  const _UPIMethodCard({required this.method});

  @override
  Widget build(BuildContext context) {
    final upiId      = method['upi_id'] as String? ?? '';
    final name       = method['account_name'] as String? ?? 'Admin';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: AppSpacing.borderRadiusSm,
          ),
          child: const Icon(Icons.payment, color: AppColors.primary, size: 22),
        ),
        AppSpacing.gapW12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: AppTypography.labelMedium
                      .copyWith(fontWeight: FontWeight.w600)),
              Text(upiId,
                  style: AppTypography.titleSmall
                      .copyWith(color: AppColors.primary)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 18,
              color: AppColors.textSecondary),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: upiId));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('UPI ID copied!'),
              duration: Duration(seconds: 2),
            ));
          },
        ),
      ]),
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String text;
  const _Step(this.number, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Container(
          width: 20, height: 20,
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(number,
                style: const TextStyle(
                    color: AppColors.info,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
          ),
        ),
        AppSpacing.gapW8,
        Expanded(
            child: Text(text,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textSecondary))),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3: Confirm — enter UTR and submit to admin
// ─────────────────────────────────────────────────────────────────────────────

class _StepConfirm extends StatelessWidget {
  final double amount;
  final TextEditingController utrCtrl;
  final bool submitting;
  final VoidCallback onSubmit;

  const _StepConfirm({
    required this.amount,
    required this.utrCtrl,
    required this.submitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(children: [
              _Row('Amount Paid', '₹${amount.toStringAsFixed(0)}',
                  bold: true),
              const Divider(height: 16),
              _Row('Credit to Wallet', '₹${amount.toStringAsFixed(0)}',
                  color: AppColors.success),
            ]),
          ),
          AppSpacing.gapH24,
          Text('Enter Transaction Reference (UTR)',
              style: AppTypography.titleMedium),
          AppSpacing.gapH8,
          Text(
            'Find the 12-digit UTR number in your payment app under transaction details.',
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
          AppSpacing.gapH12,
          TextField(
            controller: utrCtrl,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'e.g. 425812345678',
              prefixIcon: const Icon(Icons.receipt_long_outlined,
                  color: AppColors.textSecondary),
              border: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMd),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusMd,
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          AppSpacing.gapH12,
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.05),
              borderRadius: AppSpacing.borderRadiusSm,
              border:
                  Border.all(color: AppColors.error.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    color: AppColors.error, size: 16),
                AppSpacing.gapW8,
                Expanded(
                  child: Text(
                    'Without a valid UTR, admin cannot verify your payment and wallet will NOT be credited.',
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapH24,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusMd),
              ),
              onPressed: submitting ? null : onSubmit,
              child: submitting
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text('SUBMIT DEPOSIT REQUEST',
                      style: AppTypography.labelLarge
                          .copyWith(color: Colors.white)),
            ),
          ),
          AppSpacing.gapH12,
          Text(
            'Your wallet will be credited within 30 minutes after admin approval.',
            style: AppTypography.labelSmall
                .copyWith(color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;
  const _Row(this.label, this.value,
      {this.bold = false, this.color});

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
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: color ?? AppColors.textPrimary,
            )),
      ],
    );
  }
}
