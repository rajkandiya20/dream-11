import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/domain/providers/auth_provider.dart';
import '../../../matches/data/models/contest_model.dart';
import '../../data/models/contest_entry_model.dart';
import '../../data/repositories/contest_repository.dart';
import '../../data/repositories/live_ranking_repository.dart';

/// State for contest list screen.
class ContestListState {
  final List<ContestModel> contests;
  final bool isLoading;
  final String? errorMessage;
  final String? filterType;

  const ContestListState({
    this.contests = const [],
    this.isLoading = false,
    this.errorMessage,
    this.filterType,
  });

  ContestListState copyWith({
    List<ContestModel>? contests,
    bool? isLoading,
    String? errorMessage,
    String? filterType,
  }) {
    return ContestListState(
      contests: contests ?? this.contests,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      filterType: filterType ?? this.filterType,
    );
  }

  /// Filtered contests based on current filter.
  List<ContestModel> get filteredContests {
    if (filterType == null || filterType == 'all') return contests;
    return contests.where((c) => c.contestType == filterType).toList();
  }
}

/// Notifier for contest list.
class ContestListNotifier extends StateNotifier<ContestListState> {
  final ContestRepository _repository;
  final String matchId;

  ContestListNotifier(this._repository, this.matchId)
      : super(const ContestListState()) {
    loadContests();
  }

  /// Load contests for the match.
  Future<void> loadContests() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final contests = await _repository.getContestsByMatch(matchId);
      state = state.copyWith(contests: contests, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load contests.',
      );
    }
  }

  /// Set filter type (all, paid, free).
  void setFilter(String? type) {
    state = state.copyWith(filterType: type);
  }

  /// Refresh contests.
  Future<void> refresh() async {
    await loadContests();
  }
}

/// State for contest detail screen.
class ContestDetailState {
  final ContestModel? contest;
  final List<LeaderboardEntry> leaderboard;
  final bool isLoading;
  final bool hasJoined;
  final String? errorMessage;

  const ContestDetailState({
    this.contest,
    this.leaderboard = const [],
    this.isLoading = false,
    this.hasJoined = false,
    this.errorMessage,
  });

  ContestDetailState copyWith({
    ContestModel? contest,
    List<LeaderboardEntry>? leaderboard,
    bool? isLoading,
    bool? hasJoined,
    String? errorMessage,
  }) {
    return ContestDetailState(
      contest: contest ?? this.contest,
      leaderboard: leaderboard ?? this.leaderboard,
      isLoading: isLoading ?? this.isLoading,
      hasJoined: hasJoined ?? this.hasJoined,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier for contest detail.
class ContestDetailNotifier extends StateNotifier<ContestDetailState> {
  final ContestRepository _repository;
  final LiveRankingRepository _liveRankingRepository;
  final String contestId;
  final String? userId;
  RealtimeChannel? _leaderboardChannel;
  RealtimeChannel? _contestEntriesChannel;

  ContestDetailNotifier(
    this._repository,
    this._liveRankingRepository,
    this.contestId,
    this.userId,
  ) : super(const ContestDetailState()) {
    loadContestDetail();
  }

  /// Load contest detail and leaderboard.
  Future<void> loadContestDetail() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final results = await Future.wait([
        _repository.getContestById(contestId),
        _repository.getLeaderboard(contestId),
        if (userId != null)
          _repository.hasUserJoinedContest(
            contestId: contestId,
            userId: userId!,
          ),
      ]);

      state = ContestDetailState(
        contest: results[0] as ContestModel?,
        leaderboard: results[1] as List<LeaderboardEntry>,
        hasJoined: results.length > 2 ? results[2] as bool : false,
        isLoading: false,
      );

      // Subscribe to realtime leaderboard updates
      _subscribeToRealtime();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load contest details.',
      );
    }
  }

  /// Subscribe to realtime leaderboard and contest entries changes.
  void _subscribeToRealtime() {
    _leaderboardChannel = _liveRankingRepository.subscribeToLeaderboard(
      contestId,
      onUpdate: (entry) {
        // Re-sort leaderboard by points DESC and update ranks
        final list = List<LeaderboardEntry>.from(state.leaderboard);
        final index = list.indexWhere((e) => e.userId == entry.userId);
        if (index >= 0) {
          // Update existing entry
          list[index] = LeaderboardEntry(
            id: list[index].id,
            contestId: list[index].contestId,
            userId: list[index].userId,
            fantasyTeamId: list[index].fantasyTeamId,
            points: entry.totalPoints,
            rank: list[index].rank,
            prizeWon: entry.prizeWon,
            user: list[index].user,
          );
        } else {
          // Add new entry (INSERT event - new user joined mid-session)
          list.add(LeaderboardEntry(
            id: entry.id,
            contestId: entry.contestId,
            userId: entry.userId,
            fantasyTeamId: entry.fantasyTeamId,
            points: entry.totalPoints,
            rank: list.length + 1,
            prizeWon: entry.prizeWon,
            user: null,
          ));
        }
        // Sort by points DESC
        list.sort((a, b) => b.points.compareTo(a.points));
        // Re-assign ranks
        for (int i = 0; i < list.length; i++) {
          list[i] = LeaderboardEntry(
            id: list[i].id,
            contestId: list[i].contestId,
            userId: list[i].userId,
            fantasyTeamId: list[i].fantasyTeamId,
            points: list[i].points,
            rank: i + 1,
            prizeWon: list[i].prizeWon,
            user: list[i].user,
          );
        }
        state = state.copyWith(leaderboard: list);
      },
    );

    _contestEntriesChannel = _liveRankingRepository.subscribeToContestEntries(
      contestId,
      onUpdate: (entry) {
        // Refresh leaderboard when contest entries change
        _repository.getLeaderboard(contestId).then((leaderboard) {
          if (mounted) {
            state = state.copyWith(leaderboard: leaderboard);
          }
        });
      },
    );
  }

  /// Join contest with a fantasy team.
  Future<bool> joinContest(String fantasyTeamId) async {
    if (userId == null) return false;

    final success = await _repository.joinContest(
      contestId: contestId,
      userId: userId!,
      fantasyTeamId: fantasyTeamId,
    );

    if (success) {
      state = state.copyWith(hasJoined: true);
      await loadContestDetail();
    }

    return success;
  }

  /// Refresh contest detail.
  Future<void> refresh() async {
    await loadContestDetail();
  }

  @override
  void dispose() {
    if (_leaderboardChannel != null) {
      _liveRankingRepository.unsubscribe(_leaderboardChannel!);
    }
    if (_contestEntriesChannel != null) {
      _liveRankingRepository.unsubscribe(_contestEntriesChannel!);
    }
    super.dispose();
  }
}

/// Family provider for contest list keyed by matchId.
final contestListProvider = StateNotifierProvider.family<ContestListNotifier,
    ContestListState, String>((ref, matchId) {
  final repository = ref.watch(contestRepositoryProvider);
  return ContestListNotifier(repository, matchId);
});

/// Family provider for contest detail keyed by contestId.
final contestDetailProvider = StateNotifierProvider.family<
    ContestDetailNotifier, ContestDetailState, String>((ref, contestId) {
  final repository = ref.watch(contestRepositoryProvider);
  final liveRankingRepository = ref.watch(liveRankingRepositoryProvider);
  // Get user ID from auth state.
  final user = ref.read(currentUserProvider);
  return ContestDetailNotifier(repository, liveRankingRepository, contestId, user?.uid);
});
