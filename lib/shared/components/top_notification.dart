import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Notification type enum for different visual states.
enum NotificationType { success, error, info, warning }

/// Data class representing a notification.
class NotificationData {
  final String title;
  final String? message;
  final NotificationType type;
  final Duration duration;
  final VoidCallback? onTap;

  const NotificationData({
    required this.title,
    this.message,
    this.type = NotificationType.info,
    this.duration = const Duration(seconds: 3),
    this.onTap,
  });
}

/// Custom notification overlay system with animated entry/exit from top safe area,
/// blur background, swipe dismiss, and success/error/info/warning states.
class TopNotificationOverlay extends StatefulWidget {
  final NotificationData data;
  final VoidCallback onDismiss;

  const TopNotificationOverlay({
    super.key,
    required this.data,
    required this.onDismiss,
  });

  @override
  State<TopNotificationOverlay> createState() => _TopNotificationOverlayState();
}

class _TopNotificationOverlayState extends State<TopNotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _blurAnimation;

  double _dragOffset = 0;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _blurAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    // Auto-dismiss after duration
    Future.delayed(widget.data.duration, () {
      if (mounted && !_isDismissed) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_isDismissed) return;
    _isDismissed = true;
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  Color get _backgroundColor {
    switch (widget.data.type) {
      case NotificationType.success:
        return AppColors.success;
      case NotificationType.error:
        return AppColors.error;
      case NotificationType.info:
        return AppColors.info;
      case NotificationType.warning:
        return AppColors.warning;
    }
  }

  Color get _lightColor {
    switch (widget.data.type) {
      case NotificationType.success:
        return AppColors.successLight;
      case NotificationType.error:
        return AppColors.errorLight;
      case NotificationType.info:
        return AppColors.infoLight;
      case NotificationType.warning:
        return AppColors.warningLight;
    }
  }

  IconData get _icon {
    switch (widget.data.type) {
      case NotificationType.success:
        return Icons.check_circle_rounded;
      case NotificationType.error:
        return Icons.error_rounded;
      case NotificationType.info:
        return Icons.info_rounded;
      case NotificationType.warning:
        return Icons.warning_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Blur background overlay
            if (_fadeAnimation.value > 0)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _dismiss,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _blurAnimation.value * 0.3,
                      sigmaY: _blurAnimation.value * 0.3,
                    ),
                    child: Container(
                      color: Colors.black.withOpacity(
                        _fadeAnimation.value * 0.1,
                      ),
                    ),
                  ),
                ),
              ),
            // Notification card
            Positioned(
              top: topPadding + 8,
              left: 16,
              right: 16,
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.translate(
                    offset: Offset(0, _dragOffset),
                    child: GestureDetector(
                      onVerticalDragUpdate: (details) {
                        setState(() {
                          _dragOffset += details.delta.dy;
                          if (_dragOffset > 0) _dragOffset = 0;
                        });
                      },
                      onVerticalDragEnd: (details) {
                        if (_dragOffset < -40 ||
                            details.velocity.pixelsPerSecond.dy < -200) {
                          _dismiss();
                        } else {
                          setState(() {
                            _dragOffset = 0;
                          });
                        }
                      },
                      onTap: () {
                        widget.data.onTap?.call();
                        _dismiss();
                      },
                      child: _buildNotificationCard(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(
          color: _lightColor.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _backgroundColor.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _backgroundColor.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Icon(
              _icon,
              color: _backgroundColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.data.title,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.data.message != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.data.message!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Close button
          GestureDetector(
            onTap: _dismiss,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper widget to show top notifications using an Overlay.
class TopNotificationManager {
  TopNotificationManager._();

  static OverlayEntry? _currentEntry;

  /// Show a notification at the top of the screen.
  static void show(
    BuildContext context, {
    required String title,
    String? message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    // Dismiss existing notification
    _currentEntry?.remove();
    _currentEntry = null;

    final overlayState = Overlay.of(context);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => TopNotificationOverlay(
        data: NotificationData(
          title: title,
          message: message,
          type: type,
          duration: duration,
          onTap: onTap,
        ),
        onDismiss: () {
          entry.remove();
          if (_currentEntry == entry) {
            _currentEntry = null;
          }
        },
      ),
    );

    _currentEntry = entry;
    overlayState.insert(entry);
  }

  /// Show a success notification.
  static void success(BuildContext context, {required String title, String? message}) {
    show(context, title: title, message: message, type: NotificationType.success);
  }

  /// Show an error notification.
  static void error(BuildContext context, {required String title, String? message}) {
    show(context, title: title, message: message, type: NotificationType.error);
  }

  /// Show an info notification.
  static void info(BuildContext context, {required String title, String? message}) {
    show(context, title: title, message: message, type: NotificationType.info);
  }

  /// Show a warning notification.
  static void warning(BuildContext context, {required String title, String? message}) {
    show(context, title: title, message: message, type: NotificationType.warning);
  }

  /// Dismiss the current notification.
  static void dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}
