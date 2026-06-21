import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/admin_repository.dart';

/// Admin state with per-screen loading flags so no screen blocks another.
class AdminState {
  final AdminAnalytics analytics;
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> tournaments;
  final List<Map<String, dynamic>> matches;
  final List<Map<String, dynamic>> teams;
  final List<Map<String, dynamic>> players;
  final List<Map<String, dynamic>> contests;
  final List<Map<String, dynamic>> pendingDeposits;
  final List<Map<String, dynamic>> pendingWithdrawals;
  final List<Map<String, dynamic>> scoreboard;
  final List<Map<String, dynamic>> paymentMethods;

  // Global loading (dashboard only)
  final bool isLoading;

  // Per-screen loading flags — independent of each other
  final bool tournamentsLoading;
  final bool matchesLoading;
  final bool teamsLoading;
  final bool playersLoading;
  final bool contestsLoading;
  final bool scoreboardLoading;

  // Per-screen error messages
  final String? errorMessage;
  final String? tournamentsError;
  final String? matchesError;
  final String? teamsError;
  final String? playersError;
  final String? contestsError;
  final String? scoreboardError;

  const AdminState({
    this.analytics = const AdminAnalytics(),
    this.users = const [],
    this.tournaments = const [],
    this.matches = const [],
    this.teams = const [],
    this.players = const [],
    this.contests = const [],
    this.pendingDeposits = const [],
    this.pendingWithdrawals = const [],
    this.scoreboard = const [],
    this.paymentMethods = const [],
    this.isLoading = false,
    this.tournamentsLoading = false,
    this.matchesLoading = false,
    this.teamsLoading = false,
    this.playersLoading = false,
    this.contestsLoading = false,
    this.scoreboardLoading = false,
    this.errorMessage,
    this.tournamentsError,
    this.matchesError,
    this.teamsError,
    this.playersError,
    this.contestsError,
    this.scoreboardError,
  });

  AdminState copyWith({
    AdminAnalytics? analytics,
    List<Map<String, dynamic>>? users,
    List<Map<String, dynamic>>? tournaments,
    List<Map<String, dynamic>>? matches,
    List<Map<String, dynamic>>? teams,
    List<Map<String, dynamic>>? players,
    List<Map<String, dynamic>>? contests,
    List<Map<String, dynamic>>? pendingDeposits,
    List<Map<String, dynamic>>? pendingWithdrawals,
    List<Map<String, dynamic>>? scoreboard,
    List<Map<String, dynamic>>? paymentMethods,
    bool? isLoading,
    bool? tournamentsLoading,
    bool? matchesLoading,
    bool? teamsLoading,
    bool? playersLoading,
    bool? contestsLoading,
    bool? scoreboardLoading,
    String? errorMessage,
    String? tournamentsError,
    String? matchesError,
    String? teamsError,
    String? playersError,
    String? contestsError,
    String? scoreboardError,
    bool clearTournamentsError = false,
    bool clearMatchesError = false,
    bool clearTeamsError = false,
    bool clearPlayersError = false,
    bool clearContestsError = false,
    bool clearScoreboardError = false,
  }) {
    return AdminState(
      analytics: analytics ?? this.analytics,
      users: users ?? this.users,
      tournaments: tournaments ?? this.tournaments,
      matches: matches ?? this.matches,
      teams: teams ?? this.teams,
      players: players ?? this.players,
      contests: contests ?? this.contests,
      pendingDeposits: pendingDeposits ?? this.pendingDeposits,
      pendingWithdrawals: pendingWithdrawals ?? this.pendingWithdrawals,
      scoreboard: scoreboard ?? this.scoreboard,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      isLoading: isLoading ?? this.isLoading,
      tournamentsLoading: tournamentsLoading ?? this.tournamentsLoading,
      matchesLoading: matchesLoading ?? this.matchesLoading,
      teamsLoading: teamsLoading ?? this.teamsLoading,
      playersLoading: playersLoading ?? this.playersLoading,
      contestsLoading: contestsLoading ?? this.contestsLoading,
      scoreboardLoading: scoreboardLoading ?? this.scoreboardLoading,
      errorMessage: errorMessage,
      tournamentsError: clearTournamentsError ? null : (tournamentsError ?? this.tournamentsError),
      matchesError: clearMatchesError ? null : (matchesError ?? this.matchesError),
      teamsError: clearTeamsError ? null : (teamsError ?? this.teamsError),
      playersError: clearPlayersError ? null : (playersError ?? this.playersError),
      contestsError: clearContestsError ? null : (contestsError ?? this.contestsError),
      scoreboardError: clearScoreboardError ? null : (scoreboardError ?? this.scoreboardError),
    );
  }
}

/// Admin state notifier managing dashboard and CRUD operations.
class AdminNotifier extends StateNotifier<AdminState> {
  final AdminRepository _repository;

  AdminNotifier(this._repository) : super(const AdminState()) {
    loadDashboard();
  }

  // ========== DASHBOARD ==========

  /// Load dashboard analytics. Uses global isLoading but NEVER stays stuck.
  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true);
    try {
      final analytics = await _repository.getAnalytics()
          .timeout(const Duration(seconds: 8));
      state = state.copyWith(analytics: analytics, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  // ========== USERS ==========

  Future<void> loadUsers({String? search}) async {
    state = state.copyWith(isLoading: true);
    try {
      final users = await _repository.getUsers(search: search)
          .timeout(const Duration(seconds: 8));
      state = state.copyWith(users: users, isLoading: false);
    } catch (_) {
      state = state.copyWith(users: [], isLoading: false);
    }
  }

  Future<bool> updateUserRole(String userId, String role) async {
    final success = await _repository.updateUserRole(userId, role);
    if (success) await loadUsers();
    return success;
  }

  // ========== TOURNAMENTS ==========

  Future<void> loadTournaments() async {
    state = state.copyWith(tournamentsLoading: true, clearTournamentsError: true);
    try {
      final tournaments = await _repository.getTournaments()
          .timeout(const Duration(seconds: 8));
      state = state.copyWith(tournaments: tournaments, tournamentsLoading: false);
    } catch (_) {
      state = state.copyWith(
        tournaments: [],
        tournamentsLoading: false,
        tournamentsError: 'Could not load tournaments. Check connection.',
      );
    }
  }

  Future<bool> createTournament(Map<String, dynamic> data) async {
    final result = await _repository.createTournament(data);
    if (result != null) { await loadTournaments(); return true; }
    return false;
  }

  Future<bool> updateTournament(String id, Map<String, dynamic> data) async {
    final success = await _repository.updateTournament(id, data);
    if (success) await loadTournaments();
    return success;
  }

  Future<bool> deleteTournament(String id) async {
    final success = await _repository.deleteTournament(id);
    if (success) await loadTournaments();
    return success;
  }

  // ========== MATCHES ==========

  Future<void> loadMatches({String? status}) async {
    state = state.copyWith(matchesLoading: true, clearMatchesError: true);
    try {
      final matches = await _repository.getMatches(status: status)
          .timeout(const Duration(seconds: 8));
      state = state.copyWith(matches: matches, matchesLoading: false);
    } catch (_) {
      state = state.copyWith(
        matches: [],
        matchesLoading: false,
        matchesError: 'Could not load matches. Check connection.',
      );
    }
  }

  Future<bool> createMatch(Map<String, dynamic> data) async {
    final result = await _repository.createMatch(data);
    if (result != null) { await loadMatches(); return true; }
    return false;
  }

  Future<bool> updateMatch(String id, Map<String, dynamic> data) async {
    final success = await _repository.updateMatch(id, data);
    if (success) await loadMatches();
    return success;
  }

  Future<bool> deleteMatch(String id) async {
    final success = await _repository.deleteMatch(id);
    if (success) await loadMatches();
    return success;
  }

  // ========== TEAMS ==========

  Future<void> loadTeams() async {
    state = state.copyWith(teamsLoading: true, clearTeamsError: true);
    try {
      final teams = await _repository.getTeams()
          .timeout(const Duration(seconds: 8));
      state = state.copyWith(teams: teams, teamsLoading: false);
    } catch (_) {
      state = state.copyWith(
        teams: [],
        teamsLoading: false,
        teamsError: 'Could not load teams. Check connection.',
      );
    }
  }

  Future<bool> createTeam(Map<String, dynamic> data) async {
    final result = await _repository.createTeam(data);
    if (result != null) { await loadTeams(); return true; }
    return false;
  }

  Future<bool> updateTeam(String id, Map<String, dynamic> data) async {
    final success = await _repository.updateTeam(id, data);
    if (success) await loadTeams();
    return success;
  }

  Future<bool> deleteTeam(String id) async {
    final success = await _repository.deleteTeam(id);
    if (success) await loadTeams();
    return success;
  }

  // ========== PLAYERS ==========

  Future<void> loadPlayers({String? teamId}) async {
    state = state.copyWith(playersLoading: true, clearPlayersError: true);
    try {
      final players = await _repository.getPlayers(teamId: teamId)
          .timeout(const Duration(seconds: 8));
      state = state.copyWith(players: players, playersLoading: false);
    } catch (_) {
      state = state.copyWith(
        players: [],
        playersLoading: false,
        playersError: 'Could not load players. Check connection.',
      );
    }
  }

  Future<bool> createPlayer(Map<String, dynamic> data) async {
    final result = await _repository.createPlayer(data);
    if (result != null) { await loadPlayers(); return true; }
    return false;
  }

  Future<bool> updatePlayer(String id, Map<String, dynamic> data) async {
    final success = await _repository.updatePlayer(id, data);
    if (success) await loadPlayers();
    return success;
  }

  Future<bool> deletePlayer(String id) async {
    final success = await _repository.deletePlayer(id);
    if (success) await loadPlayers();
    return success;
  }

  // ========== CONTESTS ==========

  Future<void> loadContests({String? matchId}) async {
    state = state.copyWith(contestsLoading: true, clearContestsError: true);
    try {
      final contests = await _repository.getContests(matchId: matchId)
          .timeout(const Duration(seconds: 8));
      state = state.copyWith(contests: contests, contestsLoading: false);
    } catch (_) {
      state = state.copyWith(
        contests: [],
        contestsLoading: false,
        contestsError: 'Could not load contests. Check connection.',
      );
    }
  }

  Future<bool> createContest(Map<String, dynamic> data) async {
    final result = await _repository.createContest(data);
    if (result != null) { await loadContests(); return true; }
    return false;
  }

  Future<bool> updateContest(String id, Map<String, dynamic> data) async {
    final success = await _repository.updateContest(id, data);
    if (success) await loadContests();
    return success;
  }

  Future<bool> deleteContest(String id) async {
    final success = await _repository.deleteContest(id);
    if (success) await loadContests();
    return success;
  }

  // ========== SCOREBOARD ==========

  Future<void> loadScoreboard(String matchId) async {
    state = state.copyWith(scoreboardLoading: true, clearScoreboardError: true);
    try {
      final scoreboard = await _repository.getScoreboard(matchId)
          .timeout(const Duration(seconds: 8));
      state = state.copyWith(scoreboard: scoreboard, scoreboardLoading: false);
    } catch (_) {
      state = state.copyWith(
        scoreboard: [],
        scoreboardLoading: false,
        scoreboardError: 'Could not load scoreboard. Check connection.',
      );
    }
  }

  Future<bool> upsertScoreboard(Map<String, dynamic> data) async {
    return await _repository.upsertScoreboard(data);
  }

  // ========== WALLET ==========

  Future<void> loadPendingDeposits() async {
    state = state.copyWith(isLoading: true);
    try {
      final deposits = await _repository.getPendingDeposits()
          .timeout(const Duration(seconds: 8));
      state = state.copyWith(pendingDeposits: deposits, isLoading: false);
    } catch (_) {
      state = state.copyWith(pendingDeposits: [], isLoading: false);
    }
  }

  Future<void> loadPendingWithdrawals() async {
    state = state.copyWith(isLoading: true);
    try {
      final withdrawals = await _repository.getPendingWithdrawals()
          .timeout(const Duration(seconds: 8));
      state = state.copyWith(pendingWithdrawals: withdrawals, isLoading: false);
    } catch (_) {
      state = state.copyWith(pendingWithdrawals: [], isLoading: false);
    }
  }

  Future<bool> approveDeposit(String transactionId) async {
    final success = await _repository.approveDeposit(transactionId);
    if (success) await loadPendingDeposits();
    return success;
  }

  Future<bool> approveWithdrawal(String transactionId) async {
    final success = await _repository.approveWithdrawal(transactionId);
    if (success) await loadPendingWithdrawals();
    return success;
  }

  Future<bool> rejectTransaction(String transactionId) async {
    final success = await _repository.rejectTransaction(transactionId);
    if (success) {
      await loadPendingDeposits();
      await loadPendingWithdrawals();
    }
    return success;
  }

  // ========== PAYMENT METHODS ==========

  Future<void> loadPaymentMethods() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final methods = await _repository.getAdminPaymentMethods()
          .timeout(const Duration(seconds: 8));
      state = state.copyWith(paymentMethods: methods, isLoading: false);
    } catch (_) {
      state = state.copyWith(paymentMethods: [], isLoading: false);
    }
  }

  Future<bool> createPaymentMethod(Map<String, dynamic> data) async {
    state = state.copyWith(errorMessage: null);
    final result = await _repository.createAdminPaymentMethod(data);
    if (result != null) { await loadPaymentMethods(); return true; }
    state = state.copyWith(errorMessage: 'Failed to create payment method');
    return false;
  }

  Future<bool> updatePaymentMethod(String id, Map<String, dynamic> data) async {
    state = state.copyWith(errorMessage: null);
    final success = await _repository.updateAdminPaymentMethod(id, data);
    if (success) { await loadPaymentMethods(); return true; }
    state = state.copyWith(errorMessage: 'Failed to update payment method');
    return false;
  }

  Future<bool> deletePaymentMethod(String id) async {
    state = state.copyWith(errorMessage: null);
    final success = await _repository.deleteAdminPaymentMethod(id);
    if (success) { await loadPaymentMethods(); return true; }
    state = state.copyWith(errorMessage: 'Failed to delete payment method');
    return false;
  }

  /// Refresh dashboard data.
  Future<void> refresh() async {
    await loadDashboard();
  }

  // ========== TEAMS BY TOURNAMENT ==========

  /// Load teams filtered by tournament ID.
  /// Returns the list directly (no state mutation needed).
  Future<List<Map<String, dynamic>>> getTeamsByTournament(
      String tournamentId) async {
    try {
      return await _repository.getTeamsByTournament(tournamentId);
    } catch (_) {
      return [];
    }
  }

  // ========== PLAYERS BY TEAM ==========

  /// Load players filtered by team ID.
  /// Returns the list directly (no state mutation needed).
  Future<List<Map<String, dynamic>>> getPlayersByTeam(String teamId) async {
    try {
      return await _repository.getPlayersByTeam(teamId);
    } catch (_) {
      return [];
    }
  }

  // ========== MATCH PLAYERS ==========

  /// Set match players for a given match and team.
  Future<bool> setMatchPlayers(
      String matchId, List<String> playerIds, String teamId) async {
    return await _repository.setMatchPlayers(matchId, playerIds, teamId);
  }
}

/// Provider for admin state.
final adminProvider =
    StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return AdminNotifier(repository);
});

/// Provider for admin analytics only.
final adminAnalyticsProvider = Provider<AdminAnalytics>((ref) {
  return ref.watch(adminProvider).analytics;
});
