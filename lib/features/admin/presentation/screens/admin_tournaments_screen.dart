import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/services/storage_service.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_nav_drawer.dart';

class AdminTournamentsScreen extends ConsumerStatefulWidget {
  const AdminTournamentsScreen({super.key});

  @override
  ConsumerState<AdminTournamentsScreen> createState() =>
      _AdminTournamentsScreenState();
}

class _AdminTournamentsScreenState
    extends ConsumerState<AdminTournamentsScreen> {
  bool _loading = false;
  List<Map<String, dynamic>> _tournaments = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await ref.read(adminProvider.notifier).loadTournaments();
      final s = ref.read(adminProvider);
      setState(() {
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
      drawer: const AdminNavDrawer(currentRoute: '/admin/tournaments'),
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
          'Tournaments',
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
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                '+ Create New Tournament',
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
                : _tournaments.isEmpty
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
                'No Tournaments Found',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
            ],
          ),
        ),
      );

  Widget _buildList() => ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _tournaments.length,
        itemBuilder: (ctx, i) {
          final t = _tournaments[i];
          final logoUrl = t['logo'] as String?;
          final startDate = t['start_date'] as String?;
          final formattedDate = startDate != null
              ? DateFormat('dd MMM yyyy').format(DateTime.parse(startDate))
              : '-';
          final tournamentType = t['tournament_type'] as String? ?? '-';
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFFEE2E2),
                backgroundImage:
                    logoUrl != null ? NetworkImage(logoUrl) : null,
                child: logoUrl == null
                    ? const Icon(Icons.emoji_events,
                        color: Color(0xFFE11D48))
                    : null,
              ),
              title: Text(t['name'] ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                  '$tournamentType | $formattedDate | ${t['status'] ?? '-'}'),
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

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final totalTeamsCtrl = TextEditingController();
    final totalMatchesCtrl = TextEditingController();
    String status = 'upcoming';
    String tournamentType = 'league';
    DateTime? startDate;
    DateTime? endDate;
    Uint8List? logoBytes;
    String? logoFileName;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Create Tournament',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tournament Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
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
                  label: Text(logoFileName ?? 'Pick Tournament Logo'),
                ),
                if (logoBytes != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Image.memory(logoBytes!,
                        height: 60, fit: BoxFit.contain),
                  ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: tournamentType,
                  decoration: const InputDecoration(
                    labelText: 'Tournament Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ['league', 'knockout', 'practice']
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setS(() => tournamentType = v!),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(startDate != null
                      ? 'Start: ${DateFormat('dd MMM yyyy').format(startDate!)}'
                      : 'Select Start Date'),
                  trailing:
                      const Icon(Icons.calendar_today, size: 20),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setS(() {
                        startDate = picked;
                        if (endDate != null &&
                            endDate!.isBefore(picked)) {
                          endDate = null;
                        }
                      });
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(endDate != null
                      ? 'End: ${DateFormat('dd MMM yyyy').format(endDate!)}'
                      : 'Select End Date'),
                  trailing:
                      const Icon(Icons.calendar_today, size: 20),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate:
                          startDate ?? DateTime.now(),
                      firstDate:
                          startDate ?? DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setS(() => endDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: totalTeamsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Total Teams',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: totalMatchesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Total Matches',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
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
                  items: ['upcoming', 'live', 'completed']
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text(s)))
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
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;

                Navigator.pop(ctx);

                // Upload logo if selected
                String? logoUrl;
                if (logoBytes != null) {
                  final path =
                      'tournament_${DateTime.now().millisecondsSinceEpoch}.png';
                  logoUrl = await ref
                      .read(storageServiceProvider)
                      .uploadImage(
                        'tournament-logos',
                        path,
                        logoBytes!,
                        contentType: 'image/png',
                      );
                }

                final data = <String, dynamic>{
                  'name': nameCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'status': status,
                  'tournament_type': tournamentType,
                  'location': locationCtrl.text.trim(),
                  if (logoUrl != null) 'logo': logoUrl,
                  if (startDate != null)
                    'start_date': startDate!.toIso8601String(),
                  if (endDate != null)
                    'end_date': endDate!.toIso8601String(),
                  if (totalTeamsCtrl.text.trim().isNotEmpty)
                    'total_teams':
                        int.tryParse(totalTeamsCtrl.text.trim()) ?? 0,
                  if (totalMatchesCtrl.text.trim().isNotEmpty)
                    'total_matches':
                        int.tryParse(totalMatchesCtrl.text.trim()) ?? 0,
                };

                final ok = await ref
                    .read(adminProvider.notifier)
                    .createTournament(data);
                if (ok) {
                  _load();
                  _snack('Tournament created!');
                } else {
                  final error =
                      ref.read(adminRepositoryProvider).lastError ??
                          'Unknown error';
                  _snack('Failed to create: $error');
                }
              },
              child: const Text('Create',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> t) {
    final nameCtrl = TextEditingController(text: t['name'] ?? '');
    final descCtrl = TextEditingController(text: t['description'] ?? '');
    final locationCtrl =
        TextEditingController(text: t['location'] ?? '');
    final totalTeamsCtrl = TextEditingController(
        text: (t['total_teams'] ?? '').toString());
    final totalMatchesCtrl = TextEditingController(
        text: (t['total_matches'] ?? '').toString());
    String status = t['status'] ?? 'upcoming';
    String tournamentType = t['tournament_type'] ?? 'league';
    DateTime? startDate = t['start_date'] != null
        ? DateTime.tryParse(t['start_date'] as String)
        : null;
    DateTime? endDate = t['end_date'] != null
        ? DateTime.tryParse(t['end_date'] as String)
        : null;
    Uint8List? logoBytes;
    String? logoFileName;
    String? existingLogoUrl = t['logo'] as String?;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Edit Tournament',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tournament Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
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
                  )
                else if (existingLogoUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Image.network(existingLogoUrl!,
                        height: 60, fit: BoxFit.contain),
                  ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: tournamentType,
                  decoration: const InputDecoration(
                    labelText: 'Tournament Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ['league', 'knockout', 'practice']
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setS(() => tournamentType = v!),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(startDate != null
                      ? 'Start: ${DateFormat('dd MMM yyyy').format(startDate!)}'
                      : 'Select Start Date'),
                  trailing:
                      const Icon(Icons.calendar_today, size: 20),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate:
                          startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setS(() {
                        startDate = picked;
                        if (endDate != null &&
                            endDate!.isBefore(picked)) {
                          endDate = null;
                        }
                      });
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(endDate != null
                      ? 'End: ${DateFormat('dd MMM yyyy').format(endDate!)}'
                      : 'Select End Date'),
                  trailing:
                      const Icon(Icons.calendar_today, size: 20),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate:
                          startDate ?? DateTime.now(),
                      firstDate:
                          startDate ?? DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setS(() => endDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: totalTeamsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Total Teams',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: totalMatchesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Total Matches',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
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
                  items: ['upcoming', 'live', 'completed']
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text(s)))
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
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              onPressed: () async {
                Navigator.pop(ctx);

                // Upload new logo if selected
                String? logoUrl = existingLogoUrl;
                if (logoBytes != null) {
                  final path =
                      'tournament_${DateTime.now().millisecondsSinceEpoch}.png';
                  logoUrl = await ref
                      .read(storageServiceProvider)
                      .uploadImage(
                        'tournament-logos',
                        path,
                        logoBytes!,
                        contentType: 'image/png',
                      );
                }

                final data = <String, dynamic>{
                  'name': nameCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'status': status,
                  'tournament_type': tournamentType,
                  'location': locationCtrl.text.trim(),
                  if (logoUrl != null) 'logo': logoUrl,
                  if (startDate != null)
                    'start_date': startDate!.toIso8601String(),
                  if (endDate != null)
                    'end_date': endDate!.toIso8601String(),
                  if (totalTeamsCtrl.text.trim().isNotEmpty)
                    'total_teams':
                        int.tryParse(totalTeamsCtrl.text.trim()) ?? 0,
                  if (totalMatchesCtrl.text.trim().isNotEmpty)
                    'total_matches':
                        int.tryParse(totalMatchesCtrl.text.trim()) ?? 0,
                };

                final ok = await ref
                    .read(adminProvider.notifier)
                    .updateTournament(t['id'] as String, data);
                if (ok) {
                  _load();
                  _snack('Tournament updated!');
                } else {
                  _snack('Failed to update tournament');
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
        title: const Text('Delete Tournament'),
        content: Text('Are you sure you want to delete "${t['name']}"?'),
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
                  .deleteTournament(t['id'] as String);
              if (ok) {
                _load();
                _snack('Tournament deleted');
              } else {
                _snack('Failed to delete tournament');
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
