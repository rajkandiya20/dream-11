import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client.dart';
import '../models/notification_model.dart';

/// Repository for notification operations with Supabase.
class NotificationRepository {
  final SupabaseClient _client;
  RealtimeChannel? _subscription;

  NotificationRepository(this._client);

  /// Get user's notifications.
  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final response = await _client
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return (response as List)
          .map((json) =>
              NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get unread notification count.
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _client
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  /// Mark a single notification as read.
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mark all notifications as read for a user.
  Future<bool> markAllAsRead(String userId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a notification.
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .delete()
          .eq('id', notificationId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Subscribe to real-time notifications for a user.
  RealtimeChannel subscribeToNotifications({
    required String userId,
    required void Function(NotificationModel notification) onNewNotification,
  }) {
    _subscription?.unsubscribe();

    _subscription = _client.channel('notifications:$userId').onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {
        final notification = NotificationModel.fromJson(payload.newRecord);
        onNewNotification(notification);
      },
    );

    _subscription!.subscribe();
    return _subscription!;
  }

  /// Unsubscribe from real-time notifications.
  Future<void> unsubscribe() async {
    if (_subscription != null) {
      await _client.removeChannel(_subscription!);
      _subscription = null;
    }
  }
}

/// Provider for the notification repository.
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return NotificationRepository(client);
});
