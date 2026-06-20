import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/group_model.dart';

/// Group list item card widget.
class GroupCard extends StatelessWidget {
  final GroupModel group;
  final VoidCallback? onTap;

  const GroupCard({
    super.key,
    required this.group,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              // Group Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: AppSpacing.borderRadiusMd,
                  image: group.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(group.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: group.avatarUrl == null
                    ? Center(
                        child: Text(
                          group.name.isNotEmpty
                              ? group.name[0].toUpperCase()
                              : 'G',
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : null,
              ),
              AppSpacing.gapW12,
              // Group Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (group.description != null &&
                        group.description!.isNotEmpty)
                      Text(
                        group.description!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${group.memberCount} member${group.memberCount != 1 ? 's' : ''}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
