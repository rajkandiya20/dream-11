import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_nav_drawer.dart';

class AdminContestsScreen extends ConsumerStatefulWidget {
  const AdminContestsScreen({super.key});

  @override
  ConsumerState<AdminContestsScreen> createState() =>
      _AdminContestsScreenState();
}

class _AdminContestsScreenState extends ConsumerState<AdminContestsScreen> {
  bool _loading = false;
  List<Map<String, dynamic>> _contests = [];
  List<Map<String, dynamic>> _matches = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await ref.read(adminProvider.notifier).loadContests();
      await ref.read(adminProvider.notifier).loadMatches();
      final s = ref.read(adminProvider);
      setState(() {
        _contests = s.contests;
        _matches = s.matches;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const AdminNavDrawer(currentRoute: '/admin/contests'),
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
          'Contests',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0F172A)),
            onPressed: _load,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _showCreateDialog,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                '+ Create New Contest',
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
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE11D48)))
                : _contests.isEmpty
                    ? _buildEmpty()
                    : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.emoji_events, size: 64, color: Color(0xFFE11D48)),
              SizedBox(height: 16),
              Text(
                'No Contests Found',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
            ],
          ),
        ),
      );

  Widget _buildList() => ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _contests.length,
        itemBuilder: (ctx, i) {
          final c = _contests[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              leading: const Icon(Icons.emoji_events, color: Color(0xFFE11D48)),
              title: Text(c['name'] ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                  'Entry: ${c['entry_fee'] ?? 0} | Prize: ${c['prize_pool'] ?? 0} | ${c['status'] ?? '-'}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
                    onPressed: () => _showEditDialog(c),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
                    onPressed: () => _confirmDelete(c),
                  ),
                ],
              ),
            ),
          );
        },
      );

  String _getMatchLabel(Map<String, dynamic> m) {
    return '${m['team_a_name'] ?? '-'} vs ${m['team_b_name'] ?? '-'}';
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final entryFeeCtrl = TextEditingController(text: '0');
    final prizePoolCtrl = TextEditingController(text: '0');
    final maxSpotsCtrl = TextEditingController(text: '100');
    final maxTeamsPerUserCtrl = TextEditingController(text: '1');
    String? selectedMatchId;
    String contestType = 'paid';
    String status = 'open';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Create Contest',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedMatchId,
                  decoration: const InputDecoration(
                    labelText: 'Match',
                    border: OutlineInputBorder(),
                  ),
                  items: _matches
                      .map((m) => DropdownMenuItem<String>(
                            value: m['id'] as String,
                            child: Text(_getMatchLabel(m)),
                          ))
                      .toList(),
                  onChanged: (v) => setS(() => selectedMatchId = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Contest Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: entryFeeCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Entry Fee',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: prizePoolCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Prize Pool',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: maxSpotsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Max Spots',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: maxTeamsPerUserCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Max Teams/User',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: contestType,
                  decoration: const InputDecoration(
                    labelText: 'Contest Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ['paid', 'free']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setS(() => contestType = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: ['open', 'closed', 'completed']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setS(() => status = v!),
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                if (selectedMatchId == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Please select a match')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                final ok =
                    await ref.read(adminProvider.notifier).createContest({
                  'match_id': selectedMatchId,
                  'name': nameCtrl.text.trim(),
                  'entry_fee': double.tryParse(entryFeeCtrl.text) ?? 0,
                  'prize_pool': double.tryParse(prizePoolCtrl.text) ?? 0,
                  'total_spots': int.tryParse(maxSpotsCtrl.text) ?? 100,
                  'max_teams': int.tryParse(maxSpotsCtrl.text) ?? 100,
                  'max_teams_per_user':
                      int.tryParse(maxTeamsPerUserCtrl.text) ?? 1,
                  'contest_type': contestType,
                  'status': status,
                  'joined_teams': 0,
                });
                if (ok) {
                  _load();
                  _snack('Contest created!');
                } else {
                  _snack('Failed to create contest');
                }
              },
              child: const Text('Create', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> c) {
    final nameCtrl = TextEditingController(text: c['name'] ?? '');
    final entryFeeCtrl =
        TextEditingController(text: '${c['entry_fee'] ?? 0}');
    final prizePoolCtrl =
        TextEditingController(text: '${c['prize_pool'] ?? 0}');
    final maxSpotsCtrl =
        TextEditingController(text: '${c['total_spots'] ?? c['max_teams'] ?? 100}');
    String status = c['status'] ?? 'open';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Edit Contest',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Contest Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: entryFeeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Entry Fee',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: prizePoolCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Prize Pool',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: maxSpotsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Max Spots',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: ['open', 'closed', 'completed']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setS(() => status = v!),
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                Navigator.pop(ctx);
                final ok = await ref
                    .read(adminProvider.notifier)
                    .updateContest(c['id'] as String, {
                  'name': nameCtrl.text.trim(),
                  'entry_fee': double.tryParse(entryFeeCtrl.text) ?? 0,
                  'prize_pool': double.tryParse(prizePoolCtrl.text) ?? 0,
                  'total_spots': int.tryParse(maxSpotsCtrl.text) ?? 100,
                  'max_teams': int.tryParse(maxSpotsCtrl.text) ?? 100,
                  'status': status,
                });
                if (ok) {
                  _load();
                  _snack('Contest updated!');
                } else {
                  _snack('Failed to update');
                }
              },
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Contest'),
        content: Text('Delete "${c['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref
                  .read(adminProvider.notifier)
                  .deleteContest(c['id'] as String);
              if (ok) {
                _load();
                _snack('Contest deleted');
              } else {
                _snack('Failed to delete');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
