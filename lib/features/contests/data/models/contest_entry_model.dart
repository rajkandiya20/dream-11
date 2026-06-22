/// Contest entry model matching the contest_entries table schema in Supabase.
///
/// Table schema:
/// id, contest_id, user_id, fantasy_team_id, total_points, rank, prize_won, created_at
class ContestEntryModel {
  final String id;
  final String contestId;
  final String userId;
  final String fantasyTeamId;
  final double totalPoints;
  final int? rank;
  final double prizeWon;
  final DateTime? createdAt;

  const ContestEntryModel({
    required this.id,
    required this.contestId,
    required this.userId,
    required this.fantasyTeamId,
    this.totalPoints = 0.0,
    this.rank,
    this.prizeWon = 0.0,
    this.createdAt,
  });

  /// Create from JSON (Supabase response).
  factory ContestEntryModel.fromJson(Map<String, dynamic> json) {
    return ContestEntryModel(
      id: json['id'] as String? ?? '',
      contestId: json['contest_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      fantasyTeamId: json['fantasy_team_id'] as String? ?? '',
      totalPoints: (json['total_points'] as num?)?.toDouble() ?? 0.0,
      rank: json['rank'] as int?,
      prizeWon: (json['prize_won'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert to JSON for Supabase operations.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contest_id': contestId,
      'user_id': userId,
      'fantasy_team_id': fantasyTeamId,
      'total_points': totalPoints,
      if (rank != null) 'rank': rank,
      'prize_won': prizeWon,
    };
  }

  /// Copy with modified fields.
  ContestEntryModel copyWith({
    String? id,
    String? contestId,
    String? userId,
    String? fantasyTeamId,
    double? totalPoints,
    int? rank,
    double? prizeWon,
    DateTime? createdAt,
  }) {
    return ContestEntryModel(
      id: id ?? this.id,
      contestId: contestId ?? this.contestId,
      userId: userId ?? this.userId,
      fantasyTeamId: fantasyTeamId ?? this.fantasyTeamId,
      totalPoints: totalPoints ?? this.totalPoints,
      rank: rank ?? this.rank,
      prizeWon: prizeWon ?? this.prizeWon,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'ContestEntryModel(id: $id, userId: $userId, points: $totalPoints, rank: $rank)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContestEntryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
