import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_nav_drawer.dart';

/// Admin wallet management - pending deposits/withdrawals with approve/reject.
class AdminWalletScreen extends ConsumerStatefulWidget {
  const AdminWalletScreen({super.key});

  @override
  ConsumerState<AdminWalletScreen> createState() => _AdminWalletScreenState();
}

class _AdminWalletScreenState extends ConsumerState<AdminWalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadPendingDeposits();
      ref.read(adminProvider.notifier).loadPendingWithdrawals();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          ),
        ),
        title: Text(
          'Wallet Management',
          style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Deposits'),
                  if (adminState.pendingDeposits.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: AppSpacing.borderRadiusFull,
                      ),
                      child: Text(
                        '${adminState.pendingDeposits.length}',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Withdrawals'),
                  if (adminState.pendingWithdrawals.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: AppSpacing.borderRadiusFull,
                      ),
                      child: Text(
                        '${adminState.pendingWithdrawals.length}',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: const AdminNavDrawer(currentRoute: '/admin/wallet'),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pending Deposits
          _TransactionList(
            transactions: adminState.pendingDeposits,
            isLoading: adminState.isLoading,
            type: 'deposit',
            onApprove: (id) =>
                ref.read(adminProvider.notifier).approveDeposit(id),
            onReject: (id) =>
                ref.read(adminProvider.notifier).rejectTransaction(id),
          ),
          // Pending Withdrawals
          _TransactionList(
            transactions: adminState.pendingWithdrawals,
            isLoading: adminState.isLoading,
            type: 'withdrawal',
            onApprove: (id) =>
                ref.read(adminProvider.notifier).approveWithdrawal(id),
            onReject: (id) =>
                ref.read(adminProvider.notifier).rejectTransaction(id),
          ),
        ],
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final bool isLoading;
  final String type;
  final Future<bool> Function(String) onApprove;
  final Future<bool> Function(String) onReject;

  const _TransactionList({
    required this.transactions,
    required this.isLoading,
    required this.type,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.success,
            ),
            AppSpacing.gapH16,
            Text(
              'All caught up!',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.gapH8,
            Text(
              'No pending ${type}s to review',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => AppSpacing.gapH8,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final user = transaction['user'] as Map<String, dynamic>?;
        final username = user?['username'] ?? user?['email'] ?? 'Unknown';
        final amount = (transaction['amount'] as num?)?.toDouble() ?? 0;
        final paymentMethod =
            transaction['payment_method'] as String? ?? 'Unknown';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (type == 'deposit'
                              ? AppColors.success
                              : AppColors.warning)
                          .withOpacity(0.1),
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                    child: Center(
                      child: Icon(
                        type == 'deposit'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: type == 'deposit'
                            ? AppColors.success
                            : AppColors.warning,
                        size: 20,
                      ),
                    ),
                  ),
                  AppSpacing.gapW12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'via $paymentMethod',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\u20B9${amount.toStringAsFixed(0)}',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: type == 'deposit'
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ],
              ),
              AppSpacing.gapH12,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => onReject(transaction['id'] as String),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => onApprove(transaction['id'] as String),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: const Text(
                      'Approve',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
