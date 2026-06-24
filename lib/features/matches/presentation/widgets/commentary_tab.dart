import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/celebration_overlay.dart';
import '../../data/models/scoreboard_model.dart';

/// Ball-by-ball commentary tab with real-time updates + celebration overlay.
/// Ported from Fantasy- commentary.js — triggers confetti on SIX/FOUR/WICKET.
class CommentaryTab extends StatefulWidget {
  final List<CommentaryModel> commentary;

  const CommentaryTab({super.key, required this.commentary});

  @override
  State<CommentaryTab> createState() => _CommentaryTabState();
}

class _CommentaryTabState extends State<CommentaryTab> {
  List<CommentaryModel> _prevCommentary = [];

  @override
  void didUpdateWidget(CommentaryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.commentary.length > _prevCommentary.length &&
        widget.commentary.isNotEmpty) {
      final latest = widget.commentary.first;
      if (latest.isWicket) {
        CelebrationOverlay.show(context, type: CelebrationEventType.wicket);
      } else if (latest.eventType == 'six') {
        CelebrationOverlay.show(context, type: CelebrationEventType.six);
      } else if (latest.eventType == 'four' || latest.isBoundary) {
        CelebrationOverlay.show(context, type: CelebrationEventType.four);
      }
    }
    _prevCommentary = widget.commentary;
  }

  @override
  Widget build(BuildContext context) {
    final commentary = widget.commentary;
    if (commentary.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.textTertiary,
            ),
            AppSpacing.gapH16,
            Text(
              'Commentary will appear once the match starts',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: commentary.length,
      itemBuilder: (context, index) {
        final entry = commentary[index];
        final showOverHeader = index == 0 ||
            commentary[index].overNumber !=
                commentary[index > 0 ? index - 1 : 0].overNumber;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showOverHeader)
              _OverHeader(overNumber: entry.overNumber),
            _CommentaryBall(entry: entry),
          ],
        );
      },
    );
  }
}

/// Over separator header.
class _OverHeader extends StatelessWidget {
  final int overNumber;

  const _OverHeader({required this.overNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.05),
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Text(
        'Over $overNumber',
        style: AppTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Single ball commentary entry.
class _CommentaryBall extends StatelessWidget {
  final CommentaryModel entry;

  const _CommentaryBall({required this.entry});

  Color get _ballColor {
    if (entry.isWicket) return AppColors.error;
    if (entry.eventType == 'six') return AppColors.primary;
    if (entry.eventType == 'four') return AppColors.info;
    if (entry.runs == 0) return AppColors.textTertiary;
    return AppColors.success;
  }

  String get _ballDisplay {
    if (entry.isWicket) return 'W';
    if (entry.eventType == 'wide') return 'WD';
    if (entry.eventType == 'no_ball') return 'NB';
    return '${entry.runs}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppSpacing.borderRadiusSm,
        border: entry.isWicket || entry.isBoundary
            ? Border.all(
                color: _ballColor.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ball indicator
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _ballColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: _ballColor, width: 1.5),
            ),
            child: Center(
              child: Text(
                _ballDisplay,
                style: AppTypography.labelSmall.copyWith(
                  color: _ballColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          AppSpacing.gapW12,
          // Commentary content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Over.Ball and batsman vs bowler
                Row(
                  children: [
                    Text(
                      entry.overBall,
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    AppSpacing.gapW8,
                    if (entry.bowler != null)
                      Text(
                        '${entry.bowler} to ${entry.batsman ?? "batsman"}',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                // Description
                if (entry.description != null && entry.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      entry.description!,
                      style: AppTypography.bodySmall,
                    ),
                  ),
                // Event badge
                if (entry.isWicket || entry.isBoundary)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _ballColor.withOpacity(0.1),
                        borderRadius: AppSpacing.borderRadiusFull,
                      ),
                      child: Text(
                        entry.isWicket
                            ? 'WICKET!'
                            : entry.eventType == 'six'
                                ? 'SIX!'
                                : 'FOUR!',
                        style: AppTypography.labelSmall.copyWith(
                          color: _ballColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
