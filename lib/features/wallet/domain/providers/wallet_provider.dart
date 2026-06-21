import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/models/payment_method_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/wallet_model.dart';
import '../../data/repositories/wallet_repository.dart';

/// Wallet state holding balance, transactions, and payment methods.
class WalletState {
  final WalletModel? wallet;
  final List<TransactionModel> transactions;
  final List<TransactionModel> recentTransactions;
  final List<PaymentMethodModel> paymentMethods;
  final List<Map<String, dynamic>> adminPaymentMethods;
  final bool isLoading;
  final bool isTransacting;
  final String? errorMessage;

  const WalletState({
    this.wallet,
    this.transactions = const [],
    this.recentTransactions = const [],
    this.paymentMethods = const [],
    this.adminPaymentMethods = const [],
    this.isLoading = false,
    this.isTransacting = false,
    this.errorMessage,
  });

  WalletState copyWith({
    WalletModel? wallet,
    List<TransactionModel>? transactions,
    List<TransactionModel>? recentTransactions,
    List<PaymentMethodModel>? paymentMethods,
    List<Map<String, dynamic>>? adminPaymentMethods,
    bool? isLoading,
    bool? isTransacting,
    String? errorMessage,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      adminPaymentMethods: adminPaymentMethods ?? this.adminPaymentMethods,
      isLoading: isLoading ?? this.isLoading,
      isTransacting: isTransacting ?? this.isTransacting,
      errorMessage: errorMessage,
    );
  }

  double get totalBalance => wallet?.totalBalance ?? 0.0;
  double get depositedBalance => wallet?.balance ?? 0.0;
  double get bonusBalance => wallet?.bonus ?? 0.0;
  double get winningsBalance => wallet?.winnings ?? 0.0;
  double get withdrawableBalance => wallet?.withdrawableBalance ?? 0.0;

  PaymentMethodModel? get defaultPaymentMethod {
    try {
      return paymentMethods.firstWhere((pm) => pm.isDefault);
    } catch (_) {
      return paymentMethods.isNotEmpty ? paymentMethods.first : null;
    }
  }
}

/// Wallet state notifier managing wallet operations.
class WalletNotifier extends StateNotifier<WalletState> {
  final WalletRepository _repository;
  final String? _userId;

  WalletNotifier(this._repository, this._userId) : super(const WalletState()) {
    if (_userId != null) {
      loadWallet();
    }
  }

  /// Load wallet data, recent transactions, and payment methods.
  Future<void> loadWallet() async {
    if (_userId == null) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final results = await Future.wait([
        _repository.getWallet(_userId!),
        _repository.getRecentTransactions(_userId!),
        _repository.getPaymentMethods(_userId!),
        _repository.getAdminPaymentMethods(),
      ]);

      state = state.copyWith(
        wallet: results[0] as WalletModel?,
        recentTransactions: results[1] as List<TransactionModel>,
        paymentMethods: results[2] as List<PaymentMethodModel>,
        adminPaymentMethods: results[3] as List<Map<String, dynamic>>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load wallet data.',
      );
    }
  }

  /// Load full transaction history with optional filter.
  Future<void> loadTransactions({TransactionType? type}) async {
    if (_userId == null) return;
    state = state.copyWith(isLoading: true);

    final transactions = await _repository.getTransactions(
      _userId!,
      type: type,
    );

    state = state.copyWith(
      transactions: transactions,
      isLoading: false,
    );
  }

  /// Initiate a deposit.
  Future<bool> deposit({
    required double amount,
    required String paymentMethod,
  }) async {
    if (_userId == null) return false;
    state = state.copyWith(isTransacting: true, errorMessage: null);

    final transaction = await _repository.initiateDeposit(
      userId: _userId!,
      amount: amount,
      paymentMethod: paymentMethod,
    );

    if (transaction != null) {
      state = state.copyWith(
        isTransacting: false,
        recentTransactions: [transaction, ...state.recentTransactions],
      );
      await loadWallet();
      return true;
    } else {
      state = state.copyWith(
        isTransacting: false,
        errorMessage: 'Deposit failed. Please try again.',
      );
      return false;
    }
  }

  /// Initiate a withdrawal.
  Future<bool> withdraw({
    required double amount,
    required String paymentMethod,
  }) async {
    if (_userId == null) return false;

    if (amount > state.withdrawableBalance) {
      state = state.copyWith(
        errorMessage: 'Insufficient withdrawable balance.',
      );
      return false;
    }

    state = state.copyWith(isTransacting: true, errorMessage: null);

    final transaction = await _repository.initiateWithdrawal(
      userId: _userId!,
      amount: amount,
      paymentMethod: paymentMethod,
    );

    if (transaction != null) {
      state = state.copyWith(
        isTransacting: false,
        recentTransactions: [transaction, ...state.recentTransactions],
      );
      await loadWallet();
      return true;
    } else {
      state = state.copyWith(
        isTransacting: false,
        errorMessage: 'Withdrawal failed. Please try again.',
      );
      return false;
    }
  }

  /// Add a payment method.
  Future<bool> addPaymentMethod({
    required PaymentMethodType methodType,
    required Map<String, dynamic> details,
    bool isDefault = false,
  }) async {
    if (_userId == null) return false;

    final method = await _repository.addPaymentMethod(
      userId: _userId!,
      methodType: methodType,
      details: details,
      isDefault: isDefault,
    );

    if (method != null) {
      state = state.copyWith(
        paymentMethods: [...state.paymentMethods, method],
      );
      return true;
    }
    return false;
  }

  /// Remove a payment method.
  Future<bool> removePaymentMethod(String methodId) async {
    final success = await _repository.removePaymentMethod(methodId);
    if (success) {
      state = state.copyWith(
        paymentMethods:
            state.paymentMethods.where((pm) => pm.id != methodId).toList(),
      );
    }
    return success;
  }

  /// Refresh wallet data.
  Future<void> refresh() async {
    await loadWallet();
  }
}

/// Provider for wallet state notifier.
final walletProvider =
    StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  final repository = ref.watch(walletRepositoryProvider);
  final authState = ref.watch(authProvider);
  final userId = authState.user?.uid;
  return WalletNotifier(repository, userId);
});

/// Provider for full transaction history.
final transactionHistoryProvider =
    FutureProvider.family<List<TransactionModel>, TransactionType?>(
        (ref, type) async {
  final repository = ref.watch(walletRepositoryProvider);
  final authState = ref.watch(authProvider);
  final userId = authState.user?.uid;
  if (userId == null) return [];
  return repository.getTransactions(userId, type: type);
});
