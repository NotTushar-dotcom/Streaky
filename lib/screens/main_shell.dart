import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:streaky/config/app_colors.dart';
import 'package:streaky/config/app_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bottom navigation shell wrapping all main tab screens.
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  // Tab configuration
  static const _tabs = [
    _TabItem(path: '/home', icon: Icons.home_rounded, label: 'Today'),
    _TabItem(path: '/stats', icon: Icons.bar_chart_rounded, label: 'Stats'),
    _TabItem(path: '/streaks', icon: Icons.local_fire_department_rounded, label: 'Streaks'),
    _TabItem(path: '/rewards', icon: Icons.emoji_events_rounded, label: 'Rewards'),
    _TabItem(path: '/profile', icon: Icons.person_rounded, label: 'Profile'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.surfaceLight.withAlpha(80),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (index) {
                final tab = _tabs[index];
                final isActive = index == currentIndex;

                return _NavItem(
                  icon: tab.icon,
                  label: tab.label,
                  isActive: isActive,
                  onTap: () {
                    // Close any open bottom sheet/dialog on the shell navigator
                    final shellNavigator = AppRouter.shellNavigatorKey.currentState;
                    if (shellNavigator != null && shellNavigator.canPop()) {
                      shellNavigator.pop();
                    }

                    // Close any open bottom sheet/dialog on the root navigator
                    final rootNavigator = AppRouter.rootNavigatorKey.currentState;
                    if (rootNavigator != null && rootNavigator.canPop()) {
                      rootNavigator.pop();
                    }

                    context.go(tab.path);
                  },
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final String path;
  final IconData icon;
  final String label;

  const _TabItem({
    required this.path,
    required this.icon,
    required this.label,
  });
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryOrange.withAlpha(20)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with glow effect when active
            Container(
              decoration: isActive
                  ? BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryOrange.withAlpha(80),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ],
                    )
                  : null,
              child: Icon(
                icon,
                color: isActive
                    ? AppColors.primaryOrange
                    : AppColors.textHint,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            // Label
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppColors.primaryOrange
                    : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
