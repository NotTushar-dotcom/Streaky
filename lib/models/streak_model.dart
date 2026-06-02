import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a streak (habit) tracked by a user.
///
/// Stored at: `users/{userId}/streaks/{streakId}`
class StreakModel {
  final String id;
  final String title;
  final String emoji;
  final String category;
  final String color;
  final int currentStreak;
  final int bestStreak;
  final int totalCheckins;
  final String frequency;
  final bool completedToday;
  final DateTime? lastCheckIn;
  final DateTime createdAt;
  final bool reminderEnabled;
  final String reminderTime;
  final bool isArchived;
  final int position;

  StreakModel({
    required this.id,
    required this.title,
    this.emoji = '🔥',
    this.category = 'general',
    this.color = '#9B5CFF',
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalCheckins = 0,
    this.frequency = 'daily',
    this.completedToday = false,
    this.lastCheckIn,
    DateTime? createdAt,
    this.reminderEnabled = false,
    this.reminderTime = '8:00 PM',
    this.isArchived = false,
    this.position = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'emoji': emoji,
      'category': category,
      'color': color,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'totalCheckins': totalCheckins,
      'frequency': frequency,
      'completedToday': completedToday,
      'lastCheckIn':
          lastCheckIn != null ? Timestamp.fromDate(lastCheckIn!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime,
      'isArchived': isArchived,
      'position': position,
    };
  }

  /// Create a StreakModel from a Firestore document snapshot.
  factory StreakModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StreakModel(
      id: doc.id,
      title: data['title'] ?? '',
      emoji: data['emoji'] ?? '🔥',
      category: data['category'] ?? 'general',
      color: data['color'] ?? '#9B5CFF',
      currentStreak: data['currentStreak'] ?? 0,
      bestStreak: data['bestStreak'] ?? 0,
      totalCheckins: data['totalCheckins'] ?? 0,
      frequency: data['frequency'] ?? 'daily',
      completedToday: data['completedToday'] ?? false,
      lastCheckIn: (data['lastCheckIn'] as Timestamp?)?.toDate(),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reminderEnabled: data['reminderEnabled'] ?? false,
      reminderTime: data['reminderTime'] ?? '8:00 PM',
      isArchived: data['isArchived'] ?? false,
      position: data['position'] ?? 0,
    );
  }

  /// Create a copy with updated fields.
  StreakModel copyWith({
    String? title,
    String? emoji,
    String? category,
    String? color,
    int? currentStreak,
    int? bestStreak,
    int? totalCheckins,
    String? frequency,
    bool? completedToday,
    DateTime? lastCheckIn,
    bool? reminderEnabled,
    String? reminderTime,
    bool? isArchived,
    int? position,
  }) {
    return StreakModel(
      id: id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      color: color ?? this.color,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalCheckins: totalCheckins ?? this.totalCheckins,
      frequency: frequency ?? this.frequency,
      completedToday: completedToday ?? this.completedToday,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      createdAt: createdAt,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      isArchived: isArchived ?? this.isArchived,
      position: position ?? this.position,
    );
  }
}
