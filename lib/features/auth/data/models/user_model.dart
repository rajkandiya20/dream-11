/// User model matching the users table schema in Supabase.
///
/// Table schema:
/// id, uid, email, username, phone_number, avatar_url, role, balance,
/// total_amount_added, total_amount_won
class UserModel {
  final String? id;
  final String uid;
  final String email;
  final String? username;
  final String? phoneNumber;
  final String? avatarUrl;
  final String role;
  final double balance;
  final double totalAmountAdded;
  final double totalAmountWon;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    this.id,
    required this.uid,
    required this.email,
    this.username,
    this.phoneNumber,
    this.avatarUrl,
    this.role = 'user',
    this.balance = 0.0,
    this.totalAmountAdded = 0.0,
    this.totalAmountWon = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON (Supabase response).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String?,
      phoneNumber: json['phone_number'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'user',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      totalAmountAdded: (json['total_amount_added'] as num?)?.toDouble() ?? 0.0,
      totalAmountWon: (json['total_amount_won'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON for Supabase upsert.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'uid': uid,
      'email': email,
      if (username != null) 'username': username,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'role': role,
      'balance': balance,
      'total_amount_added': totalAmountAdded,
      'total_amount_won': totalAmountWon,
    };
  }

  /// Copy with modified fields.
  UserModel copyWith({
    String? id,
    String? uid,
    String? email,
    String? username,
    String? phoneNumber,
    String? avatarUrl,
    String? role,
    double? balance,
    double? totalAmountAdded,
    double? totalAmountWon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      balance: balance ?? this.balance,
      totalAmountAdded: totalAmountAdded ?? this.totalAmountAdded,
      totalAmountWon: totalAmountWon ?? this.totalAmountWon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if user is admin.
  bool get isAdmin => role == 'admin' || role == 'super_admin';

  /// Get display name (username or email).
  String get displayName => username ?? email.split('@').first;

  @override
  String toString() => 'UserModel(uid: $uid, email: $email, role: $role)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
