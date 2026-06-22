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

/// Premium home screen with hero banner, live matches, upcoming matches,
/// popular contests, and more sections.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.read(homeProvider.notifier).refresh(),
          child: homeState.isLoading && homeState.liveMatches.isEmpty
              ? const _LoadingState()
              : CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // App Bar
                    SliverToBoxAdapter(
                      child: _buildAppBar(context),
                    ),
                    // Hero Banner
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: HeroBanner(),
                      ),
                    ),
                    // Live Matches Section
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
                              onTap: () => context.push(
                                '/matches/${match.id}',
                              ),
                            );
                          },
                          childCount: homeState.liveMatches.length,
                        ),
                      ),
                    ],
                    // Upcoming Matches Section
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
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.primary,
                              ),
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
                              onTap: () => context.push(
                                '/matches/${match.id}',
                              ),
                            );
                          },
                          childCount: homeState.upcomingMatches.length > 5
                              ? 5
                              : homeState.upcomingMatches.length,
                        ),
                      ),
                    ],
                    // Popular Contests Section
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: homeState.popularContests.length,
                            itemBuilder: (context, index) {
                              final contest = homeState.popularContests[index];
                              return PopularContestCard(
                                contest: contest,
                                onTap: () => context.push(
                                  '/contests/${contest.id}',
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                    // Featured Tournament Section
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
                          tournament: homeState.tournaments.first,
                        ),
                      ),
                    ],
                    // Recent Winners Section
                    SliverToBoxAdapter(
                      child: _SectionHeader(
                        title: 'Recent Winners',
                        icon: Icons.workspace_premium,
                        iconColor: AppColors.warning,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _RecentWinnersSection(),
                    ),
                    // Announcements Section
                    SliverToBoxAdapter(
                      child: _SectionHeader(
                        title: 'Announcements',
                        icon: Icons.campaign_outlined,
                        iconColor: AppColors.info,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _AnnouncementsSection(),
                    ),
                    // Bottom spacing
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          // Logo / App name
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: const Center(
                  child: Icon(
                    Icons.sports_cricket,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              AppSpacing.gapW12,
              Text(
                'DreamTeam',
                style: AppTypography.headlineMedium,
              ),
            ],
          ),
          const Spacer(),
          // Notification bell
          IconButton(
            onPressed: () => context.push(AppRoutes.notifications),
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                ),
                Positioned(
                  right: 0,
                  top: 0,
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
          ),
        ],
      ),
    );
  }
}

/// Section header with title, icon, and optional trailing widget.
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
          Text(
            title,
            style: AppTypography.titleLarge,
          ),
          if (trailing != null) ...[
            const Spacer(),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Featured tournament card.
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
            offset: const Offset(0, 4),
          ),
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
              child: Icon(
                Icons.emoji_events,
                color: AppColors.warning,
                size: 24,
              ),
            ),
          ),
          AppSpacing.gapW16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tournament.name,
                  style: AppTypography.titleLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
                AppSpacing.gapH4,
                Text(
                  tournament.description ?? 'Join the excitement!',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}

/// Recent winners section placeholder.
class _RecentWinnersSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: AppColors.warning,
              size: 20,
            ),
          ),
          AppSpacing.gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Winners will appear here',
                  style: AppTypography.titleSmall,
                ),
                AppSpacing.gapH4,
                Text(
                  'Join contests to see recent winners',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Announcements section.
class _AnnouncementsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.05),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.info.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.info,
            size: 20,
          ),
          AppSpacing.gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to DreamTeam Fantasy!',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.info,
                  ),
                ),
                AppSpacing.gapH4,
                Text(
                  'Create your dream team and compete with others. Good luck!',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.infoDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading state with shimmer placeholders.
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          // Banner shimmer
          const ShimmerLoading(width: double.infinity, height: 180),
          AppSpacing.gapH24,
          // Section title shimmer
          const Align(
            alignment: Alignment.centerLeft,
            child: ShimmerLoading(width: 150, height: 20),
          ),
          AppSpacing.gapH12,
          // Cards shimmer
          for (int i = 0; i < 3; i++) ...[
            const ShimmerLoading(width: double.infinity, height: 100),
            AppSpacing.gapH12,
          ],
        ],
      ),
    );
  }
}
