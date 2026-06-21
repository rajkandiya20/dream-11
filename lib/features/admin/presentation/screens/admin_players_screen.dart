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
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await ref.read(adminProvider.notifier).loadPlayers();
      final s = ref.read(adminProvider);
      setState(() {
        _items = s.players;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _items = [];
        _loading = false;
      });
    }
  }

  Future<void> _deletePlayer(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Player'),
        content:
            const Text('Are you sure you want to delete this player?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(adminProvider.notifier).deletePlayer(id);
      await _load();
    }
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _CreatePlayerDialog(onCreated: () => _load()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminNavDrawer(currentRoute: '/admin/players'),
      appBar: AppBar(
        title: const Text('Players'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _showCreateDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Player'),
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
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? _buildEmpty()
                    : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No players yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Add your first player to get started',
              style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          final image = item['image'] as String?;
          final name = item['name'] as String? ?? 'Unnamed';
          final role = item['role'] as String? ?? '';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: image != null && image.isNotEmpty
                    ? NetworkImage(image)
                    : null,
                child: image == null || image.isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(role.toUpperCase()),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deletePlayer(item['id'] as String);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CreatePlayerDialog extends ConsumerStatefulWidget {
  final VoidCallback onCreated;

  const _CreatePlayerDialog({required this.onCreated});

  @override
  ConsumerState<_CreatePlayerDialog> createState() =>
      _CreatePlayerDialogState();
}

class _CreatePlayerDialogState extends ConsumerState<_CreatePlayerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _jerseyCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  String _role = 'BAT';
  List<Map<String, dynamic>> _tournaments = [];
  List<Map<String, dynamic>> _teams = [];
  String? _selectedTournamentId;
  String? _selectedTeamId;
  Uint8List? _imageBytes;
  bool _submitting = false;
  bool _loadingTournaments = true;
  bool _loadingTeams = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTournaments());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _jerseyCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTournaments() async {
    await ref.read(adminProvider.notifier).loadTournaments();
    final s = ref.read(adminProvider);
    setState(() {
      _tournaments = s.tournaments;
      _loadingTournaments = false;
    });
  }

  Future<void> _loadTeams(String tournamentId) async {
    setState(() => _loadingTeams = true);
    final teams = await ref
        .read(adminProvider.notifier)
        .getTeamsByTournament(tournamentId);
    setState(() {
      _teams = teams;
      _loadingTeams = false;
      _selectedTeamId = null;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTeamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a team')),
      );
      return;
    }

    setState(() => _submitting = true);

    String? imageUrl;
    if (_imageBytes != null) {
      final storageService = ref.read(storageServiceProvider);
      imageUrl = await storageService.uploadImage(
        'player-photos',
        'players/${DateTime.now().millisecondsSinceEpoch}.png',
        _imageBytes!,
      );
    }

    final data = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'role': _role.toLowerCase(),
      'team_id': _selectedTeamId,
      'jersey_number': int.tryParse(_jerseyCtrl.text) ?? 0,
      'age': int.tryParse(_ageCtrl.text) ?? 0,
      if (imageUrl != null) 'image': imageUrl,
    };

    final success =
        await ref.read(adminProvider.notifier).createPlayer(data);

    setState(() => _submitting = false);

    if (success && mounted) {
      Navigator.pop(context);
      widget.onCreated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Add Player',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                if (_loadingTournaments)
                  const Center(child: CircularProgressIndicator())
                else
                  DropdownButtonFormField<String>(
                    value: _selectedTournamentId,
                    decoration: const InputDecoration(
                        labelText: 'Select Tournament'),
                    items: _tournaments
                        .map((t) => DropdownMenuItem(
                            value: t['id'] as String,
                            child:
                                Text(t['name'] as String? ?? 'Unnamed')))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedTournamentId = v);
                      if (v != null) _loadTeams(v);
                    },
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                const SizedBox(height: 12),
                if (_loadingTeams)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_selectedTournamentId != null)
                  DropdownButtonFormField<String>(
                    value: _selectedTeamId,
                    decoration:
                        const InputDecoration(labelText: 'Select Team'),
                    items: _teams
                        .map((t) => DropdownMenuItem(
                            value: t['id'] as String,
                            child:
                                Text(t['name'] as String? ?? 'Unnamed')))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedTeamId = v),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Player Name'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: ['WK', 'BAT', 'AR', 'BOWL']
                      .map(
                          (r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setState(() => _role = v ?? 'BAT'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _jerseyCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Jersey Number'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _ageCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Age'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _imageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(_imageBytes!,
                                fit: BoxFit.cover,
                                width: double.infinity))
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  size: 32, color: Colors.grey),
                              SizedBox(height: 4),
                              Text('Tap to select profile image',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
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
                      : const Text('Add Player'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
