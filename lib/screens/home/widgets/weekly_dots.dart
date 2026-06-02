import 'package:flutter/material.dart';
import 'package:streaky/config/app_colors.dart';
import 'package:streaky/config/app_text_styles.dart';

/// Weekly consistency dots (Mon–Sun).
///
/// Filled dot = at least one streak completed that day.
class WeeklyDots extends StatelessWidget {
  final List<bool> days; // 7 booleans, Mon to Sun

  const WeeklyDots({super.key, required this.days});

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday - 1; // 0 = Monday

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week',
            style: AppTextStyles.label,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isCompleted = index < days.length && days[index];
              final isToday = index == today;
              final isFuture = index > today;

              return Column(
                children: [
                  // Dot
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppColors.limeSuccess
                          : isFuture
                              ? AppColors.surfaceLight.withAlpha(100)
                              : AppColors.surfaceLight,
                      border: isToday
                          ? Border.all(
                              color: AppColors.primaryOrange,
                              width: 2,
                            )
                          : null,
                      boxShadow: isCompleted
                          ? [
                              BoxShadow(
                                color: AppColors.limeSuccess.withAlpha(60),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.background,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Day label
                  Text(
                    _dayLabels[index],
                    style: AppTextStyles.caption.copyWith(
                      color: isToday
                          ? AppColors.primaryOrange
                          : isCompleted
                              ? AppColors.limeSuccess
                              : AppColors.textHint,
                      fontWeight:
                          isToday ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
