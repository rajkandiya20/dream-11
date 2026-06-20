import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../data/models/match_model.dart';

/// Live match card widget with pulsing live indicator and scores.
class LiveMatchCard extends StatefulWidget {
  final MatchModel match;
  final VoidCallback? onTap;

  const LiveMatchCard({
    super.key,
    required this.match,
    this.onTap,
  });

  @override
  State<LiveMatchCard> createState() => _LiveMatchCardState();
}

class _LiveMatchCardState extends State<LiveMatchCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 16),
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppSpacing.borderRadiusLg,
          border: Border.all(color: AppColors.liveMatch.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.liveMatch.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with tournament name and LIVE badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.match.tournamentName,
                    style: AppTypography.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Live indicator
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.liveMatch
                            .withOpacity(_pulseAnimation.value * 0.15),
                        borderRadius: AppSpacing.borderRadiusFull,
                        border: Border.all(
                          color: AppColors.liveMatch
                              .withOpacity(_pulseAnimation.value),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.liveMatch
                                  .withOpacity(_pulseAnimation.value),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.liveMatch,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            AppSpacing.gapH16,
            // Teams and scores
            Row(
              children: [
                // Team A
                Expanded(
                  child: _TeamScore(
                    teamName: widget.match.teamAName,
                    teamCode: widget.match.teamACode ?? '',
                    teamFlag: widget.match.teamAFlag,
                    score: widget.match.currentScoreA ?? widget.match.teamAScore,
                  ),
                ),
                // VS divider
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.05),
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                  child: Text(
                    'VS',
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                // Team B
                Expanded(
                  child: _TeamScore(
                    teamName: widget.match.teamBName,
                    teamCode: widget.match.teamBCode ?? '',
                    teamFlag: widget.match.teamBFlag,
                    score: widget.match.currentScoreB ?? widget.match.teamBScore,
                    alignEnd: true,
                  ),
                ),
              ],
            ),
            AppSpacing.gapH12,
            // Current over info
            if (widget.match.currentOver != null)
              Center(
                child: Text(
                  'Over ${widget.match.currentOver!.toStringAsFixed(1)}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TeamScore extends StatelessWidget {
  final String teamName;
  final String teamCode;
  final String? teamFlag;
  final String? score;
  final bool alignEnd;

  const _TeamScore({
    required this.teamName,
    required this.teamCode,
    this.teamFlag,
    this.score,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (teamFlag != null && teamFlag!.isNotEmpty)
          CachedImage(
            url: teamFlag!,
            width: 32,
            height: 32,
            borderRadius: 16,
          )
        else
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                teamCode.isNotEmpty ? teamCode[0] : 'T',
                style: AppTypography.titleSmall.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        AppSpacing.gapH8,
        Text(
          teamCode.isNotEmpty ? teamCode : teamName,
          style: AppTypography.titleMedium,
        ),
        if (score != null)
          Text(
            score!,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
