import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:streaky/config/app_colors.dart';
import 'package:streaky/config/app_text_styles.dart';
import 'package:streaky/providers/auth_provider.dart';
import 'package:streaky/providers/user_provider.dart';
import 'package:streaky/providers/streak_provider.dart';
import 'widgets/profile_header.dart';
import 'widgets/theme_selector.dart';
import 'widgets/settings_list.dart';

/// Screen 7 — Profile & Customization
///
/// Profile header, stats, theme selector, and settings.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedTheme = 'arcade_dopamine';

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final streakProvider = context.watch<StreakProvider>();
    final user = userProvider.user;

    final mascotLevel = streakProvider.overallBestStreak >= 30
        ? 4
        : streakProvider.overallBestStreak >= 14
            ? 3
            : streakProvider.overallBestStreak >= 7
                ? 2
                : 1;

    // Calculate the longest current streak
    final longestCurrent = streakProvider.activeStreaks.isNotEmpty
        ? streakProvider.activeStreaks
            .map((s) => s.currentStreak)
            .reduce((a, b) => a > b ? a : b)
        : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Centered top app bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textPrimary,
                          size: 22,
                        ),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/home');
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Profile',
                          style: AppTextStyles.heading3,
                        ),
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.settings_rounded,
                          color: AppColors.textPrimary,
                          size: 22,
                        ),
                        onPressed: () => _showSignOutDialog(context, authProvider),
                      ),
                    ),
                  ],
                ),
              ),

              // Profile header
              ProfileHeader(
                name: user?.name ??
                    authProvider.user?.displayName ??
                    'Streaker',
                email: user?.email ??
                    authProvider.user?.email ??
                    '',
                currentStreak: longestCurrent,
                bestStreak: streakProvider.overallBestStreak,
                totalCheckins: streakProvider.totalCheckins,
                mascotLevel: mascotLevel,
              ),

              const SizedBox(height: 28),

              // Theme selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ThemeSelector(
                  selectedTheme: user?.theme ?? _selectedTheme,
                  onSelected: (theme) {
                    setState(() => _selectedTheme = theme);
                    if (authProvider.isLoggedIn) {
                      userProvider.updateProfile(
                        authProvider.uid,
                        {'theme': theme},
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 28),

              // Account section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Account', style: AppTextStyles.heading4),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SettingsList(
                  onReminders: () => context.push('/reminders'),
                  onExportData: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Export coming soon!',
                          style: AppTextStyles.body,
                        ),
                        backgroundColor: AppColors.surface,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  onAbout: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Streaky',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2026 Streaky',
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          'Build streaks. Build you.',
                          style: AppTextStyles.body,
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('Sign Out', style: AppTextStyles.heading4),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              authProvider.signOut();
              context.go('/splash');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
