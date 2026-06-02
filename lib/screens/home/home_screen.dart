import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streaky/config/app_colors.dart';
import 'package:streaky/config/app_text_styles.dart';
import 'package:streaky/providers/auth_provider.dart';
import 'package:streaky/providers/user_provider.dart';
import 'package:streaky/providers/streak_provider.dart';
import 'package:go_router/go_router.dart';
import 'widgets/greeting_header.dart';
import 'widgets/streak_summary_card.dart';
import 'widgets/today_streak_card.dart';

/// Screen 2 — Home Dashboard
///
/// Daily motivation center showing greeting, streak summary,
/// your streaks list, and check-in button.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final streakProvider = context.watch<StreakProvider>();

    final userName = userProvider.user?.name ?? 
        authProvider.user?.displayName ?? 'Streaker';
    final activeStreaks = streakProvider.activeStreaks;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: streakProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryOrange,
                ),
              )
            : RefreshIndicator(
                color: AppColors.primaryOrange,
                backgroundColor: AppColors.surface,
                onRefresh: () async {
                  if (authProvider.isLoggedIn) {
                    streakProvider.init(authProvider.uid);
                  }
                },
                child: Column(
                  children: [
                    // Scrollable content
                    Expanded(
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        slivers: [
                          // Greeting header (menu + bell + greeting text)
                          SliverToBoxAdapter(
                            child: GreetingHeader(
                              userName: userName,
                              bestStreak: streakProvider.overallBestStreak,
                            ),
                          ),

                          const SliverToBoxAdapter(
                              child: SizedBox(height: 16)),

                          // Streak summary card with mascot overlay
                          SliverToBoxAdapter(
                            child: StreakSummaryCard(
                              totalStreaks: streakProvider.overallCurrentStreak,
                              bestStreak: streakProvider.overallBestStreak,
                              totalCheckins: streakProvider.totalCheckins,
                            ),
                          ),

                          const SliverToBoxAdapter(
                              child: SizedBox(height: 24)),

                          // "Your Streaks" section header
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                'Your Streaks',
                                style: AppTextStyles.heading4,
                              ),
                            ),
                          ),

                          const SliverToBoxAdapter(
                              child: SizedBox(height: 8)),

                          // Streak list
                          if (activeStreaks.isEmpty)
                            SliverToBoxAdapter(
                              child: _EmptyStreaksHint(),
                            )
                          else
                            SliverReorderableList(
                              itemCount: activeStreaks.length,
                              itemBuilder: (context, index) {
                                final streak = activeStreaks[index];
                                return ReorderableDelayedDragStartListener(
                                  key: ValueKey(streak.id),
                                  index: index,
                                  child: GestureDetector(
                                    onTap: () {
                                      context.push('/streak-details', extra: streak);
                                    },
                                    child: TodayStreakCard(
                                      streak: streak,
                                      justCheckedIn: streakProvider
                                              .lastCheckedInStreakId ==
                                          streak.id,
                                      onCheckIn: streak.completedToday
                                          ? null
                                          : () {
                                              streakProvider.checkIn(
                                                authProvider.uid,
                                                streak.id,
                                              );
                                              // Add XP
                                              userProvider.addXP(
                                                authProvider.uid,
                                                UserProvider.xpPerCheckin,
                                              );
                                            },
                                    ),
                                  ),
                                );
                              },
                              onReorderItem: (oldIndex, newIndex) {
                                streakProvider.reorderStreaks(
                                  authProvider.uid,
                                  oldIndex,
                                  newIndex,
                                );
                              },
                            ),

                          const SliverToBoxAdapter(
                              child: SizedBox(height: 16)),
                        ],
                      ),
                    ),

                    // Bottom "+ Check In" button
                    _CheckInButton(
                      onPressed: () {
                        // Check in all pending streaks or show streak selection
                        final pending = streakProvider.pendingToday;
                        if (pending.isNotEmpty) {
                          for (final streak in pending) {
                            streakProvider.checkIn(
                              authProvider.uid,
                              streak.id,
                            );
                            userProvider.addXP(
                              authProvider.uid,
                              UserProvider.xpPerCheckin,
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _EmptyStreaksHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.accentPurple.withAlpha(30),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              'No streaks yet!',
              style: AppTextStyles.heading4,
            ),
            const SizedBox(height: 6),
            Text(
              'Head to the Streaks tab to create your first streak.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-width gradient "+ Check In" button at the bottom.
class _CheckInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CheckInButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF8A00),
                Color(0xFFFF6B6B),
                Color(0xFFFF1493),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF8A00).withAlpha(40),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                'Check In',
                style: AppTextStyles.button.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
