import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_nav_drawer.dart';

/// Admin scoreboard screen - update player scores for live matches.
class AdminScoreboardScreen extends ConsumerStatefulWidget {
  const AdminScoreboardScreen({super.key});

  @override
  ConsumerState<AdminScoreboardScreen> createState() =>
      _AdminScoreboardScreenState();
}

class _AdminScoreboardScreenState
    extends ConsumerState<AdminScoreboardScreen> {
  String? _selectedMatchId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadMatches(status: 'live');
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          ),
        ),
        title: Text(
          'Scoreboard',
          style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
      ),
      drawer: const AdminNavDrawer(currentRoute: '/admin/scoreboard'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match selector
            Text('Select Match', style: AppTypography.titleMedium),
            AppSpacing.gapH8,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: AppSpacing.borderRadiusSm,
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedMatchId,
                  hint: const Text('Select a live match'),
                  isExpanded: true,
                  items: adminState.matches.map((match) {
                    final teamA = match['team_a_name'] ?? '';
                    final teamB = match['team_b_name'] ?? '';
                    return DropdownMenuItem(
                      value: match['id'] as String,
                      child: Text('$teamA vs $teamB'),
                    );
                  }).toList(),
                  onChanged: (matchId) {
                    setState(() => _selectedMatchId = matchId);
                    if (matchId != null) {
                      ref
                          .read(adminProvider.notifier)
                          .loadScoreboard(matchId);
                    }
                  },
                ),
              ),
            ),
            AppSpacing.gapH24,
            // Scoreboard entries
            if (_selectedMatchId != null && adminState.scoreboard.isNotEmpty)
              ...adminState.scoreboard.map((entry) {
                final player = entry['player'] as Map<String, dynamic>?;
                return _ScoreboardEntryCard(
                  playerName: player?['name'] ?? 'Unknown',
                  playerRole: player?['role'] ?? '',
                  runs: entry['runs'] as int? ?? 0,
                  wickets: entry['wickets'] as int? ?? 0,
                  catches: entry['catches'] as int? ?? 0,
                  points: (entry['points'] as num?)?.toDouble() ?? 0,
                  onEdit: () => _showScoreEditDialog(entry),
                );
              })
            else if (_selectedMatchId != null &&
                adminState.scoreboard.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.scoreboard_outlined,
                          size: 48, color: AppColors.textTertiary),
                      AppSpacing.gapH12,
                      Text(
                        'No scores yet for this match',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      AppSpacing.gapH16,
                      ElevatedButton.icon(
                        onPressed: () => _showScoreEditDialog(null),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Add Score Entry',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Text(
                    'Select a match to manage scores',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showScoreEditDialog(Map<String, dynamic>? entry) {
    final runsController =
        TextEditingController(text: '${entry?['runs'] ?? 0}');
    final wicketsController =
        TextEditingController(text: '${entry?['wickets'] ?? 0}');
    final catchesController =
        TextEditingController(text: '${entry?['catches'] ?? 0}');
    final foursController =
        TextEditingController(text: '${entry?['fours'] ?? 0}');
    final sixesController =
        TextEditingController(text: '${entry?['sixes'] ?? 0}');
    final ballsFacedController =
        TextEditingController(text: '${entry?['balls_faced'] ?? 0}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLg,
        ),
        title: Text(
          'Update Score',
          style: AppTypography.titleLarge,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: runsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Runs',
                        border: OutlineInputBorder(
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: wicketsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Wickets',
                        border: OutlineInputBorder(
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.gapH12,
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: catchesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Catches',
                        border: OutlineInputBorder(
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: foursController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Fours',
                        border: OutlineInputBorder(
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.gapH12,
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: sixesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Sixes',
                        border: OutlineInputBorder(
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: ballsFacedController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Balls',
                        border: OutlineInputBorder(
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {
                if (entry != null) 'id': entry['id'],
                'match_id': _selectedMatchId,
                if (entry != null) 'player_id': entry['player_id'],
                'runs': int.tryParse(runsController.text) ?? 0,
                'wickets': int.tryParse(wicketsController.text) ?? 0,
                'catches': int.tryParse(catchesController.text) ?? 0,
                'fours': int.tryParse(foursController.text) ?? 0,
                'sixes': int.tryParse(sixesController.text) ?? 0,
                'balls_faced':
                    int.tryParse(ballsFacedController.text) ?? 0,
              };
              await ref
                  .read(adminProvider.notifier)
                  .upsertScoreboard(data);
              if (mounted) {
                Navigator.pop(context);
                ref
                    .read(adminProvider.notifier)
                    .loadScoreboard(_selectedMatchId!);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ScoreboardEntryCard extends StatelessWidget {
  final String playerName;
  final String playerRole;
  final int runs;
  final int wickets;
  final int catches;
  final double points;
  final VoidCallback onEdit;

  const _ScoreboardEntryCard({
    required this.playerName,
    required this.playerRole,
    required this.runs,
    required this.wickets,
    required this.catches,
    required this.points,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(playerName, style: AppTypography.titleSmall),
                Text(
                  playerRole,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          _StatChip('R', '$runs'),
          _StatChip('W', '$wickets'),
          _StatChip('C', '$catches'),
          _StatChip('Pts', points.toStringAsFixed(0)),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 18, color: AppColors.info),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
