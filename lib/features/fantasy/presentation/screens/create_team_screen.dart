import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../matches/data/models/player_model.dart';
import '../../../matches/data/repositories/match_repository.dart';
import '../../domain/providers/fantasy_provider.dart';
import '../widgets/player_card.dart';

/// Player selection screen — Dream11-style grouped layout.
/// [contestId] is optional. When provided the saved team will be
/// linked to that contest and joinContest() will be called after saving.
class CreateTeamScreen extends ConsumerStatefulWidget {
  final String matchId;
  final String? contestId;

  const CreateTeamScreen({
    super.key,
    required this.matchId,
    this.contestId,
  });

  @override
  ConsumerState<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends ConsumerState<CreateTeamScreen> {
  bool _isLoadingPlayers = true;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final repository = ref.read(matchRepositoryProvider);
    final players = await repository.getPlayersByMatch(widget.matchId);
    ref
        .read(teamBuilderProvider(widget.matchId).notifier)
        .setAvailablePlayers(players);
    if (mounted) setState(() => _isLoadingPlayers = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamBuilderProvider(widget.matchId));
    final notifier = ref.read(teamBuilderProvider(widget.matchId).notifier);

    // Group players by role
    final wkPlayers   = state.availablePlayers.where((p) => p.role == 'WK').toList();
    final batPlayers  = state.availablePlayers.where((p) => p.role == 'Batsman').toList();
    final arPlayers   = state.availablePlayers.where((p) => p.role == 'All-rounder').toList();
    final bowlPlayers = state.availablePlayers.where((p) => p.role == 'Bowler').toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Column(
        children: [
          // ── Dark header ──────────────────────────────────────────────
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Text(
                          'Create Team',
                          style: AppTypography.titleLarge.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Reset button
                      TextButton(
                        onPressed: state.selectedPlayers.isNotEmpty
                            ? () => notifier.reset()
                            : null,
                        child: Text(
                          'RESET',
                          style: AppTypography.labelMedium.copyWith(
                            color: state.selectedPlayers.isNotEmpty
                                ? AppColors.error
                                : Colors.white24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Credits + player count row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    border: Border(
                      top: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(Icons.people, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '${state.selectedCount}/11 Players',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      ]),
                      Row(children: [
                        const Icon(Icons.monetization_on,
                            color: Color(0xFFFCD34D), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '${(100.0 - state.creditsUsed).toStringAsFixed(1)} Credits Left',
                          style: const TextStyle(
                              color: Color(0xFFFCD34D),
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      ]),
                    ],
                  ),
                ),
                // Role count badges
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _RoleBadge(label: 'WK',   count: state.wkCount,   max: 4),
                      _RoleBadge(label: 'BAT',  count: state.batCount,  max: 6),
                      _RoleBadge(label: 'AR',   count: state.arCount,   max: 4),
                      _RoleBadge(label: 'BOWL', count: state.bowlCount, max: 6),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Player list ──────────────────────────────────────────────
          Expanded(
            child: _isLoadingPlayers
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : ListView(
                    padding: const EdgeInsets.only(bottom: 80),
                    children: [
                      if (wkPlayers.isNotEmpty)
                        _buildSection('WICKET-KEEPERS', wkPlayers, state, notifier),
                      if (batPlayers.isNotEmpty)
                        _buildSection('BATTERS', batPlayers, state, notifier),
                      if (arPlayers.isNotEmpty)
                        _buildSection('ALL-ROUNDERS', arPlayers, state, notifier),
                      if (bowlPlayers.isNotEmpty)
                        _buildSection('BOWLERS', bowlPlayers, state, notifier),
                    ],
                  ),
          ),
        ],
      ),

      // ── Bottom sticky bar ────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2))
          ],
        ),
        child: SafeArea(
          child: AppButton(
            text: state.selectedCount == 11
                ? 'NEXT →'
                : 'SELECT ${11 - state.selectedCount} MORE',
            onPressed: state.selectedCount == 11
                ? () {
                    // Validate minimum role constraints
                    if (!state.isValidTeam) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Team must have min 1 WK, 3 BAT, 1 AR and 3 BOWL'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    // Pass both matchId AND contestId to captain selection
                    final extra = widget.contestId;
                    context.push(
                      '/captain-selection/${widget.matchId}',
                      extra: extra,
                    );
                  }
                : null,
            isLoading: false,
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<PlayerModel> players,
    dynamic state,
    dynamic notifier,
  ) {
    final selectedCount =
        players.where((p) => state.selectedPlayers.any((s) => s.id == p.id)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: const Color(0xFFF1F5F9),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: Color(0xFF64748B)),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: selectedCount > 0
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$selectedCount selected',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: selectedCount > 0
                          ? AppColors.primary
                          : const Color(0xFF94A3B8)),
                ),
              ),
            ],
          ),
        ),
        // Players
        ...players.map((player) => PlayerSelectionCard(
              player: player,
              isSelected: state.selectedPlayers.any((p) => p.id == player.id),
              isDisabled: !state.canAddPlayer(player) &&
                  !state.selectedPlayers.any((p) => p.id == player.id),
              onTap: () => notifier.togglePlayer(player),
            )),
      ],
    );
  }
}

/// Small role badge showing count / max.
class _RoleBadge extends StatelessWidget {
  final String label;
  final int count;
  final int max;

  const _RoleBadge(
      {required this.label, required this.count, required this.max});

  @override
  Widget build(BuildContext context) {
    final isFull = count >= max;
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
              color: isFull ? AppColors.success : Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          '$count',
          style: TextStyle(
              color: isFull ? AppColors.success : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
