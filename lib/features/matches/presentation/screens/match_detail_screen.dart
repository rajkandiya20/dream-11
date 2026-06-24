import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../contests/presentation/widgets/contest_card.dart';
import '../../../fantasy/data/models/fantasy_team_model.dart';
import '../../../fantasy/data/repositories/fantasy_repository.dart';
import '../../../fantasy/presentation/screens/team_preview_screen.dart';
import '../../data/models/player_model.dart';
import '../../data/models/player_stats_model.dart';
import '../../domain/providers/match_provider.dart';
import '../widgets/match_header.dart';
import '../widgets/my_contests_tab.dart';
import '../widgets/player_stats_tab.dart';
import '../widgets/ball_display_row.dart';
import '../widgets/scorecard_tab.dart';

/// Provider that fetches user fantasy teams for a match, keyed by (userId, matchId).
final _userTeamsProvider = FutureProvider.family<List<FantasyTeamModel>,
    ({String userId, String matchId})>((ref, params) async {
  final repository = ref.watch(fantasyRepositoryProvider);
  return repository.getUserTeamsForMatch(
    userId: params.userId,
    matchId: params.matchId,
  );
});

/// Premium match detail screen.
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
                  length: 5,  // Contests | My Contests | Scorecard | Stats | My Team
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
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
                                Tab(text: 'Contests (${state.contests.length})'),
                                const Tab(text: 'My Contests'),
                                const Tab(text: 'Scorecard'),
                                const Tab(text: 'Stats'),
                                const Tab(text: 'My Team'),
                              ],
                            ),
                          ),
                        ),
                      ];
                    },
                    body: TabBarView(
                      children: [
                        _ContestsTab(matchId: matchId, state: state),
                        // My Contests tab (FIX #13 from Fantasy- analysis)
                        MyContestsTab(matchId: matchId),
                        ScorecardTab(scoreboard: state.scoreboard),
                        // Stats tab (FIX #12 from Fantasy- analysis)
                        PlayerStatsTab(
                          playerStats: state.playerStats,
                          dreamTeamPlayerIds: _computeDreamTeamIds(state.playerStats),
                        ),
                        // My Team tab
                        _MyTeamTab(
                          matchId: matchId,
                          playerStats: state.playerStats,
                          players: state.players,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

/// Compute top-11 players by fantasy points = "Dream Team"
List<String> _computeDreamTeamIds(List<dynamic> playerStats) {
  final sorted = [...playerStats]
    ..sort((a, b) => b.fantasyPoints.compareTo(a.fantasyPoints));
  return sorted.take(11).map<String>((p) => p.playerId as String).toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// Contests Tab
// ─────────────────────────────────────────────────────────────────────────────

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
            Icon(Icons.emoji_events_outlined,
                size: 64, color: AppColors.textTertiary),
            AppSpacing.gapH16,
            Text('No contests available yet',
                style: AppTypography.bodyLarge
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.contests.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
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
                      Text('Create Your Team',
                          style: AppTypography.titleMedium
                              .copyWith(color: Colors.white)),
                      Text('Pick 11 players and join contests',
                          style: AppTypography.bodySmall
                              .copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/create-team/$matchId'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                    child: Text('CREATE',
                        style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700)),
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

// ─────────────────────────────────────────────────────────────────────────────
// FIX #1: My Team Tab — Horizontal swipeable cards like Dream11
// ─────────────────────────────────────────────────────────────────────────────

class _MyTeamTab extends ConsumerStatefulWidget {
  final String matchId;
  final List<PlayerStatsModel> playerStats;
  final List<PlayerModel> players;

  const _MyTeamTab({
    required this.matchId,
    required this.playerStats,
    required this.players,
  });

  @override
  ConsumerState<_MyTeamTab> createState() => _MyTeamTabState();
}

class _MyTeamTabState extends ConsumerState<_MyTeamTab> {
  int _selectedTeamIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userId = authState.user?.uid;

    if (userId == null || userId.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: AppColors.textTertiary),
            AppSpacing.gapH16,
            Text('Please log in to view your team',
                style: AppTypography.bodyLarge
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    final teamsAsync = ref.watch(
      _userTeamsProvider((userId: userId, matchId: widget.matchId)),
    );

    return teamsAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (_, __) => Center(
        child: Text('Failed to load teams',
            style:
                AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
      ),
      data: (teams) {
        if (teams.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_outlined,
                    size: 64, color: AppColors.textTertiary),
                AppSpacing.gapH16,
                Text('No team created yet',
                    style: AppTypography.bodyLarge
                        .copyWith(color: AppColors.textSecondary)),
                AppSpacing.gapH8,
                Text('Create a team to see live points',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textTertiary)),
                AppSpacing.gapH24,
                ElevatedButton(
                  onPressed: () =>
                      context.push('/create-team/${widget.matchId}'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  child: const Text('Create Team',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // ── Horizontal team selector tabs (Team 1 | Team 2 | ...) ──
            if (teams.length > 1)
              Container(
                color: AppColors.surface,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    children: List.generate(teams.length, (i) {
                      final isActive = _selectedTeamIndex == i;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedTeamIndex = i);
                          _pageController.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.primary.withOpacity(0.08),
                            borderRadius: AppSpacing.borderRadiusFull,
                            border: Border.all(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'Team ${i + 1}',
                            style: AppTypography.labelMedium.copyWith(
                              color: isActive
                                  ? Colors.white
                                  : AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

            // ── PageView of team cards ──
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: teams.length,
                onPageChanged: (i) =>
                    setState(() => _selectedTeamIndex = i),
                itemBuilder: (context, i) {
                  return _TeamDetailCard(
                    team: teams[i],
                    teamNumber: i + 1,
                    playerStats: widget.playerStats,
                    allMatchPlayers: widget.players,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FIX #2: Team Detail Card with View Team cricket ground button
// ─────────────────────────────────────────────────────────────────────────────

class _TeamDetailCard extends StatelessWidget {
  final FantasyTeamModel team;
  final int teamNumber;
  final List<PlayerStatsModel> playerStats;
  final List<PlayerModel> allMatchPlayers;

  const _TeamDetailCard({
    required this.team,
    required this.teamNumber,
    required this.playerStats,
    required this.allMatchPlayers,
  });

  double _getPlayerPoints(String playerId) {
    final stats =
        playerStats.where((s) => s.playerId == playerId).firstOrNull;
    return stats?.fantasyPoints ?? 0.0;
  }

  double _getMultipliedPoints(FantasyTeamPlayerModel player) {
    final base = _getPlayerPoints(player.playerId);
    if (player.isCaptain) return base * 2.0;
    if (player.isViceCaptain) return base * 1.5;
    return base;
  }

  double get _totalPoints {
    double total = 0;
    for (final p in team.players) {
      total += _getMultipliedPoints(p);
    }
    return total;
  }

  /// Build full PlayerModel list from the team's player IDs
  /// using the match's player list so image/role data is available.
  List<PlayerModel> _getFullPlayers() {
    return team.players.map<PlayerModel>((tp) {
      // Try to find the full player from match players
      final full = allMatchPlayers
          .where((p) => p.id == tp.playerId)
          .firstOrNull;
      if (full != null) return full;
      // Fallback: minimal PlayerModel from team data
      return PlayerModel(
        id: tp.playerId,
        name: tp.playerName,
        role: tp.playerRole,
        credits: 0,
        points: _getPlayerPoints(tp.playerId),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Team header card ──
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppSpacing.borderRadiusMd,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Gradient header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            team.teamName.isEmpty ||
                                    team.teamName == 'My Team'
                                ? 'Team $teamNumber'
                                : team.teamName,
                            style: AppTypography.titleMedium
                                .copyWith(color: Colors.white),
                          ),
                          Text(
                            '${team.playerCount} Players',
                            style: AppTypography.bodySmall
                                .copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _totalPoints.toStringAsFixed(1),
                            style: AppTypography.headlineSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                          Text('Total Points',
                              style: AppTypography.labelSmall
                                  .copyWith(color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                ),

                // C and VC info row
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _CaptainChip(
                          label: 'C',
                          name: team.players
                                  .where((p) => p.isCaptain)
                                  .firstOrNull
                                  ?.playerName ??
                              '—',
                          color: AppColors.primary,
                        ),
                      ),
                      AppSpacing.gapW8,
                      Expanded(
                        child: _CaptainChip(
                          label: 'VC',
                          name: team.players
                                  .where((p) => p.isViceCaptain)
                                  .firstOrNull
                                  ?.playerName ??
                              '—',
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── VIEW TEAM button ──
                Padding(
                  padding:
                      const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderRadiusMd),
                      ),
                      icon: const Icon(Icons.sports_cricket, size: 18),
                      label: const Text('VIEW TEAM',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      onPressed: () {
                        final fullPlayers = _getFullPlayers();
                        // Build points map for captain/VC multiplier display
                        final pointsMap = <String, double>{};
                        for (final p in team.players) {
                          pointsMap[p.playerId] =
                              _getPlayerPoints(p.playerId);
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TeamPreviewScreen(
                              players: fullPlayers,
                              captainId: team.captainId,
                              viceCaptainId: team.viceCaptainId,
                              playerPoints: pointsMap,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          AppSpacing.gapH16,

          // ── Player list ──
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppSpacing.borderRadiusMd,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBackground,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12)),
                    border: Border(
                        bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text('Player',
                              style: AppTypography.labelSmall.copyWith(
                                  fontWeight: FontWeight.w700))),
                      SizedBox(
                          width: 50,
                          child: Text('Role',
                              style: AppTypography.labelSmall.copyWith(
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center)),
                      SizedBox(
                          width: 60,
                          child: Text('Points',
                              style: AppTypography.labelSmall.copyWith(
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center)),
                    ],
                  ),
                ),
                ...team.players.map((player) => _PlayerRow(
                      player: player,
                      points: _getMultipliedPoints(player),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptainChip extends StatelessWidget {
  final String label;
  final String name;
  final Color color;

  const _CaptainChip(
      {required this.label, required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800)),
            ),
          ),
          AppSpacing.gapW8,
          Expanded(
            child: Text(name,
                style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final FantasyTeamPlayerModel player;
  final double points;

  const _PlayerRow({required this.player, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.4))),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                player.playerName.isNotEmpty ? player.playerName[0] : '?',
                style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          AppSpacing.gapW8,
          // Name + C/VC badge
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    player.playerName,
                    style: AppTypography.bodySmall
                        .copyWith(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (player.isCaptain) ...[
                  AppSpacing.gapW4,
                  _Badge(label: 'C', color: AppColors.primary),
                ],
                if (player.isViceCaptain) ...[
                  AppSpacing.gapW4,
                  _Badge(label: 'VC', color: AppColors.info),
                ],
              ],
            ),
          ),
          // Role
          SizedBox(
            width: 50,
            child: Text(
              _roleShort(player.playerRole),
              style: AppTypography.labelSmall
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          // Points + multiplier
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  points.toStringAsFixed(1),
                  style: AppTypography.titleSmall.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
                if (player.isCaptain || player.isViceCaptain)
                  Text(
                    player.isCaptain ? '2x' : '1.5x',
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.textTertiary, fontSize: 9),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _roleShort(String role) {
    switch (role) {
      case 'WK':
        return 'WK';
      case 'Batsman':
        return 'BAT';
      case 'All-rounder':
        return 'AR';
      case 'Bowler':
        return 'BOWL';
      default:
        return role.isNotEmpty ? role.substring(0, 2).toUpperCase() : '—';
    }
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w800)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab bar delegate
// ─────────────────────────────────────────────────────────────────────────────

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
    return Container(color: AppColors.surface, child: tabBar);
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading / Error states
// ─────────────────────────────────────────────────────────────────────────────

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
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            AppSpacing.gapH16,
            Text('Failed to load match', style: AppTypography.headlineSmall),
            AppSpacing.gapH24,
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
