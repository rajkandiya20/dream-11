import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../fantasy/data/repositories/fantasy_repository.dart';
import '../../../wallet/data/repositories/wallet_repository.dart';
import '../../domain/providers/contest_provider.dart';
import '../widgets/prize_breakdown.dart';

/// Contest detail screen showing prize breakdown, leaderboard, and join options.
class ContestDetailScreen extends ConsumerWidget {
  final String contestId;

  const ContestDetailScreen({super.key, required this.contestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(contestDetailProvider(contestId));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          state.contest?.name ?? 'Contest',
          style: AppTypography.titleLarge,
        ),
        centerTitle: true,
      ),
      body: state.isLoading && state.contest == null
          ? _buildLoading()
          : state.contest == null
              ? _buildError(context, ref)
              : _buildContent(context, ref, state),
      bottomNavigationBar: state.contest != null && !state.hasJoined
          ? _buildBottomBar(context, state)
          : null,
    );
  }

  Widget _buildLoading() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          const ShimmerLoading(width: double.infinity, height: 120),
          AppSpacing.gapH16,
          const ShimmerLoading(width: double.infinity, height: 200),
          AppSpacing.gapH16,
          const ShimmerLoading(width: double.infinity, height: 300),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          AppSpacing.gapH16,
          Text(
            'Failed to load contest',
            style: AppTypography.headlineSmall,
          ),
          AppSpacing.gapH24,
          ElevatedButton(
            onPressed: () => ref
                .read(contestDetailProvider(contestId).notifier)
                .refresh(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, ContestDetailState state) {
    final contest = state.contest!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contest info card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.secondaryGradient,
              borderRadius: AppSpacing.borderRadiusLg,
            ),
            child: Column(
              children: [
                // Prize pool
                Text(
                  'Prize Pool',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
                AppSpacing.gapH4,
                Text(
                  '\u20B9${contest.formattedPrizePool}',
                  style: AppTypography.displayMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.gapH20,
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ContestStat(
                      label: 'Entry',
                      value: contest.formattedEntryFee,
                      icon: Icons.confirmation_number_outlined,
                    ),
                    _ContestStat(
                      label: 'Spots',
                      value: '${contest.maxTeams}',
                      icon: Icons.people_outline,
                    ),
                    _ContestStat(
                      label: 'Filled',
                      value: '${(contest.fillPercentage * 100).toInt()}%',
                      icon: Icons.pie_chart_outline,
                    ),
                  ],
                ),
                AppSpacing.gapH16,
                // Progress bar
                ClipRRect(
                  borderRadius: AppSpacing.borderRadiusFull,
                  child: LinearProgressIndicator(
                    value: contest.fillPercentage,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.success,
                    ),
                    minHeight: 6,
                  ),
                ),
                AppSpacing.gapH8,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${contest.spotsLeft} spots left',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '${contest.joinedTeams} joined',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Joined badge
          if (state.hasJoined)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: AppSpacing.borderRadiusSm,
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  AppSpacing.gapW8,
                  Text(
                    'You have joined this contest',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          AppSpacing.gapH24,
          // Prize Breakdown
          PrizeBreakdown(contest: contest),
          AppSpacing.gapH24,
          // Leaderboard
          if (state.leaderboard.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.leaderboard, size: 18, color: AppColors.info),
                  AppSpacing.gapW8,
                  Text('Leaderboard', style: AppTypography.titleLarge),
                ],
              ),
            ),
            AppSpacing.gapH12,
            ...state.leaderboard.take(20).map(
                  (entry) => _LeaderboardRow(entry: entry),
                ),
          ],
          AppSpacing.gapH32,
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, ContestDetailState state) {
    final contest = state.contest!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Entry Fee', style: AppTypography.labelSmall),
                Text(
                  contest.formattedEntryFee,
                  style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            AppSpacing.gapW16,
            Expanded(
              child: _JoinContestButton(
                contestId: contestId,
                contest: contest,
                state: state,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stateful join button that handles the complete join flow.
class _JoinContestButton extends ConsumerWidget {
  final String contestId;
  final dynamic contest;
  final ContestDetailState state;

  const _JoinContestButton({
    required this.contestId,
    required this.contest,
    required this.state,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (contest.isFull) {
      return AppButton(text: 'FULL', isDisabled: true, onPressed: null);
    }

    return AppButton(
      text: 'JOIN CONTEST',
      variant: AppButtonVariant.gradient,
      onPressed: () => _handleJoin(context, ref),
    );
  }

  Future<void> _handleJoin(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to join contests')),
      );
      return;
    }

    // Step 1: Check wallet balance
    final walletRepo = ref.read(walletRepositoryProvider);
    final wallet = await walletRepo.getWallet(user.uid);
    final entryFee = (contest.entryFee as num).toDouble();

    if (entryFee > 0) {
      final balance = wallet?.totalBalance ?? 0.0;
      if (balance < entryFee) {
        // Insufficient balance — show deposit prompt
        if (context.mounted) {
          final shouldDeposit = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Insufficient Balance'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Entry Fee: ₹${entryFee.toStringAsFixed(0)}'),
                  Text('Your Balance: ₹${balance.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  Text(
                    'You need to add ₹${(entryFee - balance).toStringAsFixed(0)} more to join this contest.',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Add Money', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
          if (shouldDeposit == true && context.mounted) {
            context.push('/wallet');
          }
        }
        return;
      }
    }

    // Step 2: Check if user has teams for this match
    final fantasyRepo = ref.read(fantasyRepositoryProvider);
    final userTeams = await fantasyRepo.getUserTeamsForMatch(
      userId: user.uid,
      matchId: contest.matchId,
    );

    if (!context.mounted) return;

    if (userTeams.isEmpty) {
      // No team — ask to create one
      final shouldCreate = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No Team Found'),
          content: const Text('You need to create a team before joining this contest.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Create Team', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (shouldCreate == true && context.mounted) {
        context.push('/create-team/${contest.matchId}');
      }
      return;
    }

    // Step 3: Select team to join with
    String? selectedTeamId;
    if (userTeams.length == 1) {
      selectedTeamId = userTeams.first.id;
    } else {
      if (!context.mounted) return;
      selectedTeamId = await showModalBottomSheet<String>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => _TeamSelectionSheet(teams: userTeams),
      );
    }

    if (selectedTeamId == null || !context.mounted) return;

    // Step 4: Deduct balance (if paid contest)
    if (entryFee > 0) {
      final deducted = await walletRepo.deductBalance(
        userId: user.uid,
        amount: entryFee,
        description: 'Contest entry: ${contest.name}',
      );
      if (!deducted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to deduct balance. Try again.'), backgroundColor: Colors.red),
          );
        }
        return;
      }
    }

    // Step 5: Join contest
    final notifier = ref.read(contestDetailProvider(contestId).notifier);
    final success = await notifier.joinContest(selectedTeamId);

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Joined contest successfully!'), backgroundColor: Colors.green),
        );
      } else {
        // Refund if join failed
        if (entryFee > 0) {
          await walletRepo.initiateDeposit(
            userId: user.uid,
            amount: entryFee,
            paymentMethod: 'refund',
            description: 'Refund: Failed to join contest',
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to join contest. Amount refunded.'), backgroundColor: Colors.red),
        );
      }
    }
  }

class _ContestStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ContestStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.white54),
        AppSpacing.gapH4,
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final dynamic entry;

  const _LeaderboardRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppSpacing.borderRadiusSm,
        border: entry.rank <= 3
            ? Border.all(
                color: entry.rank == 1
                    ? const Color(0xFFFFD700)
                    : entry.rank == 2
                        ? const Color(0xFFC0C0C0)
                        : const Color(0xFFCD7F32),
                width: 1,
              )
            : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 32,
            child: Text(
              '#${entry.rank}',
              style: AppTypography.titleSmall.copyWith(
                color: entry.rank <= 3 ? AppColors.warning : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppSpacing.gapW12,
          // Avatar
          if (entry.avatarUrl != null)
            CachedImage(
              imageUrl: entry.avatarUrl!,
              width: 32,
              height: 32,
              borderRadius: BorderRadius.circular(16),
            )
          else
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.secondaryLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  entry.username[0].toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          AppSpacing.gapW12,
          // Username
          Expanded(
            child: Text(
              entry.username,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Points
          Text(
            '${entry.points.toStringAsFixed(1)} pts',
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}


/// Bottom sheet for selecting which team to join with.
class _TeamSelectionSheet extends StatelessWidget {
  final List<dynamic> teams;

  const _TeamSelectionSheet({required this.teams});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Select Team', style: AppTypography.titleLarge),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ]),
          AppSpacing.gapH12,
          ...List.generate(teams.length, (i) {
            final team = teams[i];
            final name = team.teamName.isEmpty || team.teamName == 'My Team'
                ? 'Team ${i + 1}'
                : team.teamName;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shield, color: AppColors.primary, size: 22),
              ),
              title: Text(name, style: AppTypography.titleSmall),
              subtitle: Text(
                '${team.playerCount} players • ${team.totalPoints.toStringAsFixed(1)} pts',
                style: AppTypography.labelSmall,
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () => Navigator.pop(context, team.id),
                child: const Text('SELECT', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            );
          }),
          AppSpacing.gapH8,
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create New Team'),
              onPressed: () => Navigator.pop(context, null),
            ),
          ),
          AppSpacing.gapH8,
        ],
      ),
    );
  }
}




}