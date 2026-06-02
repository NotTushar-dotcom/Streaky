import 'package:flutter/material.dart';
import 'package:streaky/config/app_colors.dart';
import 'package:streaky/config/app_text_styles.dart';
import 'package:streaky/widgets/fire_mascot.dart';

/// Mascot evolution preview showing 4 levels.
class MascotEvolution extends StatelessWidget {
  final int currentLevel;

  const MascotEvolution({super.key, this.currentLevel = 1});

  static const _levelNames = [
    'Newbie Fire',
    'Growing Fire',
    'On Fire',
    'Legendary',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mascot Evolution', style: AppTextStyles.heading4),
        const SizedBox(height: 4),
        Text(
          'Your mascot grows with your journey!',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            final level = index + 1;
            final isUnlocked = level <= currentLevel;
            final isActive = level == currentLevel;

            return Column(
              children: [
                // Mascot
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isUnlocked ? 1.0 : 0.3,
                  child: Container(
                    decoration: isActive
                        ? BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: AppColors.subtleGlow(
                              AppColors.primaryOrange,
                            ),
                          )
                        : null,
                    child: FireMascot(
                      size: 56,
                      level: level,
                      animate: isActive,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Label
                Text(
                  'Lv. $level',
                  style: AppTextStyles.caption.copyWith(
                    color: isActive
                        ? AppColors.primaryOrange
                        : isUnlocked
                            ? AppColors.textSecondary
                            : AppColors.textHint,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                Text(
                  _levelNames[index],
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 9,
                    color: isActive
                        ? AppColors.primaryOrange
                        : AppColors.textHint,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
