import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/notification_model.dart';

/// Notification list item with icon, time, and read/unread state.
class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error.withOpacity(0.1),
        child: Icon(Icons.delete_outline, color: AppColors.error),
      ),
      child: Material(
        color: notification.isRead
            ? Colors.transparent
            : AppColors.primary.withOpacity(0.02),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                _buildIcon(),
                AppSpacing.gapW12,
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            notification.timeAgo,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Unread dot
                if (!notification.isRead)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final IconData iconData;
    final Color iconColor;
    final Color bgColor;

    switch (notification.type) {
      case NotificationType.winning:
        iconData = Icons.emoji_events;
        iconColor = AppColors.warning;
        bgColor = AppColors.warning.withOpacity(0.1);
        break;
      case NotificationType.match:
        iconData = Icons.sports_cricket;
        iconColor = AppColors.info;
        bgColor = AppColors.info.withOpacity(0.1);
        break;
      case NotificationType.bonus:
        iconData = Icons.card_giftcard;
        iconColor = AppColors.success;
        bgColor = AppColors.success.withOpacity(0.1);
        break;
      case NotificationType.general:
      default:
        iconData = Icons.notifications_outlined;
        iconColor = AppColors.textSecondary;
        bgColor = AppColors.scaffoldBackground;
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Center(
        child: Icon(iconData, color: iconColor, size: 22),
      ),
    );
  }
}
