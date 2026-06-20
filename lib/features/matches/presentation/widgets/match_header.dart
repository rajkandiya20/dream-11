import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../home/data/models/match_model.dart';

/// Animated match header with team logos, live score, and countdown.
class MatchHeader extends StatefulWidget {
  final MatchModel match;

  const MatchHeader({super.key, required this.match});

  @override
  State<MatchHeader> createState() => _MatchHeaderState();
}

class _MatchHeaderState extends State<MatchHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    if (widget.match.isLive) {
      _pulseController.repeat(reverse: true);
    } else if (widget.match.isUpcoming) {
      _updateRemaining();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _updateRemaining();
      });
    }
  }

  void _updateRemaining() {
    final diff = widget.match.dateTime.difference(DateTime.now());
    if (mounted) {
      setState(() {
        _remaining = diff.isNegative ? Duration.zero : diff;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatCountdown() {
    if (_remaining == Duration.zero) return 'Starting soon';
    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    if (days > 0) return '${days}d ${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h ${minutes}m ${seconds}s';
    return '${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.secondaryGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 56, 16, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Tournament name
              Text(
                widget.match.tournamentName,
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white70,
                ),
              ),
              AppSpacing.gapH16,
              // Teams row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Team A
                  _TeamWidget(
                    name: widget.match.teamAName,
                    code: widget.match.teamACode,
                    flag: widget.match.teamAFlag,
                    score: widget.match.isLive
                        ? widget.match.currentScoreA
                        : widget.match.teamAScore,
                  ),
                  // Center info
                  Column(
                    children: [
                      if (widget.match.isLive) ...[
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.liveMatch.withOpacity(
                                    0.1 + _pulseController.value * 0.2),
                                borderRadius: AppSpacing.borderRadiusFull,
                                border: Border.all(
                                  color: AppColors.liveMatch,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'LIVE',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.liveMatch,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            );
                          },
                        ),
                        if (widget.match.currentOver != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Ov ${widget.match.currentOver!.toStringAsFixed(1)}',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white54,
                              ),
                            ),
                          ),
                      ] else if (widget.match.isUpcoming) ...[
                        Text(
                          'VS',
                          style: AppTypography.headlineLarge.copyWith(
                            color: Colors.white38,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppSpacing.gapH4,
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.upcomingMatch.withOpacity(0.2),
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
                      ] else ...[
                        Text(
                          'VS',
                          style: AppTypography.headlineLarge.copyWith(
                            color: Colors.white38,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (widget.match.result != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              widget.match.result!,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.success,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ],
                  ),
                  // Team B
                  _TeamWidget(
                    name: widget.match.teamBName,
                    code: widget.match.teamBCode,
                    flag: widget.match.teamBFlag,
                    score: widget.match.isLive
                        ? widget.match.currentScoreB
                        : widget.match.teamBScore,
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
                      color: Colors.white54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.match.venue!,
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamWidget extends StatelessWidget {
  final String name;
  final String? code;
  final String? flag;
  final String? score;

  const _TeamWidget({
    required this.name,
    this.code,
    this.flag,
    this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (flag != null && flag!.isNotEmpty)
          CachedImage(
            imageUrl: flag!,
            width: 48,
            height: 48,
            borderRadius: BorderRadius.circular(24),
          )
        else
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                code?.isNotEmpty == true ? code![0] : name[0],
                style: AppTypography.headlineMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        AppSpacing.gapH8,
        Text(
          code?.isNotEmpty == true ? code! : name,
          style: AppTypography.titleMedium.copyWith(color: Colors.white),
        ),
        if (score != null)
          Text(
            score!,
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
