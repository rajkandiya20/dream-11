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
import '../../../contests/domain/providers/contest_provider.dart';

/// Captain and vice-captain selection screen.
///
/// [matchId]   — required, used to read the teamBuilderProvider.
/// [contestId] — optional. When provided, joinContest() is called
///               automatically after the team is saved.
class CaptainSelectionScreen extends ConsumerWidget {
  final String matchId;
  final String? contestId;

  const CaptainSelectionScreen({
    super.key,
    required this.matchId,
    this.contestId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teamBuilderProvider(matchId));

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
          // Info card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)]),
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: AppColors.warningDark, size: 20),
                AppSpacing.gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Captain & Vice Captain',
                          style: AppTypography.titleSmall
                              .copyWith(color: AppColors.warningDark)),
                      const SizedBox(height: 4),
                      Text('C gets 2x points, VC gets 1.5x points',
                          style: AppTypography.bodySmall.copyWith(
                              color: AppColors.warningDark.withOpacity(0.8))),
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
                    color: AppColors.primary),
                AppSpacing.gapW12,
                _MultiplierBadge(
                    label: 'Vice Captain',
                    multiplier: '1.5x',
                    color: AppColors.info),
              ],
            ),
          ),
          AppSpacing.gapH16,
          // Column headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration:
                BoxDecoration(color: AppColors.secondary.withOpacity(0.03)),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('Player',
                        style: AppTypography.labelSmall
                            .copyWith(fontWeight: FontWeight.w600))),
                SizedBox(
                    width: 50,
                    child: Text('Points',
                        style: AppTypography.labelSmall
                            .copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center)),
                SizedBox(
                    width: 40,
                    child: Text('C',
                        style: AppTypography.labelSmall
                            .copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center)),
                SizedBox(
                    width: 40,
                    child: Text('VC',
                        style: AppTypography.labelSmall
                            .copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center)),
              ],
            ),
          ),
          // Player list
          Expanded(child: _CaptainPlayerList(matchId: matchId)),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        matchId: matchId,
        contestId: contestId,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Player list
// ─────────────────────────────────────────────────────────────────────────────

class _CaptainPlayerList extends ConsumerWidget {
  final String matchId;
  const _CaptainPlayerList({required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state   = ref.watch(teamBuilderProvider(matchId));
    final notifier = ref.read(teamBuilderProvider(matchId).notifier);
    final players = state.selectedPlayers;

    if (players.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app,
                  size: 48, color: AppColors.primary.withOpacity(0.5)),
              AppSpacing.gapH16,
              Text('No players selected',
                  style: AppTypography.bodyLarge
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
              AppSpacing.gapH8,
              Text('Go back and select 11 players first.',
                  style: AppTypography.bodySmall, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player      = players[index];
        final isCaptain   = state.captainId == player.id;
        final isViceCap   = state.viceCaptainId == player.id;

        return CaptainPlayerRow(
          player: player,
          isCaptain: isCaptain,
          isViceCaptain: isViceCap,
          onCaptainTap:    () => notifier.setCaptain(player.id),
          onViceCaptainTap: () => notifier.setViceCaptain(player.id),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom bar — saves team and optionally joins contest
// ─────────────────────────────────────────────────────────────────────────────

class _BottomBar extends ConsumerWidget {
  final String matchId;
  final String? contestId;

  const _BottomBar({required this.matchId, this.contestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(teamBuilderProvider(matchId));
    final notifier = ref.read(teamBuilderProvider(matchId).notifier);

    final hasBoth = state.captainId != null &&
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
              offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!hasBoth)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Select both Captain and Vice Captain to continue',
                  style: AppTypography.labelSmall
                      .copyWith(color: AppColors.textTertiary),
                ),
              ),
            AppButton(
              text: state.isSaving ? 'SAVING...' : 'SAVE TEAM',
              variant: hasBoth
                  ? AppButtonVariant.gradient
                  : AppButtonVariant.outline,
              isDisabled: !hasBoth || state.isSaving,
              onPressed: hasBoth && !state.isSaving
                  ? () async {
                      // 1. Save team (with contestId if available)
                      final savedTeam =
                          await notifier.saveTeam(contestId: contestId);

                      if (savedTeam == null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Failed to save team. Please try again.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        return;
                      }

                      // 2. Join contest if contestId provided
                      if (contestId != null && context.mounted) {
                        final joinSuccess = await ref
                            .read(contestDetailProvider(contestId!).notifier)
                            .joinContest(savedTeam.id);

                        if (!joinSuccess && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Team saved but contest join failed. Please try joining from the contest page.'),
                              backgroundColor: Colors.orange,
                              duration: Duration(seconds: 4),
                            ),
                          );
                        } else if (joinSuccess && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  '🎉 Team saved & contest joined successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Team saved successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }

                      // 3. Pop back to match detail (pop both captain + create screens)
                      if (context.mounted) {
                        context.pop(); // captain selection
                        context.pop(); // create team
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

// ─────────────────────────────────────────────────────────────────────────────
// Reusable widgets
// ─────────────────────────────────────────────────────────────────────────────

class _MultiplierBadge extends StatelessWidget {
  final String label;
  final String multiplier;
  final Color color;

  const _MultiplierBadge(
      {required this.label, required this.multiplier, required this.color});

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
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Center(
                child: Text(multiplier,
                    style: AppTypography.labelSmall.copyWith(
                        color: color, fontWeight: FontWeight.w700)),
              ),
            ),
            AppSpacing.gapW8,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTypography.labelMedium
                        .copyWith(color: color, fontWeight: FontWeight.w600)),
                Text('$multiplier Points',
                    style: AppTypography.labelSmall
                        .copyWith(color: color.withOpacity(0.7), fontSize: 9)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable captain/VC row widget (also used by other screens).
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
            bottom: BorderSide(color: AppColors.border.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          // Avatar
          if (player.image != null && player.image!.isNotEmpty)
            CachedImage(
                imageUrl: player.image!,
                width: 36,
                height: 36,
                borderRadius: BorderRadius.circular(18))
          else
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: AppColors.secondaryLight, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  player.name.isNotEmpty ? player.name[0] : 'P',
                  style:
                      AppTypography.titleSmall.copyWith(color: Colors.white),
                ),
              ),
            ),
          AppSpacing.gapW12,
          // Name + team
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.name,
                    style: AppTypography.bodySmall
                        .copyWith(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('${player.teamName} · ${player.roleAbbreviation}',
                    style: AppTypography.labelSmall),
              ],
            ),
          ),
          // Points
          SizedBox(
            width: 50,
            child: Text('${player.points.toStringAsFixed(0)}',
                style: AppTypography.bodySmall, textAlign: TextAlign.center),
          ),
          // Captain button
          _CaptainVCButton(
            label: 'C',
            active: isCaptain,
            color: AppColors.primary,
            onTap: onCaptainTap,
          ),
          // Vice-captain button
          _CaptainVCButton(
            label: 'VC',
            active: isViceCaptain,
            color: AppColors.info,
            onTap: onViceCaptainTap,
          ),
        ],
      ),
    );
  }
}

class _CaptainVCButton extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _CaptainVCButton(
      {required this.label,
      required this.active,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: active ? color : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: active ? color : AppColors.border, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: active ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: label.length > 1 ? 9 : null,
            ),
          ),
        ),
      ),
    );
  }
}
