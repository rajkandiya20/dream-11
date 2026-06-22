import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client.dart';
import '../models/ball_model.dart';

/// Repository for ball-by-ball scoring operations.
class ScoringRepository {
  final SupabaseClient _client;

  ScoringRepository(this._client);

  /// Insert a new ball delivery into the ball_by_ball table.
  Future<Map<String, dynamic>?> insertBall(BallEntry ball) async {
    try {
      final response = await _client
          .from('ball_by_ball')
          .insert(ball.toJson())
          .select()
          .single();
      debugPrint('Ball Saved: over ${ball.overNo}.${ball.ballNo}, '
          'runs: ${ball.runs}, extras: ${ball.extras}');
      return response;
    } catch (e) {
      debugPrint('ScoringRepo insertBall error: $e');
      return null;
    }
  }

  /// Get all ball deliveries for a specific innings of a match.
  Future<List<BallEntry>> getBallsForInnings(
      String matchId, int innings) async {
    try {
      final response = await _client
          .from('ball_by_ball')
          .select('*')
          .eq('match_id', matchId)
          .eq('innings', innings)
          .order('over_no', ascending: true)
          .order('ball_no', ascending: true);
      final list = List<Map<String, dynamic>>.from(response as List);
      return list.map((json) => BallEntry.fromJson(json)).toList();
    } catch (e) {
      debugPrint('ScoringRepo getBallsForInnings error: $e');
      return [];
    }
  }

  /// Get match players with player details for a given match.
  Future<List<Map<String, dynamic>>> getMatchPlayers(String matchId) async {
    try {
      final response = await _client
          .from('match_players')
          .select('*, player:players(*)')
          .eq('match_id', matchId);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('ScoringRepo getMatchPlayers error: $e');
      return [];
    }
  }

  /// Update the match score fields (team scores, current over, status, etc.).
  Future<bool> updateMatchScore(
      String matchId, Map<String, dynamic> data) async {
    try {
      await _client.from('matches').update(data).eq('id', matchId);
      debugPrint('Score Updated: matchId=$matchId, data=$data');
      return true;
    } catch (e) {
      debugPrint('ScoringRepo updateMatchScore error: $e');
      return false;
    }
  }

  /// Update or create a scoreboard entry for a player in a match.
  Future<bool> updateScoreboard(
      String matchId, String playerId, Map<String, dynamic> data) async {
    try {
      final upsertData = {
        'match_id': matchId,
        'player_id': playerId,
        ...data,
      };
      await _client
          .from('scoreboard')
          .upsert(upsertData, onConflict: 'match_id,player_id')
          .select();
      debugPrint('Batsman Updated: playerId=$playerId');
      return true;
    } catch (e) {
      debugPrint('ScoringRepo updateScoreboard error: $e');
      return false;
    }
  }

  /// Undo the last ball delivered in a given innings.
  /// Returns the deleted ball entry or null if no ball found.
  Future<BallEntry?> undoLastBall(String matchId, int innings) async {
    try {
      // Get the last ball
      final response = await _client
          .from('ball_by_ball')
          .select('*')
          .eq('match_id', matchId)
          .eq('innings', innings)
          .order('created_at', ascending: false)
          .limit(1);

      final list = List<Map<String, dynamic>>.from(response as List);
      if (list.isEmpty) {
        debugPrint('ScoringRepo undoLastBall: no balls found');
        return null;
      }

      final lastBall = BallEntry.fromJson(list.first);

      // Delete it
      await _client.from('ball_by_ball').delete().eq('id', lastBall.id!);

      debugPrint('Ball Undone: over ${lastBall.overNo}.${lastBall.ballNo}');
      return lastBall;
    } catch (e) {
      debugPrint('ScoringRepo undoLastBall error: $e');
      return null;
    }
  }

  /// Get the computed innings state from stored balls.
  Future<Map<String, dynamic>?> getInningsState(
      String matchId, int innings) async {
    try {
      final balls = await getBallsForInnings(matchId, innings);

      int totalRuns = 0;
      int totalWickets = 0;
      int legalBalls = 0;

      for (final ball in balls) {
        totalRuns += ball.runs + ball.extras;
        if (ball.isWicket) totalWickets++;
        if (ball.isLegal) legalBalls++;
      }

      final overs = legalBalls ~/ 6;
      final ballsInOver = legalBalls % 6;
      final oversDouble = overs + (ballsInOver / 10.0);

      return {
        'total_runs': totalRuns,
        'total_wickets': totalWickets,
        'legal_balls': legalBalls,
        'overs': oversDouble,
        'balls': balls.map((b) => b.toJson()).toList(),
      };
    } catch (e) {
      debugPrint('ScoringRepo getInningsState error: $e');
      return null;
    }
  }

  /// Update fantasy points for a player in the scoreboard.
  Future<bool> updateFantasyPoints(
      String matchId, String playerId, double points) async {
    try {
      await _client
          .from('scoreboard')
          .update({'points': points})
          .eq('match_id', matchId)
          .eq('player_id', playerId);
      debugPrint('Fantasy Updated: playerId=$playerId, points=$points');
      return true;
    } catch (e) {
      debugPrint('ScoringRepo updateFantasyPoints error: $e');
      return false;
    }
  }

  /// Update bowler stats in the scoreboard.
  Future<bool> updateBowlerStats(
      String matchId, String playerId, Map<String, dynamic> data) async {
    try {
      final upsertData = {
        'match_id': matchId,
        'player_id': playerId,
        ...data,
      };
      await _client
          .from('scoreboard')
          .upsert(upsertData, onConflict: 'match_id,player_id')
          .select();
      debugPrint('Bowler Updated: playerId=$playerId');
      return true;
    } catch (e) {
      debugPrint('ScoringRepo updateBowlerStats error: $e');
      return false;
    }
  }
}

/// Provider for the scoring repository.
final scoringRepositoryProvider = Provider<ScoringRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ScoringRepository(client);
});
