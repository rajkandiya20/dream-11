import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/services/storage_service.dart';
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
  List<Map<String, dynamic>> _tournaments = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await ref.read(adminProvider.notifier).loadTeams();
      await ref.read(adminProvider.notifier).loadTournaments();
      final s = ref.read(adminProvider);
      setState(() {
        _teams = s.teams;
        _tournaments = s.tournaments;
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
      drawer: const AdminNavDrawer(currentRoute: '/admin/teams'),
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
          'Teams',
          style:
              TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700),
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
              icon: const Icon(Icons.group_add, color: Colors.white),
              label: const Text(
                '+ Add New Team',
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
                    child:
                        CircularProgressIndicator(color: Color(0xFFE11D48)))
                : _teams.isEmpty
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
              Icon(Icons.groups, size: 64, color: Color(0xFFE11D48)),
              SizedBox(height: 16),
              Text(
                'No Teams Found',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
            ],
          ),
        ),
      );

  Widget _buildList() => ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _teams.length,
        itemBuilder: (ctx, i) {
          final t = _teams[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary,
                backgroundImage: t['logo'] != null &&
                        (t['logo'] as String).isNotEmpty
                    ? NetworkImage(t['logo'] as String)
                    : null,
                child: t['logo'] == null || (t['logo'] as String).isEmpty
                    ? Text(
                        (t['code'] ?? '?').toString().substring(0, 1),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700),
                      )
                    : null,
              ),
              title: Text(t['name'] ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                  'Code: ${t['code'] ?? '-'} | Tournament: ${_getTournamentName(t['tournament_id'])}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
                    onPressed: () => _showEditDialog(t),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
                    onPressed: () => _confirmDelete(t),
                  ),
                ],
              ),
            ),
          );
        },
      );

  String _getTournamentName(String? id) {
    if (id == null) return '-';
    final t = _tournaments.where((t) => t['id'] == id).toList();
    return t.isNotEmpty ? (t.first['name'] ?? '-') : '-';
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final captainCtrl = TextEditingController();
    final viceCaptainCtrl = TextEditingController();
    String? selectedTournamentId;
    Uint8List? logoBytes;
    String? logoFileName;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add Team',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Team Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Team Code (e.g. IND)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedTournamentId,
                  decoration: const InputDecoration(
                    labelText: 'Tournament',
                    border: OutlineInputBorder(),
                  ),
                  items: _tournaments
                      .map((t) => DropdownMenuItem<String>(
                            value: t['id'] as String,
                            child: Text(t['name'] ?? '-'),
                          ))
                      .toList(),
                  onChanged: (v) => setS(() => selectedTournamentId = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: captainCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Captain',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: viceCaptainCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Vice Captain',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final file = await picker.pickImage(
                        source: ImageSource.gallery);
                    if (file != null) {
                      final bytes = await file.readAsBytes();
                      setS(() {
                        logoBytes = bytes;
                        logoFileName = file.name;
                      });
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: Text(logoFileName ?? 'Pick Team Logo'),
                ),
                if (logoBytes != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Image.memory(logoBytes!,
                        height: 60, fit: BoxFit.contain),
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
                  backgroundColor: AppColors.primary),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                if (selectedTournamentId == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                        content: Text('Please select a tournament')),
                  );
                  return;
                }
                Navigator.pop(ctx);

                String? logoUrl;
                if (logoBytes != null) {
                  final path =
                      '${DateTime.now().millisecondsSinceEpoch}_${logoFileName ?? 'logo.png'}';
                  logoUrl = await ref
                      .read(storageServiceProvider)
                      .uploadImage(
                        'team-logos',
                        path,
                        logoBytes!,
                        contentType: 'image/png',
                      );
                }

                final ok =
                    await ref.read(adminProvider.notifier).createTeam({
                  'name': nameCtrl.text.trim(),
                  'code': codeCtrl.text.trim().toUpperCase(),
                  'tournament_id': selectedTournamentId,
                  'captain': captainCtrl.text.trim(),
                  'vice_captain': viceCaptainCtrl.text.trim(),
                  if (logoUrl != null) 'logo': logoUrl,
                });
                if (ok) {
                  _load();
                  _snack('Team added!');
                } else {
                  _snack('Failed to add team');
                }
              },
              child:
                  const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> t) {
    final nameCtrl = TextEditingController(text: t['name'] ?? '');
    final codeCtrl = TextEditingController(text: t['code'] ?? '');
    final captainCtrl = TextEditingController(text: t['captain'] ?? '');
    final viceCaptainCtrl =
        TextEditingController(text: t['vice_captain'] ?? '');
    String? selectedTournamentId = t['tournament_id'] as String?;
    Uint8List? logoBytes;
    String? logoFileName;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Edit Team',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Team Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Team Code',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedTournamentId,
                  decoration: const InputDecoration(
                    labelText: 'Tournament',
                    border: OutlineInputBorder(),
                  ),
                  items: _tournaments
                      .map((tr) => DropdownMenuItem<String>(
                            value: tr['id'] as String,
                            child: Text(tr['name'] ?? '-'),
                          ))
                      .toList(),
                  onChanged: (v) => setS(() => selectedTournamentId = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: captainCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Captain',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: viceCaptainCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Vice Captain',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final file = await picker.pickImage(
                        source: ImageSource.gallery);
                    if (file != null) {
                      final bytes = await file.readAsBytes();
                      setS(() {
                        logoBytes = bytes;
                        logoFileName = file.name;
                      });
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: Text(logoFileName ?? 'Change Logo'),
                ),
                if (logoBytes != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Image.memory(logoBytes!,
                        height: 60, fit: BoxFit.contain),
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
                  backgroundColor: AppColors.primary),
              onPressed: () async {
                Navigator.pop(ctx);

                String? logoUrl;
                if (logoBytes != null) {
                  final path =
                      '${DateTime.now().millisecondsSinceEpoch}_${logoFileName ?? 'logo.png'}';
                  logoUrl = await ref
                      .read(storageServiceProvider)
                      .uploadImage(
                        'team-logos',
                        path,
                        logoBytes!,
                        contentType: 'image/png',
                      );
                }

                final data = <String, dynamic>{
                  'name': nameCtrl.text.trim(),
                  'code': codeCtrl.text.trim().toUpperCase(),
                  'tournament_id': selectedTournamentId,
                  'captain': captainCtrl.text.trim(),
                  'vice_captain': viceCaptainCtrl.text.trim(),
                };
                if (logoUrl != null) data['logo'] = logoUrl;

                final ok = await ref
                    .read(adminProvider.notifier)
                    .updateTeam(t['id'] as String, data);
                if (ok) {
                  _load();
                  _snack('Team updated!');
                } else {
                  _snack('Failed to update');
                }
              },
              child: const Text('Update',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Team'),
        content: Text('Delete "${t['name']}"?'),
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
                  .deleteTeam(t['id'] as String);
              if (ok) {
                _load();
                _snack('Team deleted');
              } else {
                _snack('Failed to delete');
              }
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
