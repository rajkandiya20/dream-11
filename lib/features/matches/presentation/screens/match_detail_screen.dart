import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../contests/presentation/widgets/contest_card.dart';
import '../../domain/providers/match_provider.dart';
import '../widgets/my_team_tab.dart';
import '../widgets/match_header.dart';
import '../widgets/scorecard_tab.dart';

/// Premium match detail screen with header, tabs for contests/scorecard/my team.
class MatchDetailScreen extends ConsumerWidget {
  final String matchId;

  const MatchDetailScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchDetailProvider(matchId));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: state.isLoading && state.match == null
          ? const _LoadingState()
          : state.match == null
              ? _ErrorState(
                  onRetry: () =>
                      ref.read(matchDetailProvider(matchId).notifier).refresh(),
                )
              : DefaultTabController(
                  length: 3,
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        // Custom App Bar with match header
                        SliverAppBar(
                          expandedHeight: 220,
                          pinned: true,
                          backgroundColor: AppColors.secondary,
                          leading: IconButton(
                            icon: const Icon(Icons.arrow_back_ios,
                                color: Colors.white),
                            onPressed: () => context.pop(),
                          ),
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.share_outlined,
                                  color: Colors.white),
                              onPressed: () {},
                            ),
                          ],
                          flexibleSpace: FlexibleSpaceBar(
                            background: MatchHeader(match: state.match!),
                          ),
                        ),
                        // Tab bar
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _TabBarDelegate(
                            TabBar(
                              labelColor: AppColors.primary,
                              unselectedLabelColor: AppColors.textSecondary,
                              labelStyle: AppTypography.labelLarge,
                              unselectedLabelStyle: AppTypography.labelMedium,
                              indicatorColor: AppColors.primary,
                              indicatorWeight: 3,
                              tabs: [
                                Tab(
                                  text:
                                      'Contests (${state.contests.length})',
                                ),
                                const Tab(text: 'Scorecard'),
                                const Tab(text: 'My Team'),
                              ],
                            ),
                          ),
                        ),
                      ];
                    },
                    body: TabBarView(
                      children: [
                        // Contests Tab
                        _ContestsTab(
                          matchId: matchId,
                          state: state,
                        ),
                        // Scorecard Tab
                        ScorecardTab(scoreboard: state.scoreboard),
                        // My Team Tab
                        MyTeamTab(matchId: matchId),
                      ],
                    ),
                  ),
                ),
    );
  }
}

/// Contests tab content.
class _ContestsTab extends StatelessWidget {
  final String matchId;
  final MatchDetailState state;

  const _ContestsTab({required this.matchId, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.contests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            AppSpacing.gapH16,
            Text(
              'No contests available yet',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.contests.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // Create Team CTA
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Row(
              children: [
                const Icon(Icons.group_add, color: Colors.white),
                AppSpacing.gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Your Team',
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Pick 11 players and join contests',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/create-team/$matchId'),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                    child: Text(
                      'CREATE',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final contest = state.contests[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ContestCard(
            contest: contest,
            onTap: () => context.push('/contests/${contest.id}'),
          ),
        );
      },
    );
  }
}

/// Tab bar delegate for persistent header.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}

/// Loading state for match detail.
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const ShimmerLoading(width: double.infinity, height: 220),
          AppSpacing.gapH16,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (int i = 0; i < 4; i++) ...[
                  const ShimmerLoading(width: double.infinity, height: 80),
                  AppSpacing.gapH12,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state with retry.
class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            AppSpacing.gapH16,
            Text(
              'Failed to load match',
              style: AppTypography.headlineSmall,
            ),
            AppSpacing.gapH8,
            Text(
              'Please try again',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.gapH24,
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
