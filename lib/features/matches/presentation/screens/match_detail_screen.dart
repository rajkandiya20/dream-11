import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/supabase_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../contests/data/repositories/contest_repository.dart';
import '../../../contests/presentation/widgets/contest_card.dart';
import '../../data/models/contest_model.dart';
import '../../domain/providers/match_provider.dart';
import '../widgets/match_header.dart';
import '../widgets/my_team_tab.dart';
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

/// Contests tab content with All/My toggle.
class _ContestsTab extends ConsumerStatefulWidget {
  final String matchId;
  final MatchDetailState state;

  const _ContestsTab({required this.matchId, required this.state});

  @override
  ConsumerState<_ContestsTab> createState() => _ContestsTabState();
}

class _ContestsTabState extends ConsumerState<_ContestsTab> {
  bool _showMyContests = false;
  Set<String> _joinedContestIds = {};
  Map<String, LeaderboardEntry> _myLeaderboardEntries = {};
  bool _loadingJoined = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJoinedContests();
    });
  }

  Future<void> _loadJoinedContests() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    setState(() => _loadingJoined = true);

    final client = ref.read(supabaseClientProvider);
    final contestRepo = ContestRepository(client);

    final Set<String> joined = {};
    final Map<String, LeaderboardEntry> entries = {};

    for (final contest in widget.state.contests) {
      final hasJoined = await contestRepo.hasUserJoinedContest(
        contestId: contest.id,
        userId: user.uid,
      );
      if (hasJoined) {
        joined.add(contest.id);
        // Fetch leaderboard to get user's rank and points
        final leaderboard = await contestRepo.getLeaderboard(contest.id);
        final myEntry = leaderboard.where((e) => e.userId == user.uid).firstOrNull;
        if (myEntry != null) {
          entries[contest.id] = myEntry;
        }
      }
    }

    if (mounted) {
      setState(() {
        _joinedContestIds = joined;
        _myLeaderboardEntries = entries;
        _loadingJoined = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final contests = _showMyContests
        ? widget.state.contests
            .where((c) => _joinedContestIds.contains(c.id))
            .toList()
        : widget.state.contests;

    return Column(
      children: [
        // All/My toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _ToggleButton(
                label: 'All Contests',
                isSelected: !_showMyContests,
                onTap: () => setState(() => _showMyContests = false),
              ),
              AppSpacing.gapW8,
              _ToggleButton(
                label: 'My Contests',
                isSelected: _showMyContests,
                onTap: () => setState(() => _showMyContests = true),
                badge: _joinedContestIds.isNotEmpty
                    ? _joinedContestIds.length.toString()
                    : null,
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: _buildContestsList(context, contests),
        ),
      ],
    );
  }

  Widget _buildContestsList(BuildContext context, List<ContestModel> contests) {
    if (_loadingJoined && _showMyContests) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (contests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _showMyContests
                  ? Icons.emoji_events_outlined
                  : Icons.emoji_events_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            AppSpacing.gapH16,
            Text(
              _showMyContests
                  ? 'No contests joined yet'
                  : 'No contests available yet',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (_showMyContests) ...[
              AppSpacing.gapH8,
              Text(
                'Join a contest to see it here',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: contests.length + (_showMyContests ? 0 : 1),
      itemBuilder: (context, index) {
        if (!_showMyContests && index == 0) {
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
                  onTap: () => context.push('/create-team/${widget.matchId}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
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

        final contestIndex = _showMyContests ? index : index - 1;
        final contest = contests[contestIndex];
        final isJoined = _joinedContestIds.contains(contest.id);
        final myEntry = _myLeaderboardEntries[contest.id];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              ContestCard(
                contest: contest,
                onTap: () => context.push('/contests/${contest.id}'),
              ),
              // Show rank and points for joined contests
              if (isJoined && myEntry != null)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.08),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 14, color: AppColors.success),
                      const SizedBox(width: 6),
                      Text(
                        'Joined',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (myEntry.rank > 0) ...[
                        Icon(Icons.leaderboard,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Rank #${myEntry.rank}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Icon(Icons.star,
                          size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${myEntry.points.toStringAsFixed(1)} pts',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Toggle button for All/My Contests.
class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: AppSpacing.borderRadiusFull,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Text(
                  badge!,
                  style: AppTypography.labelSmall.copyWith(
                    color: isSelected ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ],
        ),
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
