import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../matches/data/models/player_model.dart';

/// Selectable player card with credit, points, team badge.
/// [isInPlayingXI] = true  → green ✓ tick (confirmed in lineup)
/// [isInPlayingXI] = false → red ✗ tick  (NOT in lineup, admin announced)
/// [isInPlayingXI] = null  → no lineup indicator (lineup not announced yet)
class PlayerSelectionCard extends StatelessWidget {
  final PlayerModel player;
  final bool isSelected;
  final bool isDisabled;
  final bool? isInPlayingXI; // null = not announced
  final VoidCallback? onTap;

  const PlayerSelectionCard({
    super.key,
    required this.player,
    this.isSelected = false,
    this.isDisabled = false,
    this.isInPlayingXI,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled && !isSelected ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : isDisabled
                  ? AppColors.border.withOpacity(0.3)
                  : AppColors.card,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isDisabled
                    ? AppColors.border
                    : AppColors.border.withOpacity(0.5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textTertiary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            AppSpacing.gapW8,

            // Player image with Playing XI indicator overlay
            Stack(
              clipBehavior: Clip.none,
              children: [
                if (player.image != null && player.image!.isNotEmpty)
                  CachedImage(
                    imageUrl: player.image!,
                    width: 44,
                    height: 44,
                    borderRadius: BorderRadius.circular(22),
                  )
                else
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        player.name.isNotEmpty
                            ? player.name[0].toUpperCase()
                            : 'P',
                        style: AppTypography.titleMedium
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                // ── Playing XI indicator (green ✓ / red ✗) ──────────
                if (isInPlayingXI != null)
                  Positioned(
                    bottom: -2,
                    right: -4,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: isInPlayingXI!
                            ? AppColors.success
                            : AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Center(
                        child: Icon(
                          isInPlayingXI! ? Icons.check : Icons.close,
                          size: 11,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            AppSpacing.gapW12,

            // Player info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          player.name,
                          style: AppTypography.titleSmall.copyWith(
                            color: isDisabled && !isSelected
                                ? AppColors.textTertiary
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Lineup badge text
                      if (isInPlayingXI != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: isInPlayingXI!
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isInPlayingXI! ? 'Playing' : 'Not Playing',
                            style: AppTypography.labelSmall.copyWith(
                              color: isInPlayingXI!
                                  ? AppColors.success
                                  : AppColors.error,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: AppSpacing.borderRadiusFull,
                        ),
                        child: Text(
                          player.teamName.isNotEmpty
                              ? player.teamName
                              : player.team?.code ?? '',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.info,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      AppSpacing.gapW8,
                      Text(
                        player.roleAbbreviation,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Points + Credits
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${player.points.toStringAsFixed(0)} pts',
                  style: AppTypography.labelSmall
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.secondary.withOpacity(0.05),
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                  child: Text(
                    '${player.credits.toStringAsFixed(1)} Cr',
                    style: AppTypography.labelSmall.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
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
