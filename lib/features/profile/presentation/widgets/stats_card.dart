import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Animated stats display card.
class StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Center(
              child: Icon(icon, color: color, size: 18),
            ),
          ),
          AppSpacing.gapH12,
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stats grid widget showing user statistics in a grid layout.
class StatsGrid extends StatelessWidget {
  final int matchesPlayed;
  final int contestsWon;
  final double totalWinnings;
  final int teamsCreated;

  const StatsGrid({
    super.key,
    required this.matchesPlayed,
    required this.contestsWon,
    required this.totalWinnings,
    required this.teamsCreated,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        StatsCard(
          label: 'Matches Played',
          value: matchesPlayed.toString(),
          icon: Icons.sports_cricket,
          color: AppColors.info,
        ),
        StatsCard(
          label: 'Contests Won',
          value: contestsWon.toString(),
          icon: Icons.emoji_events,
          color: AppColors.warning,
        ),
        StatsCard(
          label: 'Total Winnings',
          value: '\u20B9${totalWinnings.toStringAsFixed(0)}',
          icon: Icons.monetization_on_outlined,
          color: AppColors.success,
        ),
        StatsCard(
          label: 'Teams Created',
          value: teamsCreated.toString(),
          icon: Icons.groups_outlined,
          color: AppColors.primary,
        ),
      ],
    );
  }
}
