import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/admin_repository.dart';

/// Admin state holding analytics and entity lists.
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
  final bool isLoading;
  final String? errorMessage;

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
    this.errorMessage,
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
    String? errorMessage,
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
      errorMessage: errorMessage,
    );
  }
}

/// Admin state notifier managing dashboard and CRUD operations.
class AdminNotifier extends StateNotifier<AdminState> {
  final AdminRepository _repository;

  AdminNotifier(this._repository) : super(const AdminState()) {
    loadDashboard();
  }

  /// Load dashboard analytics.
  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true);
    final analytics = await _repository.getAnalytics();
    state = state.copyWith(analytics: analytics, isLoading: false);
  }

  /// Load users with optional search.
  Future<void> loadUsers({String? search}) async {
    state = state.copyWith(isLoading: true);
    final users = await _repository.getUsers(search: search);
    state = state.copyWith(users: users, isLoading: false);
  }

  /// Update user role.
  Future<bool> updateUserRole(String userId, String role) async {
    final success = await _repository.updateUserRole(userId, role);
    if (success) await loadUsers();
    return success;
  }

  // ========== TOURNAMENTS ==========

  Future<void> loadTournaments() async {
    state = state.copyWith(isLoading: true);
    final tournaments = await _repository.getTournaments();
    state = state.copyWith(tournaments: tournaments, isLoading: false);
  }

  Future<bool> createTournament(Map<String, dynamic> data) async {
    final result = await _repository.createTournament(data);
    if (result != null) {
      await loadTournaments();
      return true;
    }
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
    state = state.copyWith(isLoading: true);
    final matches = await _repository.getMatches(status: status);
    state = state.copyWith(matches: matches, isLoading: false);
  }

  Future<bool> createMatch(Map<String, dynamic> data) async {
    final result = await _repository.createMatch(data);
    if (result != null) {
      await loadMatches();
      return true;
    }
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
    state = state.copyWith(isLoading: true);
    final teams = await _repository.getTeams();
    state = state.copyWith(teams: teams, isLoading: false);
  }

  Future<bool> createTeam(Map<String, dynamic> data) async {
    final result = await _repository.createTeam(data);
    if (result != null) {
      await loadTeams();
      return true;
    }
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
    state = state.copyWith(isLoading: true);
    final players = await _repository.getPlayers(teamId: teamId);
    state = state.copyWith(players: players, isLoading: false);
  }

  Future<bool> createPlayer(Map<String, dynamic> data) async {
    final result = await _repository.createPlayer(data);
    if (result != null) {
      await loadPlayers();
      return true;
    }
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
    state = state.copyWith(isLoading: true);
    final contests = await _repository.getContests(matchId: matchId);
    state = state.copyWith(contests: contests, isLoading: false);
  }

  Future<bool> createContest(Map<String, dynamic> data) async {
    final result = await _repository.createContest(data);
    if (result != null) {
      await loadContests();
      return true;
    }
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
    state = state.copyWith(isLoading: true);
    final scoreboard = await _repository.getScoreboard(matchId);
    state = state.copyWith(scoreboard: scoreboard, isLoading: false);
  }

  Future<bool> upsertScoreboard(Map<String, dynamic> data) async {
    return await _repository.upsertScoreboard(data);
  }

  // ========== WALLET MANAGEMENT ==========

  Future<void> loadPendingDeposits() async {
    state = state.copyWith(isLoading: true);
    final deposits = await _repository.getPendingDeposits();
    state = state.copyWith(pendingDeposits: deposits, isLoading: false);
  }

  Future<void> loadPendingWithdrawals() async {
    state = state.copyWith(isLoading: true);
    final withdrawals = await _repository.getPendingWithdrawals();
    state = state.copyWith(pendingWithdrawals: withdrawals, isLoading: false);
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
    final methods = await _repository.getAdminPaymentMethods();
    state = state.copyWith(paymentMethods: methods, isLoading: false);
  }

  Future<bool> createPaymentMethod(Map<String, dynamic> data) async {
    state = state.copyWith(errorMessage: null);
    final result = await _repository.createAdminPaymentMethod(data);
    if (result != null) {
      await loadPaymentMethods();
      return true;
    }
    state = state.copyWith(errorMessage: 'Failed to create payment method');
    return false;
  }

  Future<bool> updatePaymentMethod(String id, Map<String, dynamic> data) async {
    state = state.copyWith(errorMessage: null);
    final success = await _repository.updateAdminPaymentMethod(id, data);
    if (success) {
      await loadPaymentMethods();
      return true;
    }
    state = state.copyWith(errorMessage: 'Failed to update payment method');
    return false;
  }

  Future<bool> deletePaymentMethod(String id) async {
    state = state.copyWith(errorMessage: null);
    final success = await _repository.deleteAdminPaymentMethod(id);
    if (success) {
      await loadPaymentMethods();
      return true;
    }
    state = state.copyWith(errorMessage: 'Failed to delete payment method');
    return false;
  }

  /// Refresh dashboard data.
  Future<void> refresh() async {
    await loadDashboard();
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
