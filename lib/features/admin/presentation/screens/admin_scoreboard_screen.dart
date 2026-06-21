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
  String _matchFilter = 'live';

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
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: AppColors.textSecondary),
            onSelected: (filter) {
              setState(() {
                _matchFilter = filter;
                _selectedMatchId = null;
              });
              ref.read(adminProvider.notifier).loadMatches(status: filter == 'all' ? null : filter);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'live', child: Text('Live Matches')),
              const PopupMenuItem(value: 'upcoming', child: Text('Upcoming')),
              const PopupMenuItem(value: 'completed', child: Text('Completed')),
              const PopupMenuItem(value: 'all', child: Text('All Matches')),
            ],
          ),
        ],
      ),
      drawer: const AdminNavDrawer(currentRoute: '/admin/scoreboard'),
      floatingActionButton: _selectedMatchId != null
          ? FloatingActionButton.extended(
              onPressed: () => _showScoreEditDialog(null),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Score',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match selector header
            Row(
              children: [
                Text('Select Match', style: AppTypography.titleMedium),
                const Spacer(),
                if (adminState.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            AppSpacing.gapH8,
            
            // Match dropdown
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: AppSpacing.borderRadiusSm,
                border: Border.all(color: AppColors.border),
              ),
              child: adminState.isLoading && adminState.matches.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text('Loading matches...')),
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedMatchId,
                        hint: Text(
                          adminState.matches.isEmpty
                              ? 'No ${_matchFilter == "all" ? "" : _matchFilter} matches available'
                              : 'Select a match',
                          style: TextStyle(
                            color: adminState.matches.isEmpty
                                ? AppColors.textTertiary
                                : AppColors.textSecondary,
                          ),
                        ),
                        isExpanded: true,
                        items: adminState.matches.map((match) {
                          final teamA = match['team_a_name'] ?? '';
                          final teamB = match['team_b_name'] ?? '';
                          final status = match['status'] ?? '';
                          final statusIcon = status == 'live'
                              ? ' 🔴'
                              : status == 'completed'
                                  ? ' ✓'
                                  : '';
                          return DropdownMenuItem(
                            value: match['id'] as String,
                            child: Row(
                              children: [
                                Expanded(child: Text('$teamA vs $teamB$statusIcon')),
                                if (status == 'live')
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'LIVE',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
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

            // Error state for matches
            if (adminState.matchesError != null)
              _buildErrorState(
                adminState.matchesError!,
                () => ref.read(adminProvider.notifier).loadMatches(status: _matchFilter == 'all' ? null : _matchFilter),
              )
            
            // No match selected state
            else if (_selectedMatchId == null)
              _buildNoMatchSelectedState()
            
            // Loading scoreboard
            else if (adminState.isLoading && adminState.scoreboard.isEmpty)
              _buildLoadingState()
            
            // Error loading scoreboard
            else if (adminState.scoreboardError != null)
              _buildErrorState(
                adminState.scoreboardError!,
                () => ref.read(adminProvider.notifier).loadScoreboard(_selectedMatchId!),
              )
            
            // Empty scoreboard
            else if (adminState.scoreboard.isEmpty)
              _buildEmptyScoreboardState()
            
            // Scoreboard entries
            else
              ..._buildScoreboardContent(adminState),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildScoreboardContent(AdminState adminState) {
    return [
      // Header row
      Row(
        children: [
          Text('Player Scores', style: AppTypography.titleMedium),
          const Spacer(),
          Text(
            '${adminState.scoreboard.length} entries',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      AppSpacing.gapH12,
      
      // Scoreboard entries
      ...adminState.scoreboard.map((entry) {
        final player = entry['player'] as Map<String, dynamic>?;
        return _ScoreboardEntryCard(
          playerName: player?['name'] ?? 'Unknown',
          playerRole: player?['role'] ?? '',
          runs: entry['runs'] as int? ?? 0,
          wickets: entry['wickets'] as int? ?? 0,
          catches: entry['catches'] as int? ?? 0,
          fours: entry['fours'] as int? ?? 0,
          sixes: entry['sixes'] as int? ?? 0,
          ballsFaced: entry['balls_faced'] as int? ?? 0,
          points: (entry['points'] as num?)?.toDouble() ?? 0,
          onEdit: () => _showScoreEditDialog(entry),
          onDelete: () => _confirmDeleteScore(entry),
        );
      }),
    ];
  }

  Widget _buildNoMatchSelectedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sports_cricket,
                size: 48,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),
            AppSpacing.gapH16,
            Text(
              'Select a Match',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.gapH8,
            Text(
              'Choose a match from the dropdown above to manage player scores',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            AppSpacing.gapH16,
            Text(
              'Loading scores...',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
            ),
            AppSpacing.gapH16,
            Text(
              'Error Loading Data',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.gapH8,
            Text(
              error,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapH16,
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Retry', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyScoreboardState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.scoreboard_outlined,
                size: 48,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),
            AppSpacing.gapH16,
            Text(
              'No Scores Yet',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.gapH8,
            Text(
              'Start adding player scores for this match',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.gapH24,
            ElevatedButton.icon(
              onPressed: () => _showScoreEditDialog(null),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Score Entry',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScoreEditDialog(Map<String, dynamic>? entry) {
    final isEditing = entry != null;
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
    final pointsController =
        TextEditingController(text: '${(entry?['points'] as num?)?.toDouble() ?? 0}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLg,
        ),
        title: Row(
          children: [
            Icon(
              isEditing ? Icons.edit : Icons.add,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              isEditing ? 'Edit Score' : 'Add Score Entry',
              style: AppTypography.titleLarge,
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Batting Stats',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.gapH8,
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: runsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Runs',
                        prefixIcon: const Icon(Icons.directions_run, size: 18),
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
                        prefixIcon: const Icon(Icons.sports_baseball, size: 18),
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
                      controller: foursController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Fours (4s)',
                        border: OutlineInputBorder(
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: sixesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Sixes (6s)',
                        border: OutlineInputBorder(
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.gapH16,
              Text(
                'Bowling & Fielding',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.gapH8,
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: wicketsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Wickets',
                        prefixIcon: const Icon(Icons.sports_cricket, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: catchesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Catches',
                        prefixIcon: const Icon(Icons.pan_tool, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.gapH16,
              Text(
                'Points',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.gapH8,
              TextField(
                controller: pointsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Total Points',
                  prefixIcon: const Icon(Icons.star, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                ),
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
                'points': double.tryParse(pointsController.text) ?? 0,
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

  void _confirmDeleteScore(Map<String, dynamic> entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Score'),
        content: const Text('Are you sure you want to delete this score entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete functionality would be implemented here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Score entry deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
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
  final int fours;
  final int sixes;
  final int ballsFaced;
  final double points;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ScoreboardEntryCard({
    required this.playerName,
    required this.playerRole,
    required this.runs,
    required this.wickets,
    required this.catches,
    required this.fours,
    required this.sixes,
    required this.ballsFaced,
    required this.points,
    required this.onEdit,
    required this.onDelete,
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
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  playerName.isNotEmpty ? playerName[0].toUpperCase() : '?',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${points.toStringAsFixed(0)} pts',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18, color: AppColors.info),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatChip('Runs', '$runs', Icons.directions_run),
              _StatChip('Balls', '$ballsFaced', Icons.sports_baseball),
              _StatChip('4s', '$fours', Icons.looks_4),
              _StatChip('6s', '$sixes', Icons.looks_6),
              _StatChip('Wkts', '$wickets', Icons.sports_cricket),
              _StatChip('Catches', '$catches', Icons.pan_tool),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatChip(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
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
    );
  }
}
