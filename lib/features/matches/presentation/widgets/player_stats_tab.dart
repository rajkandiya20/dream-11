import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/player_stats_model.dart';

/// Player stats tab — shows all player fantasy points, dream team indicator,
/// batting/bowling stats. Ported from Fantasy- stats.js.
class PlayerStatsTab extends StatefulWidget {
  final List<PlayerStatsModel> playerStats;
  final List<String> dreamTeamPlayerIds;

  const PlayerStatsTab({
    super.key,
    required this.playerStats,
    this.dreamTeamPlayerIds = const [],
  });

  @override
  State<PlayerStatsTab> createState() => _PlayerStatsTabState();
}

class _PlayerStatsTabState extends State<PlayerStatsTab> {
  _SortField _sortField = _SortField.points;
  bool _sortDesc = true;

  List<PlayerStatsModel> get _sorted {
    final list = [...widget.playerStats];
    list.sort((a, b) {
      int cmp;
      switch (_sortField) {
        case _SortField.points:
          cmp = a.fantasyPoints.compareTo(b.fantasyPoints);
          break;
        case _SortField.runs:
          cmp = a.runs.compareTo(b.runs);
          break;
        case _SortField.wickets:
          cmp = a.wickets.compareTo(b.wickets);
          break;
      }
      return _sortDesc ? -cmp : cmp;
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.playerStats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: AppColors.textTertiary),
            AppSpacing.gapH16,
            Text('Stats available once match starts',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Sort header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.scaffoldBackground,
          child: Row(
            children: [
              Text('Player', style: AppTypography.labelSmall
                  .copyWith(color: AppColors.textSecondary)),
              const Spacer(),
              _SortButton(
                label: 'PTS',
                active: _sortField == _SortField.points,
                desc: _sortDesc,
                onTap: () => setState(() {
                  if (_sortField == _SortField.points) {
                    _sortDesc = !_sortDesc;
                  } else {
                    _sortField = _SortField.points;
                    _sortDesc = true;
                  }
                }),
              ),
              const SizedBox(width: 8),
              _SortButton(
                label: 'R',
                active: _sortField == _SortField.runs,
                desc: _sortDesc,
                onTap: () => setState(() {
                  if (_sortField == _SortField.runs) {
                    _sortDesc = !_sortDesc;
                  } else {
                    _sortField = _SortField.runs;
                    _sortDesc = true;
                  }
                }),
              ),
              const SizedBox(width: 8),
              _SortButton(
                label: 'W',
                active: _sortField == _SortField.wickets,
                desc: _sortDesc,
                onTap: () => setState(() {
                  if (_sortField == _SortField.wickets) {
                    _sortDesc = !_sortDesc;
                  } else {
                    _sortField = _SortField.wickets;
                    _sortDesc = true;
                  }
                }),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Player list
        Expanded(
          child: ListView.builder(
            itemCount: _sorted.length,
            itemBuilder: (context, i) {
              final p = _sorted[i];
              final isDream = widget.dreamTeamPlayerIds.contains(p.playerId);
              return _PlayerStatRow(
                  stats: p, isDreamTeam: isDream, rank: i + 1);
            },
          ),
        ),
      ],
    );
  }
}

enum _SortField { points, runs, wickets }

class _SortButton extends StatelessWidget {
  final String label;
  final bool active;
  final bool desc;
  final VoidCallback onTap;

  const _SortButton({
    required this.label,
    required this.active,
    required this.desc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Text(label,
                style: AppTypography.labelSmall.copyWith(
                  color: active ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                )),
            if (active)
              Icon(
                desc ? Icons.arrow_downward : Icons.arrow_upward,
                size: 10,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _PlayerStatRow extends StatelessWidget {
  final PlayerStatsModel stats;
  final bool isDreamTeam;
  final int rank;

  const _PlayerStatRow({
    required this.stats,
    required this.isDreamTeam,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        // Dream team rows highlighted — from Fantasy- stats.js (even/prime classes)
        color: isDreamTeam
            ? const Color(0xFFFEF4DE)
            : rank.isEven
                ? AppColors.scaffoldBackground
                : AppColors.card,
        border: Border(
            bottom: BorderSide(color: AppColors.border.withOpacity(0.3))),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 24,
            child: Text('$rank',
                style: AppTypography.labelSmall
                    .copyWith(color: AppColors.textTertiary)),
          ),
          // Player name + dream team icon
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    stats.playerId, // ideally playerName
                    style: AppTypography.bodySmall
                        .copyWith(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Dream team icon (from Fantasy- dreamicon class)
                if (isDreamTeam) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('DT',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                        )),
                  ),
                ],
              ],
            ),
          ),
          // Points
          SizedBox(
            width: 44,
            child: Text(
              stats.fantasyPoints.toStringAsFixed(1),
              style: AppTypography.titleSmall.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          // Runs
          SizedBox(
            width: 32,
            child: Text('${stats.runs}',
                style: AppTypography.labelSmall,
                textAlign: TextAlign.center),
          ),
          // Wickets
          SizedBox(
            width: 32,
            child: Text('${stats.wickets}',
                style: AppTypography.labelSmall,
                textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
