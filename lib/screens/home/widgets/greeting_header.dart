import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streaky/config/app_colors.dart';
import 'package:streaky/config/app_text_styles.dart';
import 'package:streaky/providers/notification_provider.dart';
import 'package:streaky/providers/streak_provider.dart';
import 'notification_history_sheet.dart';

/// Greeting header with hamburger menu, bell, and time-based message.
class GreetingHeader extends StatelessWidget {
  final String userName;
  final int bestStreak;

  const GreetingHeader({
    super.key,
    required this.userName,
    this.bestStreak = 0,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _dailyQuote {
    final quotes = [
      "Small daily improvements over time lead to stunning results. ⚡",
      "Consistency is what transforms average into excellence. 🔥",
      "Success is the sum of small efforts, repeated day in and day out. 🎯",
      "Don't break the chain. Everyday consistency is key. 🔗",
      "Your habits build your future. Keep the fire burning! 🌟",
      "Discipline is choosing between what you want now and what you want most. 🧠",
      "The secret of your future is hidden in your daily routine. 📅",
      "It is not what we do once in a while that shapes our lives, but what we do consistently. 💫",
      "Great things are done by a series of small things brought together. 🧩",
      "Habits are the compound interest of self-improvement. 📈",
      "Consistency is the true foundation of trust in yourself. 🤝",
      "Show up today. That's all you need to do. 🙌",
      "Action is the foundational key to all success. 🚀",
      "One day at a time. One habit at a time. 🏆",
      "The only bad habit is the one that didn't happen today. 💪",
      "Energy flows where attention goes. Focus on your streaks! ⚡",
      "Believe you can and you're halfway there. 🌅",
      "Be stronger than your excuses. 💥",
      "Do something today that your future self will thank you for. 🙏",
      "Don't wish for it. Work for it. 🛠️",
      "It always seems impossible until it's done. 🏆",
      "You don't have to be perfect, you just have to be consistent. 💖"
    ];
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return quotes[dayOfYear % quotes.length];
  }

  @override
  Widget build(BuildContext context) {
    final streakProvider = context.watch<StreakProvider>();
    final notificationProvider = context.watch<NotificationProvider>();

    // Sync notification history with active streaks on every build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        notificationProvider.syncFromStreaks(streakProvider.activeStreaks);
      }
    });

    final hasUnread = notificationProvider.hasUnread;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Quote text Column on the left
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_greeting, $userName! 👋',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 6),
                Text(
                  _dailyQuote,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Interactive bell icon on the right
          GestureDetector(
            onTap: () => NotificationHistorySheet.show(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_rounded,
                    color: AppColors.primaryOrange,
                    size: 22,
                  ),
                  if (hasUnread)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
