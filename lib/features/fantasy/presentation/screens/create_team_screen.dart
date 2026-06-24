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

/// Dream11-style player selection screen.
/// Top: horizontal role filter tabs (WK | BAT | AR | BOWL | ALL)
/// Below: filtered player list.
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

class _CreateTeamScreenState extends ConsumerState<CreateTeamScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoadingPlayers = true;
  late TabController _tabController;

  // Tab → PlayerRoleFilter mapping
  static const _tabs = [
    ('ALL', PlayerRoleFilter.all),
    ('WK', PlayerRoleFilter.wk),
    ('BAT', PlayerRoleFilter.bat),
    ('AR', PlayerRoleFilter.ar),
    ('BOWL', PlayerRoleFilter.bowl),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      ref
          .read(teamBuilderProvider(widget.matchId).notifier)
          .setFilter(_tabs[_tabController.index].$2);
    });
    _loadPlayers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Text(
                          'Create Team',
                          style: AppTypography.titleLarge
                              .copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    border: Border(
                      top: BorderSide(
                          color: AppColors.primary.withOpacity(0.3)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(Icons.people,
                            color: Colors.white, size: 18),
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
                          '${state.creditsRemaining.toStringAsFixed(1)} Credits Left',
                          style: const TextStyle(
                              color: Color(0xFFFCD34D),
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      ]),
                    ],
                  ),
                ),

                // ── FIX #3: Role count badges (tappable) ─────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _RoleBadge(
                        label: 'WK',
                        count: state.wkCount,
                        min: 1,
                        max: 4,
                        isActive: state.activeFilter ==
                            PlayerRoleFilter.wk,
                        onTap: () {
                          notifier.setFilter(PlayerRoleFilter.wk);
                          _tabController.animateTo(1);
                        },
                      ),
                      _RoleBadge(
                        label: 'BAT',
                        count: state.batCount,
                        min: 3,
                        max: 6,
                        isActive: state.activeFilter ==
                            PlayerRoleFilter.bat,
                        onTap: () {
                          notifier.setFilter(PlayerRoleFilter.bat);
                          _tabController.animateTo(2);
                        },
                      ),
                      _RoleBadge(
                        label: 'AR',
                        count: state.arCount,
                        min: 1,
                        max: 4,
                        isActive: state.activeFilter ==
                            PlayerRoleFilter.ar,
                        onTap: () {
                          notifier.setFilter(PlayerRoleFilter.ar);
                          _tabController.animateTo(3);
                        },
                      ),
                      _RoleBadge(
                        label: 'BOWL',
                        count: state.bowlCount,
                        min: 3,
                        max: 6,
                        isActive: state.activeFilter ==
                            PlayerRoleFilter.bowl,
                        onTap: () {
                          notifier.setFilter(PlayerRoleFilter.bowl);
                          _tabController.animateTo(4);
                        },
                      ),
                    ],
                  ),
                ),

                // ── FIX #3: Horizontal role filter tabs ───────────────
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  tabs: _tabs.map((t) {
                    final (label, filter) = t;
                    final count = _filterCount(state, filter);
                    return Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(label),
                          if (count > 0) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // ── Player list (filtered by active tab) ─────────────────────
          Expanded(
            child: _isLoadingPlayers
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary))
                : state.filteredPlayers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_search,
                                size: 48,
                                color:
                                    AppColors.textTertiary.withOpacity(0.5)),
                            const SizedBox(height: 12),
                            Text('No players found',
                                style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: state.filteredPlayers.length,
                        itemBuilder: (context, index) {
                          final player = state.filteredPlayers[index];
                          final isSelected = state.isSelected(player.id);
                          final isDisabled =
                              !isSelected && !state.canAddPlayer(player);
                          return PlayerSelectionCard(
                            player: player,
                            isSelected: isSelected,
                            isDisabled: isDisabled,
                            onTap: () => notifier.togglePlayer(player),
                          );
                        },
                      ),
          ),
        ],
      ),

      // ── Bottom sticky NEXT button ──────────────────────────────────────
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
                    if (!state.isValidTeam) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Min: 1 WK · 3 BAT · 1 AR · 3 BOWL'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    context.push(
                      '/captain-selection/${widget.matchId}',
                      extra: widget.contestId,
                    );
                  }
                : null,
            isLoading: false,
          ),
        ),
      ),
    );
  }

  /// Returns the count of available players for a given filter tab.
  int _filterCount(TeamBuilderState state, PlayerRoleFilter filter) {
    if (filter == PlayerRoleFilter.all) return 0;
    final role = {
      PlayerRoleFilter.wk: 'WK',
      PlayerRoleFilter.bat: 'Batsman',
      PlayerRoleFilter.ar: 'All-rounder',
      PlayerRoleFilter.bowl: 'Bowler',
    }[filter];
    return state.availablePlayers.where((p) => p.role == role).length;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Role count badge (header) — tappable to switch tab
// ─────────────────────────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  final String label;
  final int count;
  final int min;
  final int max;
  final bool isActive;
  final VoidCallback onTap;

  const _RoleBadge({
    required this.label,
    required this.count,
    required this.min,
    required this.max,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = count >= min;
    final isFull = count >= max;
    final Color color = isFull
        ? AppColors.success
        : isComplete
            ? Colors.white
            : Colors.white54;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              '$count',
              style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
