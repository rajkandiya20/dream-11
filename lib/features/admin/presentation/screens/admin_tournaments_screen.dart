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
    } catch (_) {
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
        title: const Text('Tournaments',
            style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF0F172A)), onPressed: _load),
        ],
      ),
      body: Column(
        children: [
          // Create button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _showCreateDialog,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('+ Create New Tournament',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFE11D48)))
                : _tournaments.isEmpty
                    ? _buildEmpty()
                    : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.emoji_events, size: 64, color: AppColors.primary.withOpacity(0.5)),
      const SizedBox(height: 16),
      const Text('No Tournaments Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      const Text('Create your first tournament', style: TextStyle(color: Color(0xFF64748B))),
    ]),
  );

  Widget _buildList() => RefreshIndicator(
    onRefresh: _load,
    child: ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _tournaments.length,
      itemBuilder: (ctx, i) {
        final t = _tournaments[i];
        final logo = t['logo'] as String?;
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: logo != null && logo.isNotEmpty
                ? ClipRRect(borderRadius: BorderRadius.circular(8),
                    child: Image.network(logo, width: 48, height: 48, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _defaultLogo()))
                : _defaultLogo(),
            title: Text(t['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              '${t['tournament_type'] ?? 'league'} | ${t['status'] ?? '-'} | ${_formatDate(t['start_date'])}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') _showEditDialog(t);
                if (v == 'delete') _confirmDelete(t);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
        );
      },
    ),
  );

  Widget _defaultLogo() => Container(
    width: 48, height: 48,
    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
    child: Icon(Icons.emoji_events, color: AppColors.primary),
  );

  String _formatDate(dynamic d) {
    if (d == null) return '-';
    try { return DateFormat('dd MMM yyyy').format(DateTime.parse(d.toString())); }
    catch (_) { return d.toString(); }
  }

  // ========== CREATE ==========
  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final totalTeamsCtrl = TextEditingController(text: '8');
    final totalMatchesCtrl = TextEditingController(text: '15');
    String tournamentType = 'league';
    String status = 'upcoming';
    DateTime? startDate;
    DateTime? endDate;
    Uint8List? logoBytes;
    String? logoFileName;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
        title: const Text('Create Tournament', style: TextStyle(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Logo picker
          GestureDetector(
            onTap: () async {
              final picker = ImagePicker();
              final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512);
              if (file != null) {
                final bytes = await file.readAsBytes();
                setS(() { logoBytes = bytes; logoFileName = file.name; });
              }
            },
            child: Container(
              width: double.infinity, height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: logoBytes != null
                  ? ClipRRect(borderRadius: BorderRadius.circular(8),
                      child: Image.memory(logoBytes!, fit: BoxFit.cover))
                  : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.add_photo_alternate, size: 32, color: Color(0xFF94A3B8)),
                      SizedBox(height: 4),
                      Text('Tap to upload logo', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    ]),
            ),
          ),
          const SizedBox(height: 12),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tournament Name *', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: tournamentType,
            decoration: const InputDecoration(labelText: 'Tournament Type', border: OutlineInputBorder()),
            items: ['league', 'knockout', 'practice'].map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
            onChanged: (v) => setS(() => tournamentType = v!),
          ),
          const SizedBox(height: 12),
          // Start Date
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(startDate != null ? 'Start: ${DateFormat('dd MMM yyyy').format(startDate!)}' : 'Select Start Date *'),
            trailing: const Icon(Icons.calendar_today, size: 20),
            onTap: () async {
              final d = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
              if (d != null) setS(() => startDate = d);
            },
          ),
          // End Date
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(endDate != null ? 'End: ${DateFormat('dd MMM yyyy').format(endDate!)}' : 'Select End Date *'),
            trailing: const Icon(Icons.calendar_today, size: 20),
            onTap: () async {
              final d = await showDatePicker(context: ctx, initialDate: startDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
              if (d != null) setS(() => endDate = d);
            },
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: totalTeamsCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Teams', border: OutlineInputBorder()))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: totalMatchesCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Matches', border: OutlineInputBorder()))),
          ]),
          const SizedBox(height: 12),
          TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: status,
            decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
            items: ['upcoming', 'live', 'completed'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setS(() => status = v!),
          ),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) { _snack('Enter tournament name'); return; }
              if (startDate == null) { _snack('Select start date'); return; }
              if (endDate == null) { _snack('Select end date'); return; }
              if (endDate!.isBefore(startDate!)) { _snack('End date must be after start date'); return; }

              Navigator.pop(ctx);

              // Upload logo if selected
              String? logoUrl;
              if (logoBytes != null) {
                final path = '${DateTime.now().millisecondsSinceEpoch}_${logoFileName ?? 'logo.png'}';
                logoUrl = await ref.read(storageServiceProvider).uploadImage(
                  'tournament-logos', path, logoBytes!, contentType: 'image/png',
                );
              }

              final ok = await ref.read(adminProvider.notifier).createTournament({
                'name': nameCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                'tournament_type': tournamentType,
                'status': status,
                'start_date': startDate!.toIso8601String(),
                'end_date': endDate!.toIso8601String(),
                'total_teams': int.tryParse(totalTeamsCtrl.text) ?? 8,
                'total_matches': int.tryParse(totalMatchesCtrl.text) ?? 15,
                'location': locationCtrl.text.trim(),
                if (logoUrl != null) 'logo': logoUrl,
              });
              if (ok) { _load(); _snack('Tournament created!'); }
              else {
                final repo = ref.read(adminRepositoryProvider);
                _snack('Error: ${repo.lastError ?? "Unknown"}');
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      )),
    );
  }

  // ========== EDIT ==========
  void _showEditDialog(Map<String, dynamic> t) {
    final nameCtrl = TextEditingController(text: t['name'] ?? '');
    final descCtrl = TextEditingController(text: t['description'] ?? '');
    final locationCtrl = TextEditingController(text: t['location'] ?? '');
    final totalTeamsCtrl = TextEditingController(text: '${t['total_teams'] ?? 8}');
    final totalMatchesCtrl = TextEditingController(text: '${t['total_matches'] ?? 15}');
    String tournamentType = t['tournament_type'] ?? 'league';
    String status = t['status'] ?? 'upcoming';
    DateTime? startDate = t['start_date'] != null ? DateTime.tryParse(t['start_date'].toString()) : null;
    DateTime? endDate = t['end_date'] != null ? DateTime.tryParse(t['end_date'].toString()) : null;
    Uint8List? logoBytes;
    String? logoFileName;
    String? existingLogo = t['logo'] as String?;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
        title: const Text('Edit Tournament', style: TextStyle(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Logo
          GestureDetector(
            onTap: () async {
              final picker = ImagePicker();
              final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512);
              if (file != null) {
                final bytes = await file.readAsBytes();
                setS(() { logoBytes = bytes; logoFileName = file.name; });
              }
            },
            child: Container(
              width: double.infinity, height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: logoBytes != null
                  ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.memory(logoBytes!, fit: BoxFit.cover))
                  : existingLogo != null && existingLogo!.isNotEmpty
                      ? ClipRRect(borderRadius: BorderRadius.circular(8),
                          child: Image.network(existingLogo!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _logoPlaceholder()))
                      : _logoPlaceholder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tournament Name *', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: tournamentType,
            decoration: const InputDecoration(labelText: 'Tournament Type', border: OutlineInputBorder()),
            items: ['league', 'knockout', 'practice'].map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
            onChanged: (v) => setS(() => tournamentType = v!),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(startDate != null ? 'Start: ${DateFormat('dd MMM yyyy').format(startDate!)}' : 'Select Start Date'),
            trailing: const Icon(Icons.calendar_today, size: 20),
            onTap: () async {
              final d = await showDatePicker(context: ctx, initialDate: startDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
              if (d != null) setS(() => startDate = d);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(endDate != null ? 'End: ${DateFormat('dd MMM yyyy').format(endDate!)}' : 'Select End Date'),
            trailing: const Icon(Icons.calendar_today, size: 20),
            onTap: () async {
              final d = await showDatePicker(context: ctx, initialDate: endDate ?? startDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
              if (d != null) setS(() => endDate = d);
            },
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: totalTeamsCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Teams', border: OutlineInputBorder()))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: totalMatchesCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Matches', border: OutlineInputBorder()))),
          ]),
          const SizedBox(height: 12),
          TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: status,
            decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
            items: ['upcoming', 'live', 'completed'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setS(() => status = v!),
          ),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) { _snack('Enter tournament name'); return; }
              Navigator.pop(ctx);

              String? logoUrl = existingLogo;
              if (logoBytes != null) {
                final path = '${DateTime.now().millisecondsSinceEpoch}_${logoFileName ?? 'logo.png'}';
                logoUrl = await ref.read(storageServiceProvider).uploadImage(
                  'tournament-logos', path, logoBytes!, contentType: 'image/png',
                );
              }

              final ok = await ref.read(adminProvider.notifier).updateTournament(t['id'] as String, {
                'name': nameCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                'tournament_type': tournamentType,
                'status': status,
                if (startDate != null) 'start_date': startDate!.toIso8601String(),
                if (endDate != null) 'end_date': endDate!.toIso8601String(),
                'total_teams': int.tryParse(totalTeamsCtrl.text) ?? 8,
                'total_matches': int.tryParse(totalMatchesCtrl.text) ?? 15,
                'location': locationCtrl.text.trim(),
                if (logoUrl != null) 'logo': logoUrl,
              });
              if (ok) { _load(); _snack('Tournament updated!'); }
              else { _snack('Failed to update'); }
            },
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      )),
    );
  }

  Widget _logoPlaceholder() => const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.add_photo_alternate, size: 32, color: Color(0xFF94A3B8)),
      SizedBox(height: 4),
      Text('Tap to change logo', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
    ],
  );

  // ========== DELETE ==========
  void _confirmDelete(Map<String, dynamic> t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Tournament'),
        content: Text('Delete "${t['name']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(adminProvider.notifier).deleteTournament(t['id'] as String);
              _load();
              _snack('Tournament deleted');
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
