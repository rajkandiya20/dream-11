import 'package:flutter/material.dart';

/// Horizontal row showing last 6 balls with color coding.
/// - Regular runs (0,1,2,3,5) = Grey (#9E9E9E)
/// - Four = Green (#4CAF50)
/// - Six = Dark Green (#2E7D32)
/// - Wicket (starts with W) = Red (#F44336)
/// - Wide (starts with Wd) = Blue (#2196F3)
/// - No Ball (starts with Nb) = Orange (#FF9800)
/// - Bye/Leg Bye = Light Blue (#03A9F4)
class LastBallsWidget extends StatelessWidget {
  final List<String> lastSixBalls;

  const LastBallsWidget({
    super.key,
    required this.lastSixBalls,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This Over',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (int i = 0; i < 6; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                _buildBallCircle(
                  i < lastSixBalls.length ? lastSixBalls[i] : null,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBallCircle(String? ball) {
    if (ball == null) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: Text(
            '-',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFCBD5E1),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    final color = _getBallColor(ball);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _getDisplayText(ball),
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Color _getBallColor(String ball) {
    if (ball.startsWith('W')) return const Color(0xFFF44336);
    if (ball.startsWith('Wd')) return const Color(0xFF2196F3);
    if (ball.startsWith('Nb')) return const Color(0xFFFF9800);
    if (ball.startsWith('B') || ball.startsWith('Lb')) {
      return const Color(0xFF03A9F4);
    }
    if (ball == '4') return const Color(0xFF4CAF50);
    if (ball == '6') return const Color(0xFF2E7D32);
    return const Color(0xFF9E9E9E);
  }

  String _getDisplayText(String ball) {
    if (ball.length > 3) return ball.substring(0, 3);
    return ball;
  }
}
