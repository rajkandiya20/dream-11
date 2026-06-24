import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client.dart';

/// Handles prize distribution after a match completes.
/// Ported logic from Fantasy- howmuchwon.js + leaderboardchanges.js
class PrizeDistributionRepository {
  final SupabaseClient _client;

  PrizeDistributionRepository(this._client);

  /// Distribute prizes for all contests of a match.
  /// Call this when admin marks a match as 'completed'.
  Future<void> distributeMatchPrizes(String matchId) async {
    try {
      // Get all contests for this match
      final contests = await _client
          .from('contests')
          .select('id, prize_pool, prize_breakdown, max_winners, entry_fee')
          .eq('match_id', matchId)
          .eq('status', 'open');

      for (final contest in contests as List) {
        await _distributeContestPrize(contest as Map<String, dynamic>);
        // Close contest after distribution
        await _client
            .from('contests')
            .update({'status': 'completed'})
            .eq('id', contest['id'] as String);
      }
    } catch (e) {
      debugPrint('Prize distribution error: $e');
    }
  }

  /// Distribute prizes for a single contest based on leaderboard ranking.
  Future<void> _distributeContestPrize(
      Map<String, dynamic> contest) async {
    final contestId  = contest['id'] as String;
    final prizePool  = (contest['prize_pool'] as num?)?.toDouble() ?? 0;
    final maxWinners = contest['max_winners'] as int? ?? 3;

    // Get leaderboard sorted by points descending
    final leaderboard = await _client
        .from('leaderboard')
        .select('id, user_id, points, fantasy_team_id')
        .eq('contest_id', contestId)
        .order('points', ascending: false);

    final entries = (leaderboard as List);
    if (entries.isEmpty) return;

    // Assign ranks
    for (int i = 0; i < entries.length; i++) {
      final rank = i + 1;
      await _client
          .from('leaderboard')
          .update({'rank': rank})
          .eq('id', entries[i]['id'] as String);
    }

    // Compute prize for each winner position
    final winners = entries.take(maxWinners).toList();
    final prizes  = _computePrizes(prizePool, winners.length);

    for (int i = 0; i < winners.length; i++) {
      final entry  = winners[i] as Map<String, dynamic>;
      final userId = entry['user_id'] as String;
      final prize  = prizes[i];
      if (prize <= 0) continue;

      // Update leaderboard prize_won
      await _client
          .from('leaderboard')
          .update({'prize_won': prize})
          .eq('id', entry['id'] as String);

      // Credit to user's winnings wallet
      await _creditWinnings(userId, prize, contestId);

      // Send winner notification
      await _notifyWinner(userId, prize, i + 1);
    }
  }

  /// Credit prize amount to user's winnings balance.
  Future<void> _creditWinnings(
      String userId, double amount, String contestId) async {
    try {
      final wallet = await _client
          .from('wallets')
          .select('winnings')
          .eq('user_id', userId)
          .maybeSingle();
      final current = (wallet?['winnings'] as num?)?.toDouble() ?? 0.0;
      await _client
          .from('wallets')
          .update({'winnings': current + amount})
          .eq('user_id', userId);

      // Create transaction record
      await _client.from('transactions').insert({
        'user_id':     userId,
        'type':        'winning',
        'amount':      amount,
        'status':      'completed',
        'description': 'Contest prize',
        'reference_id': contestId,
      });
    } catch (e) {
      debugPrint('Credit winnings error: $e');
    }
  }

  /// Send in-app notification to winner.
  Future<void> _notifyWinner(
      String userId, double prize, int rank) async {
    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'title':   '🏆 You Won ₹${prize.toStringAsFixed(0)}!',
        'message': 'Congratulations! You finished at rank #$rank. ₹${prize.toStringAsFixed(0)} has been added to your winnings.',
        'type':    'winning',
        'is_read': false,
      });
    } catch (e) {
      debugPrint('Winner notification error: $e');
    }
  }

  /// Standard prize distribution: 50% to rank 1, 30% rank 2, 20% rank 3.
  /// For more winners, distribute proportionally.
  List<double> _computePrizes(double pool, int count) {
    if (count == 0) return [];
    if (count == 1) return [pool];
    if (count == 2) return [pool * 0.60, pool * 0.40];
    if (count == 3) return [pool * 0.50, pool * 0.30, pool * 0.20];

    // For more than 3: top 3 get fixed %, rest share remaining equally
    final top3Total = pool * 0.70;
    final restTotal = pool * 0.30;
    final restPerPerson = restTotal / (count - 3);
    return [
      top3Total * 0.50,
      top3Total * 0.30,
      top3Total * 0.20,
      ...List.filled(count - 3, restPerPerson),
    ];
  }
}

final prizeDistributionRepositoryProvider =
    Provider<PrizeDistributionRepository>((ref) {
  return PrizeDistributionRepository(ref.watch(supabaseClientProvider));
});
