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
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await ref.read(adminProvider.notifier).loadTeams();
      final s = ref.read(adminProvider);
      setState(() {
        _items = s.teams;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _items = [];
        _loading = false;
      });
    }
  }

  Future<void> _deleteTeam(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Team'),
        content: const Text('Are you sure you want to delete this team?'),
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
      await ref.read(adminProvider.notifier).deleteTeam(id);
      await _load();
    }
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _CreateTeamDialog(onCreated: () => _load()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminNavDrawer(currentRoute: '/admin/teams'),
      appBar: AppBar(
        title: const Text('Teams'),
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
              label: const Text('Create Team'),
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
          Icon(Icons.groups_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No teams yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Create your first team to get started',
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
          final logo = item['logo'] as String?;
          final name = item['name'] as String? ?? 'Unnamed';
          final captain = item['captain'] as String? ?? '';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: logo != null && logo.isNotEmpty
                    ? NetworkImage(logo)
                    : null,
                child: logo == null || logo.isEmpty
                    ? const Icon(Icons.groups)
                    : null,
              ),
              title: Text(name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: captain.isNotEmpty
                  ? Text('Captain: $captain')
                  : null,
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteTeam(item['id'] as String);
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

class _CreateTeamDialog extends ConsumerStatefulWidget {
  final VoidCallback onCreated;

  const _CreateTeamDialog({required this.onCreated});

  @override
  ConsumerState<_CreateTeamDialog> createState() =>
      _CreateTeamDialogState();
}

class _CreateTeamDialogState extends ConsumerState<_CreateTeamDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _captainCtrl = TextEditingController();
  final _viceCaptainCtrl = TextEditingController();
  final _maxSquadCtrl = TextEditingController(text: '16');
  final _minSquadCtrl = TextEditingController(text: '11');

  List<Map<String, dynamic>> _tournaments = [];
  String? _selectedTournamentId;
  Uint8List? _imageBytes;
  bool _submitting = false;
  bool _loadingTournaments = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTournaments());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _captainCtrl.dispose();
    _viceCaptainCtrl.dispose();
    _maxSquadCtrl.dispose();
    _minSquadCtrl.dispose();
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
    if (_selectedTournamentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a tournament')),
      );
      return;
    }

    setState(() => _submitting = true);

    String? imageUrl;
    if (_imageBytes != null) {
      final storageService = ref.read(storageServiceProvider);
      imageUrl = await storageService.uploadImage(
        'team-logos',
        'teams/${DateTime.now().millisecondsSinceEpoch}.png',
        _imageBytes!,
      );
    }

    final data = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'tournament_id': _selectedTournamentId,
      'captain': _captainCtrl.text.trim(),
      'vice_captain': _viceCaptainCtrl.text.trim(),
      'max_squad_size': int.tryParse(_maxSquadCtrl.text) ?? 16,
      'min_squad_size': int.tryParse(_minSquadCtrl.text) ?? 11,
      if (imageUrl != null) 'logo': imageUrl,
    };

    final success =
        await ref.read(adminProvider.notifier).createTeam(data);

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
                const Text('Create Team',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                if (_loadingTournaments)
                  const Center(child: CircularProgressIndicator())
                else
                  DropdownButtonFormField<String>(
                    value: _selectedTournamentId,
                    decoration:
                        const InputDecoration(labelText: 'Select Tournament'),
                    items: _tournaments
                        .map((t) => DropdownMenuItem(
                            value: t['id'] as String,
                            child:
                                Text(t['name'] as String? ?? 'Unnamed')))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedTournamentId = v),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Team Name'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
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
                              Text('Tap to select team logo',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _captainCtrl,
                  decoration: const InputDecoration(labelText: 'Captain'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _viceCaptainCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Vice Captain'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _maxSquadCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Max Squad Size'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _minSquadCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Min Squad Size'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
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
                      : const Text('Create'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
