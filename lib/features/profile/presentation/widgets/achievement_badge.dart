import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/repositories/profile_repository.dart';

/// Achievement badge widget showing progress and unlock state.
class AchievementBadge extends StatelessWidget {
  final Achievement achievement;

  const AchievementBadge({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? AppColors.warning.withOpacity(0.05)
            : AppColors.card,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: achievement.isUnlocked
              ? AppColors.warning.withOpacity(0.3)
              : AppColors.border.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          // Badge Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? AppColors.warning.withOpacity(0.15)
                  : AppColors.scaffoldBackground,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                _getIcon(),
                color: achievement.isUnlocked
                    ? AppColors.warning
                    : AppColors.textTertiary,
                size: 24,
              ),
            ),
          ),
          AppSpacing.gapW12,
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      achievement.title,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: achievement.isUnlocked
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (achievement.isUnlocked) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: AppColors.warning,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                if (!achievement.isUnlocked) ...[
                  const SizedBox(height: 6),
                  // Progress bar
                  ClipRRect(
                    borderRadius: AppSpacing.borderRadiusFull,
                    child: LinearProgressIndicator(
                      value: achievement.progress,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (achievement.icon) {
      case 'sports_cricket':
        return Icons.sports_cricket;
      case 'military_tech':
        return Icons.military_tech;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'monetization_on':
        return Icons.monetization_on;
      case 'verified':
        return Icons.verified;
      case 'groups':
        return Icons.groups;
      default:
        return Icons.star;
    }
  }
}
