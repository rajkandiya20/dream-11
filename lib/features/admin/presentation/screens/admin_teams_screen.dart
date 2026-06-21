import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_nav_drawer.dart';

class AdminTeamsScreen extends ConsumerStatefulWidget {
  const AdminTeamsScreen({super.key});

  @override
  ConsumerState<AdminTeamsScreen> createState() => _AdminTeamsScreenState();
}

class _AdminTeamsScreenState extends ConsumerState<AdminTeamsScreen> {
  bool _loading = false;
  List<Map<String, dynamic>> _teams = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(adminProvider.notifier).loadTeams();
      final s = ref.read(adminProvider);
      setState(() { _teams = s.teams; _loading = false; });
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
        title: const Text('Teams',
            style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700)),
        actions: [
          TextButton.icon(
            onPressed: _showCreateDialog,
            icon: const Icon(Icons.group_add, color: Colors.white, size: 18),
            label: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            style: TextButton.styleFrom(backgroundColor: const Color(0xFFE11D48),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
          ),
          const SizedBox(width: 8),
          IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF0F172A)), onPressed: _load),
          const SizedBox(width: 4),
        ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: const Color(0xFFE11D48),
        icon: const Icon(Icons.group_add, color: Colors.white),
        label: const Text('Add Team',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _showCreateDialog,
              icon: const Icon(Icons.group_add, color: Colors.white),
              label: const Text('+ Add New Team',
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
                : _error != null
                    ? _buildError()
                    : _teams.isEmpty
                        ? _buildEmpty()
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
      const Text('Failed to load teams', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _load,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
          child: const Text('Retry', style: TextStyle(color: Colors.white))),
    ]),
  ));

  Widget _buildEmpty() => Center(child: Padding(padding: const EdgeInsets.all(24),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.groups, size: 64, color: Color(0xFFE11D48)),
      const SizedBox(height: 16),
      const Text('No teams yet', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
      const SizedBox(height: 8),
      const Text('Tap the button above to add your first team',
          textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B))),
    ]),
  ));

  Widget _buildList() => ListView.builder(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
    itemCount: _teams.length,
    itemBuilder: (ctx, i) {
      final t = _teams[i];
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFE11D48),
            child: Text(t['code']?.toString().substring(0, 1) ?? '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          title: Text(t['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('Code: ${t['code'] ?? '-'}'),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
                onPressed: () => _showEditDialog(t)),
            IconButton(icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
                onPressed: () => _confirmDelete(t)),
          ]),
        ),
      );
    },
  );

  void _showCreateDialog() {
    final name = TextEditingController();
    final code = TextEditingController();
    final logo = TextEditingController();
    showDialog(context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Team', style: TextStyle(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Team Name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: code, decoration: const InputDecoration(labelText: 'Team Code (e.g. IND)', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: logo, decoration: const InputDecoration(labelText: 'Logo URL (optional)', border: OutlineInputBorder())),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            onPressed: () async {
              if (name.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final ok = await ref.read(adminProvider.notifier).createTeam({
                'name': name.text.trim(),
                'code': code.text.trim().toUpperCase(),
                'logo': logo.text.trim(),
              });
              if (ok) { _load(); _snack('Team added!'); } else _snack('Failed to add team');
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> t) {
    final name = TextEditingController(text: t['name'] ?? '');
    final code = TextEditingController(text: t['code'] ?? '');
    final logo = TextEditingController(text: t['logo'] ?? '');
    showDialog(context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Team', style: TextStyle(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Team Name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: code, decoration: const InputDecoration(labelText: 'Team Code', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: logo, decoration: const InputDecoration(labelText: 'Logo URL', border: OutlineInputBorder())),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref.read(adminProvider.notifier).updateTeam(t['id'] as String,
                  {'name': name.text.trim(), 'code': code.text.trim().toUpperCase(), 'logo': logo.text.trim()});
              if (ok) { _load(); _snack('Updated!'); } else _snack('Failed');
            },
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> t) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete Team'),
      content: Text('Delete "${t['name']}"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            Navigator.pop(ctx);
            await ref.read(adminProvider.notifier).deleteTeam(t['id'] as String);
            _load();
            _snack('Deleted');
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
