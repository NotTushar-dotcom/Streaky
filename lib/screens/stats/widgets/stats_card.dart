import 'package:flutter/material.dart';
import 'package:streaky/config/app_text_styles.dart';
import 'package:streaky/widgets/glow_card.dart';
import 'package:streaky/widgets/animated_counter.dart';

/// Individual stat card (used in a row on the stats screen).
class StatsCard extends StatelessWidget {
  final String label;
  final int value;
  final String? suffix;
  final IconData icon;
  final Color color;

  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    this.suffix,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlowCard(
        glowColor: color,
        borderRadius: 16,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            AnimatedCounter(
              value: value,
              suffix: suffix,
              style: AppTextStyles.statNumber.copyWith(
                color: color,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
