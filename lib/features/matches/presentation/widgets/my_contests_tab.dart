import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../contests/data/repositories/contest_repository.dart';
import '../../../auth/domain/providers/auth_provider.dart';

/// Provider for user joined contests per match.
final myContestsForMatchProvider = FutureProvider.family<
    List<_JoinedContestEntry>, String>((ref, matchId) async {
  final userId = ref.watch(authProvider).user?.uid;
  if (userId == null) return [];

  final repo = ref.watch(contestRepositoryProvider);

  // Load all contests for this match
  final contests = await repo.getContestsByMatch(matchId);

  final joined = <_JoinedContestEntry>[];
  for (final contest in contests) {
    final hasJoined = await repo.hasUserJoinedContest(
      contestId: contest.id,
      userId: userId,
    );
    if (hasJoined) {
      // Load leaderboard entry for this user
      final leaderboard = await repo.getLeaderboard(contest.id);
      final myEntry = leaderboard
          .where((e) => e.userId == userId)
          .firstOrNull;

      joined.add(_JoinedContestEntry(
        contestName: contest.name,
        contestId: contest.id,
        prizePool: contest.prizePool,
        entryFee: contest.entryFee,
        totalSpots: contest.maxTeams,
        spotsLeft: contest.spotsLeft,
        points: myEntry?.points ?? 0.0,
        rank: myEntry?.rank ?? 0,
        prizeWon: myEntry?.prizeWon ?? 0.0,
        totalPrizePositions: contest.maxWinners,
        isCompleted: contest.isCompleted,
      ));
    }
  }
  return joined;
});

class _JoinedContestEntry {
  final String contestName;
  final String contestId;
  final double prizePool;
  final double entryFee;
  final int totalSpots;
  final int spotsLeft;
  final double points;
  final int rank;
  final double prizeWon;
  final int totalPrizePositions;
  final bool isCompleted;

  const _JoinedContestEntry({
    required this.contestName,
    required this.contestId,
    required this.prizePool,
    required this.entryFee,
    required this.totalSpots,
    required this.spotsLeft,
    required this.points,
    required this.rank,
    required this.prizeWon,
    required this.totalPrizePositions,
    required this.isCompleted,
  });

  bool get isInWinningZone => rank > 0 && rank <= totalPrizePositions;
}

/// My Contests tab — shows user's joined contests for this match.
/// Ported from Fantasy- MatchTabs index 1 (My Contests).
class MyContestsTab extends ConsumerWidget {
  final String matchId;
  const MyContestsTab({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contestsAsync =
        ref.watch(myContestsForMatchProvider(matchId));

    return contestsAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(
          child: Text('Failed to load contests',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary))),
      data: (contests) {
        if (contests.isEmpty) {
          return _buildEmpty(context);
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: contests.length,
          itemBuilder: (context, i) => _JoinedContestCard(
            entry: contests[i],
            onTap: () => context.push('/contests/${contests[i].contestId}'),
          ),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined,
                size: 64, color: AppColors.textTertiary),
            AppSpacing.gapH16,
            Text('No contests joined yet',
                style: AppTypography.bodyLarge
                    .copyWith(color: AppColors.textSecondary)),
            AppSpacing.gapH8,
            Text('Join a contest to see your performance here',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textTertiary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Joined contest card with winning zone & rank
// ─────────────────────────────────────────────────────────────────────────────

class _JoinedContestCard extends StatelessWidget {
  final _JoinedContestEntry entry;
  final VoidCallback onTap;

  const _JoinedContestCard({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(
            color: entry.isInWinningZone
                ? AppColors.success.withOpacity(0.4)
                : AppColors.border.withOpacity(0.5),
            width: entry.isInWinningZone ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            // Contest info row
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.contestName,
                            style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.w600)),
                        AppSpacing.gapH4,
                        Row(
                          children: [
                            _InfoChip(
                                label: 'Pool',
                                value:
                                    '₹${_formatAmount(entry.prizePool)}'),
                            AppSpacing.gapW8,
                            _InfoChip(
                                label: 'Spots',
                                value: '${entry.totalSpots}'),
                            AppSpacing.gapW8,
                            _InfoChip(
                                label: 'Entry',
                                value: entry.entryFee == 0
                                    ? 'FREE'
                                    : '₹${entry.entryFee.toInt()}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Won amount (if completed)
                  if (entry.isCompleted && entry.prizeWon > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('You Won',
                            style: AppTypography.labelSmall
                                .copyWith(color: AppColors.success)),
                        Text('₹${entry.prizeWon.toStringAsFixed(0)}',
                            style: AppTypography.titleMedium.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                ],
              ),
            ),

            // Status row
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: entry.isInWinningZone
                    ? AppColors.success.withOpacity(0.06)
                    : AppColors.scaffoldBackground,
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12)),
                border: Border(
                    top: BorderSide(color: AppColors.border, width: 0.5)),
              ),
              child: Row(
                children: [
                  // Points
                  Icon(Icons.star, size: 14, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text('${entry.points.toStringAsFixed(1)} pts',
                      style: AppTypography.labelMedium
                          .copyWith(fontWeight: FontWeight.w600)),
                  AppSpacing.gapW16,

                  // Rank
                  Icon(Icons.leaderboard_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    entry.rank > 0 ? '#${entry.rank}' : 'Unranked',
                    style: AppTypography.labelMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),

                  const Spacer(),

                  // Winning zone badge / rank direction
                  if (entry.isInWinningZone)
                    _WinningZoneBadge()
                  else if (entry.rank > 0)
                    Row(children: [
                      Icon(Icons.south, size: 14, color: AppColors.error),
                      Text('Not in zone',
                          style: AppTypography.labelSmall
                              .copyWith(color: AppColors.error)),
                    ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.labelSmall
                .copyWith(color: AppColors.textTertiary, fontSize: 9)),
        Text(value,
            style: AppTypography.labelSmall
                .copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

/// Green "IN WINNING ZONE" badge — from Fantasy- MatchTabs
class _WinningZoneBadge extends StatelessWidget {
  const _WinningZoneBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.arrow_upward, size: 11, color: Colors.white),
          const SizedBox(width: 3),
          Text('IN WINNING ZONE',
              style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
