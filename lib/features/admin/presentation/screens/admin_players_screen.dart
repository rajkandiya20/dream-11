import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_nav_drawer.dart';

class AdminPlayersScreen extends ConsumerStatefulWidget {
  const AdminPlayersScreen({super.key});

  @override
  ConsumerState<AdminPlayersScreen> createState() => _AdminPlayersScreenState();
}

class _AdminPlayersScreenState extends ConsumerState<AdminPlayersScreen> {
  bool _loading = false;
  List<Map<String, dynamic>> _players = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(adminProvider.notifier).loadPlayers();
      final s = ref.read(adminProvider);
      setState(() { _players = s.players; _loading = false; });
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
        leading: Builder(builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF0F172A)),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        )),
        title: const Text('Players',
            style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF0F172A)), onPressed: _load),
        ],
      ),
      drawer: const AdminNavDrawer(currentRoute: '/admin/players'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: const Color(0xFFE11D48),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Player',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _showCreateDialog,
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text('+ Add New Player',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFE11D48)))
                : _error != null ? _buildError()
                : _players.isEmpty ? _buildEmpty()
                : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildError() => Center(child: Padding(padding: const EdgeInsets.all(24),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline, size: 48, color: Colors.red),
      const SizedBox(height: 12),
      const Text('Failed to load players', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _load,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
          child: const Text('Retry', style: TextStyle(color: Colors.white))),
    ]),
  ));

  Widget _buildEmpty() => Center(child: Padding(padding: const EdgeInsets.all(24),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.person, size: 64, color: Color(0xFFE11D48)),
      const SizedBox(height: 16),
      const Text('No players yet', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
      const SizedBox(height: 8),
      const Text('Tap the button above to add your first player',
          textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B))),
    ]),
  ));

  Widget _buildList() => ListView.builder(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
    itemCount: _players.length,
    itemBuilder: (ctx, i) {
      final p = _players[i];
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFE11D48),
            child: Text((p['name'] ?? '?')[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          title: Text(p['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('${p['role'] ?? '-'} • ${p['credits'] ?? 0} credits • ${p['points'] ?? 0} pts'),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)), onPressed: () => _showEditDialog(p)),
            IconButton(icon: const Icon(Icons.delete, color: Color(0xFFEF4444)), onPressed: () => _confirmDelete(p)),
          ]),
        ),
      );
    },
  );

  void _showCreateDialog() {
    final name = TextEditingController();
    final credits = TextEditingController(text: '8.0');
    final points = TextEditingController(text: '0');
    String role = 'Batsman';
    showDialog(context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
        title: const Text('Add Player', style: TextStyle(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Player Name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: role,
            decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
            items: ['Batsman','Bowler','All-rounder','WK']
                .map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setS(() => role = v!),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: credits, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Credits', border: OutlineInputBorder()))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: points, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Points', border: OutlineInputBorder()))),
          ]),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            onPressed: () async {
              if (name.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final ok = await ref.read(adminProvider.notifier).createPlayer({
                'name': name.text.trim(), 'role': role,
                'credits': double.tryParse(credits.text) ?? 8.0,
                'points': int.tryParse(points.text) ?? 0,
                'is_playing': true,
              });
              if (ok) { _load(); _snack('Player added!'); } else _snack('Failed');
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      )),
    );
  }

  void _showEditDialog(Map<String, dynamic> p) {
    final name = TextEditingController(text: p['name'] ?? '');
    final credits = TextEditingController(text: '${p['credits'] ?? 8.0}');
    final points = TextEditingController(text: '${p['points'] ?? 0}');
    String role = p['role'] ?? 'Batsman';
    showDialog(context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
        title: const Text('Edit Player', style: TextStyle(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Player Name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: role,
            decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
            items: ['Batsman','Bowler','All-rounder','WK']
                .map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setS(() => role = v!),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: credits, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Credits', border: OutlineInputBorder()))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: points, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Points', border: OutlineInputBorder()))),
          ]),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref.read(adminProvider.notifier).updatePlayer(p['id'] as String,
                  {'name': name.text.trim(), 'role': role,
                   'credits': double.tryParse(credits.text) ?? 8.0,
                   'points': int.tryParse(points.text) ?? 0});
              if (ok) { _load(); _snack('Updated!'); } else _snack('Failed');
            },
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      )),
    );
  }

  void _confirmDelete(Map<String, dynamic> p) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete Player'),
      content: Text('Delete "${p['name']}"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            Navigator.pop(ctx);
            await ref.read(adminProvider.notifier).deletePlayer(p['id'] as String);
            _load(); _snack('Deleted');
          },
          child: const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
