import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client.dart';

/// Admin analytics data model.
class AdminAnalytics {
  final int totalUsers;
  final int activeMatches;
  final int totalContests;
  final double totalRevenue;
  final int pendingDeposits;
  final int pendingWithdrawals;
  final int totalTournaments;
  final int totalTeams;

  const AdminAnalytics({
    this.totalUsers = 0,
    this.activeMatches = 0,
    this.totalContests = 0,
    this.totalRevenue = 0.0,
    this.pendingDeposits = 0,
    this.pendingWithdrawals = 0,
    this.totalTournaments = 0,
    this.totalTeams = 0,
  });
}

/// Repository for all admin CRUD operations.
class AdminRepository {
  final SupabaseClient _client;

  AdminRepository(this._client);

  // ========== ANALYTICS ==========

  /// Get admin dashboard analytics.
  Future<AdminAnalytics> getAnalytics() async {
    try {
      final users = await _client.from('users').select('id');
      final matches = await _client
          .from('matches')
          .select('id')
          .or('status.eq.live,status.eq.upcoming');
      final contests = await _client.from('contests').select('id');
      final pendingDeposits = await _client
          .from('transactions')
          .select('id')
          .eq('type', 'deposit')
          .eq('status', 'pending');
      final pendingWithdrawals = await _client
          .from('transactions')
          .select('id')
          .eq('type', 'withdrawal')
          .eq('status', 'pending');
      final tournaments = await _client.from('tournaments').select('id');
      final teams = await _client.from('teams').select('id');

      // Calculate revenue from completed deposits
      final revenue = await _client
          .from('transactions')
          .select('amount')
          .eq('type', 'deposit')
          .eq('status', 'completed');

      final totalRevenue = (revenue as List).fold<double>(
        0,
        (sum, item) => sum + ((item['amount'] as num?)?.toDouble() ?? 0),
      );

      return AdminAnalytics(
        totalUsers: (users as List).length,
        activeMatches: (matches as List).length,
        totalContests: (contests as List).length,
        totalRevenue: totalRevenue,
        pendingDeposits: (pendingDeposits as List).length,
        pendingWithdrawals: (pendingWithdrawals as List).length,
        totalTournaments: (tournaments as List).length,
        totalTeams: (teams as List).length,
      );
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return const AdminAnalytics();
    }
  }

  // ========== USERS ==========

  /// Get all users with optional search.
  Future<List<Map<String, dynamic>>> getUsers({String? search}) async {
    try {
      var query = _client.from('users').select('*');
      if (search != null && search.isNotEmpty) {
        query = query.or('username.ilike.%$search%,email.ilike.%$search%');
      }
      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return [];
    }
  }

  /// Update user role.
  Future<bool> updateUserRole(String userId, String role) async {
    try {
      await _client.from('users').update({'role': role}).eq('id', userId);
      return true;
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return false;
    }
  }

  // ========== TOURNAMENTS ==========

  /// Get all tournaments.
  Future<List<Map<String, dynamic>>> getTournaments() async {
    try {
      final response = await _client
          .from('tournaments')
          .select('*')
          .order('start_date', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return [];
    }
  }

  /// Create a tournament.
  Future<Map<String, dynamic>?> createTournament(
      Map<String, dynamic> data) async {
    try {
      final response =
          await _client.from('tournaments').insert(data).select().single();
      return response;
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return null;
    }
  }

  /// Update a tournament.
  Future<bool> updateTournament(
      String id, Map<String, dynamic> data) async {
    try {
      await _client.from('tournaments').update(data).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return false;
    }
  }

  /// Delete a tournament.
  Future<bool> deleteTournament(String id) async {
    try {
      await _client.from('tournaments').delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return false;
    }
  }

  // ========== MATCHES ==========

  /// Get all matches.
  Future<List<Map<String, dynamic>>> getMatches({String? status}) async {
    try {
      var query = _client.from('matches').select('*');
      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }
      final response = await query.order('date_time', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return [];
    }
  }

  /// Create a match.
  Future<Map<String, dynamic>?> createMatch(Map<String, dynamic> data) async {
    try {
      debugPrint('AdminRepo createMatch data: $data');
      final response =
          await _client.from('matches').insert(data).select().single();
      debugPrint('AdminRepo createMatch OK');
      return response;
    } catch (e) {
      debugPrint('AdminRepo createMatch ERROR: $e');
      lastError = e.toString();
      return null;
    }
  }

  /// Update a match.
  Future<bool> updateMatch(String id, Map<String, dynamic> data) async {
    try {
      await _client.from('matches').update(data).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return false;
    }
  }

  /// Delete a match.
  Future<bool> deleteMatch(String id) async {
    try {
      await _client.from('matches').delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return false;
    }
  }

  // ========== TEAMS ==========

  /// Get all teams.
  Future<List<Map<String, dynamic>>> getTeams() async {
    try {
      final response = await _client
          .from('teams')
          .select('*')
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return [];
    }
  }

  /// Create a team.
  Future<Map<String, dynamic>?> createTeam(Map<String, dynamic> data) async {
    try {
      final response =
          await _client.from('teams').insert(data).select().single();
      return response;
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return null;
    }
  }

  /// Update a team.
  Future<bool> updateTeam(String id, Map<String, dynamic> data) async {
    try {
      await _client.from('teams').update(data).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return false;
    }
  }

  /// Delete a team.
  Future<bool> deleteTeam(String id) async {
    try {
      await _client.from('teams').delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return false;
    }
  }

  // ========== PLAYERS ==========

  /// Get all players with optional team filter.
  Future<List<Map<String, dynamic>>> getPlayers({String? teamId}) async {
    try {
      var query = _client.from('players').select('*');
      if (teamId != null && teamId.isNotEmpty) {
        query = query.eq('team_id', teamId);
      }
      final response = await query.order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return [];
    }
  }

  /// Create a player.
  Future<Map<String, dynamic>?> createPlayer(
      Map<String, dynamic> data) async {
    try {
      final response =
          await _client.from('players').insert(data).select().single();
      return response;
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return null;
    }
  }

  /// Update a player.
  Future<bool> updatePlayer(String id, Map<String, dynamic> data) async {
    try {
      await _client.from('players').update(data).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return false;
    }
  }

  /// Delete a player.
  Future<bool> deletePlayer(String id) async {
    try {
      await _client.from('players').delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return false;
    }
  }

  // ========== CONTESTS ==========

  /// Get all contests.
  Future<List<Map<String, dynamic>>> getContests({String? matchId}) async {
    try {
      var query = _client.from('contests').select('*');
      if (matchId != null && matchId.isNotEmpty) {
        query = query.eq('match_id', matchId);
      }
      final response =
          await query.order('prize_pool', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return [];
    }
  }

  /// Create a contest.
  Future<Map<String, dynamic>?> createContest(
      Map<String, dynamic> data) async {
    try {
      final response =
          await _client.from('contests').insert(data).select().single();
      return response;
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return null;
    }
  }

  /// Update a contest.
  Future<bool> updateContest(String id, Map<String, dynamic> data) async {
    try {
      await _client.from('contests').update(data).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return false;
    }
  }

  /// Delete a contest.
  Future<bool> deleteContest(String id) async {
    try {
      await _client.from('contests').delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return false;
    }
  }

  // ========== SCOREBOARD ==========

  /// Get scoreboard for a match.
  Future<List<Map<String, dynamic>>> getScoreboard(String matchId) async {
    try {
      final response = await _client
          .from('scoreboard')
          .select('*, player:players(name, role)')
          .eq('match_id', matchId)
          .order('points', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return [];
    }
  }

  /// Update or create scoreboard entry.
  Future<bool> upsertScoreboard(Map<String, dynamic> data) async {
    try {
      await _client
          .from('scoreboard')
          .upsert(data, onConflict: 'match_id,player_id')
          .select();
      return true;
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return false;
    }
  }

  // ========== TEAMS BY TOURNAMENT ==========

  /// Get teams filtered by tournament ID.
  Future<List<Map<String, dynamic>>> getTeamsByTournament(
      String tournamentId) async {
    try {
      final response = await _client
          .from('teams')
          .select('*')
          .eq('tournament_id', tournamentId)
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return [];
    }
  }

  // ========== PLAYERS BY TEAM ==========

  /// Get players filtered by team ID.
  Future<List<Map<String, dynamic>>> getPlayersByTeam(String teamId) async {
    try {
      final response = await _client
          .from('players')
          .select('*')
          .eq('team_id', teamId)
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return [];
    }
  }

  // ========== MATCH PLAYERS (Playing XI) ==========

  /// Get match players for a given match with player details.
  Future<List<Map<String, dynamic>>> getMatchPlayers(String matchId) async {
    try {
      final response = await _client
          .from('match_players')
          .select('*, player:players(*)')
          .eq('match_id', matchId);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return [];
    }
  }

  /// Set match players for a match and team.
  /// Deletes existing entries for the match+team and inserts new ones.
  Future<bool> setMatchPlayers(
      String matchId, List<String> playerIds, String teamId) async {
    try {
      // Delete existing match_players for this match and team
      await _client
          .from('match_players')
          .delete()
          .eq('match_id', matchId)
          .eq('team_id', teamId);

      // Insert new match players
      if (playerIds.isNotEmpty) {
        final rows = playerIds
            .map((playerId) => {
                  'match_id': matchId,
                  'player_id': playerId,
                  'team_id': teamId,
                })
            .toList();
        await _client.from('match_players').insert(rows);
      }

      return true;
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return false;
    }
  }

  // ========== DEPOSITS & WITHDRAWALS (Admin Wallet) ==========

  // ========== PAYMENT METHODS (Admin) ==========

  /// Get all admin payment methods (methods available for user deposits).
  Future<List<Map<String, dynamic>>> getAdminPaymentMethods() async {
    try {
      final response = await _client
          .from('admin_payment_methods')
          .select('*')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return [];
    }
  }

  /// Create an admin payment method.
  Future<Map<String, dynamic>?> createAdminPaymentMethod(
      Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('admin_payment_methods')
          .insert(data)
          .select()
          .single();
      return response;
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return null;
    }
  }

  /// Update an admin payment method.
  Future<bool> updateAdminPaymentMethod(
      String id, Map<String, dynamic> data) async {
    try {
      await _client.from('admin_payment_methods').update(data).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return false;
    }
  }

  /// Delete an admin payment method.
  Future<bool> deleteAdminPaymentMethod(String id) async {
    try {
      await _client.from('admin_payment_methods').delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return false;
    }
  }

  // ========== DEPOSITS & WITHDRAWALS ==========

  /// Get pending deposits.
  Future<List<Map<String, dynamic>>> getPendingDeposits() async {
    try {
      final response = await _client
          .from('transactions')
          .select('*, user:users(username, email)')
          .eq('type', 'deposit')
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return [];
    }
  }

  /// Get pending withdrawals.
  Future<List<Map<String, dynamic>>> getPendingWithdrawals() async {
    try {
      final response = await _client
          .from('transactions')
          .select('*, user:users(username, email)')
          .eq('type', 'withdrawal')
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return [];
    }
  }

  /// Approve a deposit - update transaction status and credit wallet.
  Future<bool> approveDeposit(String transactionId) async {
    try {
      // Get transaction details
      final transaction = await _client
          .from('transactions')
          .select('*')
          .eq('id', transactionId)
          .single();

      final userId = transaction['user_id'] as String;
      final amount = (transaction['amount'] as num).toDouble();

      // Update transaction status
      await _client
          .from('transactions')
          .update({'status': 'completed'})
          .eq('id', transactionId);

      // Credit wallet balance
      final wallet = await _client
          .from('wallets')
          .select('balance')
          .eq('user_id', userId)
          .single();

      final currentBalance = (wallet['balance'] as num).toDouble();
      await _client
          .from('wallets')
          .update({'balance': currentBalance + amount})
          .eq('user_id', userId);

      return true;
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return false;
    }
  }

  /// Reject a transaction (deposit or withdrawal).
  Future<bool> rejectTransaction(String transactionId) async {
    try {
      await _client
          .from('transactions')
          .update({'status': 'rejected'})
          .eq('id', transactionId);
      return true;
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return false;
    }
  }

  /// Approve a withdrawal - update transaction status and debit wallet.
  Future<bool> approveWithdrawal(String transactionId) async {
    try {
      final transaction = await _client
          .from('transactions')
          .select('*')
          .eq('id', transactionId)
          .single();

      final userId = transaction['user_id'] as String;
      final amount = (transaction['amount'] as num).toDouble();

      // Update transaction status
      await _client
          .from('transactions')
          .update({'status': 'completed'})
          .eq('id', transactionId);

      // Debit wallet balance
      final wallet = await _client
          .from('wallets')
          .select('balance, winnings')
          .eq('user_id', userId)
          .single();

      final currentBalance = (wallet['balance'] as num).toDouble();
      final currentWinnings = (wallet['winnings'] as num).toDouble();

      // Debit from winnings first, then from balance
      double newWinnings = currentWinnings;
      double newBalance = currentBalance;
      double remaining = amount;

      if (remaining <= currentWinnings) {
        newWinnings = currentWinnings - remaining;
      } else {
        newWinnings = 0;
        remaining -= currentWinnings;
        newBalance = currentBalance - remaining;
      }

      await _client
          .from('wallets')
          .update({'balance': newBalance, 'winnings': newWinnings})
          .eq('user_id', userId);

      return true;
    } catch (e) {
      debugPrint('AdminRepo error: $e');
      return false;
    }
  }
}

/// Provider for the admin repository.
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AdminRepository(client);
});
