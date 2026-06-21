import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/services/storage_service.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_nav_drawer.dart';

class AdminPlayersScreen extends ConsumerStatefulWidget {
  const AdminPlayersScreen({super.key});

  @override
  ConsumerState<AdminPlayersScreen> createState() =>
      _AdminPlayersScreenState();
}

class _AdminPlayersScreenState extends ConsumerState<AdminPlayersScreen> {
  bool _loading = false;
  List<Map<String, dynamic>> _players = [];
  List<Map<String, dynamic>> _teams = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await ref.read(adminProvider.notifier).loadPlayers();
      await ref.read(adminProvider.notifier).loadTeams();
      final s = ref.read(adminProvider);
      setState(() {
        _players = s.players;
        _teams = s.teams;
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
      drawer: const AdminNavDrawer(currentRoute: '/admin/players'),
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
          'Players',
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
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text(
                '+ Add New Player',
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
                : _players.isEmpty
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
              Icon(Icons.person, size: 64, color: Color(0xFFE11D48)),
              SizedBox(height: 16),
              Text(
                'No Players Found',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
            ],
          ),
        ),
      );

  Widget _buildList() => ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _players.length,
        itemBuilder: (ctx, i) {
          final p = _players[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary,
                backgroundImage: p['image'] != null &&
                        (p['image'] as String).isNotEmpty
                    ? NetworkImage(p['image'] as String)
                    : null,
                child: p['image'] == null || (p['image'] as String).isEmpty
                    ? Text(
                        (p['name'] ?? '?')[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700),
                      )
                    : null,
              ),
              title: Text(p['name'] ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                  '${p['role'] ?? '-'} | Team: ${_getTeamName(p['team_id'])} | #${p['jersey_number'] ?? '-'}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
                    onPressed: () => _showEditDialog(p),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
                    onPressed: () => _confirmDelete(p),
                  ),
                ],
              ),
            ),
          );
        },
      );

  String _getTeamName(String? id) {
    if (id == null) return '-';
    final t = _teams.where((t) => t['id'] == id).toList();
    return t.isNotEmpty ? (t.first['name'] ?? '-') : '-';
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final creditsCtrl = TextEditingController(text: '8.0');
    final pointsCtrl = TextEditingController(text: '0');
    final jerseyCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    String role = 'Batsman';
    String? selectedTeamId;
    Uint8List? imageBytes;
    String? imageFileName;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add Player',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Player Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: ['WK', 'Batsman', 'Bowler', 'All-rounder']
                      .map((r) =>
                          DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setS(() => role = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedTeamId,
                  decoration: const InputDecoration(
                    labelText: 'Team',
                    border: OutlineInputBorder(),
                  ),
                  items: _teams
                      .map((t) => DropdownMenuItem<String>(
                            value: t['id'] as String,
                            child: Text(t['name'] ?? '-'),
                          ))
                      .toList(),
                  onChanged: (v) => setS(() => selectedTeamId = v),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: creditsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Credits',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: pointsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Points',
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
                        controller: jerseyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Jersey #',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: ageCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
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
                        imageBytes = bytes;
                        imageFileName = file.name;
                      });
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: Text(imageFileName ?? 'Pick Player Image'),
                ),
                if (imageBytes != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Image.memory(imageBytes!,
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
                if (selectedTeamId == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Please select a team')),
                  );
                  return;
                }
                Navigator.pop(ctx);

                String? imageUrl;
                if (imageBytes != null) {
                  final path =
                      '${DateTime.now().millisecondsSinceEpoch}_${imageFileName ?? 'player.png'}';
                  imageUrl = await ref
                      .read(storageServiceProvider)
                      .uploadImage(
                        'player-photos',
                        path,
                        imageBytes!,
                        contentType: 'image/png',
                      );
                }

                final ok =
                    await ref.read(adminProvider.notifier).createPlayer({
                  'name': nameCtrl.text.trim(),
                  'role': role,
                  'team_id': selectedTeamId,
                  'credits': double.tryParse(creditsCtrl.text) ?? 8.0,
                  'points': int.tryParse(pointsCtrl.text) ?? 0,
                  'jersey_number': int.tryParse(jerseyCtrl.text),
                  'age': int.tryParse(ageCtrl.text),
                  'is_playing': true,
                  if (imageUrl != null) 'image': imageUrl,
                });
                if (ok) {
                  _load();
                  _snack('Player added!');
                } else {
                  _snack('Failed to add player');
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

  void _showEditDialog(Map<String, dynamic> p) {
    final nameCtrl = TextEditingController(text: p['name'] ?? '');
    final creditsCtrl =
        TextEditingController(text: '${p['credits'] ?? 8.0}');
    final pointsCtrl = TextEditingController(text: '${p['points'] ?? 0}');
    final jerseyCtrl =
        TextEditingController(text: '${p['jersey_number'] ?? ''}');
    final ageCtrl = TextEditingController(text: '${p['age'] ?? ''}');
    String role = p['role'] ?? 'Batsman';
    String? selectedTeamId = p['team_id'] as String?;
    Uint8List? imageBytes;
    String? imageFileName;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Edit Player',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Player Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: ['WK', 'Batsman', 'Bowler', 'All-rounder']
                      .map((r) =>
                          DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setS(() => role = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedTeamId,
                  decoration: const InputDecoration(
                    labelText: 'Team',
                    border: OutlineInputBorder(),
                  ),
                  items: _teams
                      .map((t) => DropdownMenuItem<String>(
                            value: t['id'] as String,
                            child: Text(t['name'] ?? '-'),
                          ))
                      .toList(),
                  onChanged: (v) => setS(() => selectedTeamId = v),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: creditsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Credits',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: pointsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Points',
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
                        controller: jerseyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Jersey #',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: ageCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
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
                        imageBytes = bytes;
                        imageFileName = file.name;
                      });
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: Text(imageFileName ?? 'Change Image'),
                ),
                if (imageBytes != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Image.memory(imageBytes!,
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

                String? imageUrl;
                if (imageBytes != null) {
                  final path =
                      '${DateTime.now().millisecondsSinceEpoch}_${imageFileName ?? 'player.png'}';
                  imageUrl = await ref
                      .read(storageServiceProvider)
                      .uploadImage(
                        'player-photos',
                        path,
                        imageBytes!,
                        contentType: 'image/png',
                      );
                }

                final data = <String, dynamic>{
                  'name': nameCtrl.text.trim(),
                  'role': role,
                  'team_id': selectedTeamId,
                  'credits': double.tryParse(creditsCtrl.text) ?? 8.0,
                  'points': int.tryParse(pointsCtrl.text) ?? 0,
                  'jersey_number': int.tryParse(jerseyCtrl.text),
                  'age': int.tryParse(ageCtrl.text),
                };
                if (imageUrl != null) data['image'] = imageUrl;

                final ok = await ref
                    .read(adminProvider.notifier)
                    .updatePlayer(p['id'] as String, data);
                if (ok) {
                  _load();
                  _snack('Player updated!');
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

  void _confirmDelete(Map<String, dynamic> p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Player'),
        content: Text('Delete "${p['name']}"?'),
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
                  .deletePlayer(p['id'] as String);
              if (ok) {
                _load();
                _snack('Player deleted');
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
