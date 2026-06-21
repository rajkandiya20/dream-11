import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/admin_provider.dart';

class MatchManagerScreen extends ConsumerStatefulWidget {
  const MatchManagerScreen({super.key});

  @override
  ConsumerState<MatchManagerScreen> createState() => _MatchManagerScreenState();
}

class _MatchManagerScreenState extends ConsumerState<MatchManagerScreen> {
  bool _loading = false;
  List<Map<String, dynamic>> _matches = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() { _loading = true; _error = null; });
    try {
      final adminState = ref.read(adminProvider);
      await ref.read(adminProvider.notifier).loadMatches();
      final updated = ref.read(adminProvider);
      setState(() { _matches = updated.matches; _loading = false; });
    } catch (e) {
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Match Manager',
            style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700)),
        actions: [
          TextButton.icon(
            onPressed: _showCreateDialog,
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label: const Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            style: TextButton.styleFrom(backgroundColor: const Color(0xFFE11D48),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
          ),
          const SizedBox(width: 8),
          IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF0F172A)), onPressed: _loadMatches),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: const Color(0xFFE11D48),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create Match',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // TOP CREATE BUTTON - always visible
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _showCreateDialog,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('+ Create New Match',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          // LIST
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFE11D48)))
                : _error != null
                    ? _buildError()
                    : _matches.isEmpty
                        ? _buildEmpty()
                        : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.red),
        const SizedBox(height: 12),
        const Text('Failed to load matches', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        Text(_error ?? '', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B))),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _loadMatches,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            child: const Text('Retry', style: TextStyle(color: Colors.white))),
      ]),
    ),
  );

  Widget _buildEmpty() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.sports_cricket, size: 64, color: Color(0xFFE11D48)),
        const SizedBox(height: 16),
        const Text('No matches yet', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
        const SizedBox(height: 8),
        const Text('Tap the button above to create your first match',
            textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B))),
      ]),
    ),
  );

  Widget _buildList() => ListView.builder(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
    itemCount: _matches.length,
    itemBuilder: (ctx, i) {
      final m = _matches[i];
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ListTile(
          title: Text('${m['team_a_name'] ?? '-'} vs ${m['team_b_name'] ?? '-'}',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('${m['status'] ?? '-'} • ${m['venue'] ?? '-'}'),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
                onPressed: () => _showEditDialog(m)),
            IconButton(icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
                onPressed: () => _confirmDelete(m)),
          ]),
        ),
      );
    },
  );

  void _showCreateDialog() {
    final teamA = TextEditingController();
    final teamB = TextEditingController();
    final venue = TextEditingController();
    String status = 'upcoming';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
        title: const Text('Create Match', style: TextStyle(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: teamA, decoration: const InputDecoration(labelText: 'Team A Name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: teamB, decoration: const InputDecoration(labelText: 'Team B Name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: venue, decoration: const InputDecoration(labelText: 'Venue', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: status,
            decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
            items: ['upcoming','live','completed'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setS(() => status = v!),
          ),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            onPressed: () async {
              if (teamA.text.trim().isEmpty || teamB.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final ok = await ref.read(adminProvider.notifier).createMatch({
                'team_a_name': teamA.text.trim(),
                'team_b_name': teamB.text.trim(),
                'venue': venue.text.trim(),
                'status': status,
              });
              if (ok) { _loadMatches(); _snack('Match created!'); }
              else _snack('Failed to create match');
            },
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      )),
    );
  }

  void _showEditDialog(Map<String, dynamic> m) {
    final teamA = TextEditingController(text: m['team_a_name'] ?? '');
    final teamB = TextEditingController(text: m['team_b_name'] ?? '');
    final venue = TextEditingController(text: m['venue'] ?? '');
    String status = m['status'] ?? 'upcoming';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
        title: const Text('Edit Match', style: TextStyle(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: teamA, decoration: const InputDecoration(labelText: 'Team A Name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: teamB, decoration: const InputDecoration(labelText: 'Team B Name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: venue, decoration: const InputDecoration(labelText: 'Venue', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: status,
            decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
            items: ['upcoming','live','completed'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setS(() => status = v!),
          ),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref.read(adminProvider.notifier).updateMatch(m['id'] as String, {
                'team_a_name': teamA.text.trim(),
                'team_b_name': teamB.text.trim(),
                'venue': venue.text.trim(),
                'status': status,
              });
              if (ok) { _loadMatches(); _snack('Match updated!'); }
              else _snack('Failed to update match');
            },
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      )),
    );
  }

  void _confirmDelete(Map<String, dynamic> m) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Match'),
        content: Text('Delete "${m['team_a_name']} vs ${m['team_b_name']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(adminProvider.notifier).deleteMatch(m['id'] as String);
              _loadMatches();
              _snack('Match deleted');
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
