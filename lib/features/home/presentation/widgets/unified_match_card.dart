import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../data/models/match_model.dart';

/// Unified match card used for upcoming, live, and completed matches.
/// Same layout structure, only status badge changes based on match status.
class UnifiedMatchCard extends StatefulWidget {
  final MatchModel match;
  final VoidCallback? onTap;

  const UnifiedMatchCard({
    super.key,
    required this.match,
    this.onTap,
  });

  @override
  State<UnifiedMatchCard> createState() => _UnifiedMatchCardState();
}

class _UnifiedMatchCardState extends State<UnifiedMatchCard>
    with SingleTickerProviderStateMixin {
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();

    if (widget.match.isUpcoming) {
      _updateRemaining();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _updateRemaining();
      });
    }

    if (widget.match.isLive) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..repeat(reverse: true);
      _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
      );
    }
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final diff = widget.match.dateTime.difference(now);
    if (mounted) {
      setState(() {
        _remaining = diff.isNegative ? Duration.zero : diff;
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController?.dispose();
    super.dispose();
  }

  String _formatCountdown() {
    if (_remaining == Duration.zero) return 'Starting soon';

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else {
      return '${minutes}m ${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppSpacing.borderRadiusLg,
          border: Border.all(
            color: _borderColor.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Tournament name + Status badge
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
                _buildStatusBadge(),
              ],
            ),
            AppSpacing.gapH16,
            // Middle: Team A logo+name | VS | Team B logo+name
            Row(
              children: [
                // Team A
                Expanded(
                  child: Row(
                    children: [
                      _TeamLogo(
                        flag: widget.match.teamAFlag,
                        code: widget.match.teamACode,
                        name: widget.match.teamAName,
                      ),
                      AppSpacing.gapW8,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.match.teamAName,
                              style: AppTypography.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.match.isLive &&
                                (widget.match.currentScoreA != null ||
                                    widget.match.teamAScore != null))
                              Text(
                                widget.match.currentScoreA ??
                                    widget.match.teamAScore ??
                                    '',
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.match.teamBName,
                              style: AppTypography.titleMedium,
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.match.isLive &&
                                (widget.match.currentScoreB != null ||
                                    widget.match.teamBScore != null))
                              Text(
                                widget.match.currentScoreB ??
                                    widget.match.teamBScore ??
                                    '',
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      AppSpacing.gapW8,
                      _TeamLogo(
                        flag: widget.match.teamBFlag,
                        code: widget.match.teamBCode,
                        name: widget.match.teamBName,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.gapH12,
            // Bottom: Venue + Time / Countdown
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.match.venue != null) ...[
                  Icon(
                    Icons.location_on_outlined,
                    size: 12,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      widget.match.venue!,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (widget.match.isUpcoming) ...[
                  Icon(
                    Icons.schedule,
                    size: 12,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatCountdown(),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.upcomingMatch,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (widget.match.isLive && widget.match.currentOver != null) ...[
                  Text(
                    'Over ${widget.match.currentOver!.toStringAsFixed(1)}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color get _borderColor {
    if (widget.match.isLive) return AppColors.liveMatch;
    if (widget.match.isCompleted) return AppColors.completedMatch;
    return AppColors.upcomingMatch;
  }

  Widget _buildStatusBadge() {
    if (widget.match.isLive) {
      return AnimatedBuilder(
        animation: _pulseAnimation!,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.liveMatch
                  .withOpacity(_pulseAnimation!.value * 0.15),
              borderRadius: AppSpacing.borderRadiusFull,
              border: Border.all(
                color:
                    AppColors.liveMatch.withOpacity(_pulseAnimation!.value),
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
                        .withOpacity(_pulseAnimation!.value),
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
      );
    }

    if (widget.match.isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.completedMatch.withOpacity(0.1),
          borderRadius: AppSpacing.borderRadiusFull,
          border: Border.all(
            color: AppColors.completedMatch.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Text(
          'RESULT',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.completedMatch,
            fontWeight: FontWeight.w700,
            fontSize: 9,
          ),
        ),
      );
    }

    // Upcoming
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.upcomingMatch.withOpacity(0.08),
        borderRadius: AppSpacing.borderRadiusFull,
        border: Border.all(
          color: AppColors.upcomingMatch.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        'Starting Soon',
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.upcomingMatch,
          fontWeight: FontWeight.w600,
          fontSize: 9,
        ),
      ),
    );
  }
}

/// Team logo widget that shows network image or initials fallback.
class _TeamLogo extends StatelessWidget {
  final String? flag;
  final String? code;
  final String name;

  const _TeamLogo({
    this.flag,
    this.code,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    if (flag != null && flag!.isNotEmpty) {
      return CachedImage(
        imageUrl: flag!,
        width: 36,
        height: 36,
        borderRadius: BorderRadius.circular(18),
      );
    }
    // Fallback to code initials
    final initials = code?.isNotEmpty == true
        ? code!
        : (name.isNotEmpty ? name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase() : 'T');
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
