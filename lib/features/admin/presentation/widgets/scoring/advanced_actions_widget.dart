import 'package:flutter/material.dart';

/// Advanced scoring actions: Undo, Change Bowler, Retired Hurt,
/// Penalty Runs, End Over, End Innings, Declare Innings.
class AdvancedActionsWidget extends StatelessWidget {
  final VoidCallback onUndo;
  final VoidCallback onChangeBowler;
  final VoidCallback onRetiredHurt;
  final VoidCallback onPenaltyRuns;
  final VoidCallback onEndOver;
  final VoidCallback onEndInnings;
  final VoidCallback onDeclare;

  const AdvancedActionsWidget({
    super.key,
    required this.onUndo,
    required this.onChangeBowler,
    required this.onRetiredHurt,
    required this.onPenaltyRuns,
    required this.onEndOver,
    required this.onEndInnings,
    required this.onDeclare,
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
            'Actions',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActionButton(
                icon: Icons.undo,
                label: 'Undo',
                onTap: onUndo,
                color: const Color(0xFF607D8B),
              ),
              _buildActionButton(
                icon: Icons.swap_horiz,
                label: 'Change Bowler',
                onTap: onChangeBowler,
                color: const Color(0xFF9C27B0),
              ),
              _buildActionButton(
                icon: Icons.personal_injury,
                label: 'Retired Hurt',
                onTap: onRetiredHurt,
                color: const Color(0xFFFF5722),
              ),
              _buildActionButton(
                icon: Icons.add_circle_outline,
                label: 'Penalty',
                onTap: onPenaltyRuns,
                color: const Color(0xFF795548),
              ),
              _buildActionButton(
                icon: Icons.sports,
                label: 'End Over',
                onTap: onEndOver,
                color: const Color(0xFF3F51B5),
              ),
              _buildActionButton(
                icon: Icons.stop_circle_outlined,
                label: 'End Innings',
                onTap: onEndInnings,
                color: const Color(0xFFE91E63),
              ),
              _buildActionButton(
                icon: Icons.flag,
                label: 'Declare',
                onTap: onDeclare,
                color: const Color(0xFF009688),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
