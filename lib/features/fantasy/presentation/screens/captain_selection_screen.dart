import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../matches/data/models/player_model.dart';
import '../../domain/providers/fantasy_provider.dart';

/// Captain and vice-captain selection screen with multiplier info.
class CaptainSelectionScreen extends ConsumerWidget {
  const CaptainSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Find the active team builder provider.
    // Since captain selection comes after create team, we need the matchId.
    // For now we look for any team builder state that has selected players.
    // In production, this would be passed via route parameters.

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Choose Captain', style: AppTypography.titleLarge),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Info card about captain multipliers
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
              ),
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.warningDark, size: 20),
                AppSpacing.gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Captain & Vice Captain',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.warningDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'C gets 2x points, VC gets 1.5x points',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.warningDark.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Multiplier badges
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _MultiplierBadge(
                  label: 'Captain',
                  multiplier: '2x',
                  color: AppColors.primary,
                ),
                AppSpacing.gapW12,
                _MultiplierBadge(
                  label: 'Vice Captain',
                  multiplier: '1.5x',
                  color: AppColors.info,
                ),
              ],
            ),
          ),
          AppSpacing.gapH16,
          // Player list header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.03),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Player',
                      style: AppTypography.labelSmall
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
                SizedBox(
                  width: 50,
                  child: Text('Points',
                      style: AppTypography.labelSmall
                          .copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center),
                ),
                SizedBox(
                  width: 40,
                  child: Text('C',
                      style: AppTypography.labelSmall
                          .copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center),
                ),
                SizedBox(
                  width: 40,
                  child: Text('VC',
                      style: AppTypography.labelSmall
                          .copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
          // Selected players list for captain choice
          Expanded(
            child: _CaptainPlayerList(),
          ),
        ],
      ),
      // Bottom save button
      bottomNavigationBar: _BottomBar(),
    );
  }
}

/// Player list for captain selection (uses placeholder data pattern).
class _CaptainPlayerList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The captain selection screen receives selected players from the team builder.
    // In a production app, the matchId would be passed as a route parameter.
    // For now, we show a placeholder that integrates with the state.

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app,
              size: 48,
              color: AppColors.primary.withOpacity(0.5),
            ),
            AppSpacing.gapH16,
            Text(
              'Tap C or VC to assign roles',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapH8,
            Text(
              'Your selected players will appear here.\nCaptain gets 2x points, Vice Captain gets 1.5x points.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom bar with save team button.
class _BottomBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: AppButton(
          text: 'SAVE TEAM',
          variant: AppButtonVariant.gradient,
          onPressed: () {
            // In production, this would save the team and navigate back.
            // For now, pop back to the match detail.
            context.pop();
            context.pop();
          },
        ),
      ),
    );
  }
}

/// Captain/VC multiplier badge.
class _MultiplierBadge extends StatelessWidget {
  final String label;
  final String multiplier;
  final Color color;

  const _MultiplierBadge({
    required this.label,
    required this.multiplier,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: AppSpacing.borderRadiusSm,
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  multiplier,
                  style: AppTypography.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            AppSpacing.gapW8,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$multiplier Points',
                  style: AppTypography.labelSmall.copyWith(
                    color: color.withOpacity(0.7),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Player row for captain selection.
class CaptainPlayerRow extends StatelessWidget {
  final PlayerModel player;
  final bool isCaptain;
  final bool isViceCaptain;
  final VoidCallback onCaptainTap;
  final VoidCallback onViceCaptainTap;

  const CaptainPlayerRow({
    super.key,
    required this.player,
    required this.isCaptain,
    required this.isViceCaptain,
    required this.onCaptainTap,
    required this.onViceCaptainTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isCaptain || isViceCaptain
            ? (isCaptain ? AppColors.primary : AppColors.info)
                .withOpacity(0.03)
            : null,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          // Player info
          if (player.image != null && player.image!.isNotEmpty)
            CachedImage(
              url: player.image!,
              width: 36,
              height: 36,
              borderRadius: 18,
            )
          else
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.secondaryLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  player.name.isNotEmpty ? player.name[0] : 'P',
                  style: AppTypography.titleSmall
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
          AppSpacing.gapW12,
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: AppTypography.bodySmall
                      .copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${player.teamName} - ${player.roleAbbreviation}',
                  style: AppTypography.labelSmall,
                ),
              ],
            ),
          ),
          // Points
          SizedBox(
            width: 50,
            child: Text(
              '${player.points.toStringAsFixed(0)}',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          // Captain button
          GestureDetector(
            onTap: onCaptainTap,
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isCaptain ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCaptain ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  'C',
                  style: AppTypography.labelSmall.copyWith(
                    color: isCaptain ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          // Vice Captain button
          GestureDetector(
            onTap: onViceCaptainTap,
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isViceCaptain ? AppColors.info : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isViceCaptain ? AppColors.info : AppColors.border,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  'VC',
                  style: AppTypography.labelSmall.copyWith(
                    color:
                        isViceCaptain ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
