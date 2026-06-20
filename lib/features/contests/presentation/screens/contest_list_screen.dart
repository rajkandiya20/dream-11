import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../domain/providers/contest_provider.dart';
import '../widgets/contest_card.dart';

/// Contest list screen for a specific match with filters.
class ContestListScreen extends ConsumerStatefulWidget {
  final String matchId;

  const ContestListScreen({super.key, required this.matchId});

  @override
  ConsumerState<ContestListScreen> createState() => _ContestListScreenState();
}

class _ContestListScreenState extends ConsumerState<ContestListScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contestListProvider(widget.matchId));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Contests', style: AppTypography.titleLarge),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All'),
                  _buildFilterChip('paid', 'Paid'),
                  _buildFilterChip('free', 'Free'),
                ],
              ),
            ),
          ),
          // Contest list
          Expanded(
            child: state.isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 5,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child:
                          ShimmerLoading(width: double.infinity, height: 120),
                    ),
                  )
                : state.filteredContests.isEmpty
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
                              'No contests available',
                              style: AppTypography.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref
                            .read(contestListProvider(widget.matchId).notifier)
                            .refresh(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.filteredContests.length,
                          itemBuilder: (context, index) {
                            final contest = state.filteredContests[index];
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
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = value);
        ref
            .read(contestListProvider(widget.matchId).notifier)
            .setFilter(value == 'all' ? null : value);
      },
      child: Container(
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
      ),
    );
  }
}
