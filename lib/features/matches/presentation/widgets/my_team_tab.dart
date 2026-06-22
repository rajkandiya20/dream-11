import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../fantasy/data/models/fantasy_team_model.dart';
import '../../../fantasy/data/repositories/fantasy_repository.dart';
import '../../domain/providers/match_provider.dart';

/// My Team tab showing user's fantasy teams for the current match.
class MyTeamTab extends ConsumerWidget {
  final String matchId;

  const MyTeamTab({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final matchState = ref.watch(matchDetailProvider(matchId));
    final isMatchEditable = matchState.match != null &&
        !matchState.match!.isLive &&
        !matchState.match!.isCompleted;

    if (user == null) {
      return const Center(
        child: Text('Please log in to view your teams'),
      );
    }

    final teamsAsync = ref.watch(userTeamsForMatchProvider(
      (matchId: matchId, userId: user.uid),
    ));

    return teamsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            AppSpacing.gapH12,
            Text(
              'Failed to load teams',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      data: (teams) {
        debugPrint('[MyTeamTab] Fetched ${teams.length} teams for match $matchId');

        if (teams.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sports_cricket_outlined,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                AppSpacing.gapH16,
                Text(
                  'No Team Created Yet',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                AppSpacing.gapH8,
                Text(
                  'Create your fantasy team to join contests',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                if (isMatchEditable) ...[
                  AppSpacing.gapH24,
                  ElevatedButton.icon(
                    onPressed: () => context.push('/create-team/$matchId'),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Team'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: teams.length + (isMatchEditable ? 1 : 0),
          itemBuilder: (context, index) {
            if (isMatchEditable && index == teams.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/create-team/$matchId'),
                  icon: const Icon(Icons.add),
                  label: const Text('Edit Team'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                  ),
                ),
              );
            }

            final team = teams[index];
            return _FantasyTeamCard(team: team);
          },
        );
      },
    );
  }
}

/// Card displaying a single fantasy team's details.
class _FantasyTeamCard extends StatelessWidget {
  final FantasyTeamModel team;

  const _FantasyTeamCard({required this.team});

  @override
  Widget build(BuildContext context) {
    // Find captain and vice captain names from players
    String captainName = 'Not set';
    String viceCaptainName = 'Not set';

    for (final player in team.players) {
      if (player.isCaptain) {
        captainName = player.playerName.isNotEmpty
            ? player.playerName
            : 'Player ${player.playerId.substring(0, 6)}';
      }
      if (player.isViceCaptain) {
        viceCaptainName = player.playerName.isNotEmpty
            ? player.playerName
            : 'Player ${player.playerId.substring(0, 6)}';
      }
    }

    debugPrint('[MyTeamTab] Rendering team: ${team.teamName}, C: $captainName, VC: $viceCaptainName');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team name and points
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                team.teamName,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Text(
                  '${team.totalPoints.toStringAsFixed(1)} pts',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapH12,
          // Captain and Vice Captain
          Row(
            children: [
              _RoleBadge(
                label: 'C',
                playerName: captainName,
                color: AppColors.primary,
              ),
              AppSpacing.gapW16,
              _RoleBadge(
                label: 'VC',
                playerName: viceCaptainName,
                color: AppColors.info,
              ),
            ],
          ),
          AppSpacing.gapH12,
          // Player count and created time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${team.playerCount} Players',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (team.createdAt != null)
                Text(
                  _formatTime(team.createdAt!),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

/// Badge showing captain/VC role with player name.
class _RoleBadge extends StatelessWidget {
  final String label;
  final String playerName;
  final Color color;

  const _RoleBadge({
    required this.label,
    required this.playerName,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 9,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          playerName,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
