/// Player stats model matching the player_stats table schema in Supabase.
///
/// Table schema:
/// id, match_id, player_id, runs, balls_faced, fours, sixes, wickets,
/// overs_bowled, runs_conceded, maidens, catches, stumpings, run_outs,
/// economy, strike_rate, fantasy_points, created_at
class PlayerStatsModel {
  final String id;
  final String matchId;
  final String playerId;
  final int runs;
  final int ballsFaced;
  final int fours;
  final int sixes;
  final int wickets;
  final double oversBowled;
  final int runsConceded;
  final int maidens;
  final int catches;
  final int stumpings;
  final int runOuts;
  final double economy;
  final double strikeRate;
  final double fantasyPoints;
  final DateTime? createdAt;

  const PlayerStatsModel({
    required this.id,
    required this.matchId,
    required this.playerId,
    this.runs = 0,
    this.ballsFaced = 0,
    this.fours = 0,
    this.sixes = 0,
    this.wickets = 0,
    this.oversBowled = 0.0,
    this.runsConceded = 0,
    this.maidens = 0,
    this.catches = 0,
    this.stumpings = 0,
    this.runOuts = 0,
    this.economy = 0.0,
    this.strikeRate = 0.0,
    this.fantasyPoints = 0.0,
    this.createdAt,
  });

  /// Create from JSON (Supabase response).
  factory PlayerStatsModel.fromJson(Map<String, dynamic> json) {
    return PlayerStatsModel(
      id: json['id'] as String? ?? '',
      matchId: json['match_id'] as String? ?? '',
      playerId: json['player_id'] as String? ?? '',
      runs: json['runs'] as int? ?? 0,
      ballsFaced: json['balls_faced'] as int? ?? 0,
      fours: json['fours'] as int? ?? 0,
      sixes: json['sixes'] as int? ?? 0,
      wickets: json['wickets'] as int? ?? 0,
      oversBowled: (json['overs_bowled'] as num?)?.toDouble() ?? 0.0,
      runsConceded: json['runs_conceded'] as int? ?? 0,
      maidens: json['maidens'] as int? ?? 0,
      catches: json['catches'] as int? ?? 0,
      stumpings: json['stumpings'] as int? ?? 0,
      runOuts: json['run_outs'] as int? ?? 0,
      economy: (json['economy'] as num?)?.toDouble() ?? 0.0,
      strikeRate: (json['strike_rate'] as num?)?.toDouble() ?? 0.0,
      fantasyPoints: (json['fantasy_points'] as num?)?.toDouble() ?? 0.0,
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
      'player_id': playerId,
      'runs': runs,
      'balls_faced': ballsFaced,
      'fours': fours,
      'sixes': sixes,
      'wickets': wickets,
      'overs_bowled': oversBowled,
      'runs_conceded': runsConceded,
      'maidens': maidens,
      'catches': catches,
      'stumpings': stumpings,
      'run_outs': runOuts,
      'economy': economy,
      'strike_rate': strikeRate,
      'fantasy_points': fantasyPoints,
    };
  }

  /// Copy with modified fields.
  PlayerStatsModel copyWith({
    String? id,
    String? matchId,
    String? playerId,
    int? runs,
    int? ballsFaced,
    int? fours,
    int? sixes,
    int? wickets,
    double? oversBowled,
    int? runsConceded,
    int? maidens,
    int? catches,
    int? stumpings,
    int? runOuts,
    double? economy,
    double? strikeRate,
    double? fantasyPoints,
    DateTime? createdAt,
  }) {
    return PlayerStatsModel(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      playerId: playerId ?? this.playerId,
      runs: runs ?? this.runs,
      ballsFaced: ballsFaced ?? this.ballsFaced,
      fours: fours ?? this.fours,
      sixes: sixes ?? this.sixes,
      wickets: wickets ?? this.wickets,
      oversBowled: oversBowled ?? this.oversBowled,
      runsConceded: runsConceded ?? this.runsConceded,
      maidens: maidens ?? this.maidens,
      catches: catches ?? this.catches,
      stumpings: stumpings ?? this.stumpings,
      runOuts: runOuts ?? this.runOuts,
      economy: economy ?? this.economy,
      strikeRate: strikeRate ?? this.strikeRate,
      fantasyPoints: fantasyPoints ?? this.fantasyPoints,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'PlayerStatsModel(id: $id, playerId: $playerId, points: $fantasyPoints)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayerStatsModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
