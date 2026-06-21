import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_nav_drawer.dart';

class AdminScoreboardScreen extends ConsumerStatefulWidget {
  const AdminScoreboardScreen({super.key});

  @override
  ConsumerState<AdminScoreboardScreen> createState() =>
      _AdminScoreboardScreenState();
}

class _AdminScoreboardScreenState
    extends ConsumerState<AdminScoreboardScreen> {
  bool _loading = false;
  List<Map<String, dynamic>> _matches = [];
  List<Map<String, dynamic>> _scoreboard = [];
  String? _selectedMatchId;

  // Toss fields
  String? _tossWinner;
  bool _batFirst = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMatches());
  }

  Future<void> _loadMatches() async {
    await ref.read(adminProvider.notifier).loadMatches();
    final s = ref.read(adminProvider);
    setState(() {
      _matches = s.matches;
    });
  }

  Future<void> _loadScoreboard() async {
    if (_selectedMatchId == null) return;
    setState(() => _loading = true);
    try {
      await ref.read(adminProvider.notifier).loadScoreboard(_selectedMatchId!);
      final s = ref.read(adminProvider);
      setState(() {
        _scoreboard = s.scoreboard;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _scoreboard = [];
        _loading = false;
      });
    }
  }

  double _calcFantasyPoints(Map<String, dynamic> entry) {
    final runs = (entry['runs'] as num?)?.toDouble() ?? 0;
    final fours = (entry['fours'] as num?)?.toDouble() ?? 0;
    final sixes = (entry['sixes'] as num?)?.toDouble() ?? 0;
    final wickets = (entry['wickets'] as num?)?.toDouble() ?? 0;
    final catches = (entry['catches'] as num?)?.toDouble() ?? 0;
    final stumpings = (entry['stumpings'] as num?)?.toDouble() ?? 0;
    final runOuts = (entry['run_outs'] as num?)?.toDouble() ?? 0;

    double points = 0;
    points += runs * 1;
    points += fours * 1;
    points += sixes * 2;
    points += wickets * 25;
    points += catches * 8;
    points += stumpings * 12;
    points += runOuts * 6;

    return points;
  }

  double _calcStrikeRate(num runs, num balls) {
    if (balls == 0) return 0;
    return (runs / balls) * 100;
  }

  double _calcEconomy(num runsConceded, num oversBowled) {
    if (oversBowled == 0) return 0;
    return runsConceded / oversBowled;
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    double totalRuns = 0;
    double totalOvers = 0;
    int totalWickets = 0;

    for (final entry in _scoreboard) {
      totalRuns += (entry['runs'] as num?)?.toDouble() ?? 0;
      totalOvers += (entry['overs'] as num?)?.toDouble() ?? 0;
      totalWickets += (entry['wickets'] as num?)?.toInt() ?? 0;
    }

    final currentRunRate = totalOvers > 0 ? totalRuns / totalOvers : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const AdminNavDrawer(currentRoute: '/admin/scoreboard'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF0F172A)),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text(
          'Scoreboard',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0F172A)),
            onPressed: _loadScoreboard,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Match dropdown
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: DropdownButtonFormField<String>(
                value: _selectedMatchId,
                decoration: const InputDecoration(
                  labelText: 'Select Match',
                  border: OutlineInputBorder(),
                ),
                items: _matches
                    .map((m) => DropdownMenuItem<String>(
                          value: m['id'] as String,
                          child: Text(
                            '${m['team_a_name'] ?? '-'} vs ${m['team_b_name'] ?? '-'}',
                          ),
                        ))
                    .toList(),
                onChanged: (v) {
                  setState(() => _selectedMatchId = v);
                  _loadScoreboard();
                },
              ),
            ),

            if (_selectedMatchId != null) ...[
              // Toss section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Toss',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _tossWinner,
                          decoration: const InputDecoration(
                            labelText: 'Toss Winner',
                            border: OutlineInputBorder(),
                          ),
                          items: _getTeamNames()
                              .map((name) => DropdownMenuItem(
                                    value: name,
                                    child: Text(name),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _tossWinner = v),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          title: const Text('Bat First'),
                          value: _batFirst,
                          onChanged: (v) =>
                              setState(() => _batFirst = v),
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Stats summary
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Match Stats',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _statRow('Current Run Rate',
                            currentRunRate.toStringAsFixed(2)),
                        _statRow(
                            'Total Runs', totalRuns.toStringAsFixed(0)),
                        _statRow(
                            'Total Overs', totalOvers.toStringAsFixed(1)),
                        _statRow('Total Wickets', '$totalWickets'),
                      ],
                    ),
                  ),
                ),
              ),

              // Add score entry button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: _showAddScoreDialog,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    '+ Add Score Entry',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              // Player scores list
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFE11D48),
                    ),
                  ),
                )
              else if (_scoreboard.isEmpty)
                _buildEmpty()
              else
                ..._scoreboard
                    .map((entry) => _buildScoreCard(entry))
                    .toList(),
            ] else
              _buildEmpty(),
          ],
        ),
      ),
    );
  }

  List<String> _getTeamNames() {
    if (_selectedMatchId == null) return [];
    final match = _matches.firstWhere(
      (m) => m['id'] == _selectedMatchId,
      orElse: () => <String, dynamic>{},
    );
    final teamA = match['team_a_name'] as String? ?? 'Team A';
    final teamB = match['team_b_name'] as String? ?? 'Team B';
    return [teamA, teamB];
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B))),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.scoreboard,
                size: 64,
                color: Color(0xFFE11D48),
              ),
              const SizedBox(height: 16),
              Text(
                _selectedMatchId == null
                    ? 'No Scoreboard Entries Found'
                    : 'No Scoreboard Entries Found',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 20),
              ),
            ],
          ),
        ),
      );

  Widget _buildScoreCard(Map<String, dynamic> entry) {
    final player = entry['player'] as Map<String, dynamic>?;
    final playerName = player?['name'] ?? 'Unknown';
    final playerRole = player?['role'] ?? '';
    final runs = (entry['runs'] as num?)?.toInt() ?? 0;
    final balls = (entry['balls_faced'] as num?)?.toInt() ?? 0;
    final wickets = (entry['wickets'] as num?)?.toInt() ?? 0;
    final overs = (entry['overs'] as num?)?.toDouble() ?? 0;
    final fours = (entry['fours'] as num?)?.toInt() ?? 0;
    final sixes = (entry['sixes'] as num?)?.toInt() ?? 0;
    final strikeRate = _calcStrikeRate(runs, balls);
    final economy = _calcEconomy(
      (entry['runs_conceded'] as num?)?.toDouble() ?? 0,
      overs,
    );
    final fantasyPoints = _calcFantasyPoints(entry);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  playerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE11D48).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${fantasyPoints.toStringAsFixed(0)} pts',
                    style: const TextStyle(
                      color: Color(0xFFE11D48),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (playerRole.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  playerRole,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _miniStat('R', '$runs'),
                _miniStat('B', '$balls'),
                _miniStat('4s', '$fours'),
                _miniStat('6s', '$sixes'),
                _miniStat('W', '$wickets'),
                _miniStat('Ov', overs.toStringAsFixed(1)),
                _miniStat('SR', strikeRate.toStringAsFixed(1)),
                _miniStat('Eco', economy.toStringAsFixed(2)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
        ),
      ],
    );
  }

  void _showAddScoreDialog() {
    final runsCtrl = TextEditingController(text: '0');
    final wicketsCtrl = TextEditingController(text: '0');
    final oversCtrl = TextEditingController(text: '0');
    final ballsCtrl = TextEditingController(text: '0');
    final extrasCtrl = TextEditingController(text: '0');
    final foursCtrl = TextEditingController(text: '0');
    final sixesCtrl = TextEditingController(text: '0');
    final runsConcededCtrl = TextEditingController(text: '0');
    final catchesCtrl = TextEditingController(text: '0');
    final stumpingsCtrl = TextEditingController(text: '0');
    final runOutsCtrl = TextEditingController(text: '0');
    String? selectedPlayerId;

    final players = _scoreboard
        .where((e) => e['player'] != null)
        .map((e) => {
              'id': e['player_id'],
              'name': (e['player'] as Map)['name'],
            })
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text(
            'Add Score Entry',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (players.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: selectedPlayerId,
                    decoration: const InputDecoration(
                      labelText: 'Player',
                      border: OutlineInputBorder(),
                    ),
                    items: players
                        .map((p) => DropdownMenuItem<String>(
                              value: p['id'] as String?,
                              child: Text(p['name']?.toString() ?? '-'),
                            ))
                        .toList(),
                    onChanged: (v) => setS(() => selectedPlayerId = v),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: runsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Runs',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: wicketsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Wickets',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: oversCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Overs (e.g. 4.2)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ballsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Balls Faced',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: extrasCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Extras',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: foursCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Fours (4s)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: sixesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Sixes (6s)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: runsConcededCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Runs Conceded',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: catchesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Catches',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stumpingsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stumpings',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: runOutsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Run Outs',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () async {
                if (selectedPlayerId == null && players.isNotEmpty) return;
                Navigator.pop(ctx);

                final runs = int.tryParse(runsCtrl.text) ?? 0;
                final fours = int.tryParse(foursCtrl.text) ?? 0;
                final sixes = int.tryParse(sixesCtrl.text) ?? 0;
                final wickets = int.tryParse(wicketsCtrl.text) ?? 0;
                final catches = int.tryParse(catchesCtrl.text) ?? 0;
                final stumpings = int.tryParse(stumpingsCtrl.text) ?? 0;
                final runOuts = int.tryParse(runOutsCtrl.text) ?? 0;

                final pts = _calcFantasyPoints({
                  'runs': runs,
                  'fours': fours,
                  'sixes': sixes,
                  'wickets': wickets,
                  'catches': catches,
                  'stumpings': stumpings,
                  'run_outs': runOuts,
                });

                final data = <String, dynamic>{
                  'match_id': _selectedMatchId,
                  'player_id': selectedPlayerId,
                  'runs': runs,
                  'wickets': wickets,
                  'overs': double.tryParse(oversCtrl.text) ?? 0,
                  'balls_faced': int.tryParse(ballsCtrl.text) ?? 0,
                  'extras': int.tryParse(extrasCtrl.text) ?? 0,
                  'fours': fours,
                  'sixes': sixes,
                  'runs_conceded':
                      int.tryParse(runsConcededCtrl.text) ?? 0,
                  'catches': catches,
                  'stumpings': stumpings,
                  'run_outs': runOuts,
                  'points': pts,
                };

                final ok = await ref
                    .read(adminProvider.notifier)
                    .upsertScoreboard(data);
                if (ok) {
                  _loadScoreboard();
                  _snack('Score entry saved!');
                } else {
                  _snack('Could not save score entry');
                }
              },
              child:
                  const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
