import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
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
  List<Map<String, dynamic>> _items = [];

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
        _items = s.tournaments;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _items = [];
        _loading = false;
      });
    }
  }

  Future<void> _deleteTournament(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Tournament'),
        content:
            const Text('Are you sure you want to delete this tournament?'),
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
      await ref.read(adminProvider.notifier).deleteTournament(id);
      await _load();
    }
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _CreateTournamentDialog(
        onCreated: () => _load(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminNavDrawer(currentRoute: '/admin/tournaments'),
      appBar: AppBar(
        title: const Text('Tournaments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
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
              label: const Text('Create Tournament'),
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
          Icon(Icons.emoji_events_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No tournaments yet',
              style: TextStyle(
                  fontSize: 18, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Create your first tournament to get started',
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
          final status = item['status'] as String? ?? 'upcoming';
          final startDate = item['start_date'] as String?;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: logo != null && logo.isNotEmpty
                    ? NetworkImage(logo)
                    : null,
                child: logo == null || logo.isEmpty
                    ? const Icon(Icons.emoji_events)
                    : null,
              ),
              title: Text(name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(startDate != null
                  ? 'Starts: ${_formatDate(startDate)}'
                  : 'No start date'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusChip(status),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteTournament(item['id'] as String);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                          value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'live':
        color = AppColors.liveMatch;
        break;
      case 'completed':
        color = AppColors.completedMatch;
        break;
      default:
        color = AppColors.upcomingMatch;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      return date;
    }
  }
}

class _CreateTournamentDialog extends ConsumerStatefulWidget {
  final VoidCallback onCreated;

  const _CreateTournamentDialog({required this.onCreated});

  @override
  ConsumerState<_CreateTournamentDialog> createState() =>
      _CreateTournamentDialogState();
}

class _CreateTournamentDialogState
    extends ConsumerState<_CreateTournamentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _totalTeamsCtrl = TextEditingController();
  final _totalMatchesCtrl = TextEditingController();

  String _tournamentType = 'League';
  String _status = 'upcoming';
  DateTime? _startDate;
  DateTime? _endDate;
  Uint8List? _imageBytes;
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _locationCtrl.dispose();
    _totalTeamsCtrl.dispose();
    _totalMatchesCtrl.dispose();
    super.dispose();
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

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('End date must be after start date')),
      );
      return;
    }

    setState(() => _submitting = true);

    String? imageUrl;
    if (_imageBytes != null) {
      final storageService = ref.read(storageServiceProvider);
      imageUrl = await storageService.uploadImage(
        'tournament-logos',
        'tournaments/${DateTime.now().millisecondsSinceEpoch}.png',
        _imageBytes!,
      );
    }

    final data = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'description': _descriptionCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'tournament_type': _tournamentType.toLowerCase(),
      'status': _status,
      'start_date': _startDate!.toIso8601String(),
      'end_date': _endDate!.toIso8601String(),
      'total_teams': int.tryParse(_totalTeamsCtrl.text) ?? 0,
      'total_matches': int.tryParse(_totalMatchesCtrl.text) ?? 0,
      if (imageUrl != null) 'logo': imageUrl,
    };

    final success =
        await ref.read(adminProvider.notifier).createTournament(data);

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
                const Text('Create Tournament',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Tournament Name'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                // Logo picker
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
                              Text('Tap to select logo',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _tournamentType,
                  decoration:
                      const InputDecoration(labelText: 'Tournament Type'),
                  items: ['League', 'Knockout', 'Practice']
                      .map((t) =>
                          DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _tournamentType = v ?? 'League'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickStartDate,
                        child: InputDecorator(
                          decoration:
                              const InputDecoration(labelText: 'Start Date'),
                          child: Text(_startDate != null
                              ? DateFormat('dd/MM/yyyy')
                                  .format(_startDate!)
                              : 'Select'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickEndDate,
                        child: InputDecorator(
                          decoration:
                              const InputDecoration(labelText: 'End Date'),
                          child: Text(_endDate != null
                              ? DateFormat('dd/MM/yyyy').format(_endDate!)
                              : 'Select'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _totalTeamsCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Total Teams'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _totalMatchesCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Total Matches'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _locationCtrl,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: [
                    const DropdownMenuItem(
                        value: 'upcoming', child: Text('Upcoming')),
                    const DropdownMenuItem(
                        value: 'live', child: Text('Live')),
                    const DropdownMenuItem(
                        value: 'completed', child: Text('Completed')),
                  ],
                  onChanged: (v) =>
                      setState(() => _status = v ?? 'upcoming'),
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
