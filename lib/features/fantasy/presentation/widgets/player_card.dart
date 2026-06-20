import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../matches/data/models/player_model.dart';

/// Selectable player card with credit, points, and team badge.
class PlayerSelectionCard extends StatelessWidget {
  final PlayerModel player;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  const PlayerSelectionCard({
    super.key,
    required this.player,
    this.isSelected = false,
    this.isDisabled = false,
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
                  color:
                      isSelected ? AppColors.primary : AppColors.textTertiary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            AppSpacing.gapW12,
            // Player image
            if (player.image != null && player.image!.isNotEmpty)
              CachedImage(
                url: player.image!,
                width: 44,
                height: 44,
                borderRadius: 22,
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
                    player.name.isNotEmpty ? player.name[0].toUpperCase() : 'P',
                    style: AppTypography.titleMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            AppSpacing.gapW12,
            // Player info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: AppTypography.titleSmall.copyWith(
                      color: isDisabled && !isSelected
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      // Team badge
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
                      // Role
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
            // Points
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${player.points.toStringAsFixed(0)} pts',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                // Credits
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
