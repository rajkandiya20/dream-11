import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../home/domain/providers/home_provider.dart';
import '../../../home/presentation/widgets/live_match_card.dart';
import '../../../home/presentation/widgets/upcoming_match_card.dart';

/// Matches tab screen showing live, upcoming, and completed matches.
class MatchesScreen extends ConsumerWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'Matches',
                      style: AppTypography.headlineMedium,
                    ),
                  ],
                ),
              ),
              // Tab bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.border.withOpacity(0.3),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: AppTypography.labelLarge,
                  unselectedLabelStyle: AppTypography.labelMedium,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Live'),
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Completed'),
                  ],
                ),
              ),
              AppSpacing.gapH16,
              // Tab views
              Expanded(
                child: TabBarView(
                  children: [
                    // Live tab
                    _MatchList(
                      matches: homeState.liveMatches,
                      isLoading: homeState.isLoading,
                      emptyMessage: 'No live matches right now',
                      emptyIcon: Icons.live_tv_outlined,
                    ),
                    // Upcoming tab
                    _MatchList(
                      matches: homeState.upcomingMatches,
                      isLoading: homeState.isLoading,
                      emptyMessage: 'No upcoming matches',
                      emptyIcon: Icons.schedule,
                    ),
                    // Completed tab
                    _MatchList(
                      matches: homeState.completedMatches,
                      isLoading: homeState.isLoading,
                      emptyMessage: 'No completed matches',
                      emptyIcon: Icons.check_circle_outline,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchList extends StatelessWidget {
  final List<dynamic> matches;
  final bool isLoading;
  final String emptyMessage;
  final IconData emptyIcon;

  const _MatchList({
    required this.matches,
    required this.isLoading,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && matches.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShimmerLoading(width: double.infinity, height: 100),
        ),
      );
    }

    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 64,
              color: AppColors.textTertiary,
            ),
            AppSpacing.gapH16,
            Text(
              emptyMessage,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return UpcomingMatchCard(
          match: match,
          onTap: () => context.push('/matches/${match.id}'),
        );
      },
    );
  }
}
