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
import '../widgets/live_match_card.dart';
import '../widgets/upcoming_match_card.dart';

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
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 170,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: homeState.liveMatches.length,
                            itemBuilder: (context, index) {
                              final match = homeState.liveMatches[index];
                              return LiveMatchCard(
                                match: match,
                                onTap: () => context.push(
                                  '/matches/${match.id}',
                                ),
                              );
                            },
                          ),
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
                            return UpcomingMatchCard(
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
                    // Popular Contests Section - REMOVED
                    // Featured Tournament Section - REMOVED
                    // Recent Winners Section - REMOVED
                    // Announcements Section - REMOVED
                    // Completed Matches Section
                    if (homeState.completedMatches.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: _SectionHeader(
                          title: 'Completed Matches',
                          icon: Icons.check_circle_outline,
                          iconColor: AppColors.success,
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final match = homeState.completedMatches[index];
                            return UpcomingMatchCard(
                              match: match,
                              onTap: () => context.push(
                                '/matches/${match.id}',
                              ),
                            );
                          },
                          childCount: homeState.completedMatches.length > 5
                              ? 5
                              : homeState.completedMatches.length,
                        ),
                      ),
                    ],
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
