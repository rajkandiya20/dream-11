import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../matches/data/models/player_model.dart';

/// Dream11-style full-screen cricket ground team preview.
/// Layout matches the HTML reference provided by user:
///   BOWLERS   → top
///   ALL-ROUNDERS → upper-middle
///   BATTERS      → middle
///   WK           → bottom
/// Each player shows: silhouette avatar, name pill, C/VC badge, DT badge, points.
class TeamPreviewScreen extends StatelessWidget {
  final List<PlayerModel> players;
  final String? captainId;
  final String? viceCaptainId;
  final Map<String, double>? playerPoints;
  /// IDs of players in the Dream Team (top-11 by points)
  final Set<String>? dreamTeamIds;

  const TeamPreviewScreen({
    super.key,
    required this.players,
    this.captainId,
    this.viceCaptainId,
    this.playerPoints,
    this.dreamTeamIds,
  });

  @override
  Widget build(BuildContext context) {
    final bowlers      = players.where((p) => p.role == 'Bowler').toList();
    final allRounders  = players.where((p) => p.role == 'All-rounder').toList();
    final batters      = players.where((p) => p.role == 'Batsman').toList();
    final wk           = players.where((p) => p.role == 'WK').toList();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Cricket grass gradient — matches HTML reference
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1d5909), Color(0xFF216510),
              Color(0xFF1d5909), Color(0xFF216510),
              Color(0xFF1d5909), Color(0xFF216510),
            ],
            stops: [0.0, 0.18, 0.36, 0.54, 0.72, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Pitch oval in center
              Center(
                child: Container(
                  width: 130,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(65),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 2,
                    ),
                    color: Colors.white.withOpacity(0.03),
                  ),
                ),
              ),
              // Main content
              Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Expanded(flex: 25, child: _Section(
                            label: 'BOWLERS',
                            players: bowlers,
                            captainId: captainId,
                            viceCaptainId: viceCaptainId,
                            playerPoints: playerPoints,
                            dreamTeamIds: dreamTeamIds,
                          )),
                          Expanded(flex: 25, child: _Section(
                            label: 'ALL-ROUNDERS',
                            players: allRounders,
                            captainId: captainId,
                            viceCaptainId: viceCaptainId,
                            playerPoints: playerPoints,
                            dreamTeamIds: dreamTeamIds,
                          )),
                          Expanded(flex: 25, child: _Section(
                            label: 'BATTERS',
                            players: batters,
                            captainId: captainId,
                            viceCaptainId: viceCaptainId,
                            playerPoints: playerPoints,
                            dreamTeamIds: dreamTeamIds,
                          )),
                          Expanded(flex: 25, child: _Section(
                            label: 'WK',
                            players: wk,
                            captainId: captainId,
                            viceCaptainId: viceCaptainId,
                            playerPoints: playerPoints,
                            dreamTeamIds: dreamTeamIds,
                          )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
          const Spacer(),
          Text('Team Preview',
              style: AppTypography.titleLarge.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w700)),
          const Spacer(),
          const SizedBox(width: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Role section
// ─────────────────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String label;
  final List<PlayerModel> players;
  final String? captainId;
  final String? viceCaptainId;
  final Map<String, double>? playerPoints;
  final Set<String>? dreamTeamIds;

  const _Section({
    required this.label,
    required this.players,
    this.captainId,
    this.viceCaptainId,
    this.playerPoints,
    this.dreamTeamIds,
  });

  double? _pts(String id, bool isC, bool isVC) {
    if (playerPoints == null) return null;
    final b = playerPoints![id];
    if (b == null) return null;
    if (isC)  return b * 2.0;
    if (isVC) return b * 1.5;
    return b;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Section label
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        if (players.isNotEmpty)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 6,
            children: players.map((p) {
              final isC  = p.id == captainId;
              final isVC = p.id == viceCaptainId;
              final isDT = dreamTeamIds?.contains(p.id) ?? false;
              return _PlayerAvatar(
                player: p,
                isCaptain: isC,
                isViceCaptain: isVC,
                isDreamTeam: isDT,
                points: _pts(p.id, isC, isVC),
              );
            }).toList(),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Player avatar — matches HTML reference design exactly
// ─────────────────────────────────────────────────────────────────────────────

class _PlayerAvatar extends StatelessWidget {
  final PlayerModel player;
  final bool isCaptain;
  final bool isViceCaptain;
  final bool isDreamTeam;
  final double? points;

  const _PlayerAvatar({
    required this.player,
    this.isCaptain = false,
    this.isViceCaptain = false,
    this.isDreamTeam = false,
    this.points,
  });

  @override
  Widget build(BuildContext context) {
    // Unique gradient per player (from HTML .c1-.c11 pattern)
    final gradients = [
      [const Color(0xFF1b3d8a), const Color(0xFF0d1f4a)],
      [const Color(0xFF5a8c2a), const Color(0xFF2d4a10)],
      [const Color(0xFF8a1b1b), const Color(0xFF4a0d0d)],
      [const Color(0xFF1b5a8a), const Color(0xFF0d2d4a)],
      [const Color(0xFF4a1b8a), const Color(0xFF250d4a)],
      [const Color(0xFF8a5a1b), const Color(0xFF4a2d0d)],
      [const Color(0xFF1b8a5a), const Color(0xFF0d4a2d)],
      [const Color(0xFF5a1b8a), const Color(0xFF2d0d4a)],
      [const Color(0xFF1b8a8a), const Color(0xFF0d4a4a)],
      [const Color(0xFF8a1b5a), const Color(0xFF4a0d2d)],
      [const Color(0xFF4a8a1b), const Color(0xFF254a0d)],
    ];
    final idx = player.name.codeUnitAt(0) % gradients.length;
    final grad = gradients[idx];

    final hasImage = player.image != null && player.image!.isNotEmpty;

    return SizedBox(
      width: 64,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar outer (relative container for badges)
          SizedBox(
            width: 62,
            height: 72,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Avatar circle
                Positioned(
                  left: 0, right: 0, top: 5,
                  child: Container(
                    width: 62, height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: grad,
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.13),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: hasImage
                          ? CachedImage(
                              imageUrl: player.image!,
                              width: 62, height: 62,
                              fit: BoxFit.cover,
                            )
                          : CustomPaint(
                              painter: _SilhouettePainter(),
                            ),
                    ),
                  ),
                ),
                // C / VC badge — top-left, outside circle (matches HTML .badge-role)
                if (isCaptain || isViceCaptain)
                  Positioned(
                    top: -1, left: -1,
                    child: Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.9),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          isCaptain ? 'C' : 'VC',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                // DT badge — bottom-right (matches HTML .badge-dt)
                if (isDreamTeam)
                  Positioned(
                    bottom: -1, right: -1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFf6bc00), Color(0xFFde9800)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: const Text(
                        'DT',
                        style: TextStyle(
                          color: Color(0xFF1a0a00),
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Name pill — dark background (matches HTML .name-pill.pill-dark)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            constraints: const BoxConstraints(maxWidth: 64),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _shortName(player.name),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          // Points (matches HTML .player-pts)
          if (points != null) ...[
            const SizedBox(height: 2),
            Text(
              '${points!.toStringAsFixed(1)} pts',
              style: TextStyle(
                color: Colors.white.withOpacity(0.72),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  String _shortName(String full) {
    final parts = full.trim().split(' ');
    if (parts.length > 1) {
      // First initial + last name
      return '${parts.first[0]} ${parts.last}';
    }
    return full;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Silhouette painter (matches HTML SVG circle + ellipse pattern)
// ─────────────────────────────────────────────────────────────────────────────

class _SilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..style = PaintingStyle.fill;

    // Head circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.33),
      size.width * 0.18,
      paint,
    );
    // Body ellipse
    final bodyPaint = Paint()
      ..color = Colors.white.withOpacity(0.14)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.85),
        width: size.width * 0.6,
        height: size.height * 0.4,
      ),
      bodyPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
