import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../matches/data/models/player_model.dart';
import '../../../matches/domain/providers/match_provider.dart';
import '../../domain/providers/fantasy_provider.dart';

/// Captain and vice-captain selection screen with multiplier info.
class CaptainSelectionScreen extends ConsumerWidget {
  final String matchId;

  const CaptainSelectionScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teamBuilderProvider(matchId));

    debugPrint('[CaptainSelection] matchId: $matchId, selectedPlayers: ${state.selectedPlayers.length}');

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
            child: _CaptainPlayerList(matchId: matchId),
          ),
        ],
      ),
      // Bottom save button
      bottomNavigationBar: _BottomBar(matchId: matchId),
    );
  }
}

/// Player list for captain selection showing actual selected players.
class _CaptainPlayerList extends ConsumerWidget {
  final String matchId;

  const _CaptainPlayerList({required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teamBuilderProvider(matchId));
    final notifier = ref.read(teamBuilderProvider(matchId).notifier);
    final players = state.selectedPlayers;

    if (players.isEmpty) {
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
                'No players selected',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.gapH8,
              Text(
                'Go back and select 11 players first.',
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final isCaptain = state.captainId == player.id;
        final isViceCaptain = state.viceCaptainId == player.id;

        return CaptainPlayerRow(
          player: player,
          isCaptain: isCaptain,
          isViceCaptain: isViceCaptain,
          onCaptainTap: () {
            debugPrint('[CaptainSelection] Captain selected: ${player.name} (${player.id})');
            notifier.setCaptain(player.id);
          },
          onViceCaptainTap: () {
            debugPrint('[CaptainSelection] Vice Captain selected: ${player.name} (${player.id})');
            notifier.setViceCaptain(player.id);
          },
        );
      },
    );
  }
}

/// Bottom bar with save team button.
class _BottomBar extends ConsumerWidget {
  final String matchId;

  const _BottomBar({required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teamBuilderProvider(matchId));
    final notifier = ref.read(teamBuilderProvider(matchId).notifier);

    final hasBothCaptains = state.captainId != null &&
        state.captainId!.isNotEmpty &&
        state.viceCaptainId != null &&
        state.viceCaptainId!.isNotEmpty;

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!hasBothCaptains)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Select both Captain and Vice Captain to continue',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            AppButton(
              text: state.isSaving ? 'SAVING...' : 'SAVE TEAM',
              variant: hasBothCaptains
                  ? AppButtonVariant.gradient
                  : AppButtonVariant.outline,
              isDisabled: !hasBothCaptains || state.isSaving,
              onPressed: hasBothCaptains && !state.isSaving
                  ? () async {
                      debugPrint('[CaptainSelection] Save team request - matchId: $matchId, captain: ${state.captainId}, vc: ${state.viceCaptainId}');

                      final result = await notifier.saveTeam();

                      if (result != null) {
                        debugPrint('[CaptainSelection] Team saved successfully: ${result.id}');
                        // Invalidate cached teams so My Team tab picks up the new team
                        final user = ref.read(currentUserProvider);
                        if (user != null) {
                          ref.invalidate(userTeamsForMatchProvider(
                            (matchId: matchId, userId: user.uid),
                          ));
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Team saved successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Navigate back to match detail
                          context.pop();
                          context.pop();
                        }
                      } else {
                        debugPrint('[CaptainSelection] Team save failed');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to save team. Please try again.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  : null,
            ),
          ],
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
              imageUrl: player.image!,
              width: 36,
              height: 36,
              borderRadius: BorderRadius.circular(18),
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
