import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_nav_drawer.dart';

class AdminScoreboardScreen extends ConsumerStatefulWidget {
  const AdminScoreboardScreen({super.key});

  @override
  ConsumerState<AdminScoreboardScreen> createState() => _AdminScoreboardScreenState();
}

class _AdminScoreboardScreenState extends ConsumerState<AdminScoreboardScreen> {
  bool _loadingMatches = false;
  bool _loadingScores = false;
  List<Map<String, dynamic>> _matches = [];
  List<Map<String, dynamic>> _scores = [];
  String? _selectedMatchId;
  String? _selectedMatchName;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() => _loadingMatches = true);
    try {
      await ref.read(adminProvider.notifier).loadMatches();
      final s = ref.read(adminProvider);
      setState(() { _matches = s.matches; _loadingMatches = false; });
    } catch (e) {
      setState(() => _loadingMatches = false);
    }
  }

  Future<void> _loadScores(String matchId) async {
    setState(() => _loadingScores = true);
    try {
      await ref.read(adminProvider.notifier).loadScoreboard(matchId);
      final s = ref.read(adminProvider);
      setState(() { _scores = s.scoreboard; _loadingScores = false; });
    } catch (e) {
      setState(() => _loadingScores = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF0F172A)),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        )),
        title: const Text('Scoreboard',
            style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700)),
        actions: [
          if (_selectedMatchId != null)
            TextButton.icon(
              onPressed: _showAddScoreDialog,
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text('Add Score', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              style: TextButton.styleFrom(backgroundColor: const Color(0xFFE11D48),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
            ),
          const SizedBox(width: 8),
          IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF0F172A)),
              onPressed: () { _loadMatches(); if (_selectedMatchId != null) _loadScores(_selectedMatchId!); }),
          const SizedBox(width: 4),
        ],
      ),
      drawer: const AdminNavDrawer(currentRoute: '/admin/scoreboard'),
      floatingActionButton: _selectedMatchId != null
          ? FloatingActionButton.extended(
              onPressed: _showAddScoreDialog,
              backgroundColor: const Color(0xFFE11D48),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Score', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            )
          : null,
      body: Column(
        children: [
          // Match selector - always visible
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: _loadingMatches
                ? const Padding(padding: EdgeInsets.all(16),
                    child: Row(children: [
                      SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE11D48))),
                      SizedBox(width: 12),
                      Text('Loading matches...'),
                    ]))
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMatchId,
                      isExpanded: true,
                      hint: Text(_matches.isEmpty ? 'No matches available' : 'Select a match',
                          style: const TextStyle(color: Color(0xFF64748B))),
                      items: _matches.map((m) => DropdownMenuItem(
                        value: m['id'] as String,
                        child: Text('${m['team_a_name'] ?? '-'} vs ${m['team_b_name'] ?? '-'} (${m['status'] ?? '-'})'),
                      )).toList(),
                      onChanged: (id) {
                        if (id == null) return;
                        final m = _matches.firstWhere((x) => x['id'] == id, orElse: () => {});
                        setState(() {
                          _selectedMatchId = id;
                          _selectedMatchName = '${m['team_a_name']} vs ${m['team_b_name']}';
                        });
                        _loadScores(id);
                      },
                    ),
                  ),
          ),
          // Add score button - always visible when match selected
          if (_selectedMatchId != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton.icon(
                onPressed: _showAddScoreDialog,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('+ Add Score Entry',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          // Score list
          Expanded(
            child: _selectedMatchId == null
                ? Center(child: Padding(padding: const EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.scoreboard, size: 64, color: Color(0xFFE11D48)),
                      const SizedBox(height: 16),
                      const Text('Select a Match', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
                      const SizedBox(height: 8),
                      const Text('Choose a match from the dropdown above to manage scores',
                          textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B))),
                    ]),
                  ))
                : _loadingScores
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFE11D48)))
                    : _scores.isEmpty
                        ? Center(child: Padding(padding: const EdgeInsets.all(24),
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.sports_score, size: 64, color: Color(0xFFE11D48)),
                              const SizedBox(height: 16),
                              const Text('No scores yet', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
                              const SizedBox(height: 8),
                              Text('Add scores for $_selectedMatchName',
                                  textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B))),
                            ]),
                          ))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            itemCount: _scores.length,
                            itemBuilder: (ctx, i) {
                              final s = _scores[i];
                              final player = s['player'] as Map<String, dynamic>?;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Row(children: [
                                      CircleAvatar(backgroundColor: const Color(0xFFE11D48),
                                        child: Text((player?['name'] ?? '?')[0].toUpperCase(),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(player?['name'] ?? 'Unknown',
                                            style: const TextStyle(fontWeight: FontWeight.w600)),
                                        Text(player?['role'] ?? '-',
                                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                                      ])),
                                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(color: const Color(0xFFE11D48).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12)),
                                        child: Text('${(s['points'] as num?)?.toInt() ?? 0} pts',
                                            style: const TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.w700)),
                                      ),
                                      IconButton(icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
                                          onPressed: () => _showEditScoreDialog(s)),
                                    ]),
                                    const SizedBox(height: 8),
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                                      _stat('Runs', '${s['runs'] ?? 0}'),
                                      _stat('Balls', '${s['balls_faced'] ?? 0}'),
                                      _stat('4s', '${s['fours'] ?? 0}'),
                                      _stat('6s', '${s['sixes'] ?? 0}'),
                                      _stat('Wkts', '${s['wickets'] ?? 0}'),
                                      _stat('Catch', '${s['catches'] ?? 0}'),
                                    ]),
                                  ]),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => Column(children: [
    Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
    Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
  ]);

  void _showAddScoreDialog() {
    final runs = TextEditingController(text: '0');
    final wickets = TextEditingController(text: '0');
    final catches = TextEditingController(text: '0');
    final fours = TextEditingController(text: '0');
    final sixes = TextEditingController(text: '0');
    final balls = TextEditingController(text: '0');
    final points = TextEditingController(text: '0');
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Add Score Entry', style: TextStyle(fontWeight: FontWeight.w700)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Expanded(child: TextField(controller: runs, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Runs', border: OutlineInputBorder()))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: balls, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Balls', border: OutlineInputBorder()))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(controller: fours, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '4s', border: OutlineInputBorder()))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: sixes, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '6s', border: OutlineInputBorder()))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(controller: wickets, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Wickets', border: OutlineInputBorder()))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: catches, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Catches', border: OutlineInputBorder()))),
        ]),
        const SizedBox(height: 8),
        TextField(controller: points, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Total Points', border: OutlineInputBorder())),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
          onPressed: () async {
            Navigator.pop(ctx);
            await ref.read(adminProvider.notifier).upsertScoreboard({
              'match_id': _selectedMatchId,
              'runs': int.tryParse(runs.text) ?? 0,
              'wickets': int.tryParse(wickets.text) ?? 0,
              'catches': int.tryParse(catches.text) ?? 0,
              'fours': int.tryParse(fours.text) ?? 0,
              'sixes': int.tryParse(sixes.text) ?? 0,
              'balls_faced': int.tryParse(balls.text) ?? 0,
              'points': double.tryParse(points.text) ?? 0,
            });
            _loadScores(_selectedMatchId!);
            _snack('Score saved!');
          },
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  void _showEditScoreDialog(Map<String, dynamic> s) {
    final runs = TextEditingController(text: '${s['runs'] ?? 0}');
    final wickets = TextEditingController(text: '${s['wickets'] ?? 0}');
    final catches = TextEditingController(text: '${s['catches'] ?? 0}');
    final fours = TextEditingController(text: '${s['fours'] ?? 0}');
    final sixes = TextEditingController(text: '${s['sixes'] ?? 0}');
    final balls = TextEditingController(text: '${s['balls_faced'] ?? 0}');
    final points = TextEditingController(text: '${(s['points'] as num?)?.toInt() ?? 0}');
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Edit Score', style: TextStyle(fontWeight: FontWeight.w700)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Expanded(child: TextField(controller: runs, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Runs', border: OutlineInputBorder()))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: balls, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Balls', border: OutlineInputBorder()))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(controller: fours, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '4s', border: OutlineInputBorder()))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: sixes, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '6s', border: OutlineInputBorder()))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(controller: wickets, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Wickets', border: OutlineInputBorder()))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: catches, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Catches', border: OutlineInputBorder()))),
        ]),
        const SizedBox(height: 8),
        TextField(controller: points, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Total Points', border: OutlineInputBorder())),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
          onPressed: () async {
            Navigator.pop(ctx);
            await ref.read(adminProvider.notifier).upsertScoreboard({
              'id': s['id'],
              'match_id': _selectedMatchId,
              'player_id': s['player_id'],
              'runs': int.tryParse(runs.text) ?? 0,
              'wickets': int.tryParse(wickets.text) ?? 0,
              'catches': int.tryParse(catches.text) ?? 0,
              'fours': int.tryParse(fours.text) ?? 0,
              'sixes': int.tryParse(sixes.text) ?? 0,
              'balls_faced': int.tryParse(balls.text) ?? 0,
              'points': double.tryParse(points.text) ?? 0,
            });
            _loadScores(_selectedMatchId!);
            _snack('Score updated!');
          },
          child: const Text('Update', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
