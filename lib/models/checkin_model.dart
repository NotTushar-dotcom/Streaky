import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single check-in for a streak.
///
/// Stored at: `users/{userId}/streaks/{streakId}/checkins/{checkinId}`
class CheckinModel {
  final String id;
  final String date; // Format: 'YYYY-MM-DD'
  final bool completed;
  final DateTime? completedAt;
  final String method;
  final String mood;

  CheckinModel({
    required this.id,
    required this.date,
    this.completed = true,
    this.completedAt,
    this.method = 'manual',
    this.mood = 'neutral',
  });

  /// Convert to Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'completed': completed,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'method': method,
      'mood': mood,
    };
  }

  /// Create a CheckinModel from a Firestore document snapshot.
  factory CheckinModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CheckinModel(
      id: doc.id,
      date: data['date'] ?? '',
      completed: data['completed'] ?? true,
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      method: data['method'] ?? 'manual',
      mood: data['mood'] ?? 'neutral',
    );
  }

  /// Create a copy with updated fields.
  CheckinModel copyWith({
    String? date,
    bool? completed,
    DateTime? completedAt,
    String? method,
    String? mood,
  }) {
    return CheckinModel(
      id: id,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      method: method ?? this.method,
      mood: mood ?? this.mood,
    );
  }
}
