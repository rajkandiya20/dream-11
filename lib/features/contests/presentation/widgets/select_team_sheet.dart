import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../fantasy/data/models/fantasy_team_model.dart';
import '../../../matches/data/models/contest_model.dart';

/// Dream11-style bottom sheet that shows the user's existing teams for a match
/// and lets them pick one to join the contest with, or create a new team.
///
/// Returns the selected [FantasyTeamModel] via [Navigator.pop] if the user
/// picks an existing team, or null if they choose to create a new one
/// (in which case navigation has already been triggered inside this sheet).
class SelectTeamSheet extends ConsumerStatefulWidget {
  final ContestModel contest;
  final List<FantasyTeamModel> existingTeams;

  const SelectTeamSheet({
    super.key,
    required this.contest,
    required this.existingTeams,
  });

  @override
  ConsumerState<SelectTeamSheet> createState() => _SelectTeamSheetState();
}

class _SelectTeamSheetState extends ConsumerState<SelectTeamSheet> {
  String? _selectedTeamId;

  @override
  void initState() {
    super.initState();
    // Pre-select the first team
    if (widget.existingTeams.isNotEmpty) {
      _selectedTeamId = widget.existingTeams.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // ── Handle ────────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
              ),

              // ── Header ────────────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Select Team',
                              style: AppTypography.titleLarge),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.contest.name}  ·  Entry: ${widget.contest.formattedEntryFee}',
                            style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // ── Team list ────────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  itemCount: widget.existingTeams.length,
                  itemBuilder: (context, index) {
                    final team = widget.existingTeams[index];
                    final isSelected = _selectedTeamId == team.id;

                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedTeamId = team.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.05)
                              : AppColors.card,
                          borderRadius: AppSpacing.borderRadiusMd,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Selection indicator
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check,
                                      size: 14, color: Colors.white)
                                  : null,
                            ),
                            AppSpacing.gapW12,

                            // Team info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    team.teamName,
                                    style: AppTypography.titleSmall.copyWith(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  _TeamRoleChips(team: team),
                                ],
                              ),
                            ),

                            // Captain / VC badge
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _CaptainBadge(
                                    label: 'C',
                                    name: _playerName(
                                        team, team.captainId)),
                                const SizedBox(height: 4),
                                _CaptainBadge(
                                    label: 'VC',
                                    name: _playerName(
                                        team, team.viceCaptainId),
                                    isVc: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── Bottom action area ────────────────────────────────────
              const Divider(height: 1),
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Join with selected team
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderRadiusMd,
                          ),
                        ),
                        onPressed: _selectedTeamId == null
                            ? null
                            : () {
                                final team =
                                    widget.existingTeams.firstWhere(
                                  (t) => t.id == _selectedTeamId,
                                );
                                Navigator.of(context).pop(team);
                              },
                        child: Text(
                          'JOIN WITH THIS TEAM',
                          style: AppTypography.labelLarge
                              .copyWith(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Create a new team
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderRadiusMd,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // close sheet
                          context.push(
                            '/create-team/${widget.contest.matchId}',
                            extra: widget.contest.id,
                          );
                        },
                        child: Text(
                          '+ CREATE NEW TEAM',
                          style: AppTypography.labelLarge
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _playerName(FantasyTeamModel team, String? playerId) {
    if (playerId == null) return '—';
    final player = team.players
        .where((p) => p.playerId == playerId)
        .firstOrNull;
    return player?.playerName.split(' ').first ?? '—';
  }
}

/// Mini role breakdown chips (WK / BAT / AR / BOWL counts).
class _TeamRoleChips extends StatelessWidget {
  final FantasyTeamModel team;
  const _TeamRoleChips({required this.team});

  @override
  Widget build(BuildContext context) {
    final roles = <String, int>{};
    for (final p in team.players) {
      final r = _shortRole(p.playerRole);
      roles[r] = (roles[r] ?? 0) + 1;
    }

    return Row(
      children: roles.entries.map((e) {
        return Container(
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${e.value} ${e.key}',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  String _shortRole(String role) {
    switch (role) {
      case 'WK':
        return 'WK';
      case 'Batsman':
        return 'BAT';
      case 'All-rounder':
        return 'AR';
      case 'Bowler':
        return 'BOWL';
      default:
        return role.isNotEmpty ? role[0] : '?';
    }
  }
}

class _CaptainBadge extends StatelessWidget {
  final String label;
  final String name;
  final bool isVc;

  const _CaptainBadge(
      {required this.label, required this.name, this.isVc = false});

  @override
  Widget build(BuildContext context) {
    final color = isVc ? AppColors.info : AppColors.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 4),
        Text(name,
            style:
                AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
