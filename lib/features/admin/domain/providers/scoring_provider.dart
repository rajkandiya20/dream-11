import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/ball_model.dart';
import '../../data/models/innings_state.dart';
import '../../data/repositories/scoring_repository.dart';

/// Fantasy points constants.
class FantasyPoints {
  static const double perRun = 1.0;
  static const double fourBonus = 1.0;
  static const double sixBonus = 2.0;
  static const double wicket = 25.0;
  static const double catchPoints = 8.0;
  static const double runOut = 6.0;
  static const double captainMultiplier = 2.0;
  static const double viceCaptainMultiplier = 1.5;
}

/// State for the live scoring system.
class ScoringState {
  final String? matchId;
  final int innings;
  final int totalRuns;
  final int totalWickets;
  final double totalOvers;
  final double currentRunRate;
  final int? target;
  final double? requiredRunRate;
  final BatsmanState? striker;
  final BatsmanState? nonStriker;
  final BowlerState? bowler;
  final List<String> lastSixBalls;
  final Partnership partnership;
  final List<FallOfWicket> fallOfWickets;
  final bool isOverComplete;
  final bool isInningsComplete;
  final List<Map<String, dynamic>> teamAPlayers;
  final List<Map<String, dynamic>> teamBPlayers;
  final String? tossWinner;
  final String? electedTo;
  final Map<String, dynamic>? matchInfo;
  final bool isLoading;
  final String? error;

  const ScoringState({
    this.matchId,
    this.innings = 1,
    this.totalRuns = 0,
    this.totalWickets = 0,
    this.totalOvers = 0.0,
    this.currentRunRate = 0.0,
    this.target,
    this.requiredRunRate,
    this.striker,
    this.nonStriker,
    this.bowler,
    this.lastSixBalls = const [],
    this.partnership = const Partnership(),
    this.fallOfWickets = const [],
    this.isOverComplete = false,
    this.isInningsComplete = false,
    this.teamAPlayers = const [],
    this.teamBPlayers = const [],
    this.tossWinner,
    this.electedTo,
    this.matchInfo,
    this.isLoading = false,
    this.error,
  });

  ScoringState copyWith({
    String? matchId,
    int? innings,
    int? totalRuns,
    int? totalWickets,
    double? totalOvers,
    double? currentRunRate,
    int? target,
    double? requiredRunRate,
    BatsmanState? striker,
    BatsmanState? nonStriker,
    BowlerState? bowler,
    List<String>? lastSixBalls,
    Partnership? partnership,
    List<FallOfWicket>? fallOfWickets,
    bool? isOverComplete,
    bool? isInningsComplete,
    List<Map<String, dynamic>>? teamAPlayers,
    List<Map<String, dynamic>>? teamBPlayers,
    String? tossWinner,
    String? electedTo,
    Map<String, dynamic>? matchInfo,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearStriker = false,
    bool clearNonStriker = false,
    bool clearBowler = false,
    bool clearTarget = false,
    bool clearRequiredRunRate = false,
  }) {
    return ScoringState(
      matchId: matchId ?? this.matchId,
      innings: innings ?? this.innings,
      totalRuns: totalRuns ?? this.totalRuns,
      totalWickets: totalWickets ?? this.totalWickets,
      totalOvers: totalOvers ?? this.totalOvers,
      currentRunRate: currentRunRate ?? this.currentRunRate,
      target: clearTarget ? null : (target ?? this.target),
      requiredRunRate: clearRequiredRunRate
          ? null
          : (requiredRunRate ?? this.requiredRunRate),
      striker: clearStriker ? null : (striker ?? this.striker),
      nonStriker: clearNonStriker ? null : (nonStriker ?? this.nonStriker),
      bowler: clearBowler ? null : (bowler ?? this.bowler),
      lastSixBalls: lastSixBalls ?? this.lastSixBalls,
      partnership: partnership ?? this.partnership,
      fallOfWickets: fallOfWickets ?? this.fallOfWickets,
      isOverComplete: isOverComplete ?? this.isOverComplete,
      isInningsComplete: isInningsComplete ?? this.isInningsComplete,
      teamAPlayers: teamAPlayers ?? this.teamAPlayers,
      teamBPlayers: teamBPlayers ?? this.teamBPlayers,
      tossWinner: tossWinner ?? this.tossWinner,
      electedTo: electedTo ?? this.electedTo,
      matchInfo: matchInfo ?? this.matchInfo,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Notifier that manages live scoring state and ball-by-ball operations.
class ScoringNotifier extends StateNotifier<ScoringState> {
  final ScoringRepository _repository;
  int _currentBallInOver = 0;
  bool _isBusy = false;

  ScoringNotifier(this._repository) : super(const ScoringState());

  /// Initialize scoring for a match - load players and existing ball data.
  Future<void> initMatch(String matchId) async {
    state = state.copyWith(isLoading: true, clearError: true, matchId: matchId);
    try {
      // Load match players
      final matchPlayers = await _repository.getMatchPlayers(matchId);
      final teamA = <Map<String, dynamic>>[];
      final teamB = <Map<String, dynamic>>[];

      for (final mp in matchPlayers) {
        final player = mp['player'] as Map<String, dynamic>?;
        if (player != null) {
          final entry = {
            ...player,
            'team_id': mp['team_id'],
            'match_player_id': mp['id'],
          };
          // Split by team - first team found is A, second is B
          if (teamA.isEmpty ||
              (teamA.isNotEmpty &&
                  teamA.first['team_id'] == mp['team_id'])) {
            teamA.add(entry);
          } else {
            teamB.add(entry);
          }
        }
      }

      // Load existing innings state
      final inningsData =
          await _repository.getInningsState(matchId, state.innings);
      int totalRuns = 0;
      int totalWickets = 0;
      double overs = 0.0;

      if (inningsData != null) {
        totalRuns = inningsData['total_runs'] as int? ?? 0;
        totalWickets = inningsData['total_wickets'] as int? ?? 0;
        overs = (inningsData['overs'] as num?)?.toDouble() ?? 0.0;
        final legalBalls = inningsData['legal_balls'] as int? ?? 0;
        _currentBallInOver = legalBalls % 6;
      }

      // Use arithmetic overs (legalBalls / 6) for rate calculation
      final legalBalls = inningsData?['legal_balls'] as int? ?? 0;
      final oversArithmetic = legalBalls / 6.0;
      final runRate = oversArithmetic > 0 ? totalRuns / oversArithmetic : 0.0;

      state = state.copyWith(
        matchId: matchId,
        totalRuns: totalRuns,
        totalWickets: totalWickets,
        totalOvers: overs,
        currentRunRate: runRate,
        teamAPlayers: teamA,
        teamBPlayers: teamB,
        isLoading: false,
      );
      debugPrint('Match initialized: $matchId, '
          'teamA: ${teamA.length}, teamB: ${teamB.length}');
    } catch (e) {
      debugPrint('ScoringNotifier initMatch error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize match: $e',
      );
    }
  }

  /// Record runs scored off a delivery.
  Future<void> recordRun(int runs) async {
    if (_isBusy) return;
    if (state.matchId == null || state.striker == null || state.bowler == null) {
      state = state.copyWith(
          error: 'Cannot record run: match, striker, or bowler not set');
      return;
    }

    _isBusy = true;
    try {
      _currentBallInOver++;
      final overNo = state.totalOvers.toInt();
      final ballNo = _currentBallInOver;

      final ball = BallEntry(
        matchId: state.matchId!,
        innings: state.innings,
        overNo: overNo,
        ballNo: ballNo,
        batsmanId: state.striker!.id,
        nonStrikerId: state.nonStriker?.id ?? '',
        bowlerId: state.bowler!.id,
        runs: runs,
        isLegal: true,
      );

      final result = await _repository.insertBall(ball);
      if (result == null) {
        _currentBallInOver--;
        state = state.copyWith(error: 'Failed to save ball');
        return;
      }

      // Update local state
      final newTotalRuns = state.totalRuns + runs;
      final isOverComplete = _currentBallInOver >= 6;
      // Display overs: uses /10 convention (12.5 = 12 overs 5 balls)
      final newOvers = isOverComplete
          ? (overNo + 1).toDouble()
          : overNo + (_currentBallInOver / 10.0);
      // Arithmetic overs: uses /6 for rate calculations
      final totalLegalBalls =
          (overNo * 6) + _currentBallInOver;
      final newOversArithmetic = totalLegalBalls / 6.0;
      final newRunRate =
          newOversArithmetic > 0 ? newTotalRuns / newOversArithmetic : 0.0;

      // Update batsman state
      final updatedStriker = state.striker!.copyWith(
        runs: state.striker!.runs + runs,
        balls: state.striker!.balls + 1,
        fours: runs == 4 ? state.striker!.fours + 1 : state.striker!.fours,
        sixes: runs == 6 ? state.striker!.sixes + 1 : state.striker!.sixes,
      );

      // Update bowler state
      final bowlerTotalLegalBalls =
          (state.bowler!.overs.toInt() * 6) +
              (_currentBallInOver <= 6 ? _currentBallInOver : 0);
      final newBowlerOvers = isOverComplete
          ? (state.bowler!.overs.toInt() + 1).toDouble()
          : state.bowler!.overs.toInt() + (_currentBallInOver / 10.0);
      final bowlerOversArithmetic = bowlerTotalLegalBalls / 6.0;
      final updatedBowler = state.bowler!.copyWith(
        runsConceded: state.bowler!.runsConceded + runs,
        overs: newBowlerOvers,
        economy: bowlerOversArithmetic > 0
            ? (state.bowler!.runsConceded + runs) / bowlerOversArithmetic
            : 0.0,
      );

      // Update partnership
      final updatedPartnership = state.partnership.copyWith(
        runs: state.partnership.runs + runs,
        balls: state.partnership.balls + 1,
      );

      // Ball description for last 6 balls display
      final ballDesc = runs == 0 ? '0' : '$runs';
      final lastSix = [...state.lastSixBalls, ballDesc];
      if (lastSix.length > 6) lastSix.removeAt(0);

      // Calculate required run rate for 2nd innings
      double? reqRR;
      if (state.target != null && state.target! > newTotalRuns) {
        final remaining = state.target! - newTotalRuns;
        final oversRemaining = 20.0 - newOversArithmetic;
        if (oversRemaining > 0) {
          reqRR = remaining / oversRemaining;
        }
      }

      // Capture scorer's ID before potential swap for scoreboard update
      final scorerPlayerId = state.striker!.id;

      state = state.copyWith(
        totalRuns: newTotalRuns,
        totalOvers: newOvers,
        currentRunRate: newRunRate,
        requiredRunRate: reqRR,
        striker: runs % 2 == 1 ? state.nonStriker : updatedStriker,
        nonStriker: runs % 2 == 1 ? updatedStriker : state.nonStriker,
        bowler: updatedBowler,
        partnership: updatedPartnership,
        lastSixBalls: lastSix,
        isOverComplete: isOverComplete,
        clearError: true,
      );

      // Persist score update to match table
      await _repository.updateMatchScore(state.matchId!, {
        if (state.innings == 1) 'current_score_a': '$newTotalRuns/${state.totalWickets}',
        if (state.innings == 2) 'current_score_b': '$newTotalRuns/${state.totalWickets}',
        'current_over': newOvers,
      });

      // Update batsman scoreboard using the scorer's ID (not state.striker which may have swapped)
      await _repository.updateScoreboard(state.matchId!, scorerPlayerId, {
        'runs': updatedStriker.runs,
        'balls_faced': updatedStriker.balls,
        'fours': updatedStriker.fours,
        'sixes': updatedStriker.sixes,
        'strike_rate': updatedStriker.strikeRate,
      });

      // Update fantasy points for batsman (delta only for this ball)
      double fantasyDelta = runs * FantasyPoints.perRun;
      if (runs == 4) fantasyDelta += FantasyPoints.fourBonus;
      if (runs == 6) fantasyDelta += FantasyPoints.sixBonus;
      await _repository.updateFantasyPoints(
          state.matchId!, scorerPlayerId, fantasyDelta);

      // Update bowler scoreboard
      await _repository.updateBowlerStats(state.matchId!, state.bowler!.id, {
        'overs_bowled': updatedBowler.overs,
        'economy': updatedBowler.economy,
      });

      if (isOverComplete) {
        _currentBallInOver = 0;
      }
    } catch (e) {
      debugPrint('ScoringNotifier recordRun error: $e');
      state = state.copyWith(error: 'Failed to record run: $e');
    } finally {
      _isBusy = false;
    }
  }

  /// Record an extra delivery (wide, no_ball, bye, leg_bye).
  Future<void> recordExtra(String type, int additionalRuns) async {
    if (_isBusy) return;
    if (state.matchId == null || state.striker == null || state.bowler == null) {
      state = state.copyWith(
          error: 'Cannot record extra: match, striker, or bowler not set');
      return;
    }

    _isBusy = true;
    try {
      final isLegal = type == 'bye' || type == 'leg_bye';
      if (isLegal) _currentBallInOver++;

      final overNo = state.totalOvers.toInt();
      final ballNo = _currentBallInOver;

      final ball = BallEntry(
        matchId: state.matchId!,
        innings: state.innings,
        overNo: overNo,
        ballNo: ballNo,
        batsmanId: state.striker!.id,
        nonStrikerId: state.nonStriker?.id ?? '',
        bowlerId: state.bowler!.id,
        runs: 0,
        extras: 1 + additionalRuns,
        extrasType: type,
        isLegal: isLegal,
      );

      final result = await _repository.insertBall(ball);
      if (result == null) {
        if (isLegal) _currentBallInOver--;
        state = state.copyWith(error: 'Failed to save extra ball');
        return;
      }

      final extraRuns = 1 + additionalRuns;
      final newTotalRuns = state.totalRuns + extraRuns;
      final isOverComplete = isLegal && _currentBallInOver >= 6;
      // Display overs: /10 convention
      final newOvers = isOverComplete
          ? (overNo + 1).toDouble()
          : isLegal
              ? overNo + (_currentBallInOver / 10.0)
              : state.totalOvers;
      // Arithmetic overs: /6 for rate calculations
      final totalLegalBalls = isLegal
          ? (overNo * 6) + _currentBallInOver
          : (overNo * 6) + _currentBallInOver;
      final newOversArithmetic = totalLegalBalls / 6.0;
      final newRunRate =
          newOversArithmetic > 0 ? newTotalRuns / newOversArithmetic : 0.0;

      // Update bowler stats (extras count against bowler for wides/no-balls)
      BowlerState updatedBowler = state.bowler!;
      if (type == 'wide' || type == 'no_ball') {
        updatedBowler = updatedBowler.copyWith(
          runsConceded: updatedBowler.runsConceded + extraRuns,
        );
      }
      if (isLegal) {
        final newBowlerOvers = isOverComplete
            ? (updatedBowler.overs.toInt() + 1).toDouble()
            : updatedBowler.overs.toInt() + (_currentBallInOver / 10.0);
        final bowlerLegalBalls =
            (updatedBowler.overs.toInt() * 6) + _currentBallInOver;
        final bowlerOversArithmetic = bowlerLegalBalls / 6.0;
        updatedBowler = updatedBowler.copyWith(
          overs: newBowlerOvers,
          economy: bowlerOversArithmetic > 0
              ? updatedBowler.runsConceded / bowlerOversArithmetic
              : 0.0,
        );
      }

      // Ball description
      String ballDesc;
      switch (type) {
        case 'wide':
          ballDesc = 'Wd${additionalRuns > 0 ? "+$additionalRuns" : ""}';
          break;
        case 'no_ball':
          ballDesc = 'Nb${additionalRuns > 0 ? "+$additionalRuns" : ""}';
          break;
        case 'bye':
          ballDesc = 'B$extraRuns';
          break;
        case 'leg_bye':
          ballDesc = 'Lb$extraRuns';
          break;
        default:
          ballDesc = 'E$extraRuns';
      }
      final lastSix = [...state.lastSixBalls, ballDesc];
      if (lastSix.length > 6) lastSix.removeAt(0);

      // Update batsman balls faced only for legal deliveries
      BatsmanState updatedStriker = state.striker!;
      if (isLegal) {
        updatedStriker = updatedStriker.copyWith(
          balls: updatedStriker.balls + 1,
        );
      }

      state = state.copyWith(
        totalRuns: newTotalRuns,
        totalOvers: newOvers,
        currentRunRate: newRunRate,
        striker: updatedStriker,
        bowler: updatedBowler,
        lastSixBalls: lastSix,
        isOverComplete: isOverComplete,
        clearError: true,
      );

      // Persist to match table
      await _repository.updateMatchScore(state.matchId!, {
        if (state.innings == 1) 'current_score_a': '$newTotalRuns/${state.totalWickets}',
        if (state.innings == 2) 'current_score_b': '$newTotalRuns/${state.totalWickets}',
        'current_over': newOvers,
      });

      // Update bowler scoreboard
      await _repository.updateBowlerStats(state.matchId!, state.bowler!.id, {
        'overs_bowled': updatedBowler.overs,
        'economy': updatedBowler.economy,
      });

      debugPrint('Ball Saved: extra $type +$extraRuns');

      if (isOverComplete) {
        _currentBallInOver = 0;
      }
    } catch (e) {
      debugPrint('ScoringNotifier recordExtra error: $e');
      state = state.copyWith(error: 'Failed to record extra: $e');
    } finally {
      _isBusy = false;
    }
  }

  /// Record a wicket.
  Future<void> recordWicket(
    String dismissalType, {
    String? dismissedPlayerId,
    int runsCompleted = 0,
    String? fielderId,
  }) async {
    if (_isBusy) return;
    if (state.matchId == null || state.striker == null || state.bowler == null) {
      state = state.copyWith(
          error: 'Cannot record wicket: match, striker, or bowler not set');
      return;
    }

    _isBusy = true;
    try {
      _currentBallInOver++;
      final overNo = state.totalOvers.toInt();
      final ballNo = _currentBallInOver;

      final dismissedId = dismissedPlayerId ?? state.striker!.id;

      final ball = BallEntry(
        matchId: state.matchId!,
        innings: state.innings,
        overNo: overNo,
        ballNo: ballNo,
        batsmanId: state.striker!.id,
        nonStrikerId: state.nonStriker?.id ?? '',
        bowlerId: state.bowler!.id,
        runs: runsCompleted,
        isWicket: true,
        dismissalType: dismissalType,
        dismissedPlayerId: dismissedId,
        fielderId: fielderId,
        isLegal: true,
      );

      final result = await _repository.insertBall(ball);
      if (result == null) {
        _currentBallInOver--;
        state = state.copyWith(error: 'Failed to save wicket ball');
        return;
      }

      final newTotalRuns = state.totalRuns + runsCompleted;
      final newWickets = state.totalWickets + 1;
      final isOverComplete = _currentBallInOver >= 6;
      // Display overs: /10 convention
      final newOvers = isOverComplete
          ? (overNo + 1).toDouble()
          : overNo + (_currentBallInOver / 10.0);
      // Arithmetic overs: /6 for rate calculations
      final totalLegalBalls = (overNo * 6) + _currentBallInOver;
      final newOversArithmetic = totalLegalBalls / 6.0;
      final newRunRate =
          newOversArithmetic > 0 ? newTotalRuns / newOversArithmetic : 0.0;

      // Check if innings is complete (10 wickets or 20 overs)
      final isInningsComplete =
          newWickets >= 10 || newOversArithmetic >= 20.0;

      // Update bowler
      final newBowlerOvers = isOverComplete
          ? (state.bowler!.overs.toInt() + 1).toDouble()
          : state.bowler!.overs.toInt() + (_currentBallInOver / 10.0);
      final bowlerLegalBalls =
          (state.bowler!.overs.toInt() * 6) + _currentBallInOver;
      final bowlerOversArithmetic = bowlerLegalBalls / 6.0;
      final updatedBowler = state.bowler!.copyWith(
        wickets: state.bowler!.wickets + 1,
        runsConceded: state.bowler!.runsConceded + runsCompleted,
        overs: newBowlerOvers,
        economy: bowlerOversArithmetic > 0
            ? (state.bowler!.runsConceded + runsCompleted) /
                bowlerOversArithmetic
            : 0.0,
      );

      // Fall of wicket
      final fow = FallOfWicket(
        wicketNumber: newWickets,
        score: newTotalRuns,
        overs: newOvers,
        playerId: dismissedId,
        playerName: dismissedId == state.striker!.id
            ? state.striker!.name
            : (state.nonStriker?.name ?? ''),
      );
      final updatedFOW = [...state.fallOfWickets, fow];

      // Ball description
      final ballDesc = 'W${runsCompleted > 0 ? "+$runsCompleted" : ""}';
      final lastSix = [...state.lastSixBalls, ballDesc];
      if (lastSix.length > 6) lastSix.removeAt(0);

      // Update striker balls faced
      final updatedStriker = state.striker!.copyWith(
        runs: state.striker!.runs + runsCompleted,
        balls: state.striker!.balls + 1,
      );

      state = state.copyWith(
        totalRuns: newTotalRuns,
        totalWickets: newWickets,
        totalOvers: newOvers,
        currentRunRate: newRunRate,
        striker: updatedStriker,
        bowler: updatedBowler,
        fallOfWickets: updatedFOW,
        lastSixBalls: lastSix,
        isOverComplete: isOverComplete,
        isInningsComplete: isInningsComplete,
        partnership: const Partnership(),
        clearError: true,
      );

      // Persist to match table
      await _repository.updateMatchScore(state.matchId!, {
        if (state.innings == 1) 'current_score_a': '$newTotalRuns/$newWickets',
        if (state.innings == 1) 'current_wickets_a': newWickets,
        if (state.innings == 2) 'current_score_b': '$newTotalRuns/$newWickets',
        if (state.innings == 2) 'current_wickets_b': newWickets,
        'current_over': newOvers,
      });

      // Update bowler scoreboard
      await _repository.updateBowlerStats(state.matchId!, state.bowler!.id, {
        'wickets': updatedBowler.wickets,
        'overs_bowled': updatedBowler.overs,
        'economy': updatedBowler.economy,
      });

      // Fantasy points for bowler (wicket bonus - delta only)
      await _repository.updateFantasyPoints(
          state.matchId!, state.bowler!.id, FantasyPoints.wicket);

      // Fantasy points for fielder (catch or run out - delta only)
      if (fielderId != null) {
        double fielderPoints = 0;
        if (dismissalType == 'caught') {
          fielderPoints = FantasyPoints.catchPoints;
        } else if (dismissalType == 'run_out') {
          fielderPoints = FantasyPoints.runOut;
        }
        if (fielderPoints > 0) {
          await _repository.updateFantasyPoints(
              state.matchId!, fielderId, fielderPoints);
        }
      }

      // Update batsman scoreboard
      await _repository.updateScoreboard(state.matchId!, dismissedId, {
        'runs': updatedStriker.runs,
        'balls_faced': updatedStriker.balls,
        'fours': updatedStriker.fours,
        'sixes': updatedStriker.sixes,
        'strike_rate': updatedStriker.strikeRate,
      });

      debugPrint('Ball Saved: WICKET $dismissalType');

      if (isOverComplete) {
        _currentBallInOver = 0;
      }
    } catch (e) {
      debugPrint('ScoringNotifier recordWicket error: $e');
      state = state.copyWith(error: 'Failed to record wicket: $e');
    } finally {
      _isBusy = false;
    }
  }

  /// Undo the last ball delivered.
  Future<void> undoLastBall() async {
    if (_isBusy) return;
    if (state.matchId == null) {
      state = state.copyWith(error: 'Cannot undo: no match initialized');
      return;
    }

    _isBusy = true;
    try {
      final undone =
          await _repository.undoLastBall(state.matchId!, state.innings);
      if (undone == null) {
        state = state.copyWith(error: 'No ball to undo');
        return;
      }

      // Recalculate state from remaining balls
      final inningsData =
          await _repository.getInningsState(state.matchId!, state.innings);

      int totalRuns = 0;
      int totalWickets = 0;
      double overs = 0.0;

      if (inningsData != null) {
        totalRuns = inningsData['total_runs'] as int? ?? 0;
        totalWickets = inningsData['total_wickets'] as int? ?? 0;
        overs = (inningsData['overs'] as num?)?.toDouble() ?? 0.0;
        final legalBalls = inningsData['legal_balls'] as int? ?? 0;
        _currentBallInOver = legalBalls % 6;

        // Recalculate per-player stats from remaining ball records
        final ballsData = inningsData['balls'] as List<dynamic>? ?? [];
        final balls = ballsData
            .map((b) => BallEntry.fromJson(Map<String, dynamic>.from(b as Map)))
            .toList();

        // Recalculate arithmetic overs for run rate
        final oversArithmetic = legalBalls / 6.0;
        final runRate =
            oversArithmetic > 0 ? totalRuns / oversArithmetic : 0.0;

        // Rebuild striker stats if striker is set
        BatsmanState? updatedStriker = state.striker;
        if (state.striker != null) {
          int sRuns = 0, sBalls = 0, sFours = 0, sSixes = 0;
          for (final b in balls) {
            if (b.batsmanId == state.striker!.id && b.isLegal) {
              sBalls++;
              sRuns += b.runs;
              if (b.runs == 4) sFours++;
              if (b.runs == 6) sSixes++;
            }
          }
          updatedStriker = state.striker!.copyWith(
            runs: sRuns,
            balls: sBalls,
            fours: sFours,
            sixes: sSixes,
          );
        }

        // Rebuild non-striker stats if set
        BatsmanState? updatedNonStriker = state.nonStriker;
        if (state.nonStriker != null) {
          int nsRuns = 0, nsBalls = 0, nsFours = 0, nsSixes = 0;
          for (final b in balls) {
            if (b.batsmanId == state.nonStriker!.id && b.isLegal) {
              nsBalls++;
              nsRuns += b.runs;
              if (b.runs == 4) nsFours++;
              if (b.runs == 6) nsSixes++;
            }
          }
          updatedNonStriker = state.nonStriker!.copyWith(
            runs: nsRuns,
            balls: nsBalls,
            fours: nsFours,
            sixes: nsSixes,
          );
        }

        // Rebuild bowler stats if set
        BowlerState? updatedBowler = state.bowler;
        if (state.bowler != null) {
          int bRunsConceded = 0, bWickets = 0, bLegalBalls = 0;
          for (final b in balls) {
            if (b.bowlerId == state.bowler!.id) {
              if (b.isLegal) bLegalBalls++;
              bRunsConceded += b.runs + b.extras;
              if (b.isWicket) bWickets++;
            }
          }
          final bOversInt = bLegalBalls ~/ 6;
          final bBallsInOver = bLegalBalls % 6;
          final bOversDisplay =
              bOversInt + (bBallsInOver / 10.0);
          final bOversArithmetic = bLegalBalls / 6.0;
          updatedBowler = state.bowler!.copyWith(
            runsConceded: bRunsConceded,
            wickets: bWickets,
            overs: bOversDisplay,
            economy: bOversArithmetic > 0
                ? bRunsConceded / bOversArithmetic
                : 0.0,
          );
        }

        // Remove last entry from lastSixBalls
        final lastSix = [...state.lastSixBalls];
        if (lastSix.isNotEmpty) lastSix.removeLast();

        state = state.copyWith(
          totalRuns: totalRuns,
          totalWickets: totalWickets,
          totalOvers: overs,
          currentRunRate: runRate,
          striker: updatedStriker,
          nonStriker: updatedNonStriker,
          bowler: updatedBowler,
          lastSixBalls: lastSix,
          isOverComplete: false,
          isInningsComplete: false,
          clearError: true,
        );

        // Persist updated score to match table
        await _repository.updateMatchScore(state.matchId!, {
          if (state.innings == 1) 'current_score_a': '$totalRuns/$totalWickets',
          if (state.innings == 1) 'current_wickets_a': totalWickets,
          if (state.innings == 2) 'current_score_b': '$totalRuns/$totalWickets',
          if (state.innings == 2) 'current_wickets_b': totalWickets,
          'current_over': overs,
        });

        // Update scoreboard rows for affected players
        if (updatedStriker != null) {
          await _repository.updateScoreboard(
              state.matchId!, updatedStriker.id, {
            'runs': updatedStriker.runs,
            'balls_faced': updatedStriker.balls,
            'fours': updatedStriker.fours,
            'sixes': updatedStriker.sixes,
            'strike_rate': updatedStriker.strikeRate,
          });
          // Recalculate and set absolute fantasy points for batsman
          double batsmanFantasy =
              updatedStriker.runs * FantasyPoints.perRun;
          batsmanFantasy += updatedStriker.fours * FantasyPoints.fourBonus;
          batsmanFantasy += updatedStriker.sixes * FantasyPoints.sixBonus;
          await _repository.setFantasyPoints(
              state.matchId!, updatedStriker.id, batsmanFantasy);
        }

        if (updatedNonStriker != null) {
          await _repository.updateScoreboard(
              state.matchId!, updatedNonStriker.id, {
            'runs': updatedNonStriker.runs,
            'balls_faced': updatedNonStriker.balls,
            'fours': updatedNonStriker.fours,
            'sixes': updatedNonStriker.sixes,
            'strike_rate': updatedNonStriker.strikeRate,
          });
        }

        if (updatedBowler != null) {
          await _repository.updateBowlerStats(
              state.matchId!, updatedBowler.id, {
            'wickets': updatedBowler.wickets,
            'overs_bowled': updatedBowler.overs,
            'economy': updatedBowler.economy,
          });
          // Recalculate and set absolute fantasy points for bowler
          final bowlerFantasy =
              updatedBowler.wickets * FantasyPoints.wicket;
          await _repository.setFantasyPoints(
              state.matchId!, updatedBowler.id, bowlerFantasy);
        }
      } else {
        _currentBallInOver = 0;

        // Remove last entry from lastSixBalls
        final lastSix = [...state.lastSixBalls];
        if (lastSix.isNotEmpty) lastSix.removeLast();

        state = state.copyWith(
          totalRuns: totalRuns,
          totalWickets: totalWickets,
          totalOvers: overs,
          currentRunRate: 0.0,
          lastSixBalls: lastSix,
          isOverComplete: false,
          isInningsComplete: false,
          clearError: true,
        );

        await _repository.updateMatchScore(state.matchId!, {
          if (state.innings == 1) 'current_score_a': '$totalRuns/$totalWickets',
          if (state.innings == 1) 'current_wickets_a': totalWickets,
          if (state.innings == 2) 'current_score_b': '$totalRuns/$totalWickets',
          if (state.innings == 2) 'current_wickets_b': totalWickets,
          'current_over': overs,
        });
      }

      debugPrint(
          'Ball Undone: reverted to $totalRuns/$totalWickets ($overs ov)');
    } catch (e) {
      debugPrint('ScoringNotifier undoLastBall error: $e');
      state = state.copyWith(error: 'Failed to undo last ball: $e');
    } finally {
      _isBusy = false;
    }
  }

  /// Change the current bowler.
  void changeBowler(String playerId) {
    // Find player from team lists
    Map<String, dynamic>? playerData;
    for (final p in [...state.teamAPlayers, ...state.teamBPlayers]) {
      if (p['id'] == playerId) {
        playerData = p;
        break;
      }
    }

    if (playerData == null) {
      state = state.copyWith(error: 'Player not found for bowler change');
      return;
    }

    final newBowler = BowlerState(
      id: playerId,
      name: playerData['name'] as String? ?? 'Unknown',
    );

    state = state.copyWith(bowler: newBowler, isOverComplete: false, clearError: true);
    _currentBallInOver = 0;
    debugPrint('Bowler Updated: ${newBowler.name}');
  }

  /// Swap striker and non-striker.
  void changeStriker() {
    if (state.striker == null || state.nonStriker == null) {
      state = state.copyWith(error: 'Cannot swap: both batsmen must be set');
      return;
    }

    state = state.copyWith(
      striker: state.nonStriker,
      nonStriker: state.striker,
      clearError: true,
    );
    debugPrint('Batsman Updated: striker swapped');
  }

  /// End the current over - swap striker/non-striker, require new bowler.
  void endOver() {
    if (state.striker != null && state.nonStriker != null) {
      state = state.copyWith(
        striker: state.nonStriker,
        nonStriker: state.striker,
        isOverComplete: true,
        clearBowler: true,
        clearError: true,
      );
    } else {
      state = state.copyWith(
        isOverComplete: true,
        clearBowler: true,
        clearError: true,
      );
    }
    _currentBallInOver = 0;
    debugPrint('Over ended. Awaiting new bowler.');
  }

  /// End the current innings and prepare for next.
  void endInnings() {
    final firstInningsScore = state.totalRuns;

    state = ScoringState(
      matchId: state.matchId,
      innings: 2,
      target: firstInningsScore + 1,
      teamAPlayers: state.teamAPlayers,
      teamBPlayers: state.teamBPlayers,
      tossWinner: state.tossWinner,
      electedTo: state.electedTo,
      matchInfo: state.matchInfo,
    );
    _currentBallInOver = 0;
    debugPrint('Innings ended. Target: ${firstInningsScore + 1}');
  }

  /// Handle a batsman retiring hurt.
  void retiredHurt(String playerId) {
    if (state.striker?.id == playerId) {
      state = state.copyWith(clearStriker: true, clearError: true);
      debugPrint('Batsman Updated: striker retired hurt');
    } else if (state.nonStriker?.id == playerId) {
      state = state.copyWith(clearNonStriker: true, clearError: true);
      debugPrint('Batsman Updated: non-striker retired hurt');
    } else {
      state = state.copyWith(error: 'Player not currently batting');
    }
  }

  /// Award penalty runs to a team.
  Future<void> penaltyRuns(int runs, String team) async {
    if (state.matchId == null) {
      state = state.copyWith(error: 'Cannot award penalty: no match');
      return;
    }

    final newTotal = state.totalRuns + runs;
    state = state.copyWith(
      totalRuns: newTotal,
      clearError: true,
    );

    await _repository.updateMatchScore(state.matchId!, {
      if (state.innings == 1) 'current_score_a': '$newTotal/${state.totalWickets}',
      if (state.innings == 2) 'current_score_b': '$newTotal/${state.totalWickets}',
    });

    debugPrint('Score Updated: penalty $runs runs to $team');
  }

  /// Set the current striker batsman.
  void setStriker(String playerId, String playerName) {
    final batsman = BatsmanState(id: playerId, name: playerName);
    state = state.copyWith(striker: batsman, clearError: true);
    debugPrint('Batsman Updated: striker set to $playerName');
  }

  /// Set the current non-striker batsman.
  void setNonStriker(String playerId, String playerName) {
    final batsman = BatsmanState(id: playerId, name: playerName);
    state = state.copyWith(nonStriker: batsman, clearError: true);
    debugPrint('Batsman Updated: non-striker set to $playerName');
  }

  /// Set the toss information.
  void setTossInfo(String winner, String elected) {
    state = state.copyWith(tossWinner: winner, electedTo: elected);
  }

  /// Set the match info map.
  void setMatchInfo(Map<String, dynamic> info) {
    state = state.copyWith(matchInfo: info);
  }
}

/// Provider for the scoring notifier.
final scoringProvider =
    StateNotifierProvider<ScoringNotifier, ScoringState>((ref) {
  final repository = ref.watch(scoringRepositoryProvider);
  return ScoringNotifier(repository);
});

