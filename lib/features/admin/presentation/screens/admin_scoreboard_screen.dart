import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/admin_provider.dart';
import '../../domain/providers/scoring_provider.dart';
import '../widgets/admin_nav_drawer.dart';
import '../widgets/scoring/advanced_actions_widget.dart';
import '../widgets/scoring/batsman_section_widget.dart';
import '../widgets/scoring/bowler_section_widget.dart';
import '../widgets/scoring/extras_buttons_widget.dart';
import '../widgets/scoring/last_balls_widget.dart';
import '../widgets/scoring/live_scorecard_widget.dart';
import '../widgets/scoring/match_header_widget.dart';
import '../widgets/scoring/run_buttons_widget.dart';
import '../widgets/scoring/select_batsman_dialog.dart';
import '../widgets/scoring/select_bowler_dialog.dart';
import '../widgets/scoring/wicket_buttons_widget.dart';

class AdminScoreboardScreen extends ConsumerStatefulWidget {
  const AdminScoreboardScreen({super.key});

  @override
  ConsumerState<AdminScoreboardScreen> createState() =>
      _AdminScoreboardScreenState();
}

class _AdminScoreboardScreenState
    extends ConsumerState<AdminScoreboardScreen> {
  String? _selectedMatchId;
  List<Map<String, dynamic>> _matches = [];
  bool _matchInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMatches());
  }

  Future<void> _loadMatches() async {
    await ref.read(adminProvider.notifier).loadMatches();
    final s = ref.read(adminProvider);
    if (mounted) {
      setState(() {
        _matches = s.matches;
      });
    }
  }

  Future<void> _initMatch(String matchId) async {
    setState(() {
      _selectedMatchId = matchId;
      _matchInitialized = false;
    });
    await ref.read(scoringProvider.notifier).initMatch(matchId);
    if (mounted) {
      setState(() => _matchInitialized = true);
    }
  }

  String _getTeamAName() {
    if (_selectedMatchId == null) return 'Team A';
    final match = _matches.firstWhere(
      (m) => m['id'] == _selectedMatchId,
      orElse: () => <String, dynamic>{},
    );
    return match['team_a_name'] as String? ?? 'Team A';
  }

  String _getTeamBName() {
    if (_selectedMatchId == null) return 'Team B';
    final match = _matches.firstWhere(
      (m) => m['id'] == _selectedMatchId,
      orElse: () => <String, dynamic>{},
    );
    return match['team_b_name'] as String? ?? 'Team B';
  }

  String? _getTournamentName() {
    if (_selectedMatchId == null) return null;
    final match = _matches.firstWhere(
      (m) => m['id'] == _selectedMatchId,
      orElse: () => <String, dynamic>{},
    );
    return match['tournament_name'] as String?;
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFF44336),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleRunTapped(int runs) {
    final scoring = ref.read(scoringProvider);
    if (scoring.striker == null) {
      _showSelectStrikerDialog();
      return;
    }
    if (scoring.bowler == null) {
      _showSelectBowlerDialog();
      return;
    }
    ref.read(scoringProvider.notifier).recordRun(runs);
  }

  void _handleExtraTapped(String type, int additionalRuns) {
    final scoring = ref.read(scoringProvider);
    if (scoring.striker == null) {
      _showSelectStrikerDialog();
      return;
    }
    if (scoring.bowler == null) {
      _showSelectBowlerDialog();
      return;
    }
    ref.read(scoringProvider.notifier).recordExtra(type, additionalRuns);
  }

  void _handleWicketTapped(String dismissalType) {
    final scoring = ref.read(scoringProvider);
    if (scoring.striker == null) {
      _showSelectStrikerDialog();
      return;
    }
    if (scoring.bowler == null) {
      _showSelectBowlerDialog();
      return;
    }

    // For caught and run out, show fielder selection first
    if (dismissalType == 'caught' || dismissalType == 'run_out') {
      _showFielderSelectionDialog(dismissalType);
    } else {
      ref
          .read(scoringProvider.notifier)
          .recordWicket(dismissalType)
          .then((_) => _promptNextBatsman());
    }
  }

  void _showFielderSelectionDialog(String dismissalType) {
    final scoring = ref.read(scoringProvider);
    // Fielding team players (opposite of batting team)
    final fieldingPlayers = scoring.innings == 1
        ? scoring.teamBPlayers
        : scoring.teamAPlayers;

    SelectBowlerDialog.show(
      context: context,
      players: fieldingPlayers,
      title: 'Select Fielder',
      onSelected: (fielderId, _) {
        ref
            .read(scoringProvider.notifier)
            .recordWicket(dismissalType, fielderId: fielderId)
            .then((_) => _promptNextBatsman());
      },
    );
  }

  void _promptNextBatsman() {
    final scoring = ref.read(scoringProvider);
    if (scoring.isInningsComplete) return;

    // Get batting team players
    final battingPlayers = scoring.innings == 1
        ? scoring.teamAPlayers
        : scoring.teamBPlayers;

    if (battingPlayers.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      SelectBatsmanDialog.show(
        context: context,
        players: battingPlayers,
        title: 'Select Next Batsman',
        onSelected: (playerId, playerName) {
          ref.read(scoringProvider.notifier).setStriker(playerId, playerName);
        },
      );
    });
  }

  void _showSelectStrikerDialog() {
    final scoring = ref.read(scoringProvider);
    final battingPlayers = scoring.innings == 1
        ? scoring.teamAPlayers
        : scoring.teamBPlayers;

    SelectBatsmanDialog.show(
      context: context,
      players: battingPlayers,
      title: 'Select Striker',
      onSelected: (playerId, playerName) {
        ref.read(scoringProvider.notifier).setStriker(playerId, playerName);
      },
    );
  }

  void _showSelectNonStrikerDialog() {
    final scoring = ref.read(scoringProvider);
    final battingPlayers = scoring.innings == 1
        ? scoring.teamAPlayers
        : scoring.teamBPlayers;

    SelectBatsmanDialog.show(
      context: context,
      players: battingPlayers,
      title: 'Select Non-Striker',
      onSelected: (playerId, playerName) {
        ref.read(scoringProvider.notifier).setNonStriker(playerId, playerName);
      },
    );
  }

  void _showSelectBowlerDialog() {
    final scoring = ref.read(scoringProvider);
    // Bowling team is opposite of batting team
    final bowlingPlayers = scoring.innings == 1
        ? scoring.teamBPlayers
        : scoring.teamAPlayers;

    SelectBowlerDialog.show(
      context: context,
      players: bowlingPlayers,
      title: 'Select Bowler',
      onSelected: (playerId, playerName) {
        ref.read(scoringProvider.notifier).changeBowler(playerId);
      },
    );
  }

  void _handleEndOver() {
    ref.read(scoringProvider.notifier).endOver();
    _showSelectBowlerDialog();
  }

  void _handleEndInnings() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'End Innings?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to end this innings?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(scoringProvider.notifier).endInnings();
            },
            child: const Text(
              'End Innings',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRetiredHurt() {
    final scoring = ref.read(scoringProvider);
    final options = <Map<String, String>>[];
    if (scoring.striker != null) {
      options.add({'id': scoring.striker!.id, 'name': scoring.striker!.name});
    }
    if (scoring.nonStriker != null) {
      options.add({
        'id': scoring.nonStriker!.id,
        'name': scoring.nonStriker!.name,
      });
    }

    if (options.isEmpty) {
      _showError('No batsman currently batting');
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Retired Hurt',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((p) {
            return ListTile(
              title: Text(p['name'] ?? ''),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(scoringProvider.notifier).retiredHurt(p['id']!);
                _promptNextBatsman();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _handlePenaltyRuns() {
    final runsCtrl = TextEditingController(text: '5');
    String team = 'batting';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text(
            'Penalty Runs',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: runsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Runs',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: team,
                decoration: const InputDecoration(
                  labelText: 'Awarded To',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'batting', child: Text('Batting')),
                  DropdownMenuItem(value: 'bowling', child: Text('Bowling')),
                ],
                onChanged: (v) => setS(() => team = v ?? 'batting'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                final runs = int.tryParse(runsCtrl.text) ?? 5;
                ref.read(scoringProvider.notifier).penaltyRuns(runs, team);
              },
              child: const Text(
                'Award',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDeclare() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Declare Innings?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to declare this innings?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(scoringProvider.notifier).endInnings();
            },
            child: const Text(
              'Declare',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scoring = ref.watch(scoringProvider);

    // Show error snackbar when state has error
    ref.listen<ScoringState>(scoringProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        _showError(next.error!);
      }
      // Auto-popup bowler dialog when over is complete
      if (next.isOverComplete && prev?.isOverComplete != true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showSelectBowlerDialog();
        });
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const AdminNavDrawer(currentRoute: '/admin/scoreboard'),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E63),
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text(
          'Live Scorer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_matchInitialized && scoring.striker == null)
            IconButton(
              icon: const Icon(Icons.person_add, color: Colors.white),
              onPressed: _showSelectStrikerDialog,
              tooltip: 'Set Striker',
            ),
          if (_matchInitialized && scoring.nonStriker == null)
            IconButton(
              icon: const Icon(Icons.person_add_alt, color: Colors.white),
              onPressed: _showSelectNonStrikerDialog,
              tooltip: 'Set Non-Striker',
            ),
          if (_matchInitialized && scoring.bowler == null)
            IconButton(
              icon: const Icon(Icons.sports_baseball, color: Colors.white),
              onPressed: _showSelectBowlerDialog,
              tooltip: 'Set Bowler',
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(scoring),
    );
  }

  Widget _buildBody(ScoringState scoring) {
    if (_selectedMatchId == null || !_matchInitialized) {
      return _buildMatchSelection();
    }

    if (scoring.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE91E63),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Match Header
          MatchHeaderWidget(
            teamAName: _getTeamAName(),
            teamBName: _getTeamBName(),
            currentInnings: scoring.innings,
            tournamentName: _getTournamentName(),
          ),
          // Live Scorecard
          LiveScorecardWidget(
            totalRuns: scoring.totalRuns,
            totalWickets: scoring.totalWickets,
            totalOvers: scoring.totalOvers,
            currentRunRate: scoring.currentRunRate,
            target: scoring.target,
            requiredRunRate: scoring.requiredRunRate,
            tossWinner: scoring.tossWinner,
            electedTo: scoring.electedTo,
          ),
          // Batsman Section
          BatsmanSectionWidget(
            striker: scoring.striker,
            nonStriker: scoring.nonStriker,
            onSwapStrike: scoring.striker != null && scoring.nonStriker != null
                ? () => ref.read(scoringProvider.notifier).changeStriker()
                : null,
          ),
          // Bowler Section
          BowlerSectionWidget(bowler: scoring.bowler),
          // Last 6 Balls
          LastBallsWidget(lastSixBalls: scoring.lastSixBalls),
          const SizedBox(height: 8),
          // Run Buttons
          RunButtonsWidget(onRunTapped: _handleRunTapped),
          // Extras Buttons
          ExtrasButtonsWidget(onExtraTapped: _handleExtraTapped),
          // Wicket Buttons
          WicketButtonsWidget(onWicketTapped: _handleWicketTapped),
          // Advanced Actions
          AdvancedActionsWidget(
            onUndo: () => ref.read(scoringProvider.notifier).undoLastBall(),
            onChangeBowler: _showSelectBowlerDialog,
            onRetiredHurt: _handleRetiredHurt,
            onPenaltyRuns: _handlePenaltyRuns,
            onEndOver: _handleEndOver,
            onEndInnings: _handleEndInnings,
            onDeclare: _handleDeclare,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMatchSelection() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Icon(
              Icons.sports_cricket,
              size: 72,
              color: Color(0xFFE91E63),
            ),
            const SizedBox(height: 16),
            const Text(
              'Live Cricket Scorer',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a match to start ball-by-ball scoring',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 32),
            DropdownButtonFormField<String>(
              value: _selectedMatchId,
              decoration: InputDecoration(
                labelText: 'Select Match',
                prefixIcon: const Icon(
                  Icons.sports,
                  color: Color(0xFFE91E63),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFFE91E63),
                    width: 2,
                  ),
                ),
              ),
              items: _matches
                  .map((m) => DropdownMenuItem<String>(
                        value: m['id'] as String,
                        child: Text(
                          '${m['team_a_name'] ?? '-'} vs ${m['team_b_name'] ?? '-'}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) _initMatch(v);
              },
            ),
            const SizedBox(height: 24),
            if (_matches.isEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'No matches available. Create a match first.',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
