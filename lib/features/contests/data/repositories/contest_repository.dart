import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client.dart';
import '../../../matches/data/models/contest_model.dart';

/// Leaderboard entry model for contest details.
class LeaderboardEntry {
  final String id;
  final String contestId;
  final String userId;
  final String? fantasyTeamId;
  final double points;
  final int rank;
  final double prizeWon;
  final LeaderboardUserInfo? user;

  const LeaderboardEntry({
    required this.id,
    required this.contestId,
    required this.userId,
    this.fantasyTeamId,
    this.points = 0.0,
    this.rank = 0,
    this.prizeWon = 0.0,
    this.user,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'] as String? ?? '',
      contestId: json['contest_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      fantasyTeamId: json['fantasy_team_id'] as String?,
      points: (json['points'] as num?)?.toDouble() ?? 0.0,
      rank: json['rank'] as int? ?? 0,
      prizeWon: (json['prize_won'] as num?)?.toDouble() ?? 0.0,
      user: json['user'] != null
          ? LeaderboardUserInfo.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contest_id': contestId,
      'user_id': userId,
      if (fantasyTeamId != null) 'fantasy_team_id': fantasyTeamId,
      'points': points,
      'rank': rank,
      'prize_won': prizeWon,
    };
  }

  String get username => user?.username ?? 'User';
  String? get avatarUrl => user?.avatarUrl;
}

/// Lightweight user info embedded in leaderboard.
class LeaderboardUserInfo {
  final String? username;
  final String? avatarUrl;

  const LeaderboardUserInfo({this.username, this.avatarUrl});

  factory LeaderboardUserInfo.fromJson(Map<String, dynamic> json) {
    return LeaderboardUserInfo(
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

/// Repository for contest operations with Supabase.
class ContestRepository {
  final SupabaseClient _client;

  ContestRepository(this._client);

  /// Fetch contests for a match with optional filters.
  Future<List<ContestModel>> getContestsByMatch(
    String matchId, {
    String? contestType,
    double? maxEntryFee,
    double? minPrizePool,
  }) async {
    try {
      var query = _client
          .from('contests')
          .select()
          .eq('match_id', matchId);

      if (contestType != null) {
        query = query.eq('contest_type', contestType);
      }

      final response = await query.order('prize_pool', ascending: false);

      List<ContestModel> contests = (response as List)
          .map((json) => ContestModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Client-side filters for range queries.
      if (maxEntryFee != null) {
        contests =
            contests.where((c) => c.entryFee <= maxEntryFee).toList();
      }
      if (minPrizePool != null) {
        contests =
            contests.where((c) => c.prizePool >= minPrizePool).toList();
      }

      return contests;
    } catch (e) {
      return [];
    }
  }

  /// Fetch a single contest by ID.
  Future<ContestModel?> getContestById(String contestId) async {
    try {
      final response = await _client
          .from('contests')
          .select()
          .eq('id', contestId)
          .single();

      return ContestModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Join a contest (increment joined_teams and create leaderboard + contest_entries).
  Future<bool> joinContest({
    required String contestId,
    required String userId,
    required String fantasyTeamId,
  }) async {
    try {
      // Insert into contest_entries (for realtime tracking)
      await _client.from('contest_entries').upsert({
        'contest_id': contestId,
        'user_id': userId,
        'fantasy_team_id': fantasyTeamId,
        'total_points': 0,
        'rank': 0,
        'prize_won': 0,
      }, onConflict: 'contest_id,user_id');

      // Insert leaderboard entry
      await _client.from('leaderboard').upsert({
        'contest_id': contestId,
        'user_id': userId,
        'fantasy_team_id': fantasyTeamId,
        'points': 0,
        'rank': 0,
        'prize_won': 0,
      }, onConflict: 'contest_id,user_id');

      // Increment joined_teams count
      try {
        await _client.rpc('increment_joined_teams', params: {
          'contest_id_param': contestId,
        });
      } catch (_) {
        // Fallback: manual increment
        final contest = await getContestById(contestId);
        if (contest != null) {
          await _client
              .from('contests')
              .update({'joined_teams': contest.joinedTeams + 1})
              .eq('id', contestId);
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Fetch leaderboard for a contest.
  Future<List<LeaderboardEntry>> getLeaderboard(String contestId) async {
    try {
      final response = await _client
          .from('leaderboard')
          .select('*, user:users(username, avatar_url)')
          .eq('contest_id', contestId)
          .order('rank', ascending: true);

      return (response as List)
          .map((json) =>
              LeaderboardEntry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Check if user has already joined a contest.
  Future<bool> hasUserJoinedContest({
    required String contestId,
    required String userId,
  }) async {
    try {
      final response = await _client
          .from('leaderboard')
          .select('id')
          .eq('contest_id', contestId)
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }
}

/// Provider for the contest repository.
final contestRepositoryProvider = Provider<ContestRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ContestRepository(client);
});
