import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client.dart';
import '../../../home/data/models/match_model.dart';
import '../models/ball_by_ball_model.dart';
import '../models/contest_model.dart';
import '../models/player_model.dart';
import '../models/player_stats_model.dart';
import '../models/scoreboard_model.dart';

/// Repository for fetching match detail data from Supabase.
class MatchRepository {
  final SupabaseClient _client;

  MatchRepository(this._client);

  /// Fetch match by ID with full team details and tournament.
  Future<MatchModel?> getMatchById(String matchId) async {
    try {
      final response = await _client
          .from('matches')
          .select(
              '*, tournament:tournaments(name, logo), team_a_details:teams!matches_team_a_id_fkey(*), team_b_details:teams!matches_team_b_id_fkey(*)')
          .eq('id', matchId)
          .single();

      return MatchModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Fetch contests for a specific match.
  Future<List<ContestModel>> getContestsByMatch(String matchId) async {
    try {
      final response = await _client
          .from('contests')
          .select()
          .eq('match_id', matchId)
          .order('prize_pool', ascending: false);

      return (response as List)
          .map((json) => ContestModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch players for a specific match.
  Future<List<PlayerModel>> getPlayersByMatch(String matchId) async {
    try {
      final response = await _client
          .from('match_players')
          .select('*, player:players(*)')
          .eq('match_id', matchId);

      return (response as List)
          .map((json) => PlayerModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch scoreboard for a match, ordered by points descending.
  Future<List<ScoreboardModel>> getScoreboard(String matchId) async {
    try {
      final response = await _client
          .from('scoreboard')
          .select('*, player:players(name, role)')
          .eq('match_id', matchId)
          .order('points', ascending: false);

      return (response as List)
          .map(
              (json) => ScoreboardModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch commentary for a match, ordered by over/ball descending.
  Future<List<CommentaryModel>> getCommentary(String matchId) async {
    try {
      final response = await _client
          .from('commentary')
          .select()
          .eq('match_id', matchId)
          .order('over_number', ascending: false)
          .order('ball_number', ascending: false);

      return (response as List)
          .map(
              (json) => CommentaryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Subscribe to real-time scoreboard updates for a match.
  RealtimeChannel subscribeToScoreboard(
    String matchId, {
    required void Function(ScoreboardModel entry) onUpdate,
  }) {
    return _client
        .channel('realtime-scoreboard-$matchId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'scoreboard',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'match_id',
            value: matchId,
          ),
          callback: (payload) {
            final record = payload.newRecord;
            if (record.isNotEmpty) {
              onUpdate(ScoreboardModel.fromJson(record));
            }
          },
        )
        .subscribe();
  }

  /// Subscribe to real-time commentary updates for a match.
  RealtimeChannel subscribeToCommentary(
    String matchId, {
    required void Function(CommentaryModel entry) onUpdate,
  }) {
    return _client
        .channel('realtime-commentary-$matchId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'commentary',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'match_id',
            value: matchId,
          ),
          callback: (payload) {
            final record = payload.newRecord;
            if (record.isNotEmpty) {
              onUpdate(CommentaryModel.fromJson(record));
            }
          },
        )
        .subscribe();
  }

  /// Subscribe to real-time contest updates for a match.
  RealtimeChannel subscribeToContests(
    String matchId, {
    required void Function(ContestModel contest) onUpdate,
  }) {
    return _client
        .channel('realtime-contests-$matchId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'contests',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'match_id',
            value: matchId,
          ),
          callback: (payload) {
            final record = payload.newRecord;
            if (record.isNotEmpty) {
              onUpdate(ContestModel.fromJson(record));
            }
          },
        )
        .subscribe();
  }

  /// Fetch ball-by-ball data for a match, ordered by over/ball descending.
  Future<List<BallByBallModel>> getBallByBall(String matchId) async {
    try {
      final response = await _client
          .from('ball_by_ball')
          .select()
          .eq('match_id', matchId)
          .order('over_number', ascending: false)
          .order('ball_number', ascending: false);

      return (response as List)
          .map((json) =>
              BallByBallModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch player stats for a match.
  Future<List<PlayerStatsModel>> getPlayerStats(String matchId) async {
    try {
      final response = await _client
          .from('player_stats')
          .select()
          .eq('match_id', matchId)
          .order('fantasy_points', ascending: false);

      return (response as List)
          .map((json) =>
              PlayerStatsModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Subscribe to real-time ball-by-ball updates for a match.
  RealtimeChannel subscribeToBallByBall(
    String matchId, {
    required void Function(BallByBallModel entry) onUpdate,
  }) {
    return _client
        .channel('realtime-ball-by-ball-$matchId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'ball_by_ball',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'match_id',
            value: matchId,
          ),
          callback: (payload) {
            final record = payload.newRecord;
            if (record.isNotEmpty) {
              onUpdate(BallByBallModel.fromJson(record));
            }
          },
        )
        .subscribe();
  }

  /// Subscribe to real-time player stats updates for a match.
  RealtimeChannel subscribeToPlayerStats(
    String matchId, {
    required void Function(PlayerStatsModel entry) onUpdate,
  }) {
    return _client
        .channel('realtime-player-stats-$matchId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'player_stats',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'match_id',
            value: matchId,
          ),
          callback: (payload) {
            final record = payload.newRecord;
            if (record.isNotEmpty) {
              onUpdate(PlayerStatsModel.fromJson(record));
            }
          },
        )
        .subscribe();
  }

  /// Unsubscribe from a real-time channel.
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }
}

/// Provider for the match repository.
final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return MatchRepository(client);
});
