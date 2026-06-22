import 'package:flutter/material.dart';

import '../../../data/models/innings_state.dart';

/// Displays striker and non-striker stats in a compact table layout.
/// Striker is highlighted with primary color accent.
class BatsmanSectionWidget extends StatelessWidget {
  final BatsmanState? striker;
  final BatsmanState? nonStriker;
  final VoidCallback? onSwapStrike;

  const BatsmanSectionWidget({
    super.key,
    this.striker,
    this.nonStriker,
    this.onSwapStrike,
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
          Row(
            children: [
              const Icon(
                Icons.sports_cricket,
                size: 16,
                color: Color(0xFFE91E63),
              ),
              const SizedBox(width: 6),
              const Text(
                'Batsmen',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const Spacer(),
              if (onSwapStrike != null)
                GestureDetector(
                  onTap: onSwapStrike,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Swap',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Header row
          const Row(
            children: [
              Expanded(flex: 3, child: SizedBox()),
              Expanded(
                flex: 1,
                child: Text(
                  'R',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'B',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '4s',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '6s',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'SR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 8),
          if (striker != null) _buildBatsmanRow(striker!, isStriker: true),
          if (nonStriker != null) _buildBatsmanRow(nonStriker!, isStriker: false),
          if (striker == null && nonStriker == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No batsmen selected',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBatsmanRow(BatsmanState batsman, {required bool isStriker}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                if (isStriker)
                  const Icon(
                    Icons.play_arrow,
                    size: 14,
                    color: Color(0xFFE91E63),
                  )
                else
                  const SizedBox(width: 14),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    batsman.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isStriker ? FontWeight.w700 : FontWeight.w500,
                      color: isStriker
                          ? const Color(0xFFE91E63)
                          : const Color(0xFF1A1A2E),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${batsman.runs}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isStriker ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${batsman.balls}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${batsman.fours}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${batsman.sixes}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              batsman.strikeRate.toStringAsFixed(1),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
