import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../matches/data/models/player_model.dart';
import '../../../matches/data/repositories/match_repository.dart';
import '../../domain/providers/fantasy_provider.dart';
import '../widgets/credit_counter.dart';
import '../widgets/player_card.dart';
import '../widgets/role_filter_tabs.dart';
import '../widgets/team_count_indicator.dart';

/// Player selection screen with credit counter, role filters, and search.
class CreateTeamScreen extends ConsumerStatefulWidget {
  final String matchId;

  const CreateTeamScreen({super.key, required this.matchId});

  @override
  ConsumerState<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends ConsumerState<CreateTeamScreen> {
  final TextEditingController _searchController = TextEditingController();
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
    if (mounted) {
      setState(() => _isLoadingPlayers = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamBuilderProvider(widget.matchId));
    final notifier = ref.read(teamBuilderProvider(widget.matchId).notifier);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Create Team', style: AppTypography.titleLarge),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: state.selectedPlayers.isNotEmpty
                ? () => notifier.reset()
                : null,
            child: Text(
              'RESET',
              style: AppTypography.labelMedium.copyWith(
                color: state.selectedPlayers.isNotEmpty
                    ? AppColors.error
                    : AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Credit counter
          CreditCounter(creditsUsed: state.creditsUsed),
          // Team count indicator
          TeamCountIndicator(
            selectedCount: state.selectedCount,
            wkCount: state.wkCount,
            batCount: state.batCount,
            arCount: state.arCount,
            bowlCount: state.bowlCount,
          ),
          // Role filter tabs
          RoleFilterTabs(
            activeFilter: state.activeFilter,
            wkCount: state.wkCount,
            batCount: state.batCount,
            arCount: state.arCount,
            bowlCount: state.bowlCount,
            onFilterChanged: (filter) => notifier.setFilter(filter),
          ),
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => notifier.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search players...',
                hintStyle: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          notifier.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.border.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusFull,
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
              style: AppTypography.bodyMedium,
            ),
          ),
          // Player list
          Expanded(
            child: _isLoadingPlayers
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 8,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child:
                          ShimmerLoading(width: double.infinity, height: 72),
                    ),
                  )
                : state.filteredPlayers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: AppColors.textTertiary,
                            ),
                            AppSpacing.gapH12,
                            Text(
                              'No players found',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: state.filteredPlayers.length,
                        itemBuilder: (context, index) {
                          final player = state.filteredPlayers[index];
                          final isSelected = state.isSelected(player.id);
                          final canAdd = state.canAddPlayer(player);

                          return PlayerSelectionCard(
                            player: player,
                            isSelected: isSelected,
                            isDisabled: !canAdd && !isSelected,
                            onTap: () => notifier.togglePlayer(player),
                          );
                        },
                      ),
          ),
        ],
      ),
      // Bottom action bar
      bottomNavigationBar: Container(
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
              // Team preview button
              GestureDetector(
                onTap: state.selectedPlayers.isNotEmpty
                    ? () => _showTeamPreview(context, state)
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: state.selectedPlayers.isNotEmpty
                        ? AppColors.secondary.withOpacity(0.05)
                        : AppColors.border.withOpacity(0.3),
                    borderRadius: AppSpacing.borderRadiusSm,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(
                    Icons.preview_outlined,
                    color: state.selectedPlayers.isNotEmpty
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
              ),
              AppSpacing.gapW12,
              // Continue button
              Expanded(
                child: AppButton(
                  text: state.isTeamComplete
                      ? 'SELECT CAPTAIN'
                      : 'SELECT ${RoleConstraints.totalPlayers - state.selectedCount} MORE',
                  variant: state.isTeamComplete
                      ? AppButtonVariant.gradient
                      : AppButtonVariant.outline,
                  isDisabled: !state.isTeamComplete,
                  onPressed: state.isTeamComplete
                      ? () {
                          // Validate team composition before proceeding
                          if (!state.isValidTeam) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Team must have min 1 WK, 3 BAT, 1 AR, and 3 BOWL',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          debugPrint('[CreateTeam] Navigating to captain selection with ${state.selectedCount} players for match ${widget.matchId}');
                          context.push('/captain-selection/${widget.matchId}');
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTeamPreview(BuildContext context, TeamBuilderState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TeamPreviewSheet(
        selectedPlayers: state.selectedPlayers,
      ),
    );
  }
}

/// Bottom sheet for quick team preview.
class _TeamPreviewSheet extends StatelessWidget {
  final List<PlayerModel> selectedPlayers;

  const _TeamPreviewSheet({required this.selectedPlayers});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: AppSpacing.borderRadiusFull,
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Selected Players (${selectedPlayers.length})',
              style: AppTypography.titleLarge,
            ),
          ),
          // Player list
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: selectedPlayers.length,
              itemBuilder: (context, index) {
                final player = selectedPlayers[index];
                return ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        player.roleAbbreviation,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    player.name,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    '${player.teamName} - ${player.credits} Cr',
                    style: AppTypography.labelSmall,
                  ),
                  trailing: Text(
                    '${player.points.toStringAsFixed(0)} pts',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
