import 'package:flutter/material.dart';
import 'package:streaky/config/app_colors.dart';
import 'package:streaky/config/app_text_styles.dart';

/// XP progress bar showing current level and progress to next.
class XpProgressBar extends StatelessWidget {
  final int currentLevel;
  final int totalXP;
  final double progress; // 0.0 to 1.0
  final int xpToNext;

  const XpProgressBar({
    super.key,
    required this.currentLevel,
    required this.totalXP,
    required this.progress,
    required this.xpToNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentPurple.withAlpha(30),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Level badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Lv. $currentLevel',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$totalXP XP',
                style: AppTextStyles.bodyBold.copyWith(
                  color: AppColors.accentPurple,
                ),
              ),
              const Spacer(),
              Text(
                '$xpToNext XP to next',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppColors.surfaceLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.accentPurple,
                  ),
                  minHeight: 8,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
