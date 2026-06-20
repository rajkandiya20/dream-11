import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../domain/providers/wallet_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_tile.dart';

/// Premium wallet screen with balance card, quick actions, and recent transactions.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.read(walletProvider.notifier).refresh(),
          child: walletState.isLoading && walletState.wallet == null
              ? const _WalletLoadingState()
              : CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // App Bar
                    SliverToBoxAdapter(
                      child: _buildAppBar(context),
                    ),
                    // Balance Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: BalanceCard(
                          totalBalance: walletState.totalBalance,
                          deposited: walletState.depositedBalance,
                          bonus: walletState.bonusBalance,
                          winnings: walletState.winningsBalance,
                          onDeposit: () => _showDepositSheet(context, ref),
                          onWithdraw: () => _showWithdrawSheet(context, ref),
                        ),
                      ),
                    ),
                    // Quick Actions
                    SliverToBoxAdapter(
                      child: _QuickActionsSection(),
                    ),
                    // Payment Methods
                    if (walletState.paymentMethods.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _PaymentMethodsSection(
                          methods: walletState.paymentMethods,
                        ),
                      ),
                    // Recent Transactions Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Transactions',
                              style: AppTypography.titleLarge,
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.push(AppRoutes.transactionHistory),
                              child: Text(
                                'View All',
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Transaction List
                    if (walletState.recentTransactions.isEmpty)
                      SliverToBoxAdapter(
                        child: _EmptyTransactions(),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final transaction =
                                walletState.recentTransactions[index];
                            return TransactionTile(transaction: transaction);
                          },
                          childCount: walletState.recentTransactions.length,
                        ),
                      ),
                    // Bottom spacing to clear floating nav bar
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 120),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Text(
            'Wallet',
            style: AppTypography.headlineMedium,
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.push(AppRoutes.transactionHistory),
            icon: const Icon(
              Icons.history,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showDepositSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DepositBottomSheet(),
    );
  }

  void _showWithdrawSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WithdrawBottomSheet(),
    );
  }
}

/// Deposit bottom sheet.
class DepositBottomSheet extends ConsumerStatefulWidget {
  const DepositBottomSheet({super.key});

  @override
  ConsumerState<DepositBottomSheet> createState() => _DepositBottomSheetState();
}

class _DepositBottomSheetState extends ConsumerState<DepositBottomSheet> {
  final _amountController = TextEditingController();
  final _quickAmounts = [100, 500, 1000, 2000, 5000];
  String _selectedMethod = 'UPI';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Widget _buildPaymentMethodSelector(WalletState walletState) {
    final adminMethods = walletState.adminPaymentMethods;

    // If admin has defined payment methods, show those
    if (adminMethods.isNotEmpty) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: adminMethods.map((method) {
          final displayName =
              method['display_name'] as String? ?? method['method_type'] as String? ?? 'Payment';
          final isSelected = _selectedMethod == displayName;
          return ChoiceChip(
            label: Text(displayName),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) setState(() => _selectedMethod = displayName);
            },
            selectedColor: AppColors.primary.withOpacity(0.1),
            labelStyle: AppTypography.labelMedium.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          );
        }).toList(),
      );
    }

    // Fallback to default options
    return Wrap(
      spacing: 8,
      children: ['UPI', 'Bank', 'PhonePe'].map((method) {
        final isSelected = _selectedMethod == method;
        return ChoiceChip(
          label: Text(method),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) setState(() => _selectedMethod = method);
          },
          selectedColor: AppColors.primary.withOpacity(0.1),
          labelStyle: AppTypography.labelMedium.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
              ),
            ),
            AppSpacing.gapH20,
            Text('Add Money', style: AppTypography.headlineSmall),
            AppSpacing.gapH20,
            // Amount Input
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: AppTypography.headlineMedium,
              decoration: InputDecoration(
                prefixText: '\u20B9 ',
                prefixStyle: AppTypography.headlineMedium,
                hintText: '0',
                hintStyle: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                border: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMd,
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMd,
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            AppSpacing.gapH16,
            // Quick amount chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickAmounts.map((amount) {
                return ActionChip(
                  label: Text('\u20B9$amount'),
                  onPressed: () {
                    _amountController.text = amount.toString();
                  },
                  backgroundColor: AppColors.scaffoldBackground,
                  side: const BorderSide(color: AppColors.border),
                  labelStyle: AppTypography.labelMedium,
                );
              }).toList(),
            ),
            AppSpacing.gapH20,
            // Payment Method Selection
            Text('Payment Method', style: AppTypography.titleSmall),
            AppSpacing.gapH8,
            _buildPaymentMethodSelector(walletState),
            AppSpacing.gapH24,
            // Deposit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: walletState.isTransacting
                    ? null
                    : () async {
                        final amount =
                            double.tryParse(_amountController.text) ?? 0;
                        if (amount <= 0) return;
                        final success = await ref
                            .read(walletProvider.notifier)
                            .deposit(
                              amount: amount,
                              paymentMethod: _selectedMethod.toLowerCase(),
                            );
                        if (success && mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Deposit request submitted!'),
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
                        'Add Money',
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            AppSpacing.gapH16,
          ],
        ),
      ),
    );
  }
}

/// Withdraw bottom sheet.
class WithdrawBottomSheet extends ConsumerStatefulWidget {
  const WithdrawBottomSheet({super.key});

  @override
  ConsumerState<WithdrawBottomSheet> createState() =>
      _WithdrawBottomSheetState();
}

class _WithdrawBottomSheetState extends ConsumerState<WithdrawBottomSheet> {
  final _amountController = TextEditingController();
  String _selectedMethod = 'UPI';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
              ),
            ),
            AppSpacing.gapH20,
            Text('Withdraw', style: AppTypography.headlineSmall),
            AppSpacing.gapH8,
            Text(
              'Withdrawable: \u20B9${walletState.withdrawableBalance.toStringAsFixed(2)}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.gapH20,
            // Amount Input
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: AppTypography.headlineMedium,
              decoration: InputDecoration(
                prefixText: '\u20B9 ',
                prefixStyle: AppTypography.headlineMedium,
                hintText: '0',
                hintStyle: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                border: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMd,
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMd,
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            AppSpacing.gapH20,
            // Payment Method
            Text('Withdraw to', style: AppTypography.titleSmall),
            AppSpacing.gapH8,
            Wrap(
              spacing: 8,
              children: ['UPI', 'Bank Account'].map((method) {
                final isSelected = _selectedMethod == method;
                return ChoiceChip(
                  label: Text(method),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedMethod = method);
                  },
                  selectedColor: AppColors.primary.withOpacity(0.1),
                  labelStyle: AppTypography.labelMedium.copyWith(
                    color:
                        isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                );
              }).toList(),
            ),
            AppSpacing.gapH24,
            // Withdraw Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: walletState.isTransacting
                    ? null
                    : () async {
                        final amount =
                            double.tryParse(_amountController.text) ?? 0;
                        if (amount <= 0) return;
                        final success = await ref
                            .read(walletProvider.notifier)
                            .withdraw(
                              amount: amount,
                              paymentMethod: _selectedMethod.toLowerCase(),
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
                        'Withdraw',
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
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
            AppSpacing.gapH16,
          ],
        ),
      ),
    );
  }
}

/// Quick actions grid section.
class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: AppTypography.titleMedium),
          AppSpacing.gapH12,
          Row(
            children: [
              _QuickActionItem(
                icon: Icons.send_outlined,
                label: 'Send',
                color: AppColors.info,
              ),
              AppSpacing.gapW12,
              _QuickActionItem(
                icon: Icons.card_giftcard_outlined,
                label: 'Rewards',
                color: AppColors.warning,
              ),
              AppSpacing.gapW12,
              _QuickActionItem(
                icon: Icons.local_offer_outlined,
                label: 'Offers',
                color: AppColors.success,
              ),
              AppSpacing.gapW12,
              _QuickActionItem(
                icon: Icons.help_outline,
                label: 'Help',
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Center(
              child: Icon(icon, color: color, size: 24),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Payment methods horizontal list.
class _PaymentMethodsSection extends StatelessWidget {
  final List<dynamic> methods;

  const _PaymentMethodsSection({required this.methods});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Methods', style: AppTypography.titleMedium),
          AppSpacing.gapH12,
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: methods.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                if (index == methods.length) {
                  return Container(
                    width: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.border,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: AppSpacing.borderRadiusMd,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: AppSpacing.borderRadiusMd,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        methods[index].displayName ?? 'Payment',
                        style: AppTypography.labelMedium,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty transactions state.
class _EmptyTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.textTertiary,
          ),
          AppSpacing.gapH12,
          Text(
            'No transactions yet',
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.gapH4,
          Text(
            'Add money to start playing',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Wallet loading skeleton.
class _WalletLoadingState extends StatelessWidget {
  const _WalletLoadingState();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          const ShimmerLoading(width: double.infinity, height: 240),
          AppSpacing.gapH24,
          const ShimmerLoading(width: double.infinity, height: 80),
          AppSpacing.gapH16,
          for (int i = 0; i < 4; i++) ...[
            const ShimmerLoading(width: double.infinity, height: 60),
            AppSpacing.gapH12,
          ],
        ],
      ),
    );
  }
}
