import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../matches/data/models/player_model.dart';

/// Dream11-style full-screen cricket ground team preview.
///
/// Displays players on a cricket pitch layout grouped by role:
/// TOP: Bowlers, UPPER-MIDDLE: All-rounders, MIDDLE: Batters, BOTTOM: WK.
/// Shows captain (C) badge in red and vice-captain (VC) badge in blue.
/// Optionally displays fantasy points with captain 2x and VC 1.5x multipliers.
class TeamPreviewScreen extends StatelessWidget {
  final List<PlayerModel> players;
  final String? captainId;
  final String? viceCaptainId;
  final Map<String, double>? playerPoints;

  const TeamPreviewScreen({
    super.key,
    required this.players,
    this.captainId,
    this.viceCaptainId,
    this.playerPoints,
  });

  @override
  Widget build(BuildContext context) {
    // Group players by role - layout order: Bowlers top, WK bottom
    final bowlers = players.where((p) => p.role == 'Bowler').toList();
    final allRounders = players.where((p) => p.role == 'All-rounder').toList();
    final batters = players.where((p) => p.role == 'Batsman').toList();
    final wicketKeepers = players.where((p) => p.role == 'WK').toList();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A472A),
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
              Color(0xFF388E3C),
              Color(0xFF43A047),
            ],
            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with close button and title
              _buildHeader(context),
              // Cricket ground with players
              Expanded(
                child: _buildCricketGround(
                  bowlers: bowlers,
                  allRounders: allRounders,
                  batters: batters,
                  wicketKeepers: wicketKeepers,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Team Preview',
            style: AppTypography.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildCricketGround({
    required List<PlayerModel> bowlers,
    required List<PlayerModel> allRounders,
    required List<PlayerModel> batters,
    required List<PlayerModel> wicketKeepers,
  }) {
    return Stack(
      children: [
        // Pitch oval decoration in the center
        Center(
          child: Container(
            width: 180,
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(90),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 2,
              ),
              color: Colors.white.withOpacity(0.03),
            ),
          ),
        ),
        // Player sections
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              // BOWLERS - Top
              Expanded(
                flex: 25,
                child: _RoleSection(
                  label: 'BOWLERS',
                  players: bowlers,
                  captainId: captainId,
                  viceCaptainId: viceCaptainId,
                  playerPoints: playerPoints,
                ),
              ),
              // ALL-ROUNDERS - Upper middle
              Expanded(
                flex: 25,
                child: _RoleSection(
                  label: 'ALL-ROUNDERS',
                  players: allRounders,
                  captainId: captainId,
                  viceCaptainId: viceCaptainId,
                  playerPoints: playerPoints,
                ),
              ),
              // BATTERS - Middle
              Expanded(
                flex: 25,
                child: _RoleSection(
                  label: 'BATTERS',
                  players: batters,
                  captainId: captainId,
                  viceCaptainId: viceCaptainId,
                  playerPoints: playerPoints,
                ),
              ),
              // WICKET-KEEPERS - Bottom
              Expanded(
                flex: 25,
                child: _RoleSection(
                  label: 'WICKET-KEEPERS',
                  players: wicketKeepers,
                  captainId: captainId,
                  viceCaptainId: viceCaptainId,
                  playerPoints: playerPoints,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A section for a specific role displaying players in a wrap layout.
class _RoleSection extends StatelessWidget {
  final String label;
  final List<PlayerModel> players;
  final String? captainId;
  final String? viceCaptainId;
  final Map<String, double>? playerPoints;

  const _RoleSection({
    required this.label,
    required this.players,
    this.captainId,
    this.viceCaptainId,
    this.playerPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Section label
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        AppSpacing.gapH8,
        // Players in a row
        if (players.isNotEmpty)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: players.map((player) {
              final isCaptain = player.id == captainId;
              final isViceCaptain = player.id == viceCaptainId;
              return _PlayerAvatar(
                player: player,
                isCaptain: isCaptain,
                isViceCaptain: isViceCaptain,
                points: _getDisplayPoints(player.id, isCaptain, isViceCaptain),
              );
            }).toList(),
          ),
      ],
    );
  }

  /// Get display points with captain/VC multiplier applied.
  double? _getDisplayPoints(
    String playerId,
    bool isCaptain,
    bool isViceCaptain,
  ) {
    if (playerPoints == null) return null;
    final basePoints = playerPoints![playerId];
    if (basePoints == null) return null;

    if (isCaptain) return basePoints * 2.0;
    if (isViceCaptain) return basePoints * 1.5;
    return basePoints;
  }
}

/// Individual player avatar on the cricket ground.
class _PlayerAvatar extends StatelessWidget {
  final PlayerModel player;
  final bool isCaptain;
  final bool isViceCaptain;
  final double? points;

  const _PlayerAvatar({
    required this.player,
    this.isCaptain = false,
    this.isViceCaptain = false,
    this.points,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar with badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              _buildAvatar(),
              // Captain or Vice-Captain badge
              if (isCaptain || isViceCaptain)
                Positioned(
                  top: -2,
                  right: -2,
                  child: _buildBadge(),
                ),
            ],
          ),
          AppSpacing.gapH4,
          // Player name in dark pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: AppSpacing.borderRadiusFull,
            ),
            child: Text(
              _getShortName(player.name),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          // Fantasy points below name
          if (points != null) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              child: Text(
                '${points!.toStringAsFixed(1)} pts',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final hasImage = player.image != null && player.image!.isNotEmpty;

    return Container(
      width: 46,
      height: 46,
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
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: hasImage
            ? CachedImage(
                imageUrl: player.image,
                width: 42,
                height: 42,
                borderRadius: AppSpacing.borderRadiusFull,
              )
            : Center(
                child: Text(
                  player.name.isNotEmpty
                      ? player.name[0].toUpperCase()
                      : 'P',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: isCaptain ? AppColors.primary : AppColors.info,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
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
    );
  }

  /// Get a short display name (last name or abbreviated).
  String _getShortName(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length > 1) {
      return parts.last;
    }
    return fullName;
  }
}
