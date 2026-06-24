import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Confetti/celebration overlay — shown on SIX, FOUR, WICKET events.
/// Ported from Fantasy- animate.js + Cracker.js
///
/// Usage:
///   CelebrationOverlay.show(context, type: CelebrationEventType.six);
class CelebrationOverlay {
  static OverlayEntry? _entry;

  static void show(
    BuildContext context, {
    required CelebrationEventType type,
  }) {
    // Remove existing
    _entry?.remove();
    _entry = null;

    final overlay = Overlay.of(context);
    _entry = OverlayEntry(
      builder: (_) => _CelebrationWidget(
        type: type,
        onDone: () {
          _entry?.remove();
          _entry = null;
        },
      ),
    );
    overlay.insert(_entry!);
  }
}

enum CelebrationEventType { six, four, wicket }

class _CelebrationWidget extends StatefulWidget {
  final CelebrationEventType type;
  final VoidCallback onDone;

  const _CelebrationWidget({required this.type, required this.onDone});

  @override
  State<_CelebrationWidget> createState() => _CelebrationWidgetState();
}

class _CelebrationWidgetState extends State<_CelebrationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _particles = List.generate(60, (_) => _Particle());

    _controller.forward().then((_) {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _eventColor {
    switch (widget.type) {
      case CelebrationEventType.six:
        return AppColors.primary;
      case CelebrationEventType.four:
        return AppColors.info;
      case CelebrationEventType.wicket:
        return AppColors.error;
    }
  }

  String get _eventLabel {
    switch (widget.type) {
      case CelebrationEventType.six:
        return 'SIX!';
      case CelebrationEventType.four:
        return 'FOUR!';
      case CelebrationEventType.wicket:
        return 'WICKET!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final size = MediaQuery.of(context).size;

            return Stack(
              children: [
                // Particles
                ..._particles.map((p) {
                  final progress = t;
                  final x =
                      p.startX * size.width + p.velocityX * progress * size.width;
                  final y = p.startY * size.height +
                      p.velocityY * progress * size.height +
                      0.5 * 9.8 * progress * progress * size.height * 0.1;
                  final opacity = (1 - progress).clamp(0.0, 1.0);

                  return Positioned(
                    left: x,
                    top: y,
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.rotate(
                        angle: p.rotation * progress * math.pi * 4,
                        child: Container(
                          width: p.size,
                          height: p.size * (p.isCircle ? 1 : 0.4),
                          decoration: BoxDecoration(
                            color: p.color,
                            shape: p.isCircle
                                ? BoxShape.circle
                                : BoxShape.rectangle,
                            borderRadius: p.isCircle
                                ? null
                                : BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // Center label
                if (t < 0.5)
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 400),
                      builder: (_, v, __) => Transform.scale(
                        scale: v,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            color: _eventColor.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: _eventColor.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 4,
                              )
                            ],
                          ),
                          child: Text(
                            _eventLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Particle {
  final double startX;
  final double startY;
  final double velocityX;
  final double velocityY;
  final double rotation;
  final double size;
  final Color color;
  final bool isCircle;

  static final _rng = math.Random();
  static const _colors = [
    AppColors.primary,
    AppColors.warning,
    AppColors.success,
    AppColors.info,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.yellow,
  ];

  _Particle()
      : startX     = _rng.nextDouble(),
        startY     = _rng.nextDouble() * 0.4,
        velocityX  = (_rng.nextDouble() - 0.5) * 0.4,
        velocityY  = -_rng.nextDouble() * 0.6 - 0.2,
        rotation   = (_rng.nextDouble() - 0.5) * 6,
        size       = _rng.nextDouble() * 10 + 4,
        color      = _colors[_rng.nextInt(_colors.length)],
        isCircle   = _rng.nextBool();
}
