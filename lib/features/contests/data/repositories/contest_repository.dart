import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client.dart';
import '../../../matches/data/models/contest_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Result type returned by joinContest so callers know WHY it failed.
// ─────────────────────────────────────────────────────────────────────────────

enum JoinContestFailReason {
  insufficientBalance,
  alreadyJoined,
  contestFull,
  contestClosed,
  unknown,
}

class JoinContestResult {
  final bool success;
  final JoinContestFailReason? failReason;
  final String? message;

  const JoinContestResult.success()
      : success = true,
        failReason = null,
        message = null;

  const JoinContestResult.failure(this.failReason, this.message)
      : success = false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Leaderboard entry model
// ─────────────────────────────────────────────────────────────────────────────

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'contest_id': contestId,
        'user_id': userId,
        if (fantasyTeamId != null) 'fantasy_team_id': fantasyTeamId,
        'points': points,
        'rank': rank,
        'prize_won': prizeWon,
      };

  String get username => user?.username ?? 'User';
  String? get avatarUrl => user?.avatarUrl;
}

class LeaderboardUserInfo {
  final String? username;
  final String? avatarUrl;

  const LeaderboardUserInfo({this.username, this.avatarUrl});

  factory LeaderboardUserInfo.fromJson(Map<String, dynamic> json) =>
      LeaderboardUserInfo(
        username: json['username'] as String?,
        avatarUrl: json['avatar_url'] as String?,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Contest Repository
// ─────────────────────────────────────────────────────────────────────────────

class ContestRepository {
  final SupabaseClient _client;

  ContestRepository(this._client);

  // ── Contests ─────────────────────────────────────────────────────────────

  Future<List<ContestModel>> getContestsByMatch(
    String matchId, {
    String? contestType,
    double? maxEntryFee,
    double? minPrizePool,
  }) async {
    try {
      var query =
          _client.from('contests').select().eq('match_id', matchId);

      if (contestType != null) query = query.eq('contest_type', contestType);

      final response =
          await query.order('prize_pool', ascending: false);

      List<ContestModel> contests = (response as List)
          .map((json) => ContestModel.fromJson(json as Map<String, dynamic>))
          .toList();

      if (maxEntryFee != null) {
        contests = contests.where((c) => c.entryFee <= maxEntryFee).toList();
      }
      if (minPrizePool != null) {
        contests =
            contests.where((c) => c.prizePool >= minPrizePool).toList();
      }

      return contests;
    } catch (_) {
      return [];
    }
  }

  Future<ContestModel?> getContestById(String contestId) async {
    try {
      final response = await _client
          .from('contests')
          .select()
          .eq('id', contestId)
          .single();
      return ContestModel.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  // ── Join Contest (with wallet debit + transaction record) ─────────────────

  /// Full contest-join flow:
  ///  1. Load contest and verify it is still open and not full.
  ///  2. Check the user has not already joined.
  ///  3. For paid contests: verify wallet balance ≥ entry fee.
  ///  4. Debit entry fee from wallet (balance column).
  ///  5. Create a `contest_join` transaction record.
  ///  6. Insert into `contest_entries` table (used by live ranking).
  ///  7. Insert into `leaderboard` table.
  ///  8. Increment `joined_teams` counter on the contest.
  ///
  /// Returns a [JoinContestResult] so the UI can show the right error message.
  Future<JoinContestResult> joinContestWithResult({
    required String contestId,
    required String userId,
    required String fantasyTeamId,
  }) async {
    try {
      // ── 1. Load contest ───────────────────────────────────────────────
      final contest = await getContestById(contestId);
      if (contest == null) {
        return const JoinContestResult.failure(
            JoinContestFailReason.unknown, 'Contest not found.');
      }

      // ── 2. Check contest is still open ────────────────────────────────
      if (!contest.isOpen) {
        return const JoinContestResult.failure(
            JoinContestFailReason.contestClosed,
            'This contest is closed.');
      }
      if (contest.isFull) {
        return const JoinContestResult.failure(
            JoinContestFailReason.contestFull,
            'This contest is full.');
      }

      // ── 3. Check not already joined ───────────────────────────────────
      final alreadyJoined = await hasUserJoinedContest(
        contestId: contestId,
        userId: userId,
      );
      if (alreadyJoined) {
        return const JoinContestResult.failure(
            JoinContestFailReason.alreadyJoined,
            'You have already joined this contest with a team.');
      }

      // ── 4. Wallet balance check for paid contests ─────────────────────
      if (!contest.isFree && contest.entryFee > 0) {
        final walletRow = await _client
            .from('wallets')
            .select('balance, bonus, winnings')
            .eq('user_id', userId)
            .maybeSingle();

        if (walletRow == null) {
          return const JoinContestResult.failure(
              JoinContestFailReason.insufficientBalance,
              'Wallet not found. Please add money to your wallet.');
        }

        final balance  = (walletRow['balance']  as num?)?.toDouble() ?? 0.0;
        final bonus    = (walletRow['bonus']     as num?)?.toDouble() ?? 0.0;
        final winnings = (walletRow['winnings']  as num?)?.toDouble() ?? 0.0;
        final total    = balance + bonus + winnings;

        if (total < contest.entryFee) {
          return JoinContestResult.failure(
            JoinContestFailReason.insufficientBalance,
            'Insufficient balance. You need ₹${contest.entryFee.toStringAsFixed(0)} but have ₹${total.toStringAsFixed(0)}.',
          );
        }

        // ── 5. Debit entry fee (prefer balance → winnings → bonus) ───────
        await _debitWallet(
          userId: userId,
          amount: contest.entryFee,
          balance: balance,
          winnings: winnings,
          bonus: bonus,
        );

        // ── 6. Create contest_join transaction record ─────────────────────
        await _client.from('transactions').insert({
          'user_id': userId,
          'type': 'contest_join',
          'amount': -contest.entryFee,
          'status': 'completed',
          'description': 'Entry fee for ${contest.name}',
          'reference_id': contestId,
        });
      }

      // ── 7. Insert into contest_entries (used by LiveRankingRepository) ─
      // FIX #5: Don't use upsert with onConflict — DB may not have a unique
      // constraint. Instead check first, then insert only if not exists.
      final existingEntry = await _client
          .from('contest_entries')
          .select('id')
          .eq('contest_id', contestId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingEntry == null) {
        await _client.from('contest_entries').insert({
          'contest_id': contestId,
          'user_id': userId,
          'fantasy_team_id': fantasyTeamId,
          'total_points': 0,
          'prize_won': 0,
        });
      }

      // ── 8. Insert into leaderboard ────────────────────────────────────
      // FIX #5: Same pattern — check first, then insert.
      final existingLeaderboard = await _client
          .from('leaderboard')
          .select('id')
          .eq('contest_id', contestId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingLeaderboard == null) {
        await _client.from('leaderboard').insert({
          'contest_id': contestId,
          'user_id': userId,
          'fantasy_team_id': fantasyTeamId,
          'points': 0,
          'rank': 0,
          'prize_won': 0,
        });
      }

      // ── 9. Increment joined_teams counter ─────────────────────────────
      try {
        await _client.rpc('increment_joined_teams',
            params: {'contest_id_param': contestId});
      } catch (_) {
        // Fallback: manual increment
        final fresh = await getContestById(contestId);
        if (fresh != null) {
          await _client
              .from('contests')
              .update({'joined_teams': fresh.joinedTeams + 1})
              .eq('id', contestId);
        }
      }

      return const JoinContestResult.success();
    } catch (e) {
      return JoinContestResult.failure(
          JoinContestFailReason.unknown, 'An unexpected error occurred: $e');
    }
  }

  /// Backwards-compatible bool wrapper — used by ContestDetailNotifier.joinContest().
  Future<bool> joinContest({
    required String contestId,
    required String userId,
    required String fantasyTeamId,
  }) async {
    final result = await joinContestWithResult(
      contestId: contestId,
      userId: userId,
      fantasyTeamId: fantasyTeamId,
    );
    return result.success;
  }

  // ── Wallet debit helper ───────────────────────────────────────────────────

  /// Debit [amount] from the user's wallet, consuming
  /// deposited balance first, then winnings, then bonus.
  Future<void> _debitWallet({
    required String userId,
    required double amount,
    required double balance,
    required double winnings,
    required double bonus,
  }) async {
    double remaining = amount;
    double newBalance  = balance;
    double newWinnings = winnings;
    double newBonus    = bonus;

    // Consume deposited balance first
    if (remaining > 0 && newBalance > 0) {
      final use = remaining < newBalance ? remaining : newBalance;
      newBalance  -= use;
      remaining   -= use;
    }
    // Then winnings
    if (remaining > 0 && newWinnings > 0) {
      final use = remaining < newWinnings ? remaining : newWinnings;
      newWinnings -= use;
      remaining   -= use;
    }
    // Finally bonus
    if (remaining > 0 && newBonus > 0) {
      final use = remaining < newBonus ? remaining : newBonus;
      newBonus  -= use;
      remaining -= use;
    }

    await _client.from('wallets').update({
      'balance':  newBalance,
      'winnings': newWinnings,
      'bonus':    newBonus,
    }).eq('user_id', userId);
  }

  // ── Leaderboard ───────────────────────────────────────────────────────────

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
    } catch (_) {
      return [];
    }
  }

  Future<bool> hasUserJoinedContest({
    required String contestId,
    required String userId,
  }) async {
    try {
      // FIX #5: Check both tables. Use count=exact to avoid fetching full rows.
      final leaderboardRow = await _client
          .from('leaderboard')
          .select('id')
          .eq('contest_id', contestId)
          .eq('user_id', userId)
          .maybeSingle();

      if (leaderboardRow != null) return true;

      final entryRow = await _client
          .from('contest_entries')
          .select('id')
          .eq('contest_id', contestId)
          .eq('user_id', userId)
          .maybeSingle();

      return entryRow != null;
    } catch (_) {
      return false;
    }
  }
}

/// Provider for the contest repository.
final contestRepositoryProvider = Provider<ContestRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ContestRepository(client);
});
