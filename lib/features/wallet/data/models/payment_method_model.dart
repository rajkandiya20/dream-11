/// Payment method model matching the payment_methods table schema.
///
/// Table schema:
/// id, user_id, method_type(upi/bank_account/phonepe), details(jsonb), is_default
class PaymentMethodModel {
  final String id;
  final String userId;
  final PaymentMethodType methodType;
  final Map<String, dynamic> details;
  final bool isDefault;
  final DateTime? createdAt;

  const PaymentMethodModel({
    required this.id,
    required this.userId,
    required this.methodType,
    this.details = const {},
    this.isDefault = false,
    this.createdAt,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      methodType: PaymentMethodType.fromString(
          json['method_type'] as String? ?? 'upi'),
      details: json['details'] is Map<String, dynamic>
          ? json['details'] as Map<String, dynamic>
          : {},
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'method_type': methodType.value,
      'details': details,
      'is_default': isDefault,
    };
  }

  PaymentMethodModel copyWith({
    String? id,
    String? userId,
    PaymentMethodType? methodType,
    Map<String, dynamic>? details,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      methodType: methodType ?? this.methodType,
      details: details ?? this.details,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Display name for the payment method.
  String get displayName {
    switch (methodType) {
      case PaymentMethodType.upi:
        return details['upi_id'] as String? ?? 'UPI';
      case PaymentMethodType.bankAccount:
        final accountNumber = details['account_number'] as String? ?? '';
        return accountNumber.length > 4
            ? 'Bank ****${accountNumber.substring(accountNumber.length - 4)}'
            : 'Bank Account';
      case PaymentMethodType.phonepe:
        return details['phone'] as String? ?? 'PhonePe';
    }
  }

  @override
  String toString() =>
      'PaymentMethodModel(type: ${methodType.value}, default: $isDefault)';
}

/// Payment method type enum.
enum PaymentMethodType {
  upi('upi'),
  bankAccount('bank_account'),
  phonepe('phonepe');

  final String value;
  const PaymentMethodType(this.value);

  factory PaymentMethodType.fromString(String value) {
    return PaymentMethodType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentMethodType.upi,
    );
  }

  String get displayName {
    switch (this) {
      case PaymentMethodType.upi:
        return 'UPI';
      case PaymentMethodType.bankAccount:
        return 'Bank Account';
      case PaymentMethodType.phonepe:
        return 'PhonePe';
    }
  }

  String get iconName {
    switch (this) {
      case PaymentMethodType.upi:
        return 'account_balance_wallet';
      case PaymentMethodType.bankAccount:
        return 'account_balance';
      case PaymentMethodType.phonepe:
        return 'phone_android';
    }
  }
}
