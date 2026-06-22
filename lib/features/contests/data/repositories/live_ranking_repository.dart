import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client.dart';
import '../../../fantasy/data/models/fantasy_points_model.dart';
import '../models/contest_entry_model.dart';

/// Repository for live ranking realtime subscriptions and data operations.
class LiveRankingRepository {
  final SupabaseClient _client;

  LiveRankingRepository(this._client);

  /// Subscribe to real-time leaderboard updates for a contest.
  RealtimeChannel subscribeToLeaderboard(
    String contestId, {
    required void Function(ContestEntryModel entry) onUpdate,
  }) {
    return _client
        .channel('realtime-leaderboard-$contestId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'contest_entries',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'contest_id',
            value: contestId,
          ),
          callback: (payload) {
            final record = payload.newRecord;
            if (record.isNotEmpty) {
              onUpdate(ContestEntryModel.fromJson(record));
            }
          },
        )
        .subscribe();
  }

  /// Subscribe to real-time fantasy points updates for a match.
  RealtimeChannel subscribeToFantasyPoints(
    String matchId, {
    required void Function(FantasyPointsModel entry) onUpdate,
  }) {
    return _client
        .channel('realtime-fantasy-points-$matchId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'fantasy_points',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'match_id',
            value: matchId,
          ),
          callback: (payload) {
            final record = payload.newRecord;
            if (record.isNotEmpty) {
              onUpdate(FantasyPointsModel.fromJson(record));
            }
          },
        )
        .subscribe();
  }

  /// Subscribe to real-time contest entries updates for a contest.
  RealtimeChannel subscribeToContestEntries(
    String contestId, {
    required void Function(ContestEntryModel entry) onUpdate,
  }) {
    return _client
        .channel('realtime-contest-entries-$contestId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'contest_entries',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'contest_id',
            value: contestId,
          ),
          callback: (payload) {
            final record = payload.newRecord;
            if (record.isNotEmpty) {
              onUpdate(ContestEntryModel.fromJson(record));
            }
          },
        )
        .subscribe();
  }

  /// Fetch contest entries for a contest, sorted by total_points DESC.
  Future<List<ContestEntryModel>> getContestEntries(String contestId) async {
    try {
      final response = await _client
          .from('contest_entries')
          .select()
          .eq('contest_id', contestId)
          .order('total_points', ascending: false);

      return (response as List)
          .map((json) =>
              ContestEntryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Recalculate rankings for a contest by sorting entries by total_points DESC
  /// and assigning rank values.
  Future<List<ContestEntryModel>> recalculateRanking(String contestId) async {
    try {
      final entries = await getContestEntries(contestId);
      final ranked = <ContestEntryModel>[];

      for (int i = 0; i < entries.length; i++) {
        ranked.add(entries[i].copyWith(rank: i + 1));
      }

      // Update ranks in database
      for (final entry in ranked) {
        await _client
            .from('contest_entries')
            .update({'rank': entry.rank})
            .eq('id', entry.id);
      }

      return ranked;
    } catch (e) {
      return [];
    }
  }

  /// Unsubscribe from a real-time channel.
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }
}

/// Provider for the live ranking repository.
final liveRankingRepositoryProvider = Provider<LiveRankingRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return LiveRankingRepository(client);
});
