import 'package:flutter/material.dart';
import 'package:streaky/config/app_colors.dart';
import 'package:streaky/config/app_text_styles.dart';

/// Badge grid for displaying earned/locked badges.
class BadgeGrid extends StatelessWidget {
  final List<BadgeItem> badges;

  const BadgeGrid({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return _BadgeCell(badge: badge);
      },
    );
  }
}

class BadgeItem {
  final String emoji;
  final String label;
  final bool isUnlocked;

  const BadgeItem({
    required this.emoji,
    required this.label,
    this.isUnlocked = false,
  });
}

class _BadgeCell extends StatelessWidget {
  final BadgeItem badge;

  const _BadgeCell({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: badge.isUnlocked
                ? AppColors.primaryOrange.withAlpha(20)
                : AppColors.surfaceLight.withAlpha(120),
            borderRadius: BorderRadius.circular(14),
            border: badge.isUnlocked
                ? Border.all(
                    color: AppColors.primaryOrange.withAlpha(60),
                    width: 1.5,
                  )
                : null,
            boxShadow: badge.isUnlocked
                ? AppColors.subtleGlow(AppColors.primaryOrange)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            badge.emoji,
            style: TextStyle(
              fontSize: 26,
              color: badge.isUnlocked ? null : AppColors.textHint,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          badge.label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 10,
            color: badge.isUnlocked
                ? AppColors.textSecondary
                : AppColors.textHint,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
