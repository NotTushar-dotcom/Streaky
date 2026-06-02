import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:streaky/providers/streak_provider.dart';
import 'package:streaky/screens/splash/splash_screen.dart';
import 'package:streaky/screens/auth/auth_screen.dart';
import 'package:streaky/screens/main_shell.dart';
import 'package:streaky/screens/home/home_screen.dart';
import 'package:streaky/screens/streaks/streaks_screen.dart';
import 'package:streaky/screens/stats/stats_screen.dart';
import 'package:streaky/screens/rewards/rewards_screen.dart';
import 'package:streaky/screens/profile/profile_screen.dart';
import 'package:streaky/screens/reminders/reminders_screen.dart';
import 'package:streaky/models/streak_model.dart';
import 'package:streaky/screens/streaks/streak_details_screen.dart';

/// App-wide router configuration using GoRouter.
class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // Splash screen (fullscreen, no bottom nav)
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth screen (fullscreen, no bottom nav)
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),

      // Reminders screen (fullscreen, no bottom nav)
      GoRoute(
        path: '/reminders',
        builder: (context, state) => const RemindersScreen(),
      ),

      // Streak details screen (fullscreen, no bottom nav)
      GoRoute(
        path: '/streak-details',
        builder: (context, state) {
          final streak = state.extra as StreakModel?;
          if (streak != null) {
            return StreakDetailsScreen(streak: streak);
          }
          
          final streakId = state.uri.queryParameters['id'];
          if (streakId != null) {
            final streakProvider = context.read<StreakProvider>();
            final foundStreak = streakProvider.streaks.firstWhere(
              (s) => s.id == streakId,
              orElse: () => StreakModel(
                id: streakId,
                title: streakId,
                emoji: '🔥',
                category: 'general',
                color: '#FF8A00',
                frequency: 'daily',
                reminderTime: '8:00 PM',
              ),
            );
            return StreakDetailsScreen(streak: foundStreak);
          }
          
          return const Scaffold(body: Center(child: Text('No streak selected')));
        },
      ),

      // Main shell with bottom navigation
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/streaks',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StreaksScreen(),
            ),
          ),
          GoRoute(
            path: '/stats',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StatsScreen(),
            ),
          ),
          GoRoute(
            path: '/rewards',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RewardsScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}
