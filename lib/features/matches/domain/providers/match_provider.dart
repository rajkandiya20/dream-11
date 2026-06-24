import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../home/data/models/match_model.dart';
import '../../data/models/ball_by_ball_model.dart';
import '../../data/models/contest_model.dart';
import '../../data/models/player_model.dart';
import '../../data/models/player_stats_model.dart';
import '../../data/models/scoreboard_model.dart';
import '../../data/repositories/match_repository.dart';

/// State for match detail screen.
class MatchDetailState {
  final MatchModel? match;
  final List<ContestModel> contests;
  final List<PlayerModel> players;
  final List<ScoreboardModel> scoreboard;
  final List<CommentaryModel> commentary;
  final List<PlayerStatsModel> playerStats;
  final List<BallByBallModel> ballByBall;
  final bool isLoading;
  final String? errorMessage;

  const MatchDetailState({
    this.match,
    this.contests = const [],
    this.players = const [],
    this.scoreboard = const [],
    this.commentary = const [],
    this.playerStats = const [],
    this.ballByBall = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  MatchDetailState copyWith({
    MatchModel? match,
    List<ContestModel>? contests,
    List<PlayerModel>? players,
    List<ScoreboardModel>? scoreboard,
    List<CommentaryModel>? commentary,
    List<PlayerStatsModel>? playerStats,
    List<BallByBallModel>? ballByBall,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MatchDetailState(
      match: match ?? this.match,
      contests: contests ?? this.contests,
      players: players ?? this.players,
      scoreboard: scoreboard ?? this.scoreboard,
      commentary: commentary ?? this.commentary,
      playerStats: playerStats ?? this.playerStats,
      ballByBall: ballByBall ?? this.ballByBall,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  bool get isLive => match?.isLive ?? false;
}

/// Match detail notifier managing data and real-time subscriptions.
class MatchDetailNotifier extends StateNotifier<MatchDetailState> {
  final MatchRepository _repository;
  final String matchId;
  RealtimeChannel? _scoreboardChannel;
  RealtimeChannel? _commentaryChannel;
  RealtimeChannel? _contestsChannel;
  RealtimeChannel? _playerStatsChannel;
  RealtimeChannel? _ballByBallChannel;

  MatchDetailNotifier(this._repository, this.matchId)
      : super(const MatchDetailState()) {
    loadMatchData();
  }

  /// Load all match detail data.
  Future<void> loadMatchData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final results = await Future.wait([
        _repository.getMatchById(matchId),
        _repository.getContestsByMatch(matchId),
        _repository.getPlayersByMatch(matchId),
        _repository.getScoreboard(matchId),
        _repository.getCommentary(matchId),
        _repository.getPlayerStats(matchId),
        _repository.getBallByBall(matchId),
      ]);

      final match = results[0] as MatchModel?;
      state = MatchDetailState(
        match: match,
        contests: results[1] as List<ContestModel>,
        players: results[2] as List<PlayerModel>,
        scoreboard: results[3] as List<ScoreboardModel>,
        commentary: results[4] as List<CommentaryModel>,
        playerStats: results[5] as List<PlayerStatsModel>,
        ballByBall: results[6] as List<BallByBallModel>,
        isLoading: false,
      );

      // FIX #7: Always subscribe to real-time — not just when isLive.
      // This covers: match goes live after screen opens, and scoring updates.
      _unsubscribeAll();
      _subscribeToRealtime();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load match details.',
      );
    }
  }

  /// Subscribe to real-time scoreboard and commentary updates.
  /// FIX #7: Always subscribe regardless of live status.
  /// Also listen to `scoreboard` table for fantasy points updates from admin scoring.
  void _subscribeToRealtime() {
    _scoreboardChannel = _repository.subscribeToScoreboard(
      matchId,
      onUpdate: (entry) {
        final list = List<ScoreboardModel>.from(state.scoreboard);
        final index = list.indexWhere((s) => s.id == entry.id);
        if (index >= 0) {
          list[index] = entry;
        } else {
          list.insert(0, entry);
        }
        list.sort((a, b) => b.points.compareTo(a.points));
        state = state.copyWith(scoreboard: list);

        // FIX #7: Sync fantasy points from scoreboard → playerStats.
        // Admin scores to `scoreboard.points` — reflect that in playerStats
        // so the My Team tab shows live points immediately.
        final statsList = List<PlayerStatsModel>.from(state.playerStats);
        final statIdx =
            statsList.indexWhere((s) => s.playerId == entry.playerId);
        if (statIdx >= 0) {
          statsList[statIdx] =
              statsList[statIdx].copyWith(fantasyPoints: entry.points);
        } else {
          // Create a minimal entry if not present yet
          statsList.add(PlayerStatsModel(
            id: entry.id,
            matchId: matchId,
            playerId: entry.playerId,
            fantasyPoints: entry.points,
          ));
        }
        state = state.copyWith(playerStats: statsList);
      },
    );

    _commentaryChannel = _repository.subscribeToCommentary(
      matchId,
      onUpdate: (entry) {
        final list = List<CommentaryModel>.from(state.commentary);
        list.insert(0, entry);
        state = state.copyWith(commentary: list);
      },
    );

    _contestsChannel = _repository.subscribeToContests(
      matchId,
      onUpdate: (contest) {
        final list = List<ContestModel>.from(state.contests);
        final index = list.indexWhere((c) => c.id == contest.id);
        if (index >= 0) {
          list[index] = contest;
        }
        state = state.copyWith(contests: list);
      },
    );

    _playerStatsChannel = _repository.subscribeToPlayerStats(
      matchId,
      onUpdate: (entry) {
        final list = List<PlayerStatsModel>.from(state.playerStats);
        final index = list.indexWhere((s) => s.id == entry.id);
        if (index >= 0) {
          list[index] = entry;
        } else {
          list.insert(0, entry);
        }
        list.sort((a, b) => b.fantasyPoints.compareTo(a.fantasyPoints));
        state = state.copyWith(playerStats: list);
      },
    );

    _ballByBallChannel = _repository.subscribeToBallByBall(
      matchId,
      onUpdate: (entry) {
        final list = List<BallByBallModel>.from(state.ballByBall);
        list.insert(0, entry);
        state = state.copyWith(ballByBall: list);
      },
    );
  }

  /// Unsubscribe all active channels before re-subscribing.
  void _unsubscribeAll() {
    if (_scoreboardChannel != null) {
      _repository.unsubscribe(_scoreboardChannel!);
      _scoreboardChannel = null;
    }
    if (_commentaryChannel != null) {
      _repository.unsubscribe(_commentaryChannel!);
      _commentaryChannel = null;
    }
    if (_contestsChannel != null) {
      _repository.unsubscribe(_contestsChannel!);
      _contestsChannel = null;
    }
    if (_playerStatsChannel != null) {
      _repository.unsubscribe(_playerStatsChannel!);
      _playerStatsChannel = null;
    }
    if (_ballByBallChannel != null) {
      _repository.unsubscribe(_ballByBallChannel!);
      _ballByBallChannel = null;
    }
  }

  /// Refresh match data.
  Future<void> refresh() async {
    await loadMatchData();
  }

  @override
  void dispose() {
    _unsubscribeAll();
    super.dispose();
  }
}

/// Family provider for match detail keyed by matchId.
final matchDetailProvider = StateNotifierProvider.family<
    MatchDetailNotifier, MatchDetailState, String>((ref, matchId) {
  final repository = ref.watch(matchRepositoryProvider);
  return MatchDetailNotifier(repository, matchId);
});

/// Provider for match contests only.
final matchContestsProvider =
    Provider.family<List<ContestModel>, String>((ref, matchId) {
  return ref.watch(matchDetailProvider(matchId)).contests;
});

/// Provider for match scoreboard only.
final matchScoreboardProvider =
    Provider.family<List<ScoreboardModel>, String>((ref, matchId) {
  return ref.watch(matchDetailProvider(matchId)).scoreboard;
});

/// Provider for match commentary only.
final matchCommentaryProvider =
    Provider.family<List<CommentaryModel>, String>((ref, matchId) {
  return ref.watch(matchDetailProvider(matchId)).commentary;
});

/// Provider for match player stats only.
final matchPlayerStatsProvider =
    Provider.family<List<PlayerStatsModel>, String>((ref, matchId) {
  return ref.watch(matchDetailProvider(matchId)).playerStats;
});

/// Provider for match ball-by-ball data only.
final matchBallByBallProvider =
    Provider.family<List<BallByBallModel>, String>((ref, matchId) {
  return ref.watch(matchDetailProvider(matchId)).ballByBall;
});
