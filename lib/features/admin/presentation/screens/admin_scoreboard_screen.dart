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

  // Toss and batting
  String? _tossWinner;
  bool _batFirst = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMatches());
  }

  Future<void> _loadMatches() async {
    setState(() => _loading = true);
    try {
      await ref.read(adminProvider.notifier).loadMatches();
      final s = ref.read(adminProvider);
      setState(() {
        _matches = s.matches;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _matches = [];
        _loading = false;
      });
    }
  }

  Future<void> _loadScoreboard(String matchId) async {
    setState(() => _loading = true);
    try {
      await ref.read(adminProvider.notifier).loadScoreboard(matchId);
      final s = ref.read(adminProvider);
      setState(() {
        _scoreboard = s.scoreboard;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _scoreboard = [];
        _loading = false;
      });
    }
  }

  void _showAddScoreDialog() {
    if (_selectedMatchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a match first')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => _AddScoreDialog(
        matchId: _selectedMatchId!,
        onSaved: () => _loadScoreboard(_selectedMatchId!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminNavDrawer(currentRoute: '/admin/scoreboard'),
      appBar: AppBar(
        title: const Text('Scoreboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {
            if (_selectedMatchId != null) {
              _loadScoreboard(_selectedMatchId!);
            } else {
              _loadMatches();
            }
          }),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _showAddScoreDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Score Entry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // Match selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: _selectedMatchId,
              decoration:
                  const InputDecoration(labelText: 'Select Match'),
              items: _matches
                  .map((m) => DropdownMenuItem(
                      value: m['id'] as String,
                      child: Text(
                          '${m['team_a_name'] ?? ''} vs ${m['team_b_name'] ?? ''}')))
                  .toList(),
              onChanged: (v) {
                setState(() => _selectedMatchId = v);
                if (v != null) _loadScoreboard(v);
              },
            ),
          ),
          const SizedBox(height: 8),
          // Toss section
          if (_selectedMatchId != null) _buildTossSection(),
          const Divider(),
          // Match summary
          if (_selectedMatchId != null && _scoreboard.isNotEmpty)
            _buildMatchSummary(),
          // Scoreboard list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _selectedMatchId == null
                    ? _buildSelectMatchPrompt()
                    : _scoreboard.isEmpty
                        ? _buildEmpty()
                        : _buildScoreboardList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectMatchPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.scoreboard_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('Select a match to view scoreboard',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.scoreboard_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No scores recorded yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Add score entries for this match',
              style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildTossSection() {
    final match = _matches.where((m) => m['id'] == _selectedMatchId).toList();
    if (match.isEmpty) return const SizedBox.shrink();
    final teamA = match.first['team_a_name'] as String? ?? 'Team A';
    final teamB = match.first['team_b_name'] as String? ?? 'Team B';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _tossWinner,
              decoration:
                  const InputDecoration(labelText: 'Toss Winner', isDense: true),
              items: [
                DropdownMenuItem(value: teamA, child: Text(teamA)),
                DropdownMenuItem(value: teamB, child: Text(teamB)),
              ],
              onChanged: (v) => setState(() => _tossWinner = v),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bat First', style: TextStyle(fontSize: 12)),
              Switch(
                value: _batFirst,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _batFirst = v),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchSummary() {
    int totalRuns = 0;
    int totalWickets = 0;
    int totalBalls = 0;
    int totalFours = 0;
    int totalSixes = 0;

    for (final entry in _scoreboard) {
      totalRuns += (entry['runs'] as num?)?.toInt() ?? 0;
      totalWickets += (entry['wickets'] as num?)?.toInt() ?? 0;
      totalBalls += (entry['balls_faced'] as num?)?.toInt() ?? 0;
      totalFours += (entry['fours'] as num?)?.toInt() ?? 0;
      totalSixes += (entry['sixes'] as num?)?.toInt() ?? 0;
    }

    final overs = totalBalls ~/ 6;
    final balls = totalBalls % 6;
    final crr = totalBalls > 0 ? (totalRuns / (totalBalls / 6)) : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Score', '$totalRuns/$totalWickets'),
          _statItem('Overs', '$overs.$balls'),
          _statItem('CRR', crr.toStringAsFixed(2)),
          _statItem('4s/6s', '$totalFours/$totalSixes'),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildScoreboardList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _scoreboard.length,
      itemBuilder: (context, index) {
        final entry = _scoreboard[index];
        final player = entry['player'] as Map<String, dynamic>?;
        final playerName = player?['name'] as String? ?? 'Unknown';
        final playerRole =
            (player?['role'] as String? ?? '').toUpperCase();
        final runs = entry['runs'] ?? 0;
        final wickets = entry['wickets'] ?? 0;
        final balls = entry['balls_faced'] ?? 0;
        final fours = entry['fours'] ?? 0;
        final sixes = entry['sixes'] ?? 0;
        final points = entry['points'] ?? 0;
        final sr = balls > 0 ? ((runs as num) / (balls as num) * 100) : 0.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(playerRole.isNotEmpty ? playerRole[0] : '?',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(playerName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text(playerRole,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600)),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('$points pts',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _miniStat('Runs', '$runs'),
                    _miniStat('Balls', '$balls'),
                    _miniStat('4s', '$fours'),
                    _miniStat('6s', '$sixes'),
                    _miniStat('Wkts', '$wickets'),
                    _miniStat('SR', sr.toStringAsFixed(1)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13)),
        Text(label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }
}

class _AddScoreDialog extends ConsumerStatefulWidget {
  final String matchId;
  final VoidCallback onSaved;

  const _AddScoreDialog({required this.matchId, required this.onSaved});

  @override
  ConsumerState<_AddScoreDialog> createState() => _AddScoreDialogState();
}

class _AddScoreDialogState extends ConsumerState<_AddScoreDialog> {
  final _formKey = GlobalKey<FormState>();
  final _runsCtrl = TextEditingController(text: '0');
  final _wicketsCtrl = TextEditingController(text: '0');
  final _catchesCtrl = TextEditingController(text: '0');
  final _stumpingsCtrl = TextEditingController(text: '0');
  final _runOutsCtrl = TextEditingController(text: '0');
  final _foursCtrl = TextEditingController(text: '0');
  final _sixesCtrl = TextEditingController(text: '0');
  final _ballsFacedCtrl = TextEditingController(text: '0');
  final _oversBowledCtrl = TextEditingController(text: '0');

  List<Map<String, dynamic>> _players = [];
  String? _selectedPlayerId;
  bool _submitting = false;
  bool _loadingPlayers = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPlayers());
  }

  @override
  void dispose() {
    _runsCtrl.dispose();
    _wicketsCtrl.dispose();
    _catchesCtrl.dispose();
    _stumpingsCtrl.dispose();
    _runOutsCtrl.dispose();
    _foursCtrl.dispose();
    _sixesCtrl.dispose();
    _ballsFacedCtrl.dispose();
    _oversBowledCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPlayers() async {
    // Load match details to get team IDs, then load players for those teams
    await ref.read(adminProvider.notifier).loadMatches();
    final s = ref.read(adminProvider);
    final match =
        s.matches.where((m) => m['id'] == widget.matchId).toList();

    List<Map<String, dynamic>> allPlayers = [];
    if (match.isNotEmpty) {
      final teamAId = match.first['team_a_id'] as String?;
      final teamBId = match.first['team_b_id'] as String?;
      if (teamAId != null) {
        final teamAPlayers = await ref
            .read(adminProvider.notifier)
            .getPlayersByTeam(teamAId);
        allPlayers.addAll(teamAPlayers);
      }
      if (teamBId != null) {
        final teamBPlayers = await ref
            .read(adminProvider.notifier)
            .getPlayersByTeam(teamBId);
        allPlayers.addAll(teamBPlayers);
      }
    }

    setState(() {
      _players = allPlayers;
      _loadingPlayers = false;
    });
  }

  int _calculateFantasyPoints() {
    final runs = int.tryParse(_runsCtrl.text) ?? 0;
    final wickets = int.tryParse(_wicketsCtrl.text) ?? 0;
    final catches = int.tryParse(_catchesCtrl.text) ?? 0;
    final stumpings = int.tryParse(_stumpingsCtrl.text) ?? 0;
    final runOuts = int.tryParse(_runOutsCtrl.text) ?? 0;
    final fours = int.tryParse(_foursCtrl.text) ?? 0;
    final sixes = int.tryParse(_sixesCtrl.text) ?? 0;

    int points = 0;
    // Batting points
    points += runs; // 1 point per run
    points += fours; // 1 bonus per four
    points += sixes * 2; // 2 bonus per six
    if (runs >= 50) points += 8; // half century bonus
    if (runs >= 100) points += 16; // century bonus

    // Bowling points
    points += wickets * 25; // 25 per wicket
    if (wickets >= 3) points += 4; // 3 wicket bonus
    if (wickets >= 5) points += 8; // 5 wicket bonus

    // Fielding points
    points += catches * 8;
    points += stumpings * 12;
    points += runOuts * 6;

    return points;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPlayerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a player')),
      );
      return;
    }

    setState(() => _submitting = true);

    final runs = int.tryParse(_runsCtrl.text) ?? 0;
    final ballsFaced = int.tryParse(_ballsFacedCtrl.text) ?? 0;
    final oversBowled = double.tryParse(_oversBowledCtrl.text) ?? 0;
    final wickets = int.tryParse(_wicketsCtrl.text) ?? 0;

    final strikeRate = ballsFaced > 0 ? (runs / ballsFaced * 100) : 0.0;
    // Economy: runs conceded per over (approximate)
    final economy = oversBowled > 0 ? (runs / oversBowled) : 0.0;

    final data = <String, dynamic>{
      'match_id': widget.matchId,
      'player_id': _selectedPlayerId,
      'runs': runs,
      'wickets': wickets,
      'catches': int.tryParse(_catchesCtrl.text) ?? 0,
      'stumpings': int.tryParse(_stumpingsCtrl.text) ?? 0,
      'run_outs': int.tryParse(_runOutsCtrl.text) ?? 0,
      'fours': int.tryParse(_foursCtrl.text) ?? 0,
      'sixes': int.tryParse(_sixesCtrl.text) ?? 0,
      'balls_faced': ballsFaced,
      'overs_bowled': oversBowled,
      'strike_rate': strikeRate,
      'economy': economy,
      'points': _calculateFantasyPoints(),
    };

    final success =
        await ref.read(adminProvider.notifier).upsertScoreboard(data);

    setState(() => _submitting = false);

    if (success && mounted) {
      Navigator.pop(context);
      widget.onSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add Score Entry',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  // Fantasy points display
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${_calculateFantasyPoints()} pts',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_loadingPlayers)
                        const Center(child: CircularProgressIndicator())
                      else
                        DropdownButtonFormField<String>(
                          value: _selectedPlayerId,
                          decoration: const InputDecoration(
                              labelText: 'Select Player'),
                          items: _players
                              .map((p) => DropdownMenuItem(
                                  value: p['id'] as String,
                                  child: Text(
                                      '${p['name'] ?? 'Unknown'} (${(p['role'] ?? '').toString().toUpperCase()})')))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedPlayerId = v),
                          validator: (v) =>
                              v == null ? 'Required' : null,
                        ),
                      const SizedBox(height: 12),
                      const Text('Batting',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _runsCtrl,
                              decoration:
                                  const InputDecoration(labelText: 'Runs'),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _ballsFacedCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Balls Faced'),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _foursCtrl,
                              decoration:
                                  const InputDecoration(labelText: '4s'),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _sixesCtrl,
                              decoration:
                                  const InputDecoration(labelText: '6s'),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Bowling',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _wicketsCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Wickets'),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _oversBowledCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Overs Bowled'),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Fielding',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _catchesCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Catches'),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _stumpingsCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Stumpings'),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _runOutsCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Run Outs'),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Save Score'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
