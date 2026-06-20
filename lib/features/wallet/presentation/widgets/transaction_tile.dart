import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/transaction_model.dart';

/// Transaction list item with icon, amount, date, and status.
class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Icon
              _buildIcon(),
              AppSpacing.gapW12,
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.type.displayName,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDescription(),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AppSpacing.gapW12,
              // Amount and status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    transaction.formattedAmount,
                    style: AppTypography.titleSmall.copyWith(
                      color: transaction.isCredit
                          ? AppColors.success
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusBadge(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final IconData iconData;
    final Color iconColor;
    final Color bgColor;

    switch (transaction.type) {
      case TransactionType.deposit:
        iconData = Icons.arrow_downward_rounded;
        iconColor = AppColors.success;
        bgColor = AppColors.success.withOpacity(0.1);
        break;
      case TransactionType.withdrawal:
        iconData = Icons.arrow_upward_rounded;
        iconColor = AppColors.warning;
        bgColor = AppColors.warning.withOpacity(0.1);
        break;
      case TransactionType.contestJoin:
        iconData = Icons.sports_esports_outlined;
        iconColor = AppColors.info;
        bgColor = AppColors.info.withOpacity(0.1);
        break;
      case TransactionType.winning:
        iconData = Icons.emoji_events_outlined;
        iconColor = AppColors.warning;
        bgColor = AppColors.warning.withOpacity(0.1);
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

  Widget _buildStatusBadge() {
    final Color color;
    switch (transaction.status) {
      case TransactionStatus.completed:
        color = AppColors.success;
        break;
      case TransactionStatus.pending:
        color = AppColors.warning;
        break;
      case TransactionStatus.rejected:
        color = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Text(
        transaction.status.displayName,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontSize: 10,
        ),
      ),
    );
  }

  String _formatDescription() {
    if (transaction.description != null &&
        transaction.description!.isNotEmpty) {
      return transaction.description!;
    }
    if (transaction.createdAt != null) {
      return DateFormat('dd MMM yyyy, hh:mm a').format(transaction.createdAt!);
    }
    return transaction.type.displayName;
  }
}
