import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../data/models/transaction_model.dart';
import '../../domain/providers/wallet_provider.dart';
import '../widgets/transaction_tile.dart';

/// Full transaction history screen with filters.
class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = const [
    Tab(text: 'All'),
    Tab(text: 'Deposits'),
    Tab(text: 'Withdrawals'),
    Tab(text: 'Contests'),
    Tab(text: 'Winnings'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    // Load all transactions initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletProvider.notifier).loadTransactions();
    });
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    TransactionType? type;
    switch (_tabController.index) {
      case 1:
        type = TransactionType.deposit;
        break;
      case 2:
        type = TransactionType.withdrawal;
        break;
      case 3:
        type = TransactionType.contestJoin;
        break;
      case 4:
        type = TransactionType.winning;
        break;
    }
    ref.read(walletProvider.notifier).loadTransactions(type: type);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
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
          'Transaction History',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: AppTypography.labelMedium,
          tabs: _tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(
          _tabs.length,
          (index) => _TransactionList(
            transactions: walletState.transactions,
            isLoading: walletState.isLoading,
          ),
        ),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final bool isLoading;

  const _TransactionList({
    required this.transactions,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ListView.builder(
        padding: AppSpacing.screenPadding,
        itemCount: 6,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShimmerLoading(width: double.infinity, height: 60),
        ),
      );
    }

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            AppSpacing.gapH16,
            Text(
              'No transactions found',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.gapH8,
            Text(
              'Your transaction history will appear here',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: AppColors.border.withOpacity(0.5),
        indent: 72,
      ),
      itemBuilder: (context, index) {
        return TransactionTile(transaction: transactions[index]);
      },
    );
  }
}
