import 'package:flutter/foundation.dart';
import 'tournament_model.dart';

/// Match model matching the matches table schema in Supabase.
///
/// Table schema:
/// id, tournament_id, team_a_id, team_b_id, team_a_name, team_b_name,
/// team_a_code, team_b_code, team_a_flag, team_b_flag, date_time, venue,
/// status(upcoming/live/completed), result, winner_team_id, team_a_score,
/// team_b_score, current_over, current_score_a, current_score_b, live
class MatchModel {
  final String id;
  final String? tournamentId;
  final String? teamAId;
  final String? teamBId;
  final String teamAName;
  final String teamBName;
  final String? teamACode;
  final String? teamBCode;
  final String? teamAFlag;
  final String? teamBFlag;
  final DateTime dateTime;
  final String? venue;
  final String status;
  final String? result;
  final String? winnerTeamId;
  final String? teamAScore;
  final String? teamBScore;
  final double? currentOver;
  final String? currentScoreA;
  final String? currentScoreB;
  final bool live;
  final TournamentModel? tournament;
  final DateTime? createdAt;

  const MatchModel({
    required this.id,
    this.tournamentId,
    this.teamAId,
    this.teamBId,
    required this.teamAName,
    required this.teamBName,
    this.teamACode,
    this.teamBCode,
    this.teamAFlag,
    this.teamBFlag,
    required this.dateTime,
    this.venue,
    this.status = 'upcoming',
    this.result,
    this.winnerTeamId,
    this.teamAScore,
    this.teamBScore,
    this.currentOver,
    this.currentScoreA,
    this.currentScoreB,
    this.live = false,
    this.tournament,
    this.createdAt,
  });

  /// Create from JSON (Supabase response with tournament and team relations).
  factory MatchModel.fromJson(Map<String, dynamic> json) {
    // Parse nested team data from joined teams table
    final teamAData = json['team_a'] as Map<String, dynamic>?;
    final teamBData2 = json['team_b'] as Map<String, dynamic>?;
    debugPrint('[MatchModel] teamA join: ${teamAData != null}, teamB join: ${teamBData2 != null}, teamA logo: ${teamAData?["logo"]}');
    final teamBData = json['team_b'] as Map<String, dynamic>?;

    return MatchModel(
      id: json['id'] as String? ?? '',
      tournamentId: json['tournament_id'] as String?,
      teamAId: json['team_a_id'] as String?,
      teamBId: json['team_b_id'] as String?,
      teamAName: teamAData?['name'] as String? ?? json['team_a_name'] as String? ?? 'Team A',
      teamBName: teamBData?['name'] as String? ?? json['team_b_name'] as String? ?? 'Team B',
      teamACode: teamAData?['code'] as String? ?? json['team_a_code'] as String?,
      teamBCode: teamBData?['code'] as String? ?? json['team_b_code'] as String?,
      teamAFlag: teamAData?['logo'] as String? ?? json['team_a_flag'] as String?,
      teamBFlag: teamBData?['logo'] as String? ?? json['team_b_flag'] as String?,
      dateTime: json['date_time'] != null
          ? DateTime.parse(json['date_time'] as String)
          : DateTime.now(),
      venue: json['venue'] as String?,
      status: json['status'] as String? ?? 'upcoming',
      result: json['result'] as String?,
      winnerTeamId: json['winner_team_id'] as String?,
      teamAScore: json['team_a_score'] as String?,
      teamBScore: json['team_b_score'] as String?,
      currentOver: (json['current_over'] as num?)?.toDouble(),
      currentScoreA: json['current_score_a'] as String?,
      currentScoreB: json['current_score_b'] as String?,
      live: json['live'] as bool? ?? false,
      tournament: json['tournament'] != null
          ? TournamentModel.fromJson(json['tournament'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert to JSON for Supabase operations.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (tournamentId != null) 'tournament_id': tournamentId,
      if (teamAId != null) 'team_a_id': teamAId,
      if (teamBId != null) 'team_b_id': teamBId,
      'team_a_name': teamAName,
      'team_b_name': teamBName,
      if (teamACode != null) 'team_a_code': teamACode,
      if (teamBCode != null) 'team_b_code': teamBCode,
      if (teamAFlag != null) 'team_a_flag': teamAFlag,
      if (teamBFlag != null) 'team_b_flag': teamBFlag,
      'date_time': dateTime.toIso8601String(),
      if (venue != null) 'venue': venue,
      'status': status,
      if (result != null) 'result': result,
      if (winnerTeamId != null) 'winner_team_id': winnerTeamId,
      if (teamAScore != null) 'team_a_score': teamAScore,
      if (teamBScore != null) 'team_b_score': teamBScore,
      if (currentOver != null) 'current_over': currentOver,
      if (currentScoreA != null) 'current_score_a': currentScoreA,
      if (currentScoreB != null) 'current_score_b': currentScoreB,
      'live': live,
    };
  }

  /// Copy with modified fields.
  MatchModel copyWith({
    String? id,
    String? tournamentId,
    String? teamAId,
    String? teamBId,
    String? teamAName,
    String? teamBName,
    String? teamACode,
    String? teamBCode,
    String? teamAFlag,
    String? teamBFlag,
    DateTime? dateTime,
    String? venue,
    String? status,
    String? result,
    String? winnerTeamId,
    String? teamAScore,
    String? teamBScore,
    double? currentOver,
    String? currentScoreA,
    String? currentScoreB,
    bool? live,
    TournamentModel? tournament,
    DateTime? createdAt,
  }) {
    return MatchModel(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      teamAId: teamAId ?? this.teamAId,
      teamBId: teamBId ?? this.teamBId,
      teamAName: teamAName ?? this.teamAName,
      teamBName: teamBName ?? this.teamBName,
      teamACode: teamACode ?? this.teamACode,
      teamBCode: teamBCode ?? this.teamBCode,
      teamAFlag: teamAFlag ?? this.teamAFlag,
      teamBFlag: teamBFlag ?? this.teamBFlag,
      dateTime: dateTime ?? this.dateTime,
      venue: venue ?? this.venue,
      status: status ?? this.status,
      result: result ?? this.result,
      winnerTeamId: winnerTeamId ?? this.winnerTeamId,
      teamAScore: teamAScore ?? this.teamAScore,
      teamBScore: teamBScore ?? this.teamBScore,
      currentOver: currentOver ?? this.currentOver,
      currentScoreA: currentScoreA ?? this.currentScoreA,
      currentScoreB: currentScoreB ?? this.currentScoreB,
      live: live ?? this.live,
      tournament: tournament ?? this.tournament,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Whether match is upcoming.
  bool get isUpcoming => status == 'upcoming' || status == 'scheduled';

  /// Whether match is live.
  bool get isLive => status == 'live' || live;

  /// Whether match is completed.
  bool get isCompleted => status == 'completed';

  /// Get tournament name if available.
  String get tournamentName => tournament?.name ?? '';

  /// Get tournament logo if available.
  String? get tournamentLogo => tournament?.logo;

  /// Time remaining until match starts.
  Duration get timeUntilStart => dateTime.difference(DateTime.now());

  @override
  String toString() =>
      'MatchModel(id: $id, $teamAName vs $teamBName, status: $status)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MatchModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
