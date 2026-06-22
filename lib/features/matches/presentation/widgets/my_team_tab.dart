import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/supabase_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../fantasy/data/models/fantasy_team_model.dart';
import '../../../fantasy/data/repositories/fantasy_repository.dart';

/// My Team tab showing the user's fantasy teams for this match.
class MyTeamTab extends ConsumerStatefulWidget {
  final String matchId;

  const MyTeamTab({super.key, required this.matchId});

  @override
  ConsumerState<MyTeamTab> createState() => _MyTeamTabState();
}

class _MyTeamTabState extends ConsumerState<MyTeamTab> {
  List<FantasyTeamModel> _teams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTeams();
    });
  }

  Future<void> _loadTeams() async {
    setState(() => _isLoading = true);

    final user = ref.read(authProvider).user;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final client = ref.read(supabaseClientProvider);
    final repository = FantasyRepository(client);

    final teams = await repository.getUserTeamsForMatch(
      userId: user.uid,
      matchId: widget.matchId,
    );

    if (mounted) {
      setState(() {
        _teams = teams;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_teams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            AppSpacing.gapH16,
            Text(
              'No Team Created Yet',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.gapH8,
            Text(
              'Create a team to join contests',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadTeams,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _teams.length,
        itemBuilder: (context, index) {
          final team = _teams[index];
          final teamDisplayName = _getTeamDisplayName(team, index);
          return _TeamCard(
            team: team,
            displayName: teamDisplayName,
          );
        },
      ),
    );
  }

  /// Get proper team display name with index-based naming.
  /// If team_name is generic "My Team" or empty, auto-name as "Team 1", "Team 2" etc.
  String _getTeamDisplayName(FantasyTeamModel team, int index) {
    final name = team.teamName.trim();
    if (name.isEmpty || name == 'My Team') {
      return 'Team ${index + 1}';
    }
    return name;
  }
}

/// Card displaying a single fantasy team's info.
class _TeamCard extends StatelessWidget {
  final FantasyTeamModel team;
  final String displayName;

  const _TeamCard({required this.team, required this.displayName});

  @override
  Widget build(BuildContext context) {
    final captain = team.players.where((p) => p.isCaptain).firstOrNull;
    final viceCaptain = team.players.where((p) => p.isViceCaptain).firstOrNull;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppSpacing.borderRadiusMd,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team name and points row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: const Center(
                  child: Icon(
                    Icons.shield,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
              ),
              AppSpacing.gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${team.playerCount} players',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // Points badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Text(
                  '${team.totalPoints.toStringAsFixed(1)} pts',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapH16,
          // Captain and Vice Captain row
          Row(
            children: [
              Expanded(
                child: _CaptainInfo(
                  label: 'Captain (C)',
                  playerName: captain?.playerName ?? 'Not selected',
                  icon: Icons.star,
                  color: AppColors.warning,
                ),
              ),
              AppSpacing.gapW12,
              Expanded(
                child: _CaptainInfo(
                  label: 'Vice Captain (VC)',
                  playerName: viceCaptain?.playerName ?? 'Not selected',
                  icon: Icons.star_half,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          AppSpacing.gapH12,
          // Rank and created time
          Row(
            children: [
              if (team.rank != null && team.rank! > 0) ...[
                Icon(Icons.leaderboard, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  'Rank #${team.rank}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Icon(Icons.access_time, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                _formatCreatedAt(team.createdAt),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCreatedAt(DateTime? date) {
    if (date == null) return 'Unknown';
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }
}

/// Captain/Vice Captain info widget.
class _CaptainInfo extends StatelessWidget {
  final String label;
  final String playerName;
  final IconData icon;
  final Color color;

  const _CaptainInfo({
    required this.label,
    required this.playerName,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            playerName,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
