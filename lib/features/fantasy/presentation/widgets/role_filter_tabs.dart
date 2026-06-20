import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/providers/fantasy_provider.dart';

/// WK/BAT/AR/BOWL filter tabs with selection count indicators.
class RoleFilterTabs extends StatelessWidget {
  final PlayerRoleFilter activeFilter;
  final int wkCount;
  final int batCount;
  final int arCount;
  final int bowlCount;
  final ValueChanged<PlayerRoleFilter> onFilterChanged;

  const RoleFilterTabs({
    super.key,
    required this.activeFilter,
    required this.wkCount,
    required this.batCount,
    required this.arCount,
    required this.bowlCount,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          _FilterTab(
            label: 'WK',
            count: wkCount,
            min: RoleConstraints.minWK,
            max: RoleConstraints.maxWK,
            isActive: activeFilter == PlayerRoleFilter.wk,
            onTap: () => onFilterChanged(PlayerRoleFilter.wk),
          ),
          AppSpacing.gapW8,
          _FilterTab(
            label: 'BAT',
            count: batCount,
            min: RoleConstraints.minBAT,
            max: RoleConstraints.maxBAT,
            isActive: activeFilter == PlayerRoleFilter.bat,
            onTap: () => onFilterChanged(PlayerRoleFilter.bat),
          ),
          AppSpacing.gapW8,
          _FilterTab(
            label: 'AR',
            count: arCount,
            min: RoleConstraints.minAR,
            max: RoleConstraints.maxAR,
            isActive: activeFilter == PlayerRoleFilter.ar,
            onTap: () => onFilterChanged(PlayerRoleFilter.ar),
          ),
          AppSpacing.gapW8,
          _FilterTab(
            label: 'BOWL',
            count: bowlCount,
            min: RoleConstraints.minBOWL,
            max: RoleConstraints.maxBOWL,
            isActive: activeFilter == PlayerRoleFilter.bowl,
            onTap: () => onFilterChanged(PlayerRoleFilter.bowl),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final int count;
  final int min;
  final int max;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.count,
    required this.min,
    required this.max,
    required this.isActive,
    required this.onTap,
  });

  bool get _meetsMinimum => count >= min;
  bool get _atMaximum => count >= max;

  Color get _countColor {
    if (_atMaximum) return AppColors.success;
    if (_meetsMinimum) return AppColors.info;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: AppSpacing.borderRadiusSm,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.border,
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color:
                      isActive ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              // Count indicator
              Text(
                '$count',
                style: AppTypography.titleSmall.copyWith(
                  color: _countColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              // Min-Max range
              Text(
                '($min-$max)',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
