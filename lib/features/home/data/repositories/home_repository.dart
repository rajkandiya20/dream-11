import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client.dart';
import '../../../matches/data/models/contest_model.dart';
import '../models/match_model.dart';
import '../models/tournament_model.dart';

/// Repository for fetching home screen data from Supabase.
class HomeRepository {
  final SupabaseClient _client;

  HomeRepository(this._client);

  /// Fetch all matches with tournament and team relations, ordered by date.
  Future<List<MatchModel>> getMatches() async {
    try {
      final response = await _client
          .from('matches')
          .select('*, tournament:tournaments(name, logo), team_a:teams!team_a_id(name, logo, code), team_b:teams!team_b_id(name, logo, code)')
          .order('date_time');

      return (response as List)
          .map((json) => MatchModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch upcoming/scheduled matches.
  Future<List<MatchModel>> getUpcomingMatches() async {
    try {
      final response = await _client
          .from('matches')
          .select('*, tournament:tournaments(name, logo), team_a:teams!team_a_id(name, logo, code), team_b:teams!team_b_id(name, logo, code)')
          .inFilter('status', ['upcoming', 'scheduled'])
          .order('date_time', ascending: true);

      return (response as List)
          .map((json) => MatchModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch live matches.
  Future<List<MatchModel>> getLiveMatches() async {
    try {
      final response = await _client
          .from('matches')
          .select('*, tournament:tournaments(name, logo), team_a:teams!team_a_id(name, logo, code), team_b:teams!team_b_id(name, logo, code)')
          .eq('status', 'live');

      return (response as List)
          .map((json) => MatchModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch completed matches.
  Future<List<MatchModel>> getCompletedMatches() async {
    try {
      final response = await _client
          .from('matches')
          .select('*, tournament:tournaments(name, logo), team_a:teams!team_a_id(name, logo, code), team_b:teams!team_b_id(name, logo, code)')
          .eq('status', 'completed')
          .order('date_time', ascending: false)
          .limit(10);

      return (response as List)
          .map((json) => MatchModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch active tournaments.
  Future<List<TournamentModel>> getTournaments() async {
    try {
      final response = await _client
          .from('tournaments')
          .select()
          .eq('status', 'active')
          .order('start_date', ascending: false);

      return (response as List)
          .map(
              (json) => TournamentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch popular contests (highest prize pools, open status).
  Future<List<ContestModel>> getPopularContests() async {
    try {
      final response = await _client
          .from('contests')
          .select()
          .eq('status', 'open')
          .order('prize_pool', ascending: false)
          .limit(5);

      return (response as List)
          .map((json) => ContestModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Subscribe to real-time match updates.
  RealtimeChannel subscribeToMatches({
    required void Function(MatchModel match) onMatchUpdate,
  }) {
    return _client
        .channel('realtime-matches')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'matches',
          callback: (payload) {
            final newRecord = payload.newRecord;
            if (newRecord.isNotEmpty) {
              onMatchUpdate(MatchModel.fromJson(newRecord));
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

/// Provider for the home repository.
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return HomeRepository(client);
});
