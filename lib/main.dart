import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/network/supabase_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/hive_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/providers/auth_provider.dart';
import 'features/notifications/services/push_notification_service.dart';
import 'firebase_options.dart';

// Top-level background message handler (required by FCM)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM Background: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase (required for FCM)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Register background handler before anything else
    FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler);
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization failed: $e');
  }

  await HiveStorage.initialize();

  try {
    await SupabaseClientHelper.initialize();
    debugPrint('✅ Supabase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Supabase initialization failed: $e');
  }

  runApp(
    const ProviderScope(
      child: DreamTeamApp(),
    ),
  );
}

/// Root application widget.
class DreamTeamApp extends ConsumerStatefulWidget {
  const DreamTeamApp({super.key});

  @override
  ConsumerState<DreamTeamApp> createState() => _DreamTeamAppState();
}

class _DreamTeamAppState extends ConsumerState<DreamTeamApp> {
  @override
  void initState() {
    super.initState();
    // Init FCM after first frame so Riverpod providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPushNotifications();
    });
  }

  Future<void> _initPushNotifications() async {
    final authState = ref.read(authProvider);
    final userId = authState.user?.uid;
    if (userId == null) return;

    final pushService = ref.read(pushNotificationServiceProvider);
    await pushService.initialize(
      userId: userId,
      onForegroundMessage: (message) {
        // Show in-app snackbar for foreground notifications
        final title = message.notification?.title ?? '';
        final body  = message.notification?.body  ?? '';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  if (body.isNotEmpty)
                    Text(body,
                        style: const TextStyle(color: Colors.white70)),
                ],
              ),
              backgroundColor: const Color(0xFF0F172A),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Local 11',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
