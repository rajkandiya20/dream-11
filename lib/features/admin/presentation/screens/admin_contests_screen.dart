import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_nav_drawer.dart';

class AdminContestsScreen extends ConsumerStatefulWidget {
  const AdminContestsScreen({super.key});

  @override
  ConsumerState<AdminContestsScreen> createState() => _AdminContestsScreenState();
}

class _AdminContestsScreenState extends ConsumerState<AdminContestsScreen> {
  bool _loading = false;
  List<Map<String, dynamic>> _contests = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(adminProvider.notifier).loadContests();
      final s = ref.read(adminProvider);
      setState(() { _contests = s.contests; _loading = false; });
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
        title: const Text('Contests',
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
          IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF0F172A)), onPressed: _load),
          const SizedBox(width: 4),
        ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: const Color(0xFFE11D48),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create Contest',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _showCreateDialog,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('+ Create New Contest',
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
                : _contests.isEmpty ? _buildEmpty()
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
      const Text('Failed to load contests', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _load,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
          child: const Text('Retry', style: TextStyle(color: Colors.white))),
    ]),
  ));

  Widget _buildEmpty() => Center(child: Padding(padding: const EdgeInsets.all(24),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.emoji_events, size: 64, color: Color(0xFFE11D48)),
      const SizedBox(height: 16),
      const Text('No contests yet', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
      const SizedBox(height: 8),
      const Text('Tap the button above to create your first contest',
          textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B))),
    ]),
  ));

  Widget _buildList() => ListView.builder(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
    itemCount: _contests.length,
    itemBuilder: (ctx, i) {
      final c = _contests[i];
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ListTile(
          leading: const Icon(Icons.emoji_events, color: Color(0xFFE11D48)),
          title: Text(c['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('Entry: ₹${c['entry_fee'] ?? 0} • Prize: ₹${c['prize_pool'] ?? 0} • ${c['status'] ?? '-'}'),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)), onPressed: () => _showEditDialog(c)),
            IconButton(icon: const Icon(Icons.delete, color: Color(0xFFEF4444)), onPressed: () => _confirmDelete(c)),
          ]),
        ),
      );
    },
  );

  void _showCreateDialog() {
    final name = TextEditingController();
    final entryFee = TextEditingController(text: '0');
    final prizePool = TextEditingController(text: '0');
    final maxTeams = TextEditingController(text: '100');
    String status = 'open';
    String type = 'paid';
    showDialog(context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
        title: const Text('Create Contest', style: TextStyle(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Contest Name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: entryFee, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Entry Fee (₹)', border: OutlineInputBorder()))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: prizePool, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Prize Pool (₹)', border: OutlineInputBorder()))),
          ]),
          const SizedBox(height: 12),
          TextField(controller: maxTeams, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Max Teams', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: type,
            decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
            items: ['paid','free'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setS(() => type = v!),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: status,
            decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
            items: ['open','closed','completed'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setS(() => status = v!),
          ),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            onPressed: () async {
              if (name.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final ok = await ref.read(adminProvider.notifier).createContest({
                'name': name.text.trim(),
                'entry_fee': double.tryParse(entryFee.text) ?? 0,
                'prize_pool': double.tryParse(prizePool.text) ?? 0,
                'max_teams': int.tryParse(maxTeams.text) ?? 100,
                'contest_type': type, 'status': status, 'joined_teams': 0,
              });
              if (ok) { _load(); _snack('Contest created!'); } else _snack('Failed');
            },
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      )),
    );
  }

  void _showEditDialog(Map<String, dynamic> c) {
    final name = TextEditingController(text: c['name'] ?? '');
    final entryFee = TextEditingController(text: '${c['entry_fee'] ?? 0}');
    final prizePool = TextEditingController(text: '${c['prize_pool'] ?? 0}');
    String status = c['status'] ?? 'open';
    showDialog(context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
        title: const Text('Edit Contest', style: TextStyle(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Contest Name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: entryFee, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Entry Fee (₹)', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: prizePool, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Prize Pool (₹)', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: status,
            decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
            items: ['open','closed','completed'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setS(() => status = v!),
          ),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref.read(adminProvider.notifier).updateContest(c['id'] as String,
                  {'name': name.text.trim(), 'entry_fee': double.tryParse(entryFee.text) ?? 0,
                   'prize_pool': double.tryParse(prizePool.text) ?? 0, 'status': status});
              if (ok) { _load(); _snack('Updated!'); } else _snack('Failed');
            },
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      )),
    );
  }

  void _confirmDelete(Map<String, dynamic> c) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete Contest'),
      content: Text('Delete "${c['name']}"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            Navigator.pop(ctx);
            await ref.read(adminProvider.notifier).deleteContest(c['id'] as String);
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
