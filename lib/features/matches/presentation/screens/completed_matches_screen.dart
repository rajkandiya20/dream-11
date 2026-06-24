import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../home/data/models/match_model.dart';
import '../../../home/domain/providers/home_provider.dart';

/// Completed (My) Matches screen — shows all past matches where the user
/// created teams or joined contests, with winnings per match.
///
/// Ported from Fantasy- /completed/:id
class CompletedMatchesScreen extends ConsumerWidget {
  const CompletedMatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState  = ref.watch(homeProvider);
    final authState  = ref.watch(authProvider);
    final completed  = homeState.completedMatches;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('My Matches', style: AppTypography.titleLarge.copyWith(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: homeState.isLoading && completed.isEmpty
          ? _buildLoading()
          : completed.isEmpty
              ? _buildEmpty(context)
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => ref.read(homeProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: completed.length,
                    itemBuilder: (context, i) =>
                        _CompletedMatchCard(match: completed[i]),
                  ),
                ),
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: ShimmerLoading(width: double.infinity, height: 120),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_cricket, size: 72, color: AppColors.textTertiary),
          AppSpacing.gapH16,
          Text('No completed matches yet',
              style: AppTypography.headlineSmall
                  .copyWith(color: AppColors.textSecondary)),
          AppSpacing.gapH8,
          Text('Join contests to see your match history here',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center),
          AppSpacing.gapH24,
          ElevatedButton(
            onPressed: () => context.go('/matches'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14)),
            child: const Text('View Upcoming Matches'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Match card
// ─────────────────────────────────────────────────────────────────────────────

class _CompletedMatchCard extends StatelessWidget {
  final MatchModel match;
  const _CompletedMatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/matches/${match.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppSpacing.borderRadiusMd,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            // Header — tournament name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.04),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12)),
                border: Border(
                    bottom: BorderSide(color: AppColors.border, width: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(match.tournamentName,
                      style: AppTypography.labelMedium
                          .copyWith(color: AppColors.textSecondary)),
                  // Completed badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: AppSpacing.borderRadiusFull,
                      border: Border.all(
                          color: AppColors.success.withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('Completed',
                          style: AppTypography.labelSmall
                              .copyWith(color: AppColors.success, fontSize: 10)),
                    ]),
                  ),
                ],
              ),
            ),

            // Teams row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Team A
                  _TeamBlock(
                    name: match.teamAName,
                    code: match.teamACode,
                    flag: match.teamAFlag,
                    score: match.teamAScore,
                    alignRight: false,
                  ),
                  // Center
                  Expanded(
                    child: Column(
                      children: [
                        Text('VS',
                            style: AppTypography.titleMedium.copyWith(
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w700)),
                        if (match.result != null && match.result!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(match.result!,
                                style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.success, fontSize: 9),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          ),
                      ],
                    ),
                  ),
                  // Team B
                  _TeamBlock(
                    name: match.teamBName,
                    code: match.teamBCode,
                    flag: match.teamBFlag,
                    score: match.teamBScore,
                    alignRight: true,
                  ),
                ],
              ),
            ),

            // Bottom bar — teams/contests joined + winnings
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Icon(Icons.people_outline,
                      size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text('Teams joined',
                      style: AppTypography.labelSmall
                          .copyWith(color: AppColors.textTertiary)),
                  const Spacer(),
                  Icon(Icons.emoji_events_outlined,
                      size: 14, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text('View Results',
                      style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right,
                      size: 14, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamBlock extends StatelessWidget {
  final String name;
  final String? code;
  final String? flag;
  final String? score;
  final bool alignRight;

  const _TeamBlock({
    required this.name,
    this.code,
    this.flag,
    this.score,
    required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    final children = [
      // Flag / avatar
      flag != null && flag!.isNotEmpty
          ? CachedImage(
              imageUrl: flag!,
              width: 40,
              height: 40,
              borderRadius: BorderRadius.circular(20))
          : Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: AppColors.secondaryLight, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  (code?.isNotEmpty == true ? code! : name)[0],
                  style: AppTypography.titleSmall
                      .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
      const SizedBox(height: 6),
      Text(code?.isNotEmpty == true ? code! : name,
          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600)),
      if (score != null && score!.isNotEmpty)
        Text(score!,
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textSecondary)),
    ];

    return SizedBox(
      width: 90,
      child: Column(
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
