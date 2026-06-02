import 'package:flutter/material.dart';
import 'package:streaky/config/app_colors.dart';
import 'package:streaky/config/app_text_styles.dart';
import 'package:streaky/models/achievement_model.dart';
import 'package:streaky/widgets/glassmorphic_container.dart';

/// Individual achievement card with progress indicator.
/// Shows green checkmark when completed, or "X/Y" text + progress bar when in progress.
class AchievementCard extends StatelessWidget {
  final AchievementModel achievement;
  final bool isUnlocked;
  final double progress;

  const AchievementCard({
    super.key,
    required this.achievement,
    required this.isUnlocked,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate current/required values for display
    final currentValue = (progress * achievement.requiredValue).round();
    final requiredValue = achievement.requiredValue;
    final glowColor = isUnlocked ? AppColors.limeSuccess : null;

    return GlassmorphicContainer(
      borderRadius: 16,
      glowColor: glowColor,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          // Emoji badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.primaryOrange.withAlpha(20)
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              achievement.emoji,
              style: TextStyle(
                fontSize: 22,
                color: isUnlocked ? null : AppColors.textHint,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info: title, description, progress bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: AppTextStyles.bodyBold.copyWith(
                    color: isUnlocked
                        ? AppColors.textPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isUnlocked) ...[
                  const SizedBox(height: 8),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.surfaceLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress > 0.7
                            ? AppColors.primaryOrange
                            : AppColors.error,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Progress text or check
          if (isUnlocked)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.limeSuccess,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 18,
              ),
            )
          else
            Text(
              '$currentValue/$requiredValue',
              style: AppTextStyles.bodyBold.copyWith(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }
}
