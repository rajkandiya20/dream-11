import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_nav_drawer.dart';

class AdminContestsScreen extends ConsumerStatefulWidget {
  const AdminContestsScreen({super.key});

  @override
  ConsumerState<AdminContestsScreen> createState() =>
      _AdminContestsScreenState();
}

class _AdminContestsScreenState extends ConsumerState<AdminContestsScreen> {
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
      await ref.read(adminProvider.notifier).loadContests();
      final s = ref.read(adminProvider);
      setState(() {
        _items = s.contests;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _items = [];
        _loading = false;
      });
    }
  }

  Future<void> _deleteContest(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Contest'),
        content:
            const Text('Are you sure you want to delete this contest?'),
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
      await ref.read(adminProvider.notifier).deleteContest(id);
      await _load();
    }
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _CreateContestDialog(onCreated: () => _load()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminNavDrawer(currentRoute: '/admin/contests'),
      appBar: AppBar(
        title: const Text('Contests'),
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
              label: const Text('Create Contest'),
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
          Icon(Icons.sports_esports_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No contests yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Create your first contest to get started',
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
          final name = item['name'] as String? ?? 'Unnamed';
          final prizePool = item['prize_pool'];
          final entryFee = item['entry_fee'];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.emoji_events, color: Colors.white),
              ),
              title: Text(name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                  'Prize: ${_formatCurrency(prizePool)} | Entry: ${_formatCurrency(entryFee)}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteContest(item['id'] as String);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                      value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return '0';
    final num amount = value is num ? value : num.tryParse(value.toString()) ?? 0;
    return amount.toStringAsFixed(0);
  }
}

class _CreateContestDialog extends ConsumerStatefulWidget {
  final VoidCallback onCreated;

  const _CreateContestDialog({required this.onCreated});

  @override
  ConsumerState<_CreateContestDialog> createState() =>
      _CreateContestDialogState();
}

class _CreateContestDialogState
    extends ConsumerState<_CreateContestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _entryFeeCtrl = TextEditingController();
  final _prizePoolCtrl = TextEditingController();
  final _totalSpotsCtrl = TextEditingController();
  final _maxTeamsPerUserCtrl = TextEditingController(text: '1');

  List<Map<String, dynamic>> _matches = [];
  String? _selectedMatchId;
  String _contestType = 'Mega';
  bool _submitting = false;
  bool _loadingMatches = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMatches());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _entryFeeCtrl.dispose();
    _prizePoolCtrl.dispose();
    _totalSpotsCtrl.dispose();
    _maxTeamsPerUserCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMatches() async {
    await ref.read(adminProvider.notifier).loadMatches();
    final s = ref.read(adminProvider);
    setState(() {
      _matches = s.matches;
      _loadingMatches = false;
    });
  }

  double get _collectedAmount {
    final entryFee = double.tryParse(_entryFeeCtrl.text) ?? 0;
    final totalSpots = int.tryParse(_totalSpotsCtrl.text) ?? 0;
    return entryFee * totalSpots;
  }

  double get _profit {
    return _collectedAmount - (double.tryParse(_prizePoolCtrl.text) ?? 0);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMatchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a match')),
      );
      return;
    }

    setState(() => _submitting = true);

    final data = <String, dynamic>{
      'match_id': _selectedMatchId,
      'name': _nameCtrl.text.trim(),
      'entry_fee': double.tryParse(_entryFeeCtrl.text) ?? 0,
      'prize_pool': double.tryParse(_prizePoolCtrl.text) ?? 0,
      'total_spots': int.tryParse(_totalSpotsCtrl.text) ?? 0,
      'max_teams_per_user': int.tryParse(_maxTeamsPerUserCtrl.text) ?? 1,
      'contest_type': _contestType.toLowerCase().replaceAll(' ', '_'),
      'status': 'upcoming',
      'joined_teams': 0,
      'max_teams': int.tryParse(_totalSpotsCtrl.text) ?? 0,
      'winning_distribution': _profit > 0
          ? '{"1st": ${(_collectedAmount * 0.5).toStringAsFixed(0)}, "2nd": ${(_collectedAmount * 0.3).toStringAsFixed(0)}, "3rd": ${(_collectedAmount * 0.2).toStringAsFixed(0)}}'
          : '{}',
    };

    final success =
        await ref.read(adminProvider.notifier).createContest(data);

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
                const Text('Create Contest',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                if (_loadingMatches)
                  const Center(child: CircularProgressIndicator())
                else
                  DropdownButtonFormField<String>(
                    value: _selectedMatchId,
                    decoration: const InputDecoration(
                        labelText: 'Select Match'),
                    items: _matches
                        .map((m) => DropdownMenuItem(
                            value: m['id'] as String,
                            child: Text(
                                '${m['team_a_name'] ?? ''} vs ${m['team_b_name'] ?? ''}')))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedMatchId = v),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Contest Name'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _entryFeeCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Entry Fee'),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        validator: (v) =>
                            v == null || v.trim().isEmpty
                                ? 'Required'
                                : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _prizePoolCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Prize Pool'),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        validator: (v) =>
                            v == null || v.trim().isEmpty
                                ? 'Required'
                                : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _totalSpotsCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Total Spots'),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        validator: (v) =>
                            v == null || v.trim().isEmpty
                                ? 'Required'
                                : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _maxTeamsPerUserCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Max Teams/User'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _contestType,
                  decoration:
                      const InputDecoration(labelText: 'Contest Type'),
                  items: [
                    'Mega',
                    'HeadToHead',
                    'Small League',
                    'Winner Takes All'
                  ]
                      .map(
                          (t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _contestType = v ?? 'Mega'),
                ),
                const SizedBox(height: 16),
                // Auto-calculated fields
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Auto-calculated',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Collected Amount:'),
                          Text(_collectedAmount.toStringAsFixed(0),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Profit:'),
                          Text(
                            _profit.toStringAsFixed(0),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _profit >= 0
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ],
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
                      : const Text('Create Contest'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
