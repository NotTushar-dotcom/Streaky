import 'package:flutter/material.dart';
import 'package:streaky/config/app_colors.dart';
import 'package:streaky/config/app_text_styles.dart';

/// Motivational tone selector (Gentle / Energetic / Strict).
class ToneSelector extends StatelessWidget {
  final String selectedTone;
  final ValueChanged<String> onSelected;

  const ToneSelector({
    super.key,
    required this.selectedTone,
    required this.onSelected,
  });

  static const _tones = [
    _Tone(id: 'gentle', label: 'Gentle', emoji: '🌸', color: AppColors.cyanHighlight),
    _Tone(id: 'energetic', label: 'Energetic', emoji: '⚡', color: AppColors.primaryOrange),
    _Tone(id: 'strict', label: 'Strict', emoji: '🔥', color: AppColors.error),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _tones.map((tone) {
        final isSelected = selectedTone == tone.id;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(tone.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? tone.color.withAlpha(20)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? tone.color : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(tone.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 6),
                  Text(
                    tone.label,
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected ? tone.color : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Tone {
  final String id;
  final String label;
  final String emoji;
  final Color color;

  const _Tone({
    required this.id,
    required this.label,
    required this.emoji,
    required this.color,
  });
}
