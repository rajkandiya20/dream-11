import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../contests/presentation/widgets/contest_card.dart';
import '../../../fantasy/data/models/fantasy_team_model.dart';
import '../../../fantasy/data/repositories/fantasy_repository.dart';
import '../../data/models/player_stats_model.dart';
import '../../domain/providers/match_provider.dart';
import '../widgets/match_header.dart';
import '../widgets/scorecard_tab.dart';

/// Premium match detail screen with header, tabs for contests/scorecard/commentary.
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
                        ScorecardTab(
                          scoreboard: state.scoreboard,
                          ballByBall: state.ballByBall,
                        ),
                        // My Team Tab
                        _MyTeamTab(
                          matchId: matchId,
                          playerStats: state.playerStats,
                        ),
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

/// My Team tab showing user's fantasy team with live points.
class _MyTeamTab extends ConsumerWidget {
  final String matchId;
  final List<PlayerStatsModel> playerStats;

  const _MyTeamTab({required this.matchId, required this.playerStats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fantasyRepository = ref.watch(fantasyRepositoryProvider);

    return FutureBuilder<List<FantasyTeamModel>>(
      future: fantasyRepository.getUserTeamsForMatch(
        userId: '', // Will use authenticated user
        matchId: matchId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final teams = snapshot.data ?? [];

        if (teams.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_outlined,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                AppSpacing.gapH16,
                Text(
                  'No team created yet',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                AppSpacing.gapH8,
                Text(
                  'Create a team to see live points',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                AppSpacing.gapH24,
                ElevatedButton(
                  onPressed: () => context.push('/create-team/$matchId'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Create Team'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final team = teams[index];
            return _TeamCard(
              team: team,
              playerStats: playerStats,
            );
          },
        );
      },
    );
  }
}

/// Card showing a single fantasy team with live points.
class _TeamCard extends StatelessWidget {
  final FantasyTeamModel team;
  final List<PlayerStatsModel> playerStats;

  const _TeamCard({required this.team, required this.playerStats});

  double _getPlayerPoints(String playerId) {
    final stats = playerStats.where((s) => s.playerId == playerId).firstOrNull;
    return stats?.fantasyPoints ?? 0.0;
  }

  double _getMultipliedPoints(FantasyTeamPlayerModel player) {
    final basePoints = _getPlayerPoints(player.playerId);
    if (player.isCaptain) return basePoints * 2.0;
    if (player.isViceCaptain) return basePoints * 1.5;
    return basePoints;
  }

  double get _totalTeamPoints {
    double total = 0.0;
    for (final player in team.players) {
      total += _getMultipliedPoints(player);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team header with name and total points
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.teamName,
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${team.playerCount} Players',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _totalTeamPoints.toStringAsFixed(1),
                      style: AppTypography.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Total Points',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Player list
          ...team.players.map((player) => _PlayerRow(
                player: player,
                points: _getMultipliedPoints(player),
                basePoints: _getPlayerPoints(player.playerId),
              )),
          AppSpacing.gapH8,
        ],
      ),
    );
  }
}

/// Row showing a single player with live points.
class _PlayerRow extends StatelessWidget {
  final FantasyTeamPlayerModel player;
  final double points;
  final double basePoints;

  const _PlayerRow({
    required this.player,
    required this.points,
    required this.basePoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          // Player avatar placeholder
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                player.playerName.isNotEmpty ? player.playerName[0] : '',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          AppSpacing.gapW12,
          // Player name and role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        player.playerName,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (player.isCaptain) ...[
                      AppSpacing.gapW4,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'C',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    if (player.isViceCaptain) ...[
                      AppSpacing.gapW4,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'VC',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  player.playerRole,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          // Multiplier info
          if (player.isCaptain || player.isViceCaptain)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: Text(
                player.isCaptain ? '2x' : '1.5x',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ),
          // Points
          Text(
            points.toStringAsFixed(1),
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
