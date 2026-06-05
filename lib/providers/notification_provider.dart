import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// A single notification entry for display in the notification history.
class NotificationEntry {
  final String streakId;
  final String title;
  final String body;
  final String emoji;
  final DateTime receivedAt;
  bool isRead;

  NotificationEntry({
    required this.streakId,
    required this.title,
    required this.body,
    this.emoji = '🔥',
    required this.receivedAt,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'streakId': streakId,
        'title': title,
        'body': body,
        'emoji': emoji,
        'receivedAt': receivedAt.toIso8601String(),
        'isRead': isRead,
      };

  factory NotificationEntry.fromJson(Map<String, dynamic> json) {
    return NotificationEntry(
      streakId: json['streakId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      emoji: json['emoji'] ?? '🔥',
      receivedAt: DateTime.tryParse(json['receivedAt'] ?? '') ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }
}

/// Manages notification history — persisted via SharedPreferences.
class NotificationProvider extends ChangeNotifier {
  List<NotificationEntry> _notifications = [];
  static const String _storageKey = 'notification_history';

  List<NotificationEntry> get notifications => _notifications;

  /// Today's notifications only.
  List<NotificationEntry> get todayNotifications {
    final now = DateTime.now();
    return _notifications
        .where((n) =>
            n.receivedAt.year == now.year &&
            n.receivedAt.month == now.month &&
            n.receivedAt.day == now.day)
        .toList()
      ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
  }

  /// Count of unread notifications today.
  int get unreadCount =>
      todayNotifications.where((n) => !n.isRead).length;

  bool get hasUnread => unreadCount > 0;

  /// Load saved notification history from SharedPreferences.
  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null) {
        final List<dynamic> jsonList = json.decode(jsonStr);
        _notifications =
            jsonList.map((j) => NotificationEntry.fromJson(j)).toList();

        // Prune entries older than 7 days
        final cutoff = DateTime.now().subtract(const Duration(days: 7));
        _notifications =
            _notifications.where((n) => n.receivedAt.isAfter(cutoff)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading notification history: $e');
    }
  }

  /// Save current notification list to SharedPreferences.
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr =
          json.encode(_notifications.map((n) => n.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (e) {
      debugPrint('Error saving notification history: $e');
    }
  }

  /// Add a notification entry (called when a notification is received or scheduled).
  void addNotification(NotificationEntry entry) {
    // Prevent duplicate entries within 1 minute for the same streak
    final isDuplicate = _notifications.any((n) =>
        n.streakId == entry.streakId &&
        n.receivedAt.difference(entry.receivedAt).inMinutes.abs() < 1);
    if (isDuplicate) return;

    _notifications.add(entry);
    notifyListeners();
    _saveHistory();
  }

  /// Build notification entries from active streaks that have reminders enabled.
  /// This creates "expected" notifications for today based on reminder times.
  void syncFromStreaks(List<dynamic> streaks) {
    final now = DateTime.now();
    for (final streak in streaks) {
      if (streak.reminderEnabled && !streak.isArchived) {
        final time = _parseTimeStr(streak.reminderTime);
        if (time != null) {
          final scheduledTime = DateTime(
            now.year,
            now.month,
            now.day,
            time.hour,
            time.minute,
          );

          // Only add if the scheduled time has already passed today
          if (scheduledTime.isBefore(now)) {
            final entry = NotificationEntry(
              streakId: streak.id,
              title: 'Keep the fire burning! ${streak.emoji}',
              body:
                  'Your "${streak.title}" streak is waiting. Tap to complete it! ⚡',
              emoji: streak.emoji,
              receivedAt: scheduledTime,
            );
            addNotification(entry);
          }
        }
      }
    }
  }

  /// Mark all today's notifications as read.
  void markAllRead() {
    for (final n in todayNotifications) {
      n.isRead = true;
    }
    notifyListeners();
    _saveHistory();
  }

  /// Mark a single notification as read.
  void markRead(NotificationEntry entry) {
    entry.isRead = true;
    notifyListeners();
    _saveHistory();
  }

  /// Clear all notifications.
  void clearAll() {
    _notifications.clear();
    notifyListeners();
    _saveHistory();
  }

  /// Parse a time string like "8:00 PM" to TimeOfDay.
  TimeOfDay? _parseTimeStr(String timeStr) {
    try {
      final parts = timeStr.trim().split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      if (parts.length > 1) {
        final meridian = parts.last.toUpperCase();
        if (meridian == 'PM' && hour < 12) hour += 12;
        if (meridian == 'AM' && hour == 12) hour = 0;
      }
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }
}
