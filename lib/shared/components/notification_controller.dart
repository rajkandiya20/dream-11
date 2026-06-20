import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'top_notification.dart';

/// State class for a notification event.
class NotificationEvent {
  final String title;
  final String? message;
  final NotificationType type;
  final Duration duration;
  final VoidCallback? onTap;
  final DateTime timestamp;

  NotificationEvent({
    required this.title,
    this.message,
    this.type = NotificationType.info,
    this.duration = const Duration(seconds: 3),
    this.onTap,
  }) : timestamp = DateTime.now();
}

/// Riverpod notifier to trigger notifications app-wide.
class NotificationController extends StateNotifier<NotificationEvent?> {
  NotificationController() : super(null);

  /// Show a success notification.
  void showSuccess({required String title, String? message}) {
    state = NotificationEvent(
      title: title,
      message: message,
      type: NotificationType.success,
    );
  }

  /// Show an error notification.
  void showError({required String title, String? message}) {
    state = NotificationEvent(
      title: title,
      message: message,
      type: NotificationType.error,
    );
  }

  /// Show an info notification.
  void showInfo({required String title, String? message}) {
    state = NotificationEvent(
      title: title,
      message: message,
      type: NotificationType.info,
    );
  }

  /// Show a warning notification.
  void showWarning({required String title, String? message}) {
    state = NotificationEvent(
      title: title,
      message: message,
      type: NotificationType.warning,
    );
  }

  /// Show a custom notification.
  void show({
    required String title,
    String? message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    state = NotificationEvent(
      title: title,
      message: message,
      type: type,
      duration: duration,
      onTap: onTap,
    );
  }

  /// Clear the current notification state.
  void clear() {
    state = null;
  }
}

/// Provider for the notification controller.
final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationEvent?>((ref) {
  return NotificationController();
});

/// Mixin/Widget to listen for notification events and display them.
/// Wrap your app's root widget (or shell) with this to auto-display notifications.
class NotificationListener extends ConsumerStatefulWidget {
  final Widget child;

  const NotificationListener({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<NotificationListener> createState() =>
      _NotificationListenerState();
}

class _NotificationListenerState extends ConsumerState<NotificationListener> {
  @override
  Widget build(BuildContext context) {
    ref.listen<NotificationEvent?>(
      notificationControllerProvider,
      (previous, next) {
        if (next != null) {
          TopNotificationManager.show(
            context,
            title: next.title,
            message: next.message,
            type: next.type,
            duration: next.duration,
            onTap: next.onTap,
          );
        }
      },
    );

    return widget.child;
  }
}
