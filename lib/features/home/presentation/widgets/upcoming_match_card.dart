import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../data/models/match_model.dart';

/// Upcoming match card widget with countdown timer.
class UpcomingMatchCard extends StatefulWidget {
  final MatchModel match;
  final VoidCallback? onTap;

  const UpcomingMatchCard({
    super.key,
    required this.match,
    this.onTap,
  });

  @override
  State<UpcomingMatchCard> createState() => _UpcomingMatchCardState();
}

class _UpcomingMatchCardState extends State<UpcomingMatchCard> {
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
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
          borderRadius: AppSpacing.borderRadiusMd,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Tournament and countdown
            Row(
              children: [
                if (widget.match.tournamentLogo != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CachedImage(
                      imageUrl: widget.match.tournamentLogo!,
                      width: 16,
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                Expanded(
                  child: Text(
                    widget.match.tournamentName,
                    style: AppTypography.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.upcomingMatch.withOpacity(0.08),
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                  child: Text(
                    _formatCountdown(),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.upcomingMatch,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.gapH16,
            // Teams row
            Row(
              children: [
                // Team A
                Expanded(
                  child: Row(
                    children: [
                      _TeamLogo(
                        flag: widget.match.teamAFlag,
                        code: widget.match.teamACode,
                      ),
                      AppSpacing.gapW8,
                      Expanded(
                        child: Text(
                          widget.match.teamAName,
                          style: AppTypography.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // VS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'vs',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                // Team B
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          widget.match.teamBName,
                          style: AppTypography.titleMedium,
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AppSpacing.gapW8,
                      _TeamLogo(
                        flag: widget.match.teamBFlag,
                        code: widget.match.teamBCode,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.gapH12,
            // Venue
            if (widget.match.venue != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 12,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.match.venue!,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _TeamLogo extends StatelessWidget {
  final String? flag;
  final String? code;

  const _TeamLogo({this.flag, this.code});

  @override
  Widget build(BuildContext context) {
    debugPrint('[_TeamLogo] flag: $flag, code: $code');
    if (flag != null && flag!.isNotEmpty) {
      return CachedImage(
        imageUrl: flag!,
        width: 36,
        height: 36,
        borderRadius: BorderRadius.circular(18),
      );
    }
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          code?.isNotEmpty == true ? code![0] : 'T',
          style: AppTypography.titleSmall.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
