import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/providers/wallet_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Deposit screen — UPI details + manual UTR + screenshot upload
// Ported from Fantasy- transaction/deposit.js
// ─────────────────────────────────────────────────────────────────────────────

class DepositScreen extends ConsumerStatefulWidget {
  const DepositScreen({super.key});

  @override
  ConsumerState<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends ConsumerState<DepositScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Add Money',
            style: AppTypography.titleLarge.copyWith(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'UPI / Manual'),
            Tab(text: 'Quick Add'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ManualDepositTab(),
          _QuickDepositTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1 — Manual UPI deposit with UTR + screenshot
// ─────────────────────────────────────────────────────────────────────────────

class _ManualDepositTab extends ConsumerStatefulWidget {
  const _ManualDepositTab();

  @override
  ConsumerState<_ManualDepositTab> createState() => _ManualDepositTabState();
}

class _ManualDepositTabState extends ConsumerState<_ManualDepositTab> {
  final _amountCtrl = TextEditingController();
  final _utrCtrl    = TextEditingController();
  File? _screenshotFile;
  bool _isSubmitting = false;

  static const _upiId          = '7259293140@ybl';
  static const _accountHolder  = 'Rajesh M N';

  @override
  void dispose() {
    _amountCtrl.dispose();
    _utrCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickScreenshot() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      setState(() => _screenshotFile = File(picked.path));
    }
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final utr    = _utrCtrl.text.trim();

    if (amount <= 0) {
      _snack('Please enter a valid amount', isError: true);
      return;
    }
    if (utr.length < 6) {
      _snack('Please enter a valid UTR number (min 6 chars)', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await ref.read(walletProvider.notifier).deposit(
      amount: amount,
      paymentMethod: 'upi_manual',
      utrNumber: utr,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;
    if (success) {
      _snack('Deposit request submitted! Admin will approve shortly.');
      Navigator.of(context).pop();
    } else {
      _snack('Failed to submit deposit request. Please try again.', isError: true);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.success,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── UPI Details card ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Payment Details',
                    style: AppTypography.titleSmall
                        .copyWith(fontWeight: FontWeight.w700)),
                AppSpacing.gapH12,
                _DetailRow(label: 'UPI ID', value: _upiId),
                AppSpacing.gapH6,
                _DetailRow(label: 'Account Holder', value: _accountHolder),
                AppSpacing.gapH12,
                // PhonePe logo placeholder
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5F259F).withOpacity(0.08),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone_android,
                          color: Color(0xFF5F259F), size: 18),
                      const SizedBox(width: 6),
                      Text('Pay via PhonePe / GPay / BHIM',
                          style: AppTypography.labelSmall.copyWith(
                              color: const Color(0xFF5F259F),
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          AppSpacing.gapH20,

          // ── Important note ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.06),
              borderRadius: AppSpacing.borderRadiusSm,
              border: Border.all(color: AppColors.error.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'IMPORTANT: After completing the transaction, fill in the UTR number and upload a screenshot. Without this your deposit will NOT be credited.',
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),

          AppSpacing.gapH20,

          // ── Amount field ──────────────────────────────────────────────
          Text('Amount', style: AppTypography.titleSmall),
          AppSpacing.gapH8,
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: '₹ ',
              hintText: 'Enter amount',
              border: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMd),
              focusedBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMd,
                  borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            ),
          ),

          AppSpacing.gapH16,

          // ── UTR field ─────────────────────────────────────────────────
          Text('UTR / Transaction Reference',
              style: AppTypography.titleSmall),
          AppSpacing.gapH8,
          TextField(
            controller: _utrCtrl,
            decoration: InputDecoration(
              hintText: 'Enter UTR number (12 digits)',
              border: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMd),
              focusedBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMd,
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2)),
            ),
          ),

          AppSpacing.gapH16,

          // ── Screenshot upload ─────────────────────────────────────────
          Text('Upload Screenshot (Optional)',
              style: AppTypography.titleSmall),
          AppSpacing.gapH8,
          GestureDetector(
            onTap: _pickScreenshot,
            child: Container(
              width: double.infinity,
              height: _screenshotFile == null ? 100 : 200,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(
                    color: AppColors.border, style: BorderStyle.solid),
              ),
              child: _screenshotFile != null
                  ? ClipRRect(
                      borderRadius: AppSpacing.borderRadiusMd,
                      child: Image.file(_screenshotFile!, fit: BoxFit.cover))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file,
                            size: 32, color: AppColors.textTertiary),
                        const SizedBox(height: 8),
                        Text('Tap to upload screenshot',
                            style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary)),
                      ],
                    ),
            ),
          ),
          if (_screenshotFile != null)
            TextButton.icon(
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Remove'),
              onPressed: () => setState(() => _screenshotFile = null),
            ),

          AppSpacing.gapH24,

          // ── Submit button ─────────────────────────────────────────────
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
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text('Submit Deposit Request',
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
// Tab 2 — Quick amount selection (existing logic kept)
// ─────────────────────────────────────────────────────────────────────────────

class _QuickDepositTab extends ConsumerStatefulWidget {
  const _QuickDepositTab();

  @override
  ConsumerState<_QuickDepositTab> createState() => _QuickDepositTabState();
}

class _QuickDepositTabState extends ConsumerState<_QuickDepositTab> {
  final _amountController = TextEditingController();
  final _quickAmounts     = [100, 250, 500, 1000, 2000, 5000];
  String _selectedMethod  = 'upi';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.05),
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: AppColors.info.withOpacity(0.2)),
            ),
            child: Row(children: [
              Icon(Icons.account_balance_wallet_outlined, color: AppColors.info),
              AppSpacing.gapW12,
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Current Balance', style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textSecondary)),
                Text('₹${walletState.totalBalance.toStringAsFixed(2)}',
                    style: AppTypography.titleMedium
                        .copyWith(fontWeight: FontWeight.w700)),
              ]),
            ]),
          ),
          AppSpacing.gapH20,

          // Amount input
          Text('Enter Amount', style: AppTypography.titleMedium),
          AppSpacing.gapH12,
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: AppTypography.headlineMedium.copyWith(fontSize: 28),
            decoration: InputDecoration(
              prefixText: '₹ ',
              hintText: '0',
              border: OutlineInputBorder(borderRadius: AppSpacing.borderRadiusMd),
              focusedBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMd,
                  borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            ),
          ),
          AppSpacing.gapH16,

          // Quick amounts
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: AppSpacing.borderRadiusSm,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text('₹$amount',
                      style: AppTypography.labelMedium
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
              );
            }).toList(),
          ),
          AppSpacing.gapH24,

          // Proceed button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: walletState.isTransacting ? null : () async {
                final amount = double.tryParse(_amountController.text) ?? 0;
                if (amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please enter a valid amount')));
                  return;
                }
                final success = await ref.read(walletProvider.notifier).deposit(
                    amount: amount, paymentMethod: _selectedMethod);
                if (success && mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Deposit request submitted!'),
                      backgroundColor: AppColors.success));
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderRadiusMd)),
              child: walletState.isTransacting
                  ? const SizedBox(width: 24, height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Proceed to Pay',
                      style: AppTypography.titleMedium
                          .copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widget
// ─────────────────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text('$label :',
              style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Text(value,
              style: AppTypography.labelSmall
                  .copyWith(fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}

// Helper extension for spacing
extension _SpacingX on AppSpacing {
  static const gapH6 = SizedBox(height: 6);
}
