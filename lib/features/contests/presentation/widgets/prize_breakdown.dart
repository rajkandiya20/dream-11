import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../matches/data/models/contest_model.dart';

/// Prize distribution table showing rank ranges and prize amounts.
class PrizeBreakdown extends StatelessWidget {
  final ContestModel contest;

  const PrizeBreakdown({super.key, required this.contest});

  /// Generate prize breakdown based on prize pool and max teams.
  List<_PrizeSlot> get _prizeSlots {
    final prizePool = contest.prizePool;
    final totalTeams = contest.maxTeams;

    if (totalTeams <= 2) {
      return [
        _PrizeSlot(rankStart: 1, rankEnd: 1, prize: prizePool),
      ];
    }

    // Standard prize distribution
    final slots = <_PrizeSlot>[];

    // 1st place: 35% of pool
    slots.add(_PrizeSlot(
      rankStart: 1,
      rankEnd: 1,
      prize: prizePool * 0.35,
    ));

    // 2nd place: 20% of pool
    slots.add(_PrizeSlot(
      rankStart: 2,
      rankEnd: 2,
      prize: prizePool * 0.20,
    ));

    // 3rd place: 10% of pool
    slots.add(_PrizeSlot(
      rankStart: 3,
      rankEnd: 3,
      prize: prizePool * 0.10,
    ));

    if (totalTeams >= 10) {
      // 4th-5th: 8% each
      slots.add(_PrizeSlot(
        rankStart: 4,
        rankEnd: 5,
        prize: prizePool * 0.08,
      ));
    }

    if (totalTeams >= 50) {
      // 6th-10th: 3% each
      slots.add(_PrizeSlot(
        rankStart: 6,
        rankEnd: 10,
        prize: prizePool * 0.03,
      ));
    }

    if (totalTeams >= 100) {
      // 11th-50th: share 10%
      final perTeam = (prizePool * 0.10) / 40;
      slots.add(_PrizeSlot(
        rankStart: 11,
        rankEnd: 50,
        prize: perTeam,
      ));
    }

    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final slots = _prizeSlots;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.emoji_events, size: 18, color: AppColors.warning),
              AppSpacing.gapW8,
              Text('Prize Breakdown', style: AppTypography.titleLarge),
            ],
          ),
        ),
        AppSpacing.gapH12,
        // Table header
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.05),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Rank', style: AppTypography.labelMedium),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Prize',
                  style: AppTypography.labelMedium,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        // Table rows
        ...slots.asMap().entries.map((entry) {
          final index = entry.key;
          final slot = entry.value;
          final isFirst = index == 0;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isFirst
                  ? AppColors.warning.withOpacity(0.05)
                  : AppColors.card,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border.withOpacity(0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                // Rank badge
                if (isFirst)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.emoji_events,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 28),
                AppSpacing.gapW12,
                // Rank text
                Expanded(
                  flex: 2,
                  child: Text(
                    slot.rankStart == slot.rankEnd
                        ? '#${slot.rankStart}'
                        : '#${slot.rankStart} - #${slot.rankEnd}',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight:
                          isFirst ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                // Prize amount
                Expanded(
                  flex: 3,
                  child: Text(
                    '\u20B9${slot.prize.toStringAsFixed(0)}',
                    style: AppTypography.titleMedium.copyWith(
                      color: isFirst ? AppColors.warning : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          );
        }),
        // Total
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 40),
              Expanded(
                flex: 2,
                child: Text(
                  'Total Prize Pool',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  '\u20B9${contest.formattedPrizePool}',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrizeSlot {
  final int rankStart;
  final int rankEnd;
  final double prize;

  const _PrizeSlot({
    required this.rankStart,
    required this.rankEnd,
    required this.prize,
  });
}
