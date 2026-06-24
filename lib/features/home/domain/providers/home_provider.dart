import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client.dart';
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
  final SupabaseClient _client;
  RealtimeChannel? _matchesChannel;
  // Timers for auto-starting matches when countdown hits 0
  final Map<String, Timer> _autoStartTimers = {};

  HomeNotifier(this._repository, this._client) : super(const HomeState()) {
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

      // Schedule auto-start timers for all upcoming matches
      _scheduleAutoStartTimers(state.upcomingMatches);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load data. Pull to refresh.',
      );
    }
  }

  // ── Tasks #4 & #5: Schedule auto-start timers ─────────────────────────────

  /// For each upcoming match, schedule a timer that fires when the match
  /// dateTime is reached and auto-updates its status to 'live' in Supabase.
  void _scheduleAutoStartTimers(List<MatchModel> upcomingMatches) {
    // Cancel existing timers
    for (final t in _autoStartTimers.values) {
      t.cancel();
    }
    _autoStartTimers.clear();

    for (final match in upcomingMatches) {
      final delay = match.dateTime.difference(DateTime.now());
      if (delay.isNegative || delay.inSeconds <= 0) {
        // Match time already passed but still showing upcoming — auto-start now
        _autoStartMatch(match.id);
        continue;
      }
      // Only schedule if < 24 hours away (prevent too many long-lived timers)
      if (delay.inHours < 24) {
        _autoStartTimers[match.id] = Timer(delay, () {
          _autoStartMatch(match.id);
        });
      }
    }
  }

  /// Update match status to 'live' in Supabase and refresh local state.
  Future<void> _autoStartMatch(String matchId) async {
    try {
      await _client
          .from('matches')
          .update({'status': 'live', 'live': true})
          .eq('id', matchId);
      // Refresh to pick up the change
      await loadData();
    } catch (_) {
      // Silently fail — real-time subscription will handle the update
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
  ///
  /// Real-time Postgres payloads only contain flat row data without joined
  /// relations (team logos, names, codes, tournament). We merge only the
  /// scalar fields that can change at runtime into the existing model so
  /// that logo/code/name/tournament data is preserved.
  void _handleMatchUpdate(MatchModel updatedMatch) {
    // Find the existing match from any list to preserve joined relation data.
    final existingMatch = _findExistingMatch(updatedMatch.id);

    // Merge: keep the existing team logos/codes/names/tournament, update only
    // the scalar fields that real-time payloads actually carry.
    final mergedMatch = existingMatch != null
        ? existingMatch.copyWith(
            status: updatedMatch.status,
            live: updatedMatch.live,
            currentOver: updatedMatch.currentOver,
            currentScoreA: updatedMatch.currentScoreA,
            currentScoreB: updatedMatch.currentScoreB,
            teamAScore: updatedMatch.teamAScore,
            teamBScore: updatedMatch.teamBScore,
            result: updatedMatch.result,
            winnerTeamId: updatedMatch.winnerTeamId,
          )
        : updatedMatch;

    // Update in live matches
    if (mergedMatch.isLive) {
      final liveList = List<MatchModel>.from(state.liveMatches);
      final index = liveList.indexWhere((m) => m.id == mergedMatch.id);
      if (index >= 0) {
        liveList[index] = mergedMatch;
      } else {
        liveList.insert(0, mergedMatch);
      }
      state = state.copyWith(liveMatches: liveList);

      // Remove from upcoming if it went live
      final upcomingList = List<MatchModel>.from(state.upcomingMatches)
        ..removeWhere((m) => m.id == mergedMatch.id);
      state = state.copyWith(upcomingMatches: upcomingList);
    }

    // Update in upcoming matches
    if (mergedMatch.isUpcoming) {
      final upcomingList = List<MatchModel>.from(state.upcomingMatches);
      final index = upcomingList.indexWhere((m) => m.id == mergedMatch.id);
      if (index >= 0) {
        upcomingList[index] = mergedMatch;
      }
      state = state.copyWith(upcomingMatches: upcomingList);
    }

    // Move to completed if match is done
    if (mergedMatch.isCompleted) {
      final liveList = List<MatchModel>.from(state.liveMatches)
        ..removeWhere((m) => m.id == mergedMatch.id);
      final completedList = List<MatchModel>.from(state.completedMatches);
      if (!completedList.any((m) => m.id == mergedMatch.id)) {
        completedList.insert(0, mergedMatch);
      }
      state = state.copyWith(
        liveMatches: liveList,
        completedMatches: completedList,
      );
    }
  }

  /// Find an existing match by ID across all match lists.
  MatchModel? _findExistingMatch(String matchId) {
    for (final match in state.liveMatches) {
      if (match.id == matchId) return match;
    }
    for (final match in state.upcomingMatches) {
      if (match.id == matchId) return match;
    }
    for (final match in state.completedMatches) {
      if (match.id == matchId) return match;
    }
    return null;
  }

  /// Refresh all data.
  Future<void> refresh() async {
    await loadData();
  }

  @override
  void dispose() {
    for (final t in _autoStartTimers.values) {
      t.cancel();
    }
    _autoStartTimers.clear();
    if (_matchesChannel != null) {
      _repository.unsubscribe(_matchesChannel!);
    }
    super.dispose();
  }
}

/// Provider for home state.
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  final client = ref.watch(supabaseClientProvider);
  return HomeNotifier(repository, client);
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
