import 'package:flutter/material.dart';
import 'package:streaky/config/app_colors.dart';
import 'package:streaky/config/app_text_styles.dart';
import 'package:streaky/config/streak_categories.dart';
import 'package:streaky/models/streak_model.dart';
import 'package:streaky/widgets/glassmorphic_container.dart';

/// Individual streak card for the home "Your Streaks" section.
/// Shows category icon, name, weekly dots, streak count + fire emoji.
class TodayStreakCard extends StatelessWidget {
  final StreakModel streak;
  final VoidCallback? onCheckIn;
  final bool justCheckedIn;

  const TodayStreakCard({
    super.key,
    required this.streak,
    this.onCheckIn,
    this.justCheckedIn = false,
  });

  @override
  Widget build(BuildContext context) {
    final category = StreakCategories.byId(streak.category);
    final glowColor = category.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GlassmorphicContainer(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        glowColor: glowColor,
        child: Row(
          children: [
            // Category icon circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: glowColor.withAlpha(25),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                streak.emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(width: 12),

            // Name + weekly dots
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    streak.title,
                    style: AppTextStyles.bodyBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Weekly colored dots
                  _WeeklyDotsRow(
                    color: glowColor,
                    streak: streak,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Streak count + fire
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${streak.currentStreak}',
                  style: AppTextStyles.statNumber.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(
                  Icons.local_fire_department_rounded,
                  color: streak.completedToday
                      ? AppColors.primaryOrange
                      : AppColors.primaryOrange.withValues(alpha: 0.25),
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Small inline weekly dots for each streak card.
class _WeeklyDotsRow extends StatelessWidget {
  final Color color;
  final StreakModel streak;

  const _WeeklyDotsRow({
    required this.color,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    // Generate 7 dots for the week (Mon-Sun)
    final now = DateTime.now();
    final mondayOffset = now.weekday - 1;
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: mondayOffset));

    return Row(
      children: List.generate(7, (i) {
        final day = monday.add(Duration(days: i));
        final isFuture = day.isAfter(now);

        // Check if streak was active on this day
        bool isCompleted = false;
        if (!isFuture && streak.lastCheckIn != null) {
          // Calculate the difference in calendar days between last check-in and this day
          final lastCheckInDate = DateTime(
            streak.lastCheckIn!.year,
            streak.lastCheckIn!.month,
            streak.lastCheckIn!.day,
          );
          final targetDate = DateTime(day.year, day.month, day.day);
          final daysDiff = lastCheckInDate.difference(targetDate).inDays;

          // If the day is on or before lastCheckIn, and falls within the current streak count
          isCompleted = daysDiff >= 0 && daysDiff < streak.currentStreak;
        }

        return Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? color
                : isFuture
                    ? Colors.white.withAlpha(20)
                    : Colors.white.withAlpha(50),
            border: Border.all(
              color: isCompleted
                  ? Colors.transparent
                  : isFuture
                      ? Colors.white.withAlpha(45)
                      : Colors.white.withAlpha(120),
              width: 1,
            ),
          ),
        );
      }),
    );
  }
}
