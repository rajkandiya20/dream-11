import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

/// Notification state.
class NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? errorMessage;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// Get notifications filtered by type.
  List<NotificationModel> getByType(NotificationType type) {
    return notifications.where((n) => n.type == type).toList();
  }

  /// Get unread notifications.
  List<NotificationModel> get unreadNotifications {
    return notifications.where((n) => !n.isRead).toList();
  }

  bool get hasUnread => unreadCount > 0;
}

/// Notification state notifier with real-time subscription.
class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;
  final String? _userId;

  NotificationNotifier(this._repository, this._userId)
      : super(const NotificationState()) {
    if (_userId != null) {
      _init();
    }
  }

  /// Initialize: load notifications and set up real-time subscription.
  Future<void> _init() async {
    await loadNotifications();
    _setupRealtimeSubscription();
  }

  /// Load all notifications.
  Future<void> loadNotifications() async {
    if (_userId == null) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final notifications = await _repository.getNotifications(_userId!);
      final unreadCount = await _repository.getUnreadCount(_userId!);

      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load notifications.',
      );
    }
  }

  /// Set up real-time subscription for new notifications.
  void _setupRealtimeSubscription() {
    if (_userId == null) return;

    _repository.subscribeToNotifications(
      userId: _userId!,
      onNewNotification: (notification) {
        state = state.copyWith(
          notifications: [notification, ...state.notifications],
          unreadCount: state.unreadCount + 1,
        );
      },
    );
  }

  /// Mark a notification as read.
  Future<void> markAsRead(String notificationId) async {
    final success = await _repository.markAsRead(notificationId);
    if (success) {
      state = state.copyWith(
        notifications: state.notifications
            .map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n)
            .toList(),
        unreadCount: (state.unreadCount - 1).clamp(0, 9999),
      );
    }
  }

  /// Mark all notifications as read.
  Future<void> markAllAsRead() async {
    if (_userId == null) return;

    final success = await _repository.markAllAsRead(_userId!);
    if (success) {
      state = state.copyWith(
        notifications:
            state.notifications.map((n) => n.copyWith(isRead: true)).toList(),
        unreadCount: 0,
      );
    }
  }

  /// Delete a notification.
  Future<void> deleteNotification(String notificationId) async {
    final notification =
        state.notifications.firstWhere((n) => n.id == notificationId);
    final success = await _repository.deleteNotification(notificationId);
    if (success) {
      state = state.copyWith(
        notifications:
            state.notifications.where((n) => n.id != notificationId).toList(),
        unreadCount: notification.isRead
            ? state.unreadCount
            : (state.unreadCount - 1).clamp(0, 9999),
      );
    }
  }

  /// Refresh notifications.
  Future<void> refresh() async {
    await loadNotifications();
  }

  @override
  void dispose() {
    _repository.unsubscribe();
    super.dispose();
  }
}

/// Provider for notification state.
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  final authState = ref.watch(authProvider);
  final userId = authState.user?.id;
  return NotificationNotifier(repository, userId);
});

/// Provider for unread count (convenient access).
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).unreadCount;
});

/// Provider for whether there are unread notifications.
final hasUnreadNotificationsProvider = Provider<bool>((ref) {
  return ref.watch(notificationProvider).hasUnread;
});
