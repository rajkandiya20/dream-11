import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../matches/data/models/contest_model.dart';

/// Popular contest card showing prize pool, entry fee, and spots.
class PopularContestCard extends StatelessWidget {
  final ContestModel contest;
  final VoidCallback? onTap;

  const PopularContestCard({
    super.key,
    required this.contest,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contest name
            Text(
              contest.name,
              style: AppTypography.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.gapH8,
            // Prize pool
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 14,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  'Prize Pool',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '\u20B9${contest.formattedPrizePool}',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.gapH12,
            // Spots progress bar
            ClipRRect(
              borderRadius: AppSpacing.borderRadiusFull,
              child: LinearProgressIndicator(
                value: contest.fillPercentage,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  contest.fillPercentage > 0.8
                      ? AppColors.error
                      : AppColors.primary,
                ),
                minHeight: 4,
              ),
            ),
            AppSpacing.gapH8,
            // Entry fee and spots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  contest.formattedEntryFee,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${contest.spotsLeft} spots left',
                  style: AppTypography.labelSmall.copyWith(
                    color: contest.spotsLeft < 10
                        ? AppColors.error
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
