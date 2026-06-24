import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';

/// Background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM Background: ${message.notification?.title}');
}

/// Push notification service using Firebase Messaging.
/// Handles:
///   - FCM token registration per user
///   - Foreground / background / terminated message handling
///   - Sending notifications from admin (via Supabase Edge Function or direct insert)
class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final SupabaseClient _client;

  PushNotificationService(this._client);

  /// Initialize FCM: request permission, get token, register handlers.
  Future<void> initialize({
    required String userId,
    void Function(RemoteMessage)? onForegroundMessage,
    void Function(RemoteMessage)? onMessageOpenedApp,
  }) async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission (iOS + Android 13+)
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('FCM: Permission denied');
      return;
    }

    // Get FCM token and save to DB
    final token = await _fcm.getToken();
    if (token != null) {
      await _saveFcmToken(userId, token);
    }

    // Listen for token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      _saveFcmToken(userId, newToken);
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('FCM Foreground: ${message.notification?.title}');
      onForegroundMessage?.call(message);
      // Also insert into notifications table so in-app shows it
      _insertNotification(userId, message);
    });

    // Notification tapped from background state
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onMessageOpenedApp?.call(message);
    });

    // Notification tapped from terminated state
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      onMessageOpenedApp?.call(initial);
    }
  }

  /// Save FCM token to Supabase `fcm_tokens` table.
  Future<void> _saveFcmToken(String userId, String token) async {
    try {
      await _client.from('fcm_tokens').upsert({
        'user_id': userId,
        'token': token,
        'platform': defaultTargetPlatform.name,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,token');
      debugPrint('FCM token saved for user $userId');
    } catch (e) {
      debugPrint('FCM token save error: $e');
    }
  }

  /// Insert a received FCM message as an in-app notification.
  Future<void> _insertNotification(String userId, RemoteMessage msg) async {
    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'title': msg.notification?.title ?? '',
        'message': msg.notification?.body ?? '',
        'type': msg.data['type'] ?? 'general',
        'is_read': false,
        'data': msg.data,
      });
    } catch (_) {}
  }

  /// Send a broadcast notification to all users by inserting into
  /// `notifications` table (Supabase realtime pushes it to all subscribers).
  /// Also stores FCM send request in `notification_queue` for Edge Function to process.
  Future<void> sendBroadcast({
    required String title,
    required String message,
    required String type, // 'match', 'lineup', 'offer', 'general'
    Map<String, dynamic>? data,
  }) async {
    try {
      // Queue for FCM broadcast via Edge Function
      await _client.from('notification_queue').insert({
        'title': title,
        'message': message,
        'type': type,
        'data': data ?? {},
        'status': 'pending',
      });
    } catch (e) {
      debugPrint('Broadcast notification error: $e');
    }
  }

  /// Send notification to specific user.
  Future<void> sendToUser({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        'is_read': false,
        'data': data ?? {},
      });
    } catch (e) {
      debugPrint('Send notification error: $e');
    }
  }
}

/// Provider for push notification service.
final pushNotificationServiceProvider =
    Provider<PushNotificationService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return PushNotificationService(client);
});
