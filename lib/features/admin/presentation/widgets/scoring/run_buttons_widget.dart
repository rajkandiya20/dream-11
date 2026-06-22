import 'package:flutter/material.dart';

/// Grid of run buttons 0-6, large tappable buttons for one-hand scoring.
class RunButtonsWidget extends StatelessWidget {
  final void Function(int runs) onRunTapped;

  const RunButtonsWidget({
    super.key,
    required this.onRunTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
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
            'Runs',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (int i = 0; i <= 6; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _buildRunButton(i)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRunButton(int runs) {
    Color bgColor;
    Color textColor;

    switch (runs) {
      case 0:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
        break;
      case 4:
        bgColor = const Color(0xFF4CAF50);
        textColor = Colors.white;
        break;
      case 6:
        bgColor = const Color(0xFF2E7D32);
        textColor = Colors.white;
        break;
      default:
        bgColor = const Color(0xFFE91E63).withOpacity(0.1);
        textColor = const Color(0xFFE91E63);
    }

    return GestureDetector(
      onTap: () => onRunTapped(runs),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: runs == 0
              ? Border.all(color: const Color(0xFFE2E8F0))
              : null,
        ),
        child: Center(
          child: Text(
            '$runs',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
