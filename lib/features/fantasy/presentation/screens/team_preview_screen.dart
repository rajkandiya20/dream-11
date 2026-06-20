import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../matches/data/models/player_model.dart';

/// Visual team preview showing 11 players on a cricket pitch layout.
class TeamPreviewScreen extends StatelessWidget {
  final List<PlayerModel> players;
  final String? captainId;
  final String? viceCaptainId;

  const TeamPreviewScreen({
    super.key,
    required this.players,
    this.captainId,
    this.viceCaptainId,
  });

  @override
  Widget build(BuildContext context) {
    // Group players by role
    final wk = players.where((p) => p.role == 'WK').toList();
    final bat = players.where((p) => p.role == 'Batsman').toList();
    final ar = players.where((p) => p.role == 'All-rounder').toList();
    final bowl = players.where((p) => p.role == 'Bowler').toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
              Color(0xFF388E3C),
              Color(0xFF43A047),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Team Preview',
                      style: AppTypography.titleLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 24),
                  ],
                ),
              ),
              // Pitch layout
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // WK section
                      _RoleSection(
                        label: 'WICKET-KEEPERS',
                        players: wk,
                        captainId: captainId,
                        viceCaptainId: viceCaptainId,
                      ),
                      // BAT section
                      _RoleSection(
                        label: 'BATTERS',
                        players: bat,
                        captainId: captainId,
                        viceCaptainId: viceCaptainId,
                      ),
                      // AR section
                      _RoleSection(
                        label: 'ALL-ROUNDERS',
                        players: ar,
                        captainId: captainId,
                        viceCaptainId: viceCaptainId,
                      ),
                      // BOWL section
                      _RoleSection(
                        label: 'BOWLERS',
                        players: bowl,
                        captainId: captainId,
                        viceCaptainId: viceCaptainId,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A role section with label and player chips on the pitch.
class _RoleSection extends StatelessWidget {
  final String label;
  final List<PlayerModel> players;
  final String? captainId;
  final String? viceCaptainId;

  const _RoleSection({
    required this.label,
    required this.players,
    this.captainId,
    this.viceCaptainId,
  });

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          // Role label
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white.withOpacity(0.7),
              letterSpacing: 1.5,
              fontSize: 9,
            ),
          ),
          AppSpacing.gapH8,
          // Player chips in a row
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: players.map((player) {
              final isCaptain = player.id == captainId;
              final isViceCaptain = player.id == viceCaptainId;

              return _PitchPlayerChip(
                player: player,
                isCaptain: isCaptain,
                isViceCaptain: isViceCaptain,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Player chip displayed on the pitch.
class _PitchPlayerChip extends StatelessWidget {
  final PlayerModel player;
  final bool isCaptain;
  final bool isViceCaptain;

  const _PitchPlayerChip({
    required this.player,
    this.isCaptain = false,
    this.isViceCaptain = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Captain/VC badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Player avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCaptain
                      ? AppColors.primary
                      : isViceCaptain
                          ? AppColors.info
                          : Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  player.name.isNotEmpty
                      ? player.name[0].toUpperCase()
                      : 'P',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ),
            // Captain/VC badge
            if (isCaptain || isViceCaptain)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color:
                        isCaptain ? AppColors.primary : AppColors.info,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      isCaptain ? 'C' : 'VC',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        AppSpacing.gapH4,
        // Player name
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: AppSpacing.borderRadiusFull,
          ),
          child: Text(
            player.name.split(' ').last,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Credits
        Text(
          '${player.credits} Cr',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 8,
          ),
        ),
      ],
    );
  }
}
