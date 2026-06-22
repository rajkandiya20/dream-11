import 'package:flutter/material.dart';

/// Displays the current score, overs, CRR, target, and required run rate.
/// White card with rounded corners and modern shadow.
class LiveScorecardWidget extends StatelessWidget {
  final int totalRuns;
  final int totalWickets;
  final double totalOvers;
  final double currentRunRate;
  final int? target;
  final double? requiredRunRate;
  final String? tossWinner;
  final String? electedTo;

  const LiveScorecardWidget({
    super.key,
    required this.totalRuns,
    required this.totalWickets,
    required this.totalOvers,
    required this.currentRunRate,
    this.target,
    this.requiredRunRate,
    this.tossWinner,
    this.electedTo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Score and overs row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$totalRuns/$totalWickets',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '(${_formatOvers(totalOvers)} ov)',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Stats row
          Row(
            children: [
              _buildStatChip('CRR', currentRunRate.toStringAsFixed(2)),
              if (target != null) ...[
                const SizedBox(width: 12),
                _buildStatChip('Target', '$target'),
              ],
              if (requiredRunRate != null) ...[
                const SizedBox(width: 12),
                _buildStatChip('RRR', requiredRunRate!.toStringAsFixed(2)),
              ],
            ],
          ),
          if (tossWinner != null && tossWinner!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.swap_vert, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '$tossWinner won toss, elected to ${electedTo ?? 'bat'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatOvers(double overs) {
    final fullOvers = overs.toInt();
    final balls = ((overs - fullOvers) * 10).round();
    return '$fullOvers.$balls';
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1A1A2E),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
