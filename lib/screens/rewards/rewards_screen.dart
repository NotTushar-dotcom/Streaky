import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streaky/config/app_colors.dart';
import 'package:streaky/config/app_text_styles.dart';
import 'package:streaky/models/achievement_model.dart';
import 'package:streaky/providers/user_provider.dart';
import 'package:streaky/providers/streak_provider.dart';
import 'package:streaky/widgets/fire_mascot.dart';
import 'widgets/achievement_card.dart';
import 'widgets/badge_grid.dart';

/// Screen 5 — Rewards & Achievements
///
/// Gamification center: hero banner, tab bar for achievements/badges.
class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final streakProvider = context.watch<StreakProvider>();
    final user = userProvider.user;
    final streaks = streakProvider.activeStreaks;

    final mascotLevel = streakProvider.overallBestStreak >= 30
        ? 4
        : streakProvider.overallBestStreak >= 14
            ? 3
            : streakProvider.overallBestStreak >= 7
                ? 2
                : 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Center(
                  child: Text('Rewards', style: AppTextStyles.heading2),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Hero banner with teal/cyan gradient
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1A3A4A),
                        Color(0xFF1E2D3D),
                        Color(0xFF162230),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.cyanHighlight.withAlpha(20),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You\'re on fire! 🔥',
                              style: AppTextStyles.heading3.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Keep your streaks alive to unlock more rewards.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      FireMascot(size: 72, level: mascotLevel),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Tab bar: Achievements | Badges
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textHint,
                    labelStyle: AppTextStyles.bodyBold.copyWith(fontSize: 14),
                    unselectedLabelStyle:
                        AppTextStyles.body.copyWith(fontSize: 14),
                    tabs: const [
                      Tab(text: 'Achievements'),
                      Tab(text: 'Badges'),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Tab content
            if (_tabController.index == 0)
              // Achievements list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final achievement = Achievements.all[index];
                    final unlocked = user != null
                        ? achievement.isUnlocked(user, streaks)
                        : false;
                    final progress = user != null
                        ? achievement.progress(user, streaks)
                        : 0.0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      child: AchievementCard(
                        achievement: achievement,
                        isUnlocked: unlocked,
                        progress: progress,
                      ),
                    );
                  },
                  childCount: Achievements.all.length,
                ),
              )
            else
              // Badges grid
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: BadgeGrid(
                    badges: [
                      BadgeItem(
                        emoji: '🔥',
                        label: '7 Day',
                        isUnlocked: streakProvider.overallBestStreak >= 7,
                      ),
                      BadgeItem(
                        emoji: '⚡',
                        label: '14 Day',
                        isUnlocked: streakProvider.overallBestStreak >= 14,
                      ),
                      BadgeItem(
                        emoji: '👑',
                        label: '30 Day',
                        isUnlocked: streakProvider.overallBestStreak >= 30,
                      ),
                      BadgeItem(
                        emoji: '💎',
                        label: '100 Day',
                        isUnlocked: streakProvider.overallBestStreak >= 100,
                      ),
                      BadgeItem(
                        emoji: '🌅',
                        label: 'Early Bird',
                        isUnlocked: false,
                      ),
                      BadgeItem(
                        emoji: '🎯',
                        label: 'All Round',
                        isUnlocked: streakProvider.activeStreaks.length >= 3,
                      ),
                      BadgeItem(
                        emoji: '🏆',
                        label: 'Consistent',
                        isUnlocked: streakProvider.totalCheckins >= 50,
                      ),
                      BadgeItem(
                        emoji: '✨',
                        label: 'XP Hunter',
                        isUnlocked: (user?.totalXP ?? 0) >= 1000,
                      ),
                    ],
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
