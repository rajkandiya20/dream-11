import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../matches/data/models/contest_model.dart';
import '../../data/models/match_model.dart';
import '../../data/models/tournament_model.dart';
import '../../data/repositories/home_repository.dart';

/// State for the home screen data.
class HomeState {
  final List<MatchModel> liveMatches;
  final List<MatchModel> upcomingMatches;
  final List<MatchModel> completedMatches;
  final List<TournamentModel> tournaments;
  final List<ContestModel> popularContests;
  final bool isLoading;
  final String? errorMessage;

  const HomeState({
    this.liveMatches = const [],
    this.upcomingMatches = const [],
    this.completedMatches = const [],
    this.tournaments = const [],
    this.popularContests = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  HomeState copyWith({
    List<MatchModel>? liveMatches,
    List<MatchModel>? upcomingMatches,
    List<MatchModel>? completedMatches,
    List<TournamentModel>? tournaments,
    List<ContestModel>? popularContests,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      liveMatches: liveMatches ?? this.liveMatches,
      upcomingMatches: upcomingMatches ?? this.upcomingMatches,
      completedMatches: completedMatches ?? this.completedMatches,
      tournaments: tournaments ?? this.tournaments,
      popularContests: popularContests ?? this.popularContests,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  bool get hasLiveMatches => liveMatches.isNotEmpty;
  bool get hasUpcomingMatches => upcomingMatches.isNotEmpty;
}

/// Home state notifier managing data fetching and real-time subscriptions.
class HomeNotifier extends StateNotifier<HomeState> {
  final HomeRepository _repository;
  RealtimeChannel? _matchesChannel;

  HomeNotifier(this._repository) : super(const HomeState()) {
    loadData();
    _subscribeToMatches();
  }

  /// Load all home screen data.
  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final results = await Future.wait([
        _repository.getLiveMatches(),
        _repository.getUpcomingMatches(),
        _repository.getCompletedMatches(),
        _repository.getTournaments(),
        _repository.getPopularContests(),
      ]);

      state = HomeState(
        liveMatches: results[0] as List<MatchModel>,
        upcomingMatches: results[1] as List<MatchModel>,
        completedMatches: results[2] as List<MatchModel>,
        tournaments: results[3] as List<TournamentModel>,
        popularContests: results[4] as List<ContestModel>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load data. Pull to refresh.',
      );
    }
  }

  /// Subscribe to real-time match updates.
  void _subscribeToMatches() {
    _matchesChannel = _repository.subscribeToMatches(
      onMatchUpdate: (match) {
        _handleMatchUpdate(match);
      },
    );
  }

  /// Handle a real-time match update.
  void _handleMatchUpdate(MatchModel updatedMatch) {
    // Update in live matches
    if (updatedMatch.isLive) {
      final liveList = List<MatchModel>.from(state.liveMatches);
      final index = liveList.indexWhere((m) => m.id == updatedMatch.id);
      if (index >= 0) {
        liveList[index] = updatedMatch;
      } else {
        liveList.insert(0, updatedMatch);
      }
      state = state.copyWith(liveMatches: liveList);

      // Remove from upcoming if it went live
      final upcomingList = List<MatchModel>.from(state.upcomingMatches)
        ..removeWhere((m) => m.id == updatedMatch.id);
      state = state.copyWith(upcomingMatches: upcomingList);
    }

    // Update in upcoming matches
    if (updatedMatch.isUpcoming) {
      final upcomingList = List<MatchModel>.from(state.upcomingMatches);
      final index = upcomingList.indexWhere((m) => m.id == updatedMatch.id);
      if (index >= 0) {
        upcomingList[index] = updatedMatch;
      }
      state = state.copyWith(upcomingMatches: upcomingList);
    }

    // Move to completed if match is done
    if (updatedMatch.isCompleted) {
      final liveList = List<MatchModel>.from(state.liveMatches)
        ..removeWhere((m) => m.id == updatedMatch.id);
      final completedList = List<MatchModel>.from(state.completedMatches);
      if (!completedList.any((m) => m.id == updatedMatch.id)) {
        completedList.insert(0, updatedMatch);
      }
      state = state.copyWith(
        liveMatches: liveList,
        completedMatches: completedList,
      );
    }
  }

  /// Refresh all data.
  Future<void> refresh() async {
    await loadData();
  }

  @override
  void dispose() {
    if (_matchesChannel != null) {
      _repository.unsubscribe(_matchesChannel!);
    }
    super.dispose();
  }
}

/// Provider for home state.
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return HomeNotifier(repository);
});

/// Provider for live matches only.
final liveMatchesProvider = Provider<List<MatchModel>>((ref) {
  return ref.watch(homeProvider).liveMatches;
});

/// Provider for upcoming matches only.
final upcomingMatchesProvider = Provider<List<MatchModel>>((ref) {
  return ref.watch(homeProvider).upcomingMatches;
});

/// Provider for popular contests.
final popularContestsProvider = Provider<List<ContestModel>>((ref) {
  return ref.watch(homeProvider).popularContests;
});

/// Provider for active tournaments.
final tournamentsProvider = Provider<List<TournamentModel>>((ref) {
  return ref.watch(homeProvider).tournaments;
});
