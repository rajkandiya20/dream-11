import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../matches/data/models/contest_model.dart';

/// Contest card with prize pool bar and spots indicator.
class ContestCard extends StatelessWidget {
  final ContestModel contest;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;

  const ContestCard({
    super.key,
    required this.contest,
    this.onTap,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppSpacing.borderRadiusMd,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contest name and type badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    contest.name,
                    style: AppTypography.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: contest.isFree
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                  child: Text(
                    contest.isFree ? 'FREE' : 'PAID',
                    style: AppTypography.labelSmall.copyWith(
                      color:
                          contest.isFree ? AppColors.success : AppColors.warning,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.gapH12,
            // Prize pool and entry fee row
            Row(
              children: [
                // Prize Pool
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prize Pool',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\u20B9${contest.formattedPrizePool}',
                        style: AppTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                // Entry fee button
                GestureDetector(
                  onTap: onJoin ?? onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: AppSpacing.borderRadiusFull,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      contest.formattedEntryFee,
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.gapH16,
            // Spots progress bar
            ClipRRect(
              borderRadius: AppSpacing.borderRadiusFull,
              child: LinearProgressIndicator(
                value: contest.fillPercentage,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  contest.fillPercentage > 0.8
                      ? AppColors.error
                      : contest.fillPercentage > 0.5
                          ? AppColors.warning
                          : AppColors.success,
                ),
                minHeight: 6,
              ),
            ),
            AppSpacing.gapH8,
            // Spots info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${contest.spotsLeft} spots left',
                  style: AppTypography.labelSmall.copyWith(
                    color: contest.spotsLeft < 10
                        ? AppColors.error
                        : AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${contest.maxTeams} total spots',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
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
