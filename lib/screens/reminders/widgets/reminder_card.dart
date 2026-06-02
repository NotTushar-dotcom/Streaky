import 'package:flutter/material.dart';
import 'package:streaky/config/app_colors.dart';
import 'package:streaky/config/app_text_styles.dart';
import 'package:streaky/widgets/glow_card.dart';

/// Reminder card with toggle and time display.
class ReminderCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String time;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const ReminderCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.time,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      glowColor: isEnabled ? AppColors.accentPurple : AppColors.surfaceLight,
      showGlow: isEnabled,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyBold),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: AppTextStyles.caption.copyWith(
                    color: isEnabled
                        ? AppColors.accentPurple
                        : AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}
