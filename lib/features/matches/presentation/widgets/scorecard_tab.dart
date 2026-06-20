import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/scoreboard_model.dart';

/// Player-by-player scorecard tab showing batting and bowling stats.
class ScorecardTab extends StatelessWidget {
  final List<ScoreboardModel> scoreboard;

  const ScorecardTab({super.key, required this.scoreboard});

  @override
  Widget build(BuildContext context) {
    if (scoreboard.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.scoreboard_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            AppSpacing.gapH16,
            Text(
              'Scorecard will be available once the match starts',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Separate batsmen and bowlers
    final batsmen =
        scoreboard.where((s) => s.ballsFaced > 0 || s.runs > 0).toList();
    final bowlers =
        scoreboard.where((s) => s.oversBowled > 0 || s.wickets > 0).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Batting section
        if (batsmen.isNotEmpty) ...[
          _SectionTitle(title: 'Batting', icon: Icons.sports_cricket),
          AppSpacing.gapH8,
          _BattingHeader(),
          ...batsmen.map((entry) => _BattingRow(entry: entry)),
          AppSpacing.gapH24,
        ],
        // Bowling section
        if (bowlers.isNotEmpty) ...[
          _SectionTitle(title: 'Bowling', icon: Icons.sports_baseball),
          AppSpacing.gapH8,
          _BowlingHeader(),
          ...bowlers.map((entry) => _BowlingRow(entry: entry)),
          AppSpacing.gapH24,
        ],
        // Points breakdown
        _SectionTitle(title: 'Fantasy Points', icon: Icons.star),
        AppSpacing.gapH8,
        ...scoreboard.take(15).map((entry) => _PointsRow(entry: entry)),
        AppSpacing.gapH32,
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        AppSpacing.gapW8,
        Text(title, style: AppTypography.titleLarge),
      ],
    );
  }
}

class _BattingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('Batter', style: AppTypography.labelSmall),
          ),
          _StatLabel('R'),
          _StatLabel('B'),
          _StatLabel('4s'),
          _StatLabel('6s'),
          _StatLabel('SR'),
          _StatLabel('Pts'),
        ],
      ),
    );
  }
}

class _BattingRow extends StatelessWidget {
  final ScoreboardModel entry;

  const _BattingRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.playerName,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  entry.playerRole,
                  style: AppTypography.labelSmall.copyWith(fontSize: 9),
                ),
              ],
            ),
          ),
          _StatValue('${entry.runs}', highlight: entry.runs >= 50),
          _StatValue('${entry.ballsFaced}'),
          _StatValue('${entry.fours}'),
          _StatValue('${entry.sixes}'),
          _StatValue(entry.strikeRate.toStringAsFixed(1)),
          _StatValue(
            entry.points.toStringAsFixed(0),
            highlight: true,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _BowlingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('Bowler', style: AppTypography.labelSmall),
          ),
          _StatLabel('O'),
          _StatLabel('W'),
          _StatLabel('R'),
          _StatLabel('Eco'),
          _StatLabel('Pts'),
        ],
      ),
    );
  }
}

class _BowlingRow extends StatelessWidget {
  final ScoreboardModel entry;

  const _BowlingRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.playerName,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          _StatValue(entry.oversBowled.toStringAsFixed(1)),
          _StatValue('${entry.wickets}', highlight: entry.wickets >= 3),
          _StatValue('${entry.runs}'),
          _StatValue(entry.economy.toStringAsFixed(1)),
          _StatValue(
            entry.points.toStringAsFixed(0),
            highlight: true,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _PointsRow extends StatelessWidget {
  final ScoreboardModel entry;

  const _PointsRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                entry.playerName.isNotEmpty ? entry.playerName[0] : '',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          AppSpacing.gapW12,
          Expanded(
            child: Text(
              entry.playerName,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${entry.points.toStringAsFixed(1)} pts',
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatLabel extends StatelessWidget {
  final String label;

  const _StatLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _StatValue extends StatelessWidget {
  final String value;
  final bool highlight;
  final Color? color;

  const _StatValue(this.value, {this.highlight = false, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Text(
        value,
        style: AppTypography.bodySmall.copyWith(
          fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
          color: color ?? AppColors.textPrimary,
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
