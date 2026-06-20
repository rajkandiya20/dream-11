import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../domain/providers/contest_provider.dart';
import '../widgets/prize_breakdown.dart';

/// Contest detail screen showing prize breakdown, leaderboard, and join options.
class ContestDetailScreen extends ConsumerWidget {
  final String contestId;

  const ContestDetailScreen({super.key, required this.contestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(contestDetailProvider(contestId));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          state.contest?.name ?? 'Contest',
          style: AppTypography.titleLarge,
        ),
        centerTitle: true,
      ),
      body: state.isLoading && state.contest == null
          ? _buildLoading()
          : state.contest == null
              ? _buildError(context, ref)
              : _buildContent(context, ref, state),
      bottomNavigationBar: state.contest != null && !state.hasJoined
          ? _buildBottomBar(context, state)
          : null,
    );
  }

  Widget _buildLoading() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          const ShimmerLoading(width: double.infinity, height: 120),
          AppSpacing.gapH16,
          const ShimmerLoading(width: double.infinity, height: 200),
          AppSpacing.gapH16,
          const ShimmerLoading(width: double.infinity, height: 300),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          AppSpacing.gapH16,
          Text(
            'Failed to load contest',
            style: AppTypography.headlineSmall,
          ),
          AppSpacing.gapH24,
          ElevatedButton(
            onPressed: () => ref
                .read(contestDetailProvider(contestId).notifier)
                .refresh(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, ContestDetailState state) {
    final contest = state.contest!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contest info card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.secondaryGradient,
              borderRadius: AppSpacing.borderRadiusLg,
            ),
            child: Column(
              children: [
                // Prize pool
                Text(
                  'Prize Pool',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
                AppSpacing.gapH4,
                Text(
                  '\u20B9${contest.formattedPrizePool}',
                  style: AppTypography.displayMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.gapH20,
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ContestStat(
                      label: 'Entry',
                      value: contest.formattedEntryFee,
                      icon: Icons.confirmation_number_outlined,
                    ),
                    _ContestStat(
                      label: 'Spots',
                      value: '${contest.maxTeams}',
                      icon: Icons.people_outline,
                    ),
                    _ContestStat(
                      label: 'Filled',
                      value: '${(contest.fillPercentage * 100).toInt()}%',
                      icon: Icons.pie_chart_outline,
                    ),
                  ],
                ),
                AppSpacing.gapH16,
                // Progress bar
                ClipRRect(
                  borderRadius: AppSpacing.borderRadiusFull,
                  child: LinearProgressIndicator(
                    value: contest.fillPercentage,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.success,
                    ),
                    minHeight: 6,
                  ),
                ),
                AppSpacing.gapH8,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${contest.spotsLeft} spots left',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '${contest.joinedTeams} joined',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Joined badge
          if (state.hasJoined)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: AppSpacing.borderRadiusSm,
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  AppSpacing.gapW8,
                  Text(
                    'You have joined this contest',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          AppSpacing.gapH24,
          // Prize Breakdown
          PrizeBreakdown(contest: contest),
          AppSpacing.gapH24,
          // Leaderboard
          if (state.leaderboard.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.leaderboard, size: 18, color: AppColors.info),
                  AppSpacing.gapW8,
                  Text('Leaderboard', style: AppTypography.titleLarge),
                ],
              ),
            ),
            AppSpacing.gapH12,
            ...state.leaderboard.take(20).map(
                  (entry) => _LeaderboardRow(entry: entry),
                ),
          ],
          AppSpacing.gapH32,
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, ContestDetailState state) {
    final contest = state.contest!;

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
        child: Row(
          children: [
            // Entry fee info
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entry Fee',
                  style: AppTypography.labelSmall,
                ),
                Text(
                  contest.formattedEntryFee,
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            AppSpacing.gapW16,
            // Join button
            Expanded(
              child: AppButton(
                text: contest.isFull ? 'FULL' : 'JOIN CONTEST',
                variant: AppButtonVariant.gradient,
                isDisabled: contest.isFull,
                onPressed: contest.isFull
                    ? null
                    : () {
                        // Navigate to team selection or create team
                        context.push('/create-team/${contest.matchId}');
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContestStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ContestStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.white54),
        AppSpacing.gapH4,
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final dynamic entry;

  const _LeaderboardRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppSpacing.borderRadiusSm,
        border: entry.rank <= 3
            ? Border.all(
                color: entry.rank == 1
                    ? const Color(0xFFFFD700)
                    : entry.rank == 2
                        ? const Color(0xFFC0C0C0)
                        : const Color(0xFFCD7F32),
                width: 1,
              )
            : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 32,
            child: Text(
              '#${entry.rank}',
              style: AppTypography.titleSmall.copyWith(
                color: entry.rank <= 3 ? AppColors.warning : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppSpacing.gapW12,
          // Avatar
          if (entry.avatarUrl != null)
            CachedImage(
              imageUrl: entry.avatarUrl!,
              width: 32,
              height: 32,
              borderRadius: BorderRadius.circular(16),
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
                  entry.username[0].toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          AppSpacing.gapW12,
          // Username
          Expanded(
            child: Text(
              entry.username,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Points
          Text(
            '${entry.points.toStringAsFixed(1)} pts',
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
