import '../../../matches/data/models/player_model.dart';

/// Fantasy team model matching the fantasy_teams table schema in Supabase.
///
/// Table schema:
/// id, user_id, match_id, contest_id, team_name, captain_id, vice_captain_id,
/// total_points, rank
class FantasyTeamModel {
  final String id;
  final String userId;
  final String matchId;
  final String? contestId;
  final String teamName;
  final String? captainId;
  final String? viceCaptainId;
  final double totalPoints;
  final int? rank;
  final List<FantasyTeamPlayerModel> players;
  final DateTime? createdAt;

  const FantasyTeamModel({
    required this.id,
    required this.userId,
    required this.matchId,
    this.contestId,
    required this.teamName,
    this.captainId,
    this.viceCaptainId,
    this.totalPoints = 0.0,
    this.rank,
    this.players = const [],
    this.createdAt,
  });

  /// Create from JSON (Supabase response with fantasy_team_players relation).
  factory FantasyTeamModel.fromJson(Map<String, dynamic> json) {
    final playersJson = json['fantasy_team_players'] as List<dynamic>?;

    return FantasyTeamModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      matchId: json['match_id'] as String? ?? '',
      contestId: json['contest_id'] as String?,
      teamName: json['team_name'] as String? ?? 'My Team',
      captainId: json['captain_id'] as String?,
      viceCaptainId: json['vice_captain_id'] as String?,
      totalPoints: (json['total_points'] as num?)?.toDouble() ?? 0.0,
      rank: json['rank'] as int?,
      players: playersJson
              ?.map((p) =>
                  FantasyTeamPlayerModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert to JSON for Supabase insert.
  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'match_id': matchId,
      if (contestId != null) 'contest_id': contestId,
      'team_name': teamName,
      if (captainId != null) 'captain_id': captainId,
      if (viceCaptainId != null) 'vice_captain_id': viceCaptainId,
      'total_points': totalPoints,
      if (rank != null) 'rank': rank,
    };
  }

  /// Copy with modified fields.
  FantasyTeamModel copyWith({
    String? id,
    String? userId,
    String? matchId,
    String? contestId,
    String? teamName,
    String? captainId,
    String? viceCaptainId,
    double? totalPoints,
    int? rank,
    List<FantasyTeamPlayerModel>? players,
    DateTime? createdAt,
  }) {
    return FantasyTeamModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      matchId: matchId ?? this.matchId,
      contestId: contestId ?? this.contestId,
      teamName: teamName ?? this.teamName,
      captainId: captainId ?? this.captainId,
      viceCaptainId: viceCaptainId ?? this.viceCaptainId,
      totalPoints: totalPoints ?? this.totalPoints,
      rank: rank ?? this.rank,
      players: players ?? this.players,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Number of players selected.
  int get playerCount => players.length;

  /// Whether team has all 11 players.
  bool get isComplete => playerCount == 11;

  /// Whether captain and vice captain are selected.
  bool get hasCaptains =>
      captainId != null &&
      captainId!.isNotEmpty &&
      viceCaptainId != null &&
      viceCaptainId!.isNotEmpty;

  @override
  String toString() =>
      'FantasyTeamModel(id: $id, teamName: $teamName, players: $playerCount)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FantasyTeamModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Fantasy team player model matching fantasy_team_players table.
///
/// Table schema:
/// id, fantasy_team_id, player_id, is_captain, is_vice_captain, points
class FantasyTeamPlayerModel {
  final String id;
  final String fantasyTeamId;
  final String playerId;
  final bool isCaptain;
  final bool isViceCaptain;
  final double points;
  final PlayerModel? player;

  const FantasyTeamPlayerModel({
    required this.id,
    required this.fantasyTeamId,
    required this.playerId,
    this.isCaptain = false,
    this.isViceCaptain = false,
    this.points = 0.0,
    this.player,
  });

  /// Create from JSON (Supabase response with player relation).
  factory FantasyTeamPlayerModel.fromJson(Map<String, dynamic> json) {
    return FantasyTeamPlayerModel(
      id: json['id'] as String? ?? '',
      fantasyTeamId: json['fantasy_team_id'] as String? ?? '',
      playerId: json['player_id'] as String? ?? '',
      isCaptain: json['is_captain'] as bool? ?? false,
      isViceCaptain: json['is_vice_captain'] as bool? ?? false,
      points: (json['points'] as num?)?.toDouble() ?? 0.0,
      player: json['player'] != null
          ? PlayerModel.fromJson(json['player'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert to JSON for Supabase insert.
  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'fantasy_team_id': fantasyTeamId,
      'player_id': playerId,
      'is_captain': isCaptain,
      'is_vice_captain': isViceCaptain,
      'points': points,
    };
  }

  /// Copy with modified fields.
  FantasyTeamPlayerModel copyWith({
    String? id,
    String? fantasyTeamId,
    String? playerId,
    bool? isCaptain,
    bool? isViceCaptain,
    double? points,
    PlayerModel? player,
  }) {
    return FantasyTeamPlayerModel(
      id: id ?? this.id,
      fantasyTeamId: fantasyTeamId ?? this.fantasyTeamId,
      playerId: playerId ?? this.playerId,
      isCaptain: isCaptain ?? this.isCaptain,
      isViceCaptain: isViceCaptain ?? this.isViceCaptain,
      points: points ?? this.points,
      player: player ?? this.player,
    );
  }

  /// Get player name from relation.
  String get playerName => player?.name ?? '';

  /// Get player role from relation.
  String get playerRole => player?.role ?? '';

  @override
  String toString() =>
      'FantasyTeamPlayerModel(playerId: $playerId, captain: $isCaptain)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FantasyTeamPlayerModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
