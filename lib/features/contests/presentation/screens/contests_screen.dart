import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../home/domain/providers/home_provider.dart';
import '../widgets/contest_card.dart';

/// Contests tab screen showing all available contests.
class ContestsScreen extends ConsumerWidget {
  const ContestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final contests = homeState.popularContests;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'My Contests',
                style: AppTypography.headlineMedium,
              ),
            ),
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _FilterChip(label: 'All', isSelected: true),
                  _FilterChip(label: 'Upcoming'),
                  _FilterChip(label: 'Live'),
                  _FilterChip(label: 'Completed'),
                ],
              ),
            ),
            AppSpacing.gapH16,
            // Contest list
            Expanded(
              child: homeState.isLoading && contests.isEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 5,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ShimmerLoading(
                            width: double.infinity, height: 120),
                      ),
                    )
                  : contests.isEmpty
                      ? Center(
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
                                'No contests joined yet',
                                style: AppTypography.bodyLarge.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              AppSpacing.gapH8,
                              Text(
                                'Join contests from match pages',
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: contests.length,
                          itemBuilder: (context, index) {
                            final contest = contests[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ContestCard(
                                contest: contest,
                                onTap: () => context.push(
                                  '/contests/${contest.id}',
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.card,
        borderRadius: AppSpacing.borderRadiusFull,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}
