import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../matches/data/models/player_model.dart';

/// Trending player card showing player info, points, and team badge.
class TrendingPlayerCard extends StatelessWidget {
  final PlayerModel player;
  final VoidCallback? onTap;

  const TrendingPlayerCard({
    super.key,
    required this.player,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
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
          children: [
            // Player image
            if (player.image != null && player.image!.isNotEmpty)
              CachedImage(
                url: player.image!,
                width: 56,
                height: 56,
                borderRadius: 28,
              )
            else
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    player.name.isNotEmpty ? player.name[0].toUpperCase() : 'P',
                    style: AppTypography.headlineMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            AppSpacing.gapH8,
            // Player name
            Text(
              player.name,
              style: AppTypography.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            // Team name
            Text(
              player.teamName,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.gapH8,
            // Points and role
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                  child: Text(
                    '${player.points.toStringAsFixed(0)} pts',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                  child: Text(
                    player.roleAbbreviation,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                    ),
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
