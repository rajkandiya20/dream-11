import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/ball_by_ball_model.dart';

/// Shows last 6 balls of the current over with color-coded circles.
/// W = red, 4 = blue, 6 = green/primary, 0 = grey, rest = dark.
///
/// Ported from Fantasy- ShowOver.js + showBalls util.
class BallDisplayRow extends StatelessWidget {
  /// Latest ball-by-ball entries (newest first).
  final List<BallByBallModel> balls;

  const BallDisplayRow({super.key, required this.balls});

  @override
  Widget build(BuildContext context) {
    // Take last 6 valid deliveries of the current over
    final displayBalls = _prepareDisplay(balls);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: displayBalls.map((b) => _BallCircle(ball: b)).toList(),
    );
  }

  List<_BallDisplay> _prepareDisplay(List<BallByBallModel> raw) {
    // Filter to current over balls, newest first → take 6
    final currentOver = raw.isNotEmpty ? raw.first.overNumber : 0;
    final overBalls = raw
        .where((b) => b.overNumber == currentOver)
        .toList();

    // Build display list (max 6, pad with empty)
    final display = <_BallDisplay>[];
    for (final b in overBalls.take(6)) {
      display.add(_BallDisplay.fromModel(b));
    }
    // Pad remaining with empty slots
    while (display.length < 6) {
      display.add(_BallDisplay.empty());
    }
    return display;
  }
}

class _BallDisplay {
  final String label;
  final _BallType type;

  const _BallDisplay({required this.label, required this.type});

  factory _BallDisplay.fromModel(BallByBallModel b) {
    if (b.isWicket) return const _BallDisplay(label: 'W', type: _BallType.wicket);
    if (b.runs == 6) return const _BallDisplay(label: '6', type: _BallType.six);
    if (b.runs == 4) return const _BallDisplay(label: '4', type: _BallType.four);
    return _BallDisplay(label: '${b.runs}', type: _BallType.normal);
  }

  factory _BallDisplay.empty() =>
      const _BallDisplay(label: '', type: _BallType.empty);
}

enum _BallType { wicket, six, four, extra, normal, empty }

class _BallCircle extends StatelessWidget {
  final _BallDisplay ball;
  const _BallCircle({required this.ball});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    bool dashed = false;

    switch (ball.type) {
      case _BallType.wicket:
        bg = AppColors.error;
        fg = Colors.white;
        break;
      case _BallType.six:
        bg = AppColors.primary;
        fg = Colors.white;
        break;
      case _BallType.four:
        bg = AppColors.secondary;
        fg = Colors.white;
        break;
      case _BallType.extra:
        bg = AppColors.warning.withOpacity(0.2);
        fg = AppColors.warning;
        break;
      case _BallType.normal:
        bg = AppColors.secondaryLight;
        fg = Colors.white;
        break;
      case _BallType.empty:
        bg = Colors.transparent;
        fg = Colors.white24;
        dashed = true;
        break;
    }

    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: dashed ? Colors.transparent : bg,
        shape: BoxShape.circle,
        border: dashed
            ? Border.all(color: Colors.white24, width: 1)
            : ball.type == _BallType.empty
                ? null
                : null,
      ),
      child: ball.label.isNotEmpty
          ? Center(
              child: Text(
                ball.label,
                style: AppTypography.labelSmall.copyWith(
                  color: fg,
                  fontSize: ball.label.length > 1 ? 8 : 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
    );
  }
}
