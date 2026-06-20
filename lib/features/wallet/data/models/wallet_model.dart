/// Wallet model matching the wallets table schema in Supabase.
///
/// Table schema:
/// id, user_id, balance, bonus, winnings
class WalletModel {
  final String id;
  final String userId;
  final double balance;
  final double bonus;
  final double winnings;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WalletModel({
    required this.id,
    required this.userId,
    this.balance = 0.0,
    this.bonus = 0.0,
    this.winnings = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  /// Total available balance (deposited + bonus + winnings).
  double get totalBalance => balance + bonus + winnings;

  /// Withdrawable amount (balance + winnings, bonus is non-withdrawable).
  double get withdrawableBalance => balance + winnings;

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      bonus: (json['bonus'] as num?)?.toDouble() ?? 0.0,
      winnings: (json['winnings'] as num?)?.toDouble() ?? 0.0,
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
      'id': id,
      'user_id': userId,
      'balance': balance,
      'bonus': bonus,
      'winnings': winnings,
    };
  }

  WalletModel copyWith({
    String? id,
    String? userId,
    double? balance,
    double? bonus,
    double? winnings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      bonus: bonus ?? this.bonus,
      winnings: winnings ?? this.winnings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static const WalletModel empty = WalletModel(
    id: '',
    userId: '',
  );

  @override
  String toString() =>
      'WalletModel(balance: $balance, bonus: $bonus, winnings: $winnings)';
}
