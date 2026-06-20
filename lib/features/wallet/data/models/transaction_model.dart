/// Transaction model matching the transactions table schema in Supabase.
///
/// Table schema:
/// id, user_id, type(deposit/withdrawal/contest_join/winning), amount,
/// status(pending/completed/rejected), description, payment_method
class TransactionModel {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final TransactionStatus status;
  final String? description;
  final String? paymentMethod;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    this.status = TransactionStatus.pending,
    this.description,
    this.paymentMethod,
    this.createdAt,
    this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      type: TransactionType.fromString(json['type'] as String? ?? 'deposit'),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status:
          TransactionStatus.fromString(json['status'] as String? ?? 'pending'),
      description: json['description'] as String?,
      paymentMethod: json['payment_method'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'type': type.value,
      'amount': amount,
      'status': status.value,
      if (description != null) 'description': description,
      if (paymentMethod != null) 'payment_method': paymentMethod,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    double? amount,
    TransactionStatus? status,
    String? description,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Whether the transaction is a credit (money in).
  bool get isCredit =>
      type == TransactionType.deposit || type == TransactionType.winning;

  /// Whether the transaction is a debit (money out).
  bool get isDebit =>
      type == TransactionType.withdrawal || type == TransactionType.contestJoin;

  /// Formatted amount string with sign.
  String get formattedAmount =>
      isCredit ? '+\u20B9${amount.toStringAsFixed(0)}' : '-\u20B9${amount.toStringAsFixed(0)}';

  @override
  String toString() =>
      'TransactionModel(type: ${type.value}, amount: $amount, status: ${status.value})';
}

/// Transaction type enum.
enum TransactionType {
  deposit('deposit'),
  withdrawal('withdrawal'),
  contestJoin('contest_join'),
  winning('winning');

  final String value;
  const TransactionType(this.value);

  factory TransactionType.fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionType.deposit,
    );
  }

  String get displayName {
    switch (this) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.contestJoin:
        return 'Contest Entry';
      case TransactionType.winning:
        return 'Winning';
    }
  }
}

/// Transaction status enum.
enum TransactionStatus {
  pending('pending'),
  completed('completed'),
  rejected('rejected');

  final String value;
  const TransactionStatus(this.value);

  factory TransactionStatus.fromString(String value) {
    return TransactionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.rejected:
        return 'Rejected';
    }
  }
}
