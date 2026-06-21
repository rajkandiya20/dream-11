import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/admin_repository.dart';
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
  List<Map<String, dynamic>> _matches = [];
  List<Map<String, dynamic>> _tournaments = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await ref.read(adminProvider.notifier).loadMatches();
      await ref.read(adminProvider.notifier).loadTournaments();
      final s = ref.read(adminProvider);
      setState(() {
        _matches = s.matches;
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
      drawer: const AdminNavDrawer(currentRoute: '/admin/matches'),
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
          'Matches',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700),
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
                '+ Create New Match',
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
                    child: CircularProgressIndicator(color: Color(0xFFE11D48)))
                : _matches.isEmpty
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
              Icon(Icons.sports_cricket, size: 64, color: Color(0xFFE11D48)),
              SizedBox(height: 16),
              Text(
                'No Matches Found',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
            ],
          ),
        ),
      );

  Widget _buildList() => ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _matches.length,
        itemBuilder: (ctx, i) {
          final m = _matches[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              leading: const Icon(Icons.sports_cricket, color: Color(0xFFE11D48)),
              title: Text(
                '${m['team_a_name'] ?? '-'} vs ${m['team_b_name'] ?? '-'}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('${m['status'] ?? '-'} | ${m['venue'] ?? '-'}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.people, color: Color(0xFF10B981)),
                    tooltip: 'Playing XI',
                    onPressed: () => _showPlayingXIDialog(m),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
                    onPressed: () => _showEditDialog(m),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
                    onPressed: () => _confirmDelete(m),
                  ),
                ],
              ),
            ),
          );
        },
      );

  void _showCreateDialog() {
    String? selectedTournamentId;
    String? selectedTeamAId;
    String? selectedTeamBId;
    List<Map<String, dynamic>> tournamentTeams = [];
    final venueCtrl = TextEditingController();
    final oversCtrl = TextEditingController(text: '20');
    String status = 'upcoming';
    DateTime? matchDate;
    TimeOfDay? matchTime;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Create Match',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  onChanged: (v) async {
                    setS(() {
                      selectedTournamentId = v;
                      selectedTeamAId = null;
                      selectedTeamBId = null;
                      tournamentTeams = [];
                    });
                    if (v != null) {
                      final teams = await ref
                          .read(adminProvider.notifier)
                          .getTeamsByTournament(v);
                      setS(() => tournamentTeams = teams);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedTeamAId,
                  decoration: const InputDecoration(
                    labelText: 'Team A',
                    border: OutlineInputBorder(),
                  ),
                  items: tournamentTeams
                      .map((t) => DropdownMenuItem<String>(
                            value: t['id'] as String,
                            child: Text(t['name'] ?? '-'),
                          ))
                      .toList(),
                  onChanged: (v) => setS(() => selectedTeamAId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedTeamBId,
                  decoration: const InputDecoration(
                    labelText: 'Team B',
                    border: OutlineInputBorder(),
                  ),
                  items: tournamentTeams
                      .where((t) => t['id'] != selectedTeamAId)
                      .map((t) => DropdownMenuItem<String>(
                            value: t['id'] as String,
                            child: Text(t['name'] ?? '-'),
                          ))
                      .toList(),
                  onChanged: (v) => setS(() => selectedTeamBId = v),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(matchDate == null
                      ? 'Select Date'
                      : DateFormat('yyyy-MM-dd').format(matchDate!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                    );
                    if (d != null) setS(() => matchDate = d);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(matchTime == null
                      ? 'Select Time'
                      : matchTime!.format(ctx)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final t = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay.now(),
                    );
                    if (t != null) setS(() => matchTime = t);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: venueCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Venue',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: oversCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Overs',
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
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                if (selectedTournamentId == null ||
                    selectedTeamAId == null ||
                    selectedTeamBId == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                        content: Text('Please select tournament and both teams')),
                  );
                  return;
                }
                if (selectedTeamAId == selectedTeamBId) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                        content: Text('Team A and Team B cannot be the same')),
                  );
                  return;
                }
                Navigator.pop(ctx);

                final teamA = tournamentTeams
                    .firstWhere((t) => t['id'] == selectedTeamAId);
                final teamB = tournamentTeams
                    .firstWhere((t) => t['id'] == selectedTeamBId);

                String? dateTimeStr;
                if (matchDate != null) {
                  final dt = DateTime(
                    matchDate!.year,
                    matchDate!.month,
                    matchDate!.day,
                    matchTime?.hour ?? 0,
                    matchTime?.minute ?? 0,
                  );
                  dateTimeStr = dt.toIso8601String();
                }

                final matchId = await ref
                    .read(adminProvider.notifier)
                    .createMatch({
                  'tournament_id': selectedTournamentId,
                  'team_a_id': selectedTeamAId,
                  'team_b_id': selectedTeamBId,
                  'team_a_name': teamA['name'],
                  'team_b_name': teamB['name'],
                  'venue': venueCtrl.text.trim(),
                  'overs': int.tryParse(oversCtrl.text) ?? 20,
                  'status': status,
                  if (dateTimeStr != null) 'date_time': dateTimeStr,
                  if (matchTime != null)
                    'time': matchTime!.format(ctx),
                });

                if (matchId != null) {
                  _load();
                  _snack('Match created!');
                  // Show Playing XI dialog
                  _showPlayingXIDialogForNewMatch(
                    matchId,
                    selectedTeamAId!,
                    selectedTeamBId!,
                    teamA['name'] ?? 'Team A',
                    teamB['name'] ?? 'Team B',
                  );
                } else {
                  final error = ref.read(adminRepositoryProvider).lastError ?? 'Unknown error';
                  _snack('Failed: $error');
                }
              },
              child: const Text('Create', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlayingXIDialog(Map<String, dynamic> match) {
    final matchId = match['id'] as String;
    final teamAId = match['team_a_id'] as String?;
    final teamBId = match['team_b_id'] as String?;
    final teamAName = match['team_a_name'] ?? 'Team A';
    final teamBName = match['team_b_name'] ?? 'Team B';

    if (teamAId == null || teamBId == null) {
      _snack('Match has no teams assigned');
      return;
    }

    _showPlayingXIDialogForNewMatch(
        matchId, teamAId, teamBId, teamAName, teamBName);
  }

  void _showPlayingXIDialogForNewMatch(
    String matchId,
    String teamAId,
    String teamBId,
    String teamAName,
    String teamBName,
  ) {
    List<Map<String, dynamic>> teamAPlayers = [];
    List<Map<String, dynamic>> teamBPlayers = [];
    List<String> selectedTeamAPlayerIds = [];
    List<String> selectedTeamBPlayerIds = [];
    bool loadingPlayers = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          // Load players on first build
          if (loadingPlayers) {
            Future.microtask(() async {
              final pA = await ref
                  .read(adminProvider.notifier)
                  .getPlayersByTeam(teamAId);
              final pB = await ref
                  .read(adminProvider.notifier)
                  .getPlayersByTeam(teamBId);
              setS(() {
                teamAPlayers = pA;
                teamBPlayers = pB;
                loadingPlayers = false;
              });
            });
          }

          return AlertDialog(
            title: const Text('Select Playing XI',
                style: TextStyle(fontWeight: FontWeight.w700)),
            content: SizedBox(
              width: double.maxFinite,
              child: loadingPlayers
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$teamAName (${selectedTeamAPlayerIds.length}/11)',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          ...teamAPlayers.map((p) {
                            final pid = p['id'] as String;
                            final selected =
                                selectedTeamAPlayerIds.contains(pid);
                            return CheckboxListTile(
                              dense: true,
                              value: selected,
                              title: Text('${p['name']} (${p['role'] ?? '-'})'),
                              onChanged: (v) {
                                setS(() {
                                  if (v == true) {
                                    if (selectedTeamAPlayerIds.length < 11) {
                                      selectedTeamAPlayerIds.add(pid);
                                    }
                                  } else {
                                    selectedTeamAPlayerIds.remove(pid);
                                  }
                                });
                              },
                            );
                          }).toList(),
                          const Divider(height: 24),
                          Text(
                            '$teamBName (${selectedTeamBPlayerIds.length}/11)',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          ...teamBPlayers.map((p) {
                            final pid = p['id'] as String;
                            final selected =
                                selectedTeamBPlayerIds.contains(pid);
                            return CheckboxListTile(
                              dense: true,
                              value: selected,
                              title: Text('${p['name']} (${p['role'] ?? '-'})'),
                              onChanged: (v) {
                                setS(() {
                                  if (v == true) {
                                    if (selectedTeamBPlayerIds.length < 11) {
                                      selectedTeamBPlayerIds.add(pid);
                                    }
                                  } else {
                                    selectedTeamBPlayerIds.remove(pid);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ],
                      ),
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Skip'),
              ),
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () async {
                  if (selectedTeamAPlayerIds.length != 11) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text(
                            'Select exactly 11 players for $teamAName')));
                    return;
                  }
                  if (selectedTeamBPlayerIds.length != 11) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text(
                            'Select exactly 11 players for $teamBName')));
                    return;
                  }
                  // Validate at least 1 WK per team
                  final teamAWK = teamAPlayers
                      .where((p) =>
                          selectedTeamAPlayerIds.contains(p['id']) &&
                          p['role'] == 'WK')
                      .length;
                  final teamBWK = teamBPlayers
                      .where((p) =>
                          selectedTeamBPlayerIds.contains(p['id']) &&
                          p['role'] == 'WK')
                      .length;
                  if (teamAWK < 1) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text(
                            '$teamAName must have at least 1 WK')));
                    return;
                  }
                  if (teamBWK < 1) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text(
                            '$teamBName must have at least 1 WK')));
                    return;
                  }
                  Navigator.pop(ctx);

                  final okA = await ref
                      .read(adminProvider.notifier)
                      .setMatchPlayers(
                          matchId, selectedTeamAPlayerIds, teamAId);
                  final okB = await ref
                      .read(adminProvider.notifier)
                      .setMatchPlayers(
                          matchId, selectedTeamBPlayerIds, teamBId);

                  if (okA && okB) {
                    _snack('Playing XI saved!');
                  } else {
                    _snack('Failed to save Playing XI');
                  }
                },
                child: const Text('Save Playing XI',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> m) {
    final venueCtrl = TextEditingController(text: m['venue'] ?? '');
    final oversCtrl = TextEditingController(text: '${m['overs'] ?? 20}');
    String status = m['status'] ?? 'upcoming';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Edit Match',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: venueCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Venue',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: oversCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Overs',
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
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                Navigator.pop(ctx);
                final ok = await ref
                    .read(adminProvider.notifier)
                    .updateMatch(m['id'] as String, {
                  'venue': venueCtrl.text.trim(),
                  'overs': int.tryParse(oversCtrl.text) ?? 20,
                  'status': status,
                });
                if (ok) {
                  _load();
                  _snack('Match updated!');
                } else {
                  _snack('Failed to update');
                }
              },
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> m) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Match'),
        content:
            Text('Delete "${m['team_a_name']} vs ${m['team_b_name']}"?'),
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
                  .deleteMatch(m['id'] as String);
              if (ok) {
                _load();
                _snack('Match deleted');
              } else {
                _snack('Failed to delete');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
