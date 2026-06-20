import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../data/models/fantasy_team_model.dart';
import '../../data/repositories/fantasy_repository.dart';
import 'team_preview_screen.dart';

/// Fantasy team detail screen showing team info and player list.
class FantasyTeamScreen extends ConsumerWidget {
  final String teamId;

  const FantasyTeamScreen({super.key, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(fantasyRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('My Team', style: AppTypography.titleLarge),
        centerTitle: true,
      ),
      body: FutureBuilder<FantasyTeamModel?>(
        future: repository.getFantasyTeamById(teamId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                children: [
                  const ShimmerLoading(width: double.infinity, height: 100),
                  AppSpacing.gapH16,
                  for (int i = 0; i < 5; i++) ...[
                    const ShimmerLoading(width: double.infinity, height: 60),
                    AppSpacing.gapH8,
                  ],
                ],
              ),
            );
          }

          final team = snapshot.data;
          if (team == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  AppSpacing.gapH16,
                  Text(
                    'Team not found',
                    style: AppTypography.headlineSmall,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Team info card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: AppSpacing.borderRadiusLg,
                  ),
                  child: Column(
                    children: [
                      Text(
                        team.teamName,
                        style: AppTypography.headlineMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      AppSpacing.gapH8,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _Stat(
                              label: 'Players', value: '${team.playerCount}'),
                          _Stat(
                            label: 'Points',
                            value: team.totalPoints.toStringAsFixed(1),
                          ),
                          if (team.rank != null)
                            _Stat(label: 'Rank', value: '#${team.rank}'),
                        ],
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapH24,
                // Players header
                Text('Players', style: AppTypography.titleLarge),
                AppSpacing.gapH12,
                // Player list
                ...team.players.map((p) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: AppSpacing.borderRadiusSm,
                        border: p.isCaptain || p.isViceCaptain
                            ? Border.all(
                                color: p.isCaptain
                                    ? AppColors.primary
                                    : AppColors.info,
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          // Role badge
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                p.player?.roleAbbreviation ?? '',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ),
                          AppSpacing.gapW12,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.playerName,
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  p.player?.teamName ?? '',
                                  style: AppTypography.labelSmall,
                                ),
                              ],
                            ),
                          ),
                          if (p.isCaptain)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: AppSpacing.borderRadiusFull,
                              ),
                              child: Text(
                                'C',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          else if (p.isViceCaptain)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.info,
                                borderRadius: AppSpacing.borderRadiusFull,
                              ),
                              child: Text(
                                'VC',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          AppSpacing.gapW8,
                          Text(
                            '${p.points.toStringAsFixed(1)} pts',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleLarge.copyWith(color: Colors.white),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
