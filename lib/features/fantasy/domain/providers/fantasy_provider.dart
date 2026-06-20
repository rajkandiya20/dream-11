import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../matches/data/models/player_model.dart';
import '../../data/models/fantasy_team_model.dart';
import '../../data/repositories/fantasy_repository.dart';

/// Role constraints for fantasy team builder.
class RoleConstraints {
  static const int minWK = 1;
  static const int maxWK = 4;
  static const int minBAT = 3;
  static const int maxBAT = 6;
  static const int minAR = 1;
  static const int maxAR = 4;
  static const int minBOWL = 3;
  static const int maxBOWL = 6;
  static const int totalPlayers = 11;
  static const double maxCredits = 100.0;
}

/// Filter enum for player roles in team builder.
enum PlayerRoleFilter { all, wk, bat, ar, bowl }

/// State for fantasy team builder.
class TeamBuilderState {
  final List<PlayerModel> availablePlayers;
  final List<PlayerModel> selectedPlayers;
  final PlayerRoleFilter activeFilter;
  final String? captainId;
  final String? viceCaptainId;
  final String teamName;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? searchQuery;

  const TeamBuilderState({
    this.availablePlayers = const [],
    this.selectedPlayers = const [],
    this.activeFilter = PlayerRoleFilter.all,
    this.captainId,
    this.viceCaptainId,
    this.teamName = 'My Team 1',
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.searchQuery,
  });

  TeamBuilderState copyWith({
    List<PlayerModel>? availablePlayers,
    List<PlayerModel>? selectedPlayers,
    PlayerRoleFilter? activeFilter,
    String? captainId,
    String? viceCaptainId,
    String? teamName,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? searchQuery,
  }) {
    return TeamBuilderState(
      availablePlayers: availablePlayers ?? this.availablePlayers,
      selectedPlayers: selectedPlayers ?? this.selectedPlayers,
      activeFilter: activeFilter ?? this.activeFilter,
      captainId: captainId ?? this.captainId,
      viceCaptainId: viceCaptainId ?? this.viceCaptainId,
      teamName: teamName ?? this.teamName,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Total credits used by selected players.
  double get creditsUsed =>
      selectedPlayers.fold(0.0, (sum, p) => sum + p.credits);

  /// Remaining credits available.
  double get creditsRemaining => RoleConstraints.maxCredits - creditsUsed;

  /// Number of selected players.
  int get selectedCount => selectedPlayers.length;

  /// Whether team is complete (11 players).
  bool get isTeamComplete => selectedCount == RoleConstraints.totalPlayers;

  /// Count of selected WK players.
  int get wkCount =>
      selectedPlayers.where((p) => p.role == 'WK').length;

  /// Count of selected BAT players.
  int get batCount =>
      selectedPlayers.where((p) => p.role == 'Batsman').length;

  /// Count of selected AR players.
  int get arCount =>
      selectedPlayers.where((p) => p.role == 'All-rounder').length;

  /// Count of selected BOWL players.
  int get bowlCount =>
      selectedPlayers.where((p) => p.role == 'Bowler').length;

  /// Whether WK role can add more players.
  bool get canAddWK => wkCount < RoleConstraints.maxWK;

  /// Whether BAT role can add more players.
  bool get canAddBAT => batCount < RoleConstraints.maxBAT;

  /// Whether AR role can add more players.
  bool get canAddAR => arCount < RoleConstraints.maxAR;

  /// Whether BOWL role can add more players.
  bool get canAddBOWL => bowlCount < RoleConstraints.maxBOWL;

  /// Whether a specific player can be added.
  bool canAddPlayer(PlayerModel player) {
    if (isTeamComplete) return false;
    if (selectedPlayers.any((p) => p.id == player.id)) return false;
    if (player.credits > creditsRemaining) return false;

    switch (player.role) {
      case 'WK':
        return canAddWK;
      case 'Batsman':
        return canAddBAT;
      case 'All-rounder':
        return canAddAR;
      case 'Bowler':
        return canAddBOWL;
      default:
        return false;
    }
  }

  /// Whether minimum role constraints are met.
  bool get meetsMinimumConstraints =>
      wkCount >= RoleConstraints.minWK &&
      batCount >= RoleConstraints.minBAT &&
      arCount >= RoleConstraints.minAR &&
      bowlCount >= RoleConstraints.minBOWL;

  /// Whether team is valid for submission.
  bool get isValidTeam => isTeamComplete && meetsMinimumConstraints;

  /// Get filtered players based on active filter and search query.
  List<PlayerModel> get filteredPlayers {
    var players = availablePlayers;

    // Apply role filter
    switch (activeFilter) {
      case PlayerRoleFilter.wk:
        players = players.where((p) => p.role == 'WK').toList();
        break;
      case PlayerRoleFilter.bat:
        players = players.where((p) => p.role == 'Batsman').toList();
        break;
      case PlayerRoleFilter.ar:
        players = players.where((p) => p.role == 'All-rounder').toList();
        break;
      case PlayerRoleFilter.bowl:
        players = players.where((p) => p.role == 'Bowler').toList();
        break;
      case PlayerRoleFilter.all:
        break;
    }

    // Apply search filter
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      players = players
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();
    }

    return players;
  }

  /// Whether player is selected.
  bool isSelected(String playerId) =>
      selectedPlayers.any((p) => p.id == playerId);
}

/// Team builder notifier managing player selection logic.
class TeamBuilderNotifier extends StateNotifier<TeamBuilderState> {
  final FantasyRepository _repository;
  final String matchId;
  final String? userId;

  TeamBuilderNotifier(this._repository, this.matchId, this.userId)
      : super(const TeamBuilderState());

  /// Set available players (loaded from match).
  void setAvailablePlayers(List<PlayerModel> players) {
    state = state.copyWith(availablePlayers: players, isLoading: false);
  }

  /// Toggle player selection.
  void togglePlayer(PlayerModel player) {
    final selected = List<PlayerModel>.from(state.selectedPlayers);
    final isCurrentlySelected = selected.any((p) => p.id == player.id);

    if (isCurrentlySelected) {
      selected.removeWhere((p) => p.id == player.id);
      // Clear captain/vc if removed
      String? captainId = state.captainId;
      String? vcId = state.viceCaptainId;
      if (captainId == player.id) captainId = null;
      if (vcId == player.id) vcId = null;
      state = state.copyWith(
        selectedPlayers: selected,
        captainId: captainId,
        viceCaptainId: vcId,
      );
    } else if (state.canAddPlayer(player)) {
      selected.add(player);
      state = state.copyWith(selectedPlayers: selected);
    }
  }

  /// Set role filter.
  void setFilter(PlayerRoleFilter filter) {
    state = state.copyWith(activeFilter: filter);
  }

  /// Set search query.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Set captain.
  void setCaptain(String playerId) {
    String? vcId = state.viceCaptainId;
    // If the new captain was previously vice-captain, clear VC.
    if (vcId == playerId) vcId = null;
    state = state.copyWith(captainId: playerId, viceCaptainId: vcId);
  }

  /// Set vice-captain.
  void setViceCaptain(String playerId) {
    String? captainId = state.captainId;
    // If the new VC was previously captain, clear captain.
    if (captainId == playerId) captainId = null;
    state = state.copyWith(viceCaptainId: playerId, captainId: captainId);
  }

  /// Set team name.
  void setTeamName(String name) {
    state = state.copyWith(teamName: name);
  }

  /// Save the fantasy team.
  Future<FantasyTeamModel?> saveTeam({String? contestId}) async {
    if (!state.isValidTeam) return null;
    if (state.captainId == null || state.viceCaptainId == null) return null;
    if (userId == null) return null;

    state = state.copyWith(isSaving: true, errorMessage: null);

    final result = await _repository.createFantasyTeam(
      userId: userId!,
      matchId: matchId,
      contestId: contestId,
      teamName: state.teamName,
      captainId: state.captainId!,
      viceCaptainId: state.viceCaptainId!,
      playerIds: state.selectedPlayers.map((p) => p.id).toList(),
    );

    if (result != null) {
      state = state.copyWith(isSaving: false);
    } else {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save team. Please try again.',
      );
    }

    return result;
  }

  /// Reset team builder state.
  void reset() {
    state = TeamBuilderState(
      availablePlayers: state.availablePlayers,
    );
  }
}

/// Family provider for team builder keyed by matchId.
final teamBuilderProvider = StateNotifierProvider.family<TeamBuilderNotifier,
    TeamBuilderState, String>((ref, matchId) {
  final repository = ref.watch(fantasyRepositoryProvider);
  return TeamBuilderNotifier(repository, matchId, null);
});

/// Provider for user fantasy teams.
final userFantasyTeamsProvider =
    FutureProvider.family<List<FantasyTeamModel>, String>((ref, userId) async {
  final repository = ref.watch(fantasyRepositoryProvider);
  return repository.getUserFantasyTeams(userId);
});
