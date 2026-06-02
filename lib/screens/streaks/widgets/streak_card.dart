import 'package:flutter/material.dart';
import 'package:streaky/config/app_colors.dart';
import 'package:streaky/config/app_text_styles.dart';
import 'package:streaky/config/streak_categories.dart';
import 'package:streaky/models/streak_model.dart';
import 'package:streaky/widgets/glassmorphic_container.dart';

/// Streak card for the "My Streaks" grid/list.
class StreakCard extends StatelessWidget {
  final StreakModel streak;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const StreakCard({
    super.key,
    required this.streak,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final category = StreakCategories.byId(streak.category);
    final color = category.color;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: GlassmorphicContainer(
        borderRadius: 20,
        glowColor: color,
        padding: const EdgeInsets.all(16),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: emoji + streak count with fire icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  streak.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
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
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.primaryOrange,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Title
          Text(
            streak.title,
            style: AppTextStyles.bodyBold,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Category label
          Text(
            category.label,
            style: AppTextStyles.caption.copyWith(color: color),
          ),

          const SizedBox(height: 8),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: streak.bestStreak > 0
                  ? (streak.currentStreak / streak.bestStreak).clamp(0.0, 1.0)
                  : 0.0,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    ),
  );
}
}
