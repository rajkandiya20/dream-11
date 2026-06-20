/// Player model matching the players table schema in Supabase.
///
/// Table schema:
/// id, name, role(Batsman/Bowler/All-rounder/WK), team_id, image, points, credits, is_playing
class PlayerModel {
  final String id;
  final String name;
  final String role;
  final String? teamId;
  final String? image;
  final double points;
  final double credits;
  final bool isPlaying;
  final TeamInfo? team;
  final DateTime? createdAt;

  const PlayerModel({
    required this.id,
    required this.name,
    required this.role,
    this.teamId,
    this.image,
    this.points = 0.0,
    this.credits = 8.0,
    this.isPlaying = false,
    this.team,
    this.createdAt,
  });

  /// Create from JSON (Supabase response with team relation).
  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    // Handle nested match_players query format
    final playerData = json.containsKey('player')
        ? json['player'] as Map<String, dynamic>? ?? json
        : json;

    return PlayerModel(
      id: playerData['id'] as String? ?? json['player_id'] as String? ?? '',
      name: playerData['name'] as String? ?? '',
      role: playerData['role'] as String? ?? 'Batsman',
      teamId: playerData['team_id'] as String?,
      image: playerData['image'] as String?,
      points: (playerData['points'] as num?)?.toDouble() ??
          (json['points'] as num?)?.toDouble() ??
          0.0,
      credits: (playerData['credits'] as num?)?.toDouble() ?? 8.0,
      isPlaying: playerData['is_playing'] as bool? ??
          json['is_playing'] as bool? ??
          false,
      team: playerData['team'] != null
          ? TeamInfo.fromJson(playerData['team'] as Map<String, dynamic>)
          : null,
      createdAt: playerData['created_at'] != null
          ? DateTime.tryParse(playerData['created_at'] as String)
          : null,
    );
  }

  /// Convert to JSON for Supabase operations.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      if (teamId != null) 'team_id': teamId,
      if (image != null) 'image': image,
      'points': points,
      'credits': credits,
      'is_playing': isPlaying,
    };
  }

  /// Copy with modified fields.
  PlayerModel copyWith({
    String? id,
    String? name,
    String? role,
    String? teamId,
    String? image,
    double? points,
    double? credits,
    bool? isPlaying,
    TeamInfo? team,
    DateTime? createdAt,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      teamId: teamId ?? this.teamId,
      image: image ?? this.image,
      points: points ?? this.points,
      credits: credits ?? this.credits,
      isPlaying: isPlaying ?? this.isPlaying,
      team: team ?? this.team,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Whether player is a wicket keeper.
  bool get isWicketKeeper => role == 'WK';

  /// Whether player is a batsman.
  bool get isBatsman => role == 'Batsman';

  /// Whether player is a bowler.
  bool get isBowler => role == 'Bowler';

  /// Whether player is an all-rounder.
  bool get isAllRounder => role == 'All-rounder';

  /// Get role abbreviation.
  String get roleAbbreviation {
    switch (role) {
      case 'WK':
        return 'WK';
      case 'Batsman':
        return 'BAT';
      case 'Bowler':
        return 'BOWL';
      case 'All-rounder':
        return 'AR';
      default:
        return role;
    }
  }

  /// Get team name.
  String get teamName => team?.name ?? '';

  @override
  String toString() => 'PlayerModel(id: $id, name: $name, role: $role)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayerModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Lightweight team info embedded in player.
class TeamInfo {
  final String? name;
  final String? code;
  final String? logo;

  const TeamInfo({
    this.name,
    this.code,
    this.logo,
  });

  factory TeamInfo.fromJson(Map<String, dynamic> json) {
    return TeamInfo(
      name: json['name'] as String?,
      code: json['code'] as String?,
      logo: json['logo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (logo != null) 'logo': logo,
    };
  }
}
