import 'package:streaky/models/streak_model.dart';
import 'package:streaky/models/user_model.dart';

/// Represents an achievement/badge that can be unlocked.
class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final AchievementType type;
  final int requiredValue;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.type,
    required this.requiredValue,
  });

  /// Check if this achievement is unlocked based on user data.
  bool isUnlocked(UserModel user, List<StreakModel> streaks) {
    switch (type) {
      case AchievementType.streakDays:
        return streaks.any((s) => s.bestStreak >= requiredValue);
      case AchievementType.totalCheckins:
        final total = streaks.fold(0, (sum, s) => sum + s.totalCheckins);
        return total >= requiredValue;
      case AchievementType.activeStreaks:
        return streaks.where((s) => !s.isArchived).length >= requiredValue;
      case AchievementType.level:
        return user.currentLevel >= requiredValue;
      case AchievementType.totalXP:
        return user.totalXP >= requiredValue;
      case AchievementType.earlyBird:
        // Would need check-in time data — check if any check-in was before 9 AM
        return user.totalXP >= requiredValue;
      case AchievementType.categories:
        final uniqueCategories = streaks.map((s) => s.category).toSet();
        return uniqueCategories.length >= requiredValue;
    }
  }

  /// Get progress toward this achievement (0.0 to 1.0).
  double progress(UserModel user, List<StreakModel> streaks) {
    int current;
    switch (type) {
      case AchievementType.streakDays:
        current = streaks.fold(0, (max, s) => s.bestStreak > max ? s.bestStreak : max);
        break;
      case AchievementType.totalCheckins:
        current = streaks.fold(0, (sum, s) => sum + s.totalCheckins);
        break;
      case AchievementType.activeStreaks:
        current = streaks.where((s) => !s.isArchived).length;
        break;
      case AchievementType.level:
        current = user.currentLevel;
        break;
      case AchievementType.totalXP:
        current = user.totalXP;
        break;
      case AchievementType.earlyBird:
        current = 0;
        break;
      case AchievementType.categories:
        current = streaks.map((s) => s.category).toSet().length;
        break;
    }
    return (current / requiredValue).clamp(0.0, 1.0);
  }
}

enum AchievementType {
  streakDays,
  totalCheckins,
  activeStreaks,
  level,
  totalXP,
  earlyBird,
  categories,
}

/// All predefined achievements.
class Achievements {
  Achievements._();

  static const List<AchievementModel> all = [
    AchievementModel(
      id: '7_day_streak',
      title: '7 Day Streak',
      description: 'Keep a streak alive for 7 days',
      emoji: '🔥',
      type: AchievementType.streakDays,
      requiredValue: 7,
    ),
    AchievementModel(
      id: '14_day_streak',
      title: '14 Day Streak',
      description: 'Keep a streak alive for 14 days',
      emoji: '⚡',
      type: AchievementType.streakDays,
      requiredValue: 14,
    ),
    AchievementModel(
      id: '30_day_streak',
      title: '30 Day Streak',
      description: 'Keep a streak alive for 30 days',
      emoji: '👑',
      type: AchievementType.streakDays,
      requiredValue: 30,
    ),
    AchievementModel(
      id: '100_day_streak',
      title: 'Century Club',
      description: 'Keep a streak alive for 100 days!',
      emoji: '💎',
      type: AchievementType.streakDays,
      requiredValue: 100,
    ),
    AchievementModel(
      id: 'early_bird',
      title: 'Early Bird',
      description: 'Check in before 9 AM',
      emoji: '🌅',
      type: AchievementType.earlyBird,
      requiredValue: 1,
    ),
    AchievementModel(
      id: 'all_rounder',
      title: 'All Rounder',
      description: 'Maintain 3+ different streaks',
      emoji: '🎯',
      type: AchievementType.activeStreaks,
      requiredValue: 3,
    ),
    AchievementModel(
      id: 'consistency_king',
      title: 'Consistency King',
      description: 'Reach 50 total check-ins',
      emoji: '🏆',
      type: AchievementType.totalCheckins,
      requiredValue: 50,
    ),
    AchievementModel(
      id: 'check_in_centurion',
      title: 'Centurion',
      description: 'Reach 100 total check-ins',
      emoji: '💯',
      type: AchievementType.totalCheckins,
      requiredValue: 100,
    ),
    AchievementModel(
      id: 'explorer',
      title: 'Explorer',
      description: 'Create streaks in 5 different categories',
      emoji: '🗺️',
      type: AchievementType.categories,
      requiredValue: 5,
    ),
    AchievementModel(
      id: 'level_5',
      title: 'Rising Star',
      description: 'Reach Level 5',
      emoji: '⭐',
      type: AchievementType.level,
      requiredValue: 5,
    ),
    AchievementModel(
      id: 'level_10',
      title: 'Streak Master',
      description: 'Reach Level 10',
      emoji: '🌟',
      type: AchievementType.level,
      requiredValue: 10,
    ),
    AchievementModel(
      id: 'xp_1000',
      title: 'XP Hunter',
      description: 'Earn 1,000 total XP',
      emoji: '✨',
      type: AchievementType.totalXP,
      requiredValue: 1000,
    ),
  ];
}
