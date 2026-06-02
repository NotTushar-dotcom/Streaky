import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'config/app_theme.dart';
import 'config/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/streak_provider.dart';
import 'services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Notification Service and Request Permissions
  final notificationService = NotificationService();
  await notificationService.init();
  final granted = await notificationService.requestPermissions();
  debugPrint('Notification permissions granted: $granted');

  if (granted) {
    try {
      final now = tz.TZDateTime.now(tz.local);
      final testScheduledDate = now.add(const Duration(seconds: 15));
      final id = 'Leetcode Daily'.hashCode & 0x7FFFFFFF;
      await notificationService.scheduleTestReminder(
        id: id,
        title: 'Leetcode Daily',
        emoji: '💻',
        scheduledDate: testScheduledDate,
      );
    } catch (e) {
      debugPrint('Failed to schedule test reminder: $e');
    }
  }

  // Register notification click handler
  NotificationService.onNotificationClick = (streakId) {
    debugPrint('App opened from notification click. Navigating to streak: $streakId');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppRouter.router.push('/streak-details?id=${Uri.encodeComponent(streakId)}');
    });
  };

  // Check if notification launched the app
  try {
    final launchDetails = await notificationService.getLaunchDetails();
    if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
      final payload = launchDetails.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) {
        debugPrint('App launched via notification click. Navigating to streak: $payload');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppRouter.router.push('/streak-details?id=${Uri.encodeComponent(payload)}');
        });
      }
    }
  } catch (e) {
    debugPrint('Error handling notification launch details: $e');
  }

  // Lock to portrait mode (mobile only, not supported on web)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF16142E),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  // Initialize Firebase — wrapped in try/catch so the app still
  // launches even if Firebase connection fails (e.g. no internet).
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('⚠️ Firebase init failed: $e');
    debugPrint('App will run in offline/demo mode.');
  }

  runApp(const StreakyApp());
}

class StreakyApp extends StatelessWidget {
  const StreakyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => StreakProvider()),
      ],
      child: MaterialApp.router(
        title: 'Streaky',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
