import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client.dart';
import '../models/payment_method_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

/// Repository handling all wallet-related Supabase operations.
class WalletRepository {
  final SupabaseClient _client;

  WalletRepository(this._client);

  /// Fetch user's wallet.
  Future<WalletModel?> getWallet(String userId) async {
    try {
      final response = await _client
          .from('wallets')
          .select('*')
          .eq('user_id', userId)
          .single();

      return WalletModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Fetch transaction history for a user.
  Future<List<TransactionModel>> getTransactions(
    String userId, {
    TransactionType? type,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _client
          .from('transactions')
          .select('*')
          .eq('user_id', userId);

      if (type != null) {
        query = query.eq('type', type.value);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) =>
              TransactionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch payment methods for a user.
  Future<List<PaymentMethodModel>> getPaymentMethods(String userId) async {
    try {
      final response = await _client
          .from('payment_methods')
          .select('*')
          .eq('user_id', userId);

      return (response as List)
          .map((json) =>
              PaymentMethodModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Initiate a deposit request.
  Future<TransactionModel?> initiateDeposit({
    required String userId,
    required double amount,
    required String paymentMethod,
    String? description,
    String? utrNumber,
  }) async {
    try {
      final response = await _client.from('transactions').insert({
        'user_id': userId,
        'type': 'deposit',
        'amount': amount,
        'status': 'pending',
        'payment_method': paymentMethod,
        'description': description ?? 'Deposit via $paymentMethod',
        if (utrNumber != null) 'reference_id': utrNumber,
      }).select().single();

      return TransactionModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Initiate a withdrawal request.
  Future<TransactionModel?> initiateWithdrawal({
    required String userId,
    required double amount,
    required String paymentMethod,
    String? description,
    String? upiId,       // Task #12: UPI ID for admin to process
    String? accountNo,  // Bank account number
    String? ifscCode,   // IFSC for bank transfer
    String? accountName,
  }) async {
    try {
      final response = await _client.from('transactions').insert({
        'user_id': userId,
        'type': 'withdrawal',
        'amount': amount,
        'status': 'pending',
        'payment_method': paymentMethod,
        'description': description ?? 'Withdrawal to $paymentMethod',
        // Store payment details so admin can process it
        if (upiId != null) 'reference_id': upiId,
        'notes': {
          if (upiId != null)       'upi_id': upiId,
          if (accountNo != null)   'account_no': accountNo,
          if (ifscCode != null)    'ifsc': ifscCode,
          if (accountName != null) 'account_name': accountName,
        }.toString(),
      }).select().single();

      return TransactionModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Add a new payment method.
  Future<PaymentMethodModel?> addPaymentMethod({
    required String userId,
    required PaymentMethodType methodType,
    required Map<String, dynamic> details,
    bool isDefault = false,
  }) async {
    try {
      // If setting as default, unset other defaults first
      if (isDefault) {
        await _client
            .from('payment_methods')
            .update({'is_default': false})
            .eq('user_id', userId);
      }

      final response = await _client.from('payment_methods').insert({
        'user_id': userId,
        'method_type': methodType.value,
        'details': details,
        'is_default': isDefault,
      }).select().single();

      return PaymentMethodModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Remove a payment method.
  Future<bool> removePaymentMethod(String paymentMethodId) async {
    try {
      await _client
          .from('payment_methods')
          .delete()
          .eq('id', paymentMethodId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Set a payment method as default.
  Future<bool> setDefaultPaymentMethod({
    required String userId,
    required String paymentMethodId,
  }) async {
    try {
      // Unset all defaults
      await _client
          .from('payment_methods')
          .update({'is_default': false})
          .eq('user_id', userId);

      // Set selected as default
      await _client
          .from('payment_methods')
          .update({'is_default': true})
          .eq('id', paymentMethodId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get recent transactions (last 5).
  Future<List<TransactionModel>> getRecentTransactions(String userId) async {
    try {
      final response = await _client
          .from('transactions')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(5);

      return (response as List)
          .map((json) =>
              TransactionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get admin-defined payment methods for deposit (where user deposits should go).
  Future<List<Map<String, dynamic>>> getAdminPaymentMethods() async {
    try {
      final response = await _client
          .from('admin_payment_methods')
          .select('*')
          .eq('is_active', true)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      return [];
    }
  }
}

/// Provider for the wallet repository.
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return WalletRepository(client);
});
