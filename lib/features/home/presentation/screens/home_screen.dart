import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../domain/providers/home_provider.dart';
import '../widgets/hero_banner.dart';
import '../widgets/popular_contest_card.dart';
import '../widgets/unified_match_card.dart';

/// Home screen — pinned SliverAppBar so header never scrolls away on refresh.
/// Announcements & Recent Winners removed (were placeholder-only).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      // ── PINNED SLIVER APP BAR (fix: header stays fixed on refresh) ────
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(homeProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ── Pinned App Bar ──────────────────────────────────────────
            SliverAppBar(
              pinned: true,                // Always visible — never scrolls away
              floating: false,
              elevation: 0,
              backgroundColor: AppColors.surface,
              toolbarHeight: 64,
              automaticallyImplyLeading: false,
              title: _HomeAppBar(),
            ),

            // ── Hero Banner ─────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 8),
                child: HeroBanner(),
              ),
            ),

            // ── Live Matches ─────────────────────────────────────────────
            if (homeState.hasLiveMatches) ...[
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Live Matches',
                  icon: Icons.circle,
                  iconColor: AppColors.liveMatch,
                  showPulse: true,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final match = homeState.liveMatches[index];
                    return UnifiedMatchCard(
                      match: match,
                      onTap: () => context.push('/matches/${match.id}'),
                    );
                  },
                  childCount: homeState.liveMatches.length,
                ),
              ),
            ],

            // ── Upcoming Matches ─────────────────────────────────────────
            if (homeState.hasUpcomingMatches) ...[
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Upcoming Matches',
                  icon: Icons.schedule,
                  iconColor: AppColors.upcomingMatch,
                  trailing: TextButton(
                    onPressed: () => context.push(AppRoutes.matches),
                    child: Text(
                      'View All',
                      style: AppTypography.labelMedium
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final match = homeState.upcomingMatches[index];
                    return UnifiedMatchCard(
                      match: match,
                      onTap: () => context.push('/matches/${match.id}'),
                    );
                  },
                  childCount: homeState.upcomingMatches.length > 5
                      ? 5
                      : homeState.upcomingMatches.length,
                ),
              ),
            ],

            // ── Popular Contests ─────────────────────────────────────────
            if (homeState.popularContests.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Popular Contests',
                  icon: Icons.emoji_events_outlined,
                  iconColor: AppColors.warning,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 170,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: homeState.popularContests.length,
                    itemBuilder: (context, index) {
                      final contest = homeState.popularContests[index];
                      return PopularContestCard(
                        contest: contest,
                        onTap: () =>
                            context.push('/contests/${contest.id}'),
                      );
                    },
                  ),
                ),
              ),
            ],

            // ── Featured Tournament ──────────────────────────────────────
            if (homeState.tournaments.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Featured Tournament',
                  icon: Icons.star_outline,
                  iconColor: AppColors.info,
                ),
              ),
              SliverToBoxAdapter(
                child: _FeaturedTournamentCard(
                    tournament: homeState.tournaments.first),
              ),
            ],

            // ── Bottom spacing ───────────────────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pinned App Bar content
// ─────────────────────────────────────────────────────────────────────────────

class _HomeAppBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Logo
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: AppSpacing.borderRadiusSm,
          ),
          child: const Center(
            child: Icon(Icons.sports_cricket, color: Colors.white, size: 18),
          ),
        ),
        AppSpacing.gapW8,
        Text('DreamTeam', style: AppTypography.headlineMedium),
        const Spacer(),
        // Notification bell
        Consumer(builder: (_, ref, __) {
          return IconButton(
            padding: EdgeInsets.zero,
            onPressed: () => context.push(AppRoutes.notifications),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined,
                    color: AppColors.textPrimary),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final bool showPulse;
  final Widget? trailing;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.iconColor,
    this.showPulse = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          AppSpacing.gapW8,
          Text(title, style: AppTypography.titleLarge),
          if (trailing != null) ...[const Spacer(), trailing!],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Featured tournament card
// ─────────────────────────────────────────────────────────────────────────────

class _FeaturedTournamentCard extends StatelessWidget {
  final dynamic tournament;
  const _FeaturedTournamentCard({required this.tournament});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: [
          BoxShadow(
              color: AppColors.secondary.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: const Center(
              child: Icon(Icons.emoji_events, color: AppColors.warning, size: 24),
            ),
          ),
          AppSpacing.gapW16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tournament.name,
                    style: AppTypography.titleLarge
                        .copyWith(color: Colors.white)),
                AppSpacing.gapH4,
                Text(
                  tournament.description ?? 'Join the excitement!',
                  style: AppTypography.bodySmall
                      .copyWith(color: Colors.white.withOpacity(0.7)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white54),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer loading state
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          const ShimmerLoading(width: double.infinity, height: 180),
          AppSpacing.gapH24,
          const Align(
            alignment: Alignment.centerLeft,
            child: ShimmerLoading(width: 150, height: 20),
          ),
          AppSpacing.gapH12,
          for (int i = 0; i < 3; i++) ...[
            const ShimmerLoading(width: double.infinity, height: 100),
            AppSpacing.gapH12,
          ],
        ],
      ),
    );
  }
}
