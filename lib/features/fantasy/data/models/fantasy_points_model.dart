/// Fantasy points model matching the fantasy_points table schema in Supabase.
///
/// Table schema:
/// id, match_id, player_id, contest_id, fantasy_team_id, base_points,
/// captain_multiplier, vice_captain_multiplier, total_points, breakdown, updated_at
class FantasyPointsModel {
  final String id;
  final String matchId;
  final String playerId;
  final String? contestId;
  final String? fantasyTeamId;
  final double basePoints;
  final double captainMultiplier;
  final double viceCaptainMultiplier;
  final double totalPoints;
  final Map<String, dynamic>? breakdown;
  final DateTime? updatedAt;

  const FantasyPointsModel({
    required this.id,
    required this.matchId,
    required this.playerId,
    this.contestId,
    this.fantasyTeamId,
    this.basePoints = 0.0,
    this.captainMultiplier = 1.0,
    this.viceCaptainMultiplier = 1.0,
    this.totalPoints = 0.0,
    this.breakdown,
    this.updatedAt,
  });

  /// Create from JSON (Supabase response).
  factory FantasyPointsModel.fromJson(Map<String, dynamic> json) {
    return FantasyPointsModel(
      id: json['id'] as String? ?? '',
      matchId: json['match_id'] as String? ?? '',
      playerId: json['player_id'] as String? ?? '',
      contestId: json['contest_id'] as String?,
      fantasyTeamId: json['fantasy_team_id'] as String?,
      basePoints: (json['base_points'] as num?)?.toDouble() ?? 0.0,
      captainMultiplier:
          (json['captain_multiplier'] as num?)?.toDouble() ?? 1.0,
      viceCaptainMultiplier:
          (json['vice_captain_multiplier'] as num?)?.toDouble() ?? 1.0,
      totalPoints: (json['total_points'] as num?)?.toDouble() ?? 0.0,
      breakdown: json['breakdown'] as Map<String, dynamic>?,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON for Supabase operations.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'match_id': matchId,
      'player_id': playerId,
      if (contestId != null) 'contest_id': contestId,
      if (fantasyTeamId != null) 'fantasy_team_id': fantasyTeamId,
      'base_points': basePoints,
      'captain_multiplier': captainMultiplier,
      'vice_captain_multiplier': viceCaptainMultiplier,
      'total_points': totalPoints,
      if (breakdown != null) 'breakdown': breakdown,
    };
  }

  /// Copy with modified fields.
  FantasyPointsModel copyWith({
    String? id,
    String? matchId,
    String? playerId,
    String? contestId,
    String? fantasyTeamId,
    double? basePoints,
    double? captainMultiplier,
    double? viceCaptainMultiplier,
    double? totalPoints,
    Map<String, dynamic>? breakdown,
    DateTime? updatedAt,
  }) {
    return FantasyPointsModel(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      playerId: playerId ?? this.playerId,
      contestId: contestId ?? this.contestId,
      fantasyTeamId: fantasyTeamId ?? this.fantasyTeamId,
      basePoints: basePoints ?? this.basePoints,
      captainMultiplier: captainMultiplier ?? this.captainMultiplier,
      viceCaptainMultiplier:
          viceCaptainMultiplier ?? this.viceCaptainMultiplier,
      totalPoints: totalPoints ?? this.totalPoints,
      breakdown: breakdown ?? this.breakdown,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'FantasyPointsModel(id: $id, playerId: $playerId, total: $totalPoints)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FantasyPointsModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
