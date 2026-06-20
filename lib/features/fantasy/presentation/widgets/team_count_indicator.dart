import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/providers/fantasy_provider.dart';

/// Shows selected count per role with min/max constraints.
class TeamCountIndicator extends StatelessWidget {
  final int selectedCount;
  final int wkCount;
  final int batCount;
  final int arCount;
  final int bowlCount;

  const TeamCountIndicator({
    super.key,
    required this.selectedCount,
    required this.wkCount,
    required this.batCount,
    required this.arCount,
    required this.bowlCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          // Total player count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: selectedCount == RoleConstraints.totalPlayers
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.secondary.withOpacity(0.05),
              borderRadius: AppSpacing.borderRadiusFull,
              border: Border.all(
                color: selectedCount == RoleConstraints.totalPlayers
                    ? AppColors.success
                    : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people,
                  size: 14,
                  color: selectedCount == RoleConstraints.totalPlayers
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
                AppSpacing.gapW4,
                Text(
                  '$selectedCount/${RoleConstraints.totalPlayers}',
                  style: AppTypography.labelMedium.copyWith(
                    color: selectedCount == RoleConstraints.totalPlayers
                        ? AppColors.success
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapW12,
          // Role counts
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _RoleCount(
                  label: 'WK',
                  count: wkCount,
                  min: RoleConstraints.minWK,
                  max: RoleConstraints.maxWK,
                ),
                _RoleCount(
                  label: 'BAT',
                  count: batCount,
                  min: RoleConstraints.minBAT,
                  max: RoleConstraints.maxBAT,
                ),
                _RoleCount(
                  label: 'AR',
                  count: arCount,
                  min: RoleConstraints.minAR,
                  max: RoleConstraints.maxAR,
                ),
                _RoleCount(
                  label: 'BOWL',
                  count: bowlCount,
                  min: RoleConstraints.minBOWL,
                  max: RoleConstraints.maxBOWL,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCount extends StatelessWidget {
  final String label;
  final int count;
  final int min;
  final int max;

  const _RoleCount({
    required this.label,
    required this.count,
    required this.min,
    required this.max,
  });

  Color get _statusColor {
    if (count >= max) return AppColors.success;
    if (count >= min) return AppColors.info;
    if (count > 0) return AppColors.warning;
    return AppColors.textTertiary;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textTertiary,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$count',
          style: AppTypography.titleSmall.copyWith(
            color: _statusColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
