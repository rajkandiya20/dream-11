/// Scoreboard model matching the scoreboard table schema in Supabase.
///
/// Table schema:
/// id, match_id, player_id, runs, wickets, catches, stumpings, run_outs,
/// fours, sixes, balls_faced, overs_bowled, economy, strike_rate, points
class ScoreboardModel {
  final String id;
  final String matchId;
  final String playerId;
  final int runs;
  final int wickets;
  final int catches;
  final int stumpings;
  final int runOuts;
  final int fours;
  final int sixes;
  final int ballsFaced;
  final double oversBowled;
  final double economy;
  final double strikeRate;
  final double points;
  final PlayerInfo? player;

  const ScoreboardModel({
    required this.id,
    required this.matchId,
    required this.playerId,
    this.runs = 0,
    this.wickets = 0,
    this.catches = 0,
    this.stumpings = 0,
    this.runOuts = 0,
    this.fours = 0,
    this.sixes = 0,
    this.ballsFaced = 0,
    this.oversBowled = 0.0,
    this.economy = 0.0,
    this.strikeRate = 0.0,
    this.points = 0.0,
    this.player,
  });

  /// Create from JSON (Supabase response with player relation).
  factory ScoreboardModel.fromJson(Map<String, dynamic> json) {
    return ScoreboardModel(
      id: json['id'] as String? ?? '',
      matchId: json['match_id'] as String? ?? '',
      playerId: json['player_id'] as String? ?? '',
      runs: json['runs'] as int? ?? 0,
      wickets: json['wickets'] as int? ?? 0,
      catches: json['catches'] as int? ?? 0,
      stumpings: json['stumpings'] as int? ?? 0,
      runOuts: json['run_outs'] as int? ?? 0,
      fours: json['fours'] as int? ?? 0,
      sixes: json['sixes'] as int? ?? 0,
      ballsFaced: json['balls_faced'] as int? ?? 0,
      oversBowled: (json['overs_bowled'] as num?)?.toDouble() ?? 0.0,
      economy: (json['economy'] as num?)?.toDouble() ?? 0.0,
      strikeRate: (json['strike_rate'] as num?)?.toDouble() ?? 0.0,
      points: (json['points'] as num?)?.toDouble() ?? 0.0,
      player: json['player'] != null
          ? PlayerInfo.fromJson(json['player'] as Map<String, dynamic>)
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
      'wickets': wickets,
      'catches': catches,
      'stumpings': stumpings,
      'run_outs': runOuts,
      'fours': fours,
      'sixes': sixes,
      'balls_faced': ballsFaced,
      'overs_bowled': oversBowled,
      'economy': economy,
      'strike_rate': strikeRate,
      'points': points,
    };
  }

  /// Copy with modified fields.
  ScoreboardModel copyWith({
    String? id,
    String? matchId,
    String? playerId,
    int? runs,
    int? wickets,
    int? catches,
    int? stumpings,
    int? runOuts,
    int? fours,
    int? sixes,
    int? ballsFaced,
    double? oversBowled,
    double? economy,
    double? strikeRate,
    double? points,
    PlayerInfo? player,
  }) {
    return ScoreboardModel(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      playerId: playerId ?? this.playerId,
      runs: runs ?? this.runs,
      wickets: wickets ?? this.wickets,
      catches: catches ?? this.catches,
      stumpings: stumpings ?? this.stumpings,
      runOuts: runOuts ?? this.runOuts,
      fours: fours ?? this.fours,
      sixes: sixes ?? this.sixes,
      ballsFaced: ballsFaced ?? this.ballsFaced,
      oversBowled: oversBowled ?? this.oversBowled,
      economy: economy ?? this.economy,
      strikeRate: strikeRate ?? this.strikeRate,
      points: points ?? this.points,
      player: player ?? this.player,
    );
  }

  /// Get player name.
  String get playerName => player?.name ?? '';

  /// Get player role.
  String get playerRole => player?.role ?? '';

  @override
  String toString() =>
      'ScoreboardModel(id: $id, player: $playerName, points: $points)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScoreboardModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Lightweight player info embedded in scoreboard.
class PlayerInfo {
  final String name;
  final String role;

  const PlayerInfo({
    required this.name,
    required this.role,
  });

  factory PlayerInfo.fromJson(Map<String, dynamic> json) {
    return PlayerInfo(
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'role': role};
}

/// Commentary model matching the commentary table schema in Supabase.
///
/// Table schema:
/// id, match_id, over_number, ball_number, runs, event_type, description,
/// batsman, bowler
class CommentaryModel {
  final String id;
  final String matchId;
  final int overNumber;
  final int ballNumber;
  final int runs;
  final String? eventType;
  final String? description;
  final String? batsman;
  final String? bowler;
  final DateTime? createdAt;

  const CommentaryModel({
    required this.id,
    required this.matchId,
    this.overNumber = 0,
    this.ballNumber = 0,
    this.runs = 0,
    this.eventType,
    this.description,
    this.batsman,
    this.bowler,
    this.createdAt,
  });

  /// Create from JSON (Supabase response).
  factory CommentaryModel.fromJson(Map<String, dynamic> json) {
    return CommentaryModel(
      id: json['id'] as String? ?? '',
      matchId: json['match_id'] as String? ?? '',
      overNumber: json['over_number'] as int? ?? 0,
      ballNumber: json['ball_number'] as int? ?? 0,
      runs: json['runs'] as int? ?? 0,
      eventType: json['event_type'] as String?,
      description: json['description'] as String?,
      batsman: json['batsman'] as String?,
      bowler: json['bowler'] as String?,
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
      'over_number': overNumber,
      'ball_number': ballNumber,
      'runs': runs,
      if (eventType != null) 'event_type': eventType,
      if (description != null) 'description': description,
      if (batsman != null) 'batsman': batsman,
      if (bowler != null) 'bowler': bowler,
    };
  }

  /// Copy with modified fields.
  CommentaryModel copyWith({
    String? id,
    String? matchId,
    int? overNumber,
    int? ballNumber,
    int? runs,
    String? eventType,
    String? description,
    String? batsman,
    String? bowler,
    DateTime? createdAt,
  }) {
    return CommentaryModel(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      overNumber: overNumber ?? this.overNumber,
      ballNumber: ballNumber ?? this.ballNumber,
      runs: runs ?? this.runs,
      eventType: eventType ?? this.eventType,
      description: description ?? this.description,
      batsman: batsman ?? this.batsman,
      bowler: bowler ?? this.bowler,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get over.ball format string.
  String get overBall => '$overNumber.$ballNumber';

  /// Whether this is a wicket event.
  bool get isWicket => eventType == 'wicket';

  /// Whether this is a boundary (4 or 6).
  bool get isBoundary => eventType == 'four' || eventType == 'six';

  @override
  String toString() =>
      'CommentaryModel(id: $id, over: $overBall, runs: $runs)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommentaryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
