import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/ball_by_ball_model.dart';
import '../../data/models/scoreboard_model.dart';

/// Player-by-player scorecard tab showing batting and bowling stats.
class ScorecardTab extends StatelessWidget {
  final List<ScoreboardModel> scoreboard;
  final List<BallByBallModel> ballByBall;

  const ScorecardTab({
    super.key,
    required this.scoreboard,
    this.ballByBall = const [],
  });

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
              'No scorecard data available',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapH8,
            Text(
              'Scores will appear here once scoring begins',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Separate batsmen and bowlers based on batting/bowling stats
    final batsmen =
        scoreboard.where((s) => s.ballsFaced > 0 || s.runs > 0).toList();
    final bowlers =
        scoreboard.where((s) => s.oversBowled > 0 || s.wickets > 0).toList();

    // Get recent balls (last 6) and this over balls from ball_by_ball data
    final recentBalls = ballByBall.take(6).toList();
    final currentOver = _getCurrentOverBalls();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Recent Balls section
        if (recentBalls.isNotEmpty) ...[
          _SectionTitle(title: 'Recent Balls', icon: Icons.timeline),
          AppSpacing.gapH8,
          _RecentBallsRow(balls: recentBalls),
          AppSpacing.gapH24,
        ],
        // This Over section
        if (currentOver.isNotEmpty) ...[
          _SectionTitle(title: 'This Over', icon: Icons.sports_cricket),
          AppSpacing.gapH8,
          _ThisOverRow(balls: currentOver),
          AppSpacing.gapH24,
        ],
        // Batting section
        if (batsmen.isNotEmpty) ...[
          _SectionTitle(title: 'Batting', icon: Icons.sports_cricket),
          AppSpacing.gapH8,
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppSpacing.borderRadiusMd,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _BattingHeader(),
                ...batsmen.map((entry) => _BattingRow(entry: entry)),
              ],
            ),
          ),
          AppSpacing.gapH24,
        ],
        // Bowling section
        if (bowlers.isNotEmpty) ...[
          _SectionTitle(title: 'Bowling', icon: Icons.sports_baseball),
          AppSpacing.gapH8,
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppSpacing.borderRadiusMd,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _BowlingHeader(),
                ...bowlers.map((entry) => _BowlingRow(entry: entry)),
              ],
            ),
          ),
          AppSpacing.gapH24,
        ],
        // If we have data but no batsmen or bowlers match criteria, show all
        if (batsmen.isEmpty && bowlers.isEmpty) ...[
          _SectionTitle(title: 'Player Stats', icon: Icons.people),
          AppSpacing.gapH8,
          ...scoreboard.map((entry) => _PointsRow(entry: entry)),
          AppSpacing.gapH24,
        ],
        // Fantasy Points breakdown
        if (scoreboard.isNotEmpty) ...[
          _SectionTitle(title: 'Fantasy Points', icon: Icons.star),
          AppSpacing.gapH8,
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppSpacing.borderRadiusMd,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children:
                  scoreboard.take(15).map((entry) => _PointsRow(entry: entry)).toList(),
            ),
          ),
          AppSpacing.gapH32,
        ],
      ],
    );
  }

  /// Get all balls in the current (most recent) over.
  List<BallByBallModel> _getCurrentOverBalls() {
    if (ballByBall.isEmpty) return [];
    final currentOver = ballByBall.first.overNumber;
    return ballByBall
        .where((b) => b.overNumber == currentOver)
        .toList()
        .reversed
        .toList();
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

/// Row displaying the last 6 balls.
class _RecentBallsRow extends StatelessWidget {
  final List<BallByBallModel> balls;

  const _RecentBallsRow({required this.balls});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: balls.map((ball) => _BallChip(ball: ball)).toList(),
      ),
    );
  }
}

/// Row displaying all balls in the current over.
class _ThisOverRow extends StatelessWidget {
  final List<BallByBallModel> balls;

  const _ThisOverRow({required this.balls});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Over ${balls.isNotEmpty ? balls.first.overNumber : 0}',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.gapH8,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: balls.map((ball) => _BallChip(ball: ball)).toList(),
          ),
        ],
      ),
    );
  }
}

/// Single ball chip widget.
class _BallChip extends StatelessWidget {
  final BallByBallModel ball;

  const _BallChip({required this.ball});

  Color get _backgroundColor {
    if (ball.isWicket) return AppColors.error;
    if (ball.isSix) return AppColors.primary;
    if (ball.isBoundary) return AppColors.success;
    if (ball.runs == 0 && ball.extras == 0) {
      return AppColors.textTertiary.withOpacity(0.2);
    }
    return AppColors.secondary.withOpacity(0.1);
  }

  Color get _textColor {
    if (ball.isWicket || ball.isSix || ball.isBoundary) return Colors.white;
    return AppColors.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: _backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          ball.displayText,
          style: AppTypography.labelSmall.copyWith(
            color: _textColor,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ),
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
