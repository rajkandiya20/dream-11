/// Contest model matching the contests table schema in Supabase.
///
/// Table schema:
/// id, match_id, name, entry_fee, prize_pool, max_teams, joined_teams,
/// contest_type(paid/free), status(open/closed/completed)
class ContestModel {
  final String id;
  final String matchId;
  final String name;
  final double entryFee;
  final double prizePool;
  final int maxTeams;
  final int joinedTeams;
  final String contestType;
  final String status;
  final DateTime? createdAt;

  const ContestModel({
    required this.id,
    required this.matchId,
    required this.name,
    this.entryFee = 0.0,
    this.prizePool = 0.0,
    this.maxTeams = 100,
    this.joinedTeams = 0,
    this.contestType = 'paid',
    this.status = 'open',
    this.createdAt,
  });

  /// Create from JSON (Supabase response).
  factory ContestModel.fromJson(Map<String, dynamic> json) {
    return ContestModel(
      id: json['id'] as String? ?? '',
      matchId: json['match_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      entryFee: (json['entry_fee'] as num?)?.toDouble() ?? 0.0,
      prizePool: (json['prize_pool'] as num?)?.toDouble() ?? 0.0,
      maxTeams: json['max_teams'] as int? ?? 100,
      joinedTeams: json['joined_teams'] as int? ?? 0,
      contestType: json['contest_type'] as String? ?? 'paid',
      status: json['status'] as String? ?? 'open',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert to JSON for Supabase operations.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'match_id': matchId,
      'name': name,
      'entry_fee': entryFee,
      'prize_pool': prizePool,
      'max_teams': maxTeams,
      'joined_teams': joinedTeams,
      'contest_type': contestType,
      'status': status,
    };
  }

  /// Copy with modified fields.
  ContestModel copyWith({
    String? id,
    String? matchId,
    String? name,
    double? entryFee,
    double? prizePool,
    int? maxTeams,
    int? joinedTeams,
    String? contestType,
    String? status,
    DateTime? createdAt,
  }) {
    return ContestModel(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      name: name ?? this.name,
      entryFee: entryFee ?? this.entryFee,
      prizePool: prizePool ?? this.prizePool,
      maxTeams: maxTeams ?? this.maxTeams,
      joinedTeams: joinedTeams ?? this.joinedTeams,
      contestType: contestType ?? this.contestType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Whether the contest is free to enter.
  bool get isFree => contestType == 'free' || entryFee == 0;

  /// Whether the contest is still open for joining.
  bool get isOpen => status == 'open';

  /// Available spots remaining.
  int get spotsLeft => maxTeams - joinedTeams;

  /// Whether the contest is full.
  bool get isFull => joinedTeams >= maxTeams;

  /// Fill percentage (0.0 to 1.0).
  double get fillPercentage =>
      maxTeams > 0 ? joinedTeams / maxTeams : 0.0;

  /// Formatted prize pool string.
  String get formattedPrizePool {
    if (prizePool >= 10000000) {
      return '${(prizePool / 10000000).toStringAsFixed(1)} Cr';
    } else if (prizePool >= 100000) {
      return '${(prizePool / 100000).toStringAsFixed(1)} L';
    } else if (prizePool >= 1000) {
      return '${(prizePool / 1000).toStringAsFixed(1)}K';
    }
    return prizePool.toStringAsFixed(0);
  }

  /// Formatted entry fee string.
  String get formattedEntryFee {
    if (isFree) return 'FREE';
    return '\u20B9${entryFee.toStringAsFixed(0)}';
  }

  @override
  String toString() =>
      'ContestModel(id: $id, name: $name, prizePool: $prizePool)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContestModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
