import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_nav_drawer.dart';

class AdminMatchesScreen extends ConsumerStatefulWidget {
  const AdminMatchesScreen({super.key});

  @override
  ConsumerState<AdminMatchesScreen> createState() =>
      _AdminMatchesScreenState();
}

class _AdminMatchesScreenState extends ConsumerState<AdminMatchesScreen> {
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
      await ref.read(adminProvider.notifier).loadMatches();
      final s = ref.read(adminProvider);
      setState(() {
        _items = s.matches;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _items = [];
        _loading = false;
      });
    }
  }

  Future<void> _deleteMatch(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Match'),
        content: const Text('Are you sure you want to delete this match?'),
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
      await ref.read(adminProvider.notifier).deleteMatch(id);
      await _load();
    }
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _CreateMatchDialog(onCreated: (matchId) {
        _load();
        if (matchId != null) {
          _showPlayingXIDialog(matchId);
        }
      }),
    );
  }

  void _showPlayingXIDialog(String matchId) {
    showDialog(
      context: context,
      builder: (ctx) => _PlayingXIDialog(matchId: matchId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminNavDrawer(currentRoute: '/admin/matches'),
      appBar: AppBar(
        title: const Text('Matches'),
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
              label: const Text('Create Match'),
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
          Icon(Icons.sports_cricket_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No matches yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Create your first match to get started',
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
          final teamA = item['team_a_name'] as String? ?? 'Team A';
          final teamB = item['team_b_name'] as String? ?? 'Team B';
          final status = item['status'] as String? ?? 'upcoming';
          final dateTime = item['date_time'] as String?;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.sports_cricket),
              ),
              title: Text('$teamA vs $teamB',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(dateTime != null
                  ? _formatDateTime(dateTime)
                  : 'No date set'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusChip(status),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteMatch(item['id'] as String);
                      } else if (value == 'playing_xi') {
                        _showPlayingXIDialog(item['id'] as String);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                          value: 'playing_xi',
                          child: Text('Set Playing XI')),
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

  String _formatDateTime(String dateTime) {
    try {
      final parsed = DateTime.parse(dateTime);
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
    } catch (_) {
      return dateTime;
    }
  }
}

class _CreateMatchDialog extends ConsumerStatefulWidget {
  final void Function(String? matchId) onCreated;

  const _CreateMatchDialog({required this.onCreated});

  @override
  ConsumerState<_CreateMatchDialog> createState() =>
      _CreateMatchDialogState();
}

class _CreateMatchDialogState extends ConsumerState<_CreateMatchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _venueCtrl = TextEditingController();

  List<Map<String, dynamic>> _tournaments = [];
  List<Map<String, dynamic>> _teams = [];
  String? _selectedTournamentId;
  String? _selectedTeamAId;
  String? _selectedTeamBId;
  DateTime? _matchDate;
  TimeOfDay? _matchTime;
  int _overs = 20;
  String _status = 'upcoming';
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
    _venueCtrl.dispose();
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
      _selectedTeamAId = null;
      _selectedTeamBId = null;
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _matchDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) setState(() => _matchDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _matchTime ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => _matchTime = time);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTeamAId == null || _selectedTeamBId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both teams')),
      );
      return;
    }
    if (_selectedTeamAId == _selectedTeamBId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team A and Team B must be different')),
      );
      return;
    }
    if (_matchDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    setState(() => _submitting = true);

    final teamA =
        _teams.firstWhere((t) => t['id'] == _selectedTeamAId);
    final teamB =
        _teams.firstWhere((t) => t['id'] == _selectedTeamBId);
    final teamAName = teamA['name'] as String? ?? 'Team A';
    final teamBName = teamB['name'] as String? ?? 'Team B';

    DateTime dateTime = _matchDate!;
    if (_matchTime != null) {
      dateTime = DateTime(
        _matchDate!.year,
        _matchDate!.month,
        _matchDate!.day,
        _matchTime!.hour,
        _matchTime!.minute,
      );
    }

    final data = <String, dynamic>{
      'tournament_id': _selectedTournamentId,
      'team_a_id': _selectedTeamAId,
      'team_b_id': _selectedTeamBId,
      'team_a_name': teamAName,
      'team_b_name': teamBName,
      'date_time': dateTime.toIso8601String(),
      'venue': _venueCtrl.text.trim(),
      'overs': _overs,
      'status': _status,
      if (_matchTime != null)
        'time':
            '${_matchTime!.hour.toString().padLeft(2, '0')}:${_matchTime!.minute.toString().padLeft(2, '0')}',
    };

    final matchId =
        await ref.read(adminProvider.notifier).createMatch(data);

    setState(() => _submitting = false);

    if (mounted) {
      Navigator.pop(context);
      widget.onCreated(matchId);
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
                const Text('Create Match',
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
                else if (_selectedTournamentId != null) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedTeamAId,
                    decoration:
                        const InputDecoration(labelText: 'Select Team A'),
                    items: _teams
                        .map((t) => DropdownMenuItem(
                            value: t['id'] as String,
                            child:
                                Text(t['name'] as String? ?? 'Unnamed')))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedTeamAId = v),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedTeamBId,
                    decoration:
                        const InputDecoration(labelText: 'Select Team B'),
                    items: _teams
                        .where((t) => t['id'] != _selectedTeamAId)
                        .map((t) => DropdownMenuItem(
                            value: t['id'] as String,
                            child:
                                Text(t['name'] as String? ?? 'Unnamed')))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedTeamBId = v),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration:
                              const InputDecoration(labelText: 'Date'),
                          child: Text(_matchDate != null
                              ? DateFormat('dd/MM/yyyy')
                                  .format(_matchDate!)
                              : 'Select'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickTime,
                        child: InputDecorator(
                          decoration:
                              const InputDecoration(labelText: 'Time'),
                          child: Text(_matchTime != null
                              ? _matchTime!.format(context)
                              : 'Select'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _venueCtrl,
                  decoration: const InputDecoration(labelText: 'Venue'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _overs,
                  decoration: const InputDecoration(labelText: 'Overs'),
                  items: [5, 10, 20, 50]
                      .map((o) => DropdownMenuItem(
                          value: o, child: Text('$o overs')))
                      .toList(),
                  onChanged: (v) => setState(() => _overs = v ?? 20),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(
                        value: 'upcoming', child: Text('Upcoming')),
                    DropdownMenuItem(value: 'live', child: Text('Live')),
                    DropdownMenuItem(
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
                      : const Text('Create Match'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog to select Playing XI after match creation.
class _PlayingXIDialog extends ConsumerStatefulWidget {
  final String matchId;

  const _PlayingXIDialog({required this.matchId});

  @override
  ConsumerState<_PlayingXIDialog> createState() =>
      _PlayingXIDialogState();
}

class _PlayingXIDialogState extends ConsumerState<_PlayingXIDialog> {
  List<Map<String, dynamic>> _matchData = [];
  List<Map<String, dynamic>> _teamAPlayers = [];
  List<Map<String, dynamic>> _teamBPlayers = [];
  Set<String> _selectedTeamA = {};
  Set<String> _selectedTeamB = {};
  String? _teamAId;
  String? _teamBId;
  String _teamAName = 'Team A';
  String _teamBName = 'Team B';
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMatchData());
  }

  Future<void> _loadMatchData() async {
    await ref.read(adminProvider.notifier).loadMatches();
    final s = ref.read(adminProvider);
    _matchData = s.matches;

    final match = _matchData.where((m) => m['id'] == widget.matchId).toList();
    if (match.isNotEmpty) {
      _teamAId = match.first['team_a_id'] as String?;
      _teamBId = match.first['team_b_id'] as String?;
      _teamAName = match.first['team_a_name'] as String? ?? 'Team A';
      _teamBName = match.first['team_b_name'] as String? ?? 'Team B';

      if (_teamAId != null) {
        _teamAPlayers = await ref
            .read(adminProvider.notifier)
            .getPlayersByTeam(_teamAId!);
      }
      if (_teamBId != null) {
        _teamBPlayers = await ref
            .read(adminProvider.notifier)
            .getPlayersByTeam(_teamBId!);
      }
    }
    setState(() => _loading = false);
  }

  bool _validateSelection(Set<String> selected, List<Map<String, dynamic>> players) {
    if (selected.length != 11) return false;
    // Check at least 1 WK
    final wkCount = players
        .where((p) => selected.contains(p['id'] as String))
        .where((p) =>
            (p['role'] as String? ?? '').toLowerCase() == 'wk')
        .length;
    return wkCount >= 1;
  }

  Future<void> _submit() async {
    if (_selectedTeamA.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Select exactly 11 players for $_teamAName (${_selectedTeamA.length} selected)')),
      );
      return;
    }
    if (!_validateSelection(_selectedTeamA, _teamAPlayers)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('$_teamAName must have at least 1 wicket-keeper')),
      );
      return;
    }
    if (_selectedTeamB.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Select exactly 11 players for $_teamBName (${_selectedTeamB.length} selected)')),
      );
      return;
    }
    if (!_validateSelection(_selectedTeamB, _teamBPlayers)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('$_teamBName must have at least 1 wicket-keeper')),
      );
      return;
    }

    setState(() => _submitting = true);

    final notifier = ref.read(adminProvider.notifier);
    await notifier.setMatchPlayers(
        widget.matchId, _selectedTeamA.toList(), _teamAId!);
    await notifier.setMatchPlayers(
        widget.matchId, _selectedTeamB.toList(), _teamBId!);

    setState(() => _submitting = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Playing XI set successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Select Playing XI',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          TabBar(
                            labelColor: AppColors.primary,
                            tabs: [
                              Tab(
                                  text:
                                      '$_teamAName (${_selectedTeamA.length}/11)'),
                              Tab(
                                  text:
                                      '$_teamBName (${_selectedTeamB.length}/11)'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildPlayerList(
                                    _teamAPlayers, _selectedTeamA, true),
                                _buildPlayerList(
                                    _teamBPlayers, _selectedTeamB, false),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Save Playing XI'),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPlayerList(List<Map<String, dynamic>> players,
      Set<String> selected, bool isTeamA) {
    if (players.isEmpty) {
      return const Center(child: Text('No players available'));
    }
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final id = player['id'] as String;
        final name = player['name'] as String? ?? 'Unknown';
        final role = (player['role'] as String? ?? '').toUpperCase();
        final isSelected = selected.contains(id);

        return CheckboxListTile(
          value: isSelected,
          onChanged: (v) {
            setState(() {
              if (v == true) {
                if (selected.length < 11) {
                  selected.add(id);
                }
              } else {
                selected.remove(id);
              }
            });
          },
          title: Text(name),
          subtitle: Text(role),
          secondary: CircleAvatar(
            backgroundColor:
                isSelected ? AppColors.primary : Colors.grey.shade300,
            child: Text(role.isNotEmpty ? role[0] : '?',
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black)),
          ),
        );
      },
    );
  }
}
