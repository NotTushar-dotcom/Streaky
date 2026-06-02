import 'package:flutter/material.dart';
import 'package:streaky/config/app_text_styles.dart';

/// Color theme selector grid.
class ThemeSelector extends StatelessWidget {
  final String selectedTheme;
  final ValueChanged<String> onSelected;

  const ThemeSelector({
    super.key,
    required this.selectedTheme,
    required this.onSelected,
  });

  static const _themes = [
    _ThemeOption(id: 'arcade_dopamine', label: 'Arcade', colors: [Color(0xFFFF8A00), Color(0xFF9B5CFF)]),
    _ThemeOption(id: 'midnight_cyan', label: 'Midnight', colors: [Color(0xFF2FE6FF), Color(0xFF0B0A1F)]),
    _ThemeOption(id: 'neon_lime', label: 'Neon', colors: [Color(0xFFA8FF60), Color(0xFF16142E)]),
    _ThemeOption(id: 'sunset_glow', label: 'Sunset', colors: [Color(0xFFFF6B9D), Color(0xFFFF8A00)]),
    _ThemeOption(id: 'galaxy', label: 'Galaxy', colors: [Color(0xFF9B5CFF), Color(0xFF2FE6FF)]),
    _ThemeOption(id: 'minimal', label: 'Minimal', colors: [Color(0xFF9896B0), Color(0xFF0B0A1F)]),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Themes', style: AppTextStyles.heading4),
        const SizedBox(height: 4),
        Text('Customize your experience', style: AppTextStyles.bodySmall),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _themes.length,
            itemBuilder: (context, index) {
              final theme = _themes[index];
              final isSelected = selectedTheme == theme.id;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => onSelected(theme.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: theme.colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: theme.colors.first.withAlpha(80),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Center(
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ThemeOption {
  final String id;
  final String label;
  final List<Color> colors;

  const _ThemeOption({
    required this.id,
    required this.label,
    required this.colors,
  });
}
