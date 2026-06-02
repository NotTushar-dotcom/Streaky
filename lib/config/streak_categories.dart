import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Predefined streak categories with emojis and colors.
class StreakCategory {
  final String id;
  final String label;
  final String emoji;
  final Color color;
  final IconData icon;

  const StreakCategory({
    required this.id,
    required this.label,
    required this.emoji,
    required this.color,
    required this.icon,
  });
}

class StreakCategories {
  StreakCategories._();

  static const List<StreakCategory> all = [
    StreakCategory(
      id: 'coding',
      label: 'Coding',
      emoji: '💻',
      color: AppColors.coding,
      icon: Icons.code_rounded,
    ),
    StreakCategory(
      id: 'gym',
      label: 'Gym',
      emoji: '💪',
      color: AppColors.gym,
      icon: Icons.fitness_center_rounded,
    ),
    StreakCategory(
      id: 'learning',
      label: 'Learning',
      emoji: '📚',
      color: AppColors.learning,
      icon: Icons.school_rounded,
    ),
    StreakCategory(
      id: 'reading',
      label: 'Reading',
      emoji: '📖',
      color: AppColors.reading,
      icon: Icons.menu_book_rounded,
    ),
    StreakCategory(
      id: 'meditation',
      label: 'Meditation',
      emoji: '🧘',
      color: AppColors.meditation,
      icon: Icons.self_improvement_rounded,
    ),
    StreakCategory(
      id: 'content_creation',
      label: 'Content Creation',
      emoji: '🎨',
      color: AppColors.contentCreation,
      icon: Icons.brush_rounded,
    ),
    StreakCategory(
      id: 'journaling',
      label: 'Journaling',
      emoji: '📝',
      color: AppColors.journaling,
      icon: Icons.edit_note_rounded,
    ),
    StreakCategory(
      id: 'social_media',
      label: 'Social Media',
      emoji: '📱',
      color: AppColors.socialMedia,
      icon: Icons.share_rounded,
    ),
    StreakCategory(
      id: 'self_improvement',
      label: 'Self Improvement',
      emoji: '🚀',
      color: AppColors.selfImprovement,
      icon: Icons.trending_up_rounded,
    ),
    StreakCategory(
      id: 'general',
      label: 'General',
      emoji: '🔥',
      color: AppColors.general,
      icon: Icons.local_fire_department_rounded,
    ),
  ];

  /// Find category by ID.
  static StreakCategory byId(String id) {
    return all.firstWhere(
      (c) => c.id == id,
      orElse: () => all.last, // defaults to "General"
    );
  }

  /// Find category by label (case-insensitive).
  static StreakCategory byLabel(String label) {
    return all.firstWhere(
      (c) => c.label.toLowerCase() == label.toLowerCase(),
      orElse: () => all.last,
    );
  }
}
