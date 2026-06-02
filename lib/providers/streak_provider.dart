import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:streaky/models/streak_model.dart';
import 'package:streaky/models/checkin_model.dart';
import 'package:streaky/services/firestore_service.dart';
import 'package:streaky/services/notification_service.dart';

/// Central state management for streaks.
class StreakProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<StreakModel> _streaks = [];
  StreamSubscription? _streakSubscription;
  bool _isLoading = false;
  String? _error;

  // Tracks which streak just got checked in (for animation triggers).
  String? _lastCheckedInStreakId;

  // ─── Getters ──────────────────────────────────────────────────────────────

  List<StreakModel> get streaks => _streaks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get lastCheckedInStreakId => _lastCheckedInStreakId;

  /// Streaks that are active (not archived).
  List<StreakModel> get activeStreaks =>
      _streaks.where((s) => !s.isArchived).toList();

  /// Streaks completed today.
  List<StreakModel> get completedToday =>
      _streaks.where((s) => s.completedToday && !s.isArchived).toList();

  /// Streaks NOT yet completed today.
  List<StreakModel> get pendingToday =>
      _streaks.where((s) => !s.completedToday && !s.isArchived).toList();

  /// Total active streak count.
  int get totalActiveStreaks => activeStreaks.length;

  /// Total check-ins across all streaks.
  int get totalCheckins =>
      _streaks.fold(0, (acc, s) => acc + s.totalCheckins);

  /// Best streak across all streaks.
  int get overallBestStreak =>
      _streaks.fold(0, (max, s) => s.bestStreak > max ? s.bestStreak : max);

  /// Current streak across all active streaks.
  int get overallCurrentStreak =>
      _streaks.where((s) => !s.isArchived).fold(0, (max, s) => s.currentStreak > max ? s.currentStreak : max);

  /// Today's completion rate (0.0 to 1.0).
  double get todayCompletionRate {
    if (activeStreaks.isEmpty) return 0.0;
    return completedToday.length / activeStreaks.length;
  }

  /// Weekly consistency: list of 7 booleans (Mon to Sun).
  /// True if at least one streak was completed that day.
  List<bool> get weeklyConsistency {
    final now = DateTime.now();
    // Monday = 1, Sunday = 7
    final mondayOffset = now.weekday - 1;
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: mondayOffset));

    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      if (day.isAfter(now)) return false;

      // Check if any active streak was completed on this day
      return _streaks.any((s) {
        if (s.lastCheckIn == null || s.isArchived) return false;
        final lastCheckInDate = DateTime(
          s.lastCheckIn!.year,
          s.lastCheckIn!.month,
          s.lastCheckIn!.day,
        );
        final targetDate = DateTime(day.year, day.month, day.day);
        final daysDiff = lastCheckInDate.difference(targetDate).inDays;
        return daysDiff >= 0 && daysDiff < s.currentStreak;
      });
    });
  }

  /// Filter streaks by category.
  List<StreakModel> byCategory(String category) =>
      activeStreaks.where((s) => s.category == category).toList();

  // ─── Init / Dispose ───────────────────────────────────────────────────────

  /// Start listening to streaks for a user.
  void init(String uid) async {
    _isLoading = true;
    notifyListeners();

    // Programmatically delete "Posting every day on X" and cancel its reminder
    try {
      final userName = await _firestoreService.getUserName(uid);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userName)
          .collection('streaks')
          .doc("Posting every day on X")
          .delete();
      await NotificationService().cancelStreakReminder("Posting every day on X");
    } catch (e) {
      debugPrint('Error deleting "Posting every day on X": $e');
    }

    _streakSubscription?.cancel();
    _streakSubscription =
        _firestoreService.streamAllStreaks(uid).listen((streaks) {
      final sortedStreaks = List<StreakModel>.from(streaks);
      sortedStreaks.sort((a, b) {
        if (a.position != b.position) {
          return a.position.compareTo(b.position);
        }
        return b.createdAt.compareTo(a.createdAt);
      });
      _streaks = sortedStreaks;
      _isLoading = false;
      _error = null;
      notifyListeners();
      
      // Auto-sync daily check-ins and streaks
      _syncStreakStates(uid, sortedStreaks);
      // Auto-sync notifications
      _syncNotifications(sortedStreaks);
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  // ─── Daily/Weekly Check-In Sync Helpers ───────────────────────────────

  DateTime _startOfDay(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isYesterday(DateTime lastCheckIn, DateTime now) {
    final date1 = _startOfDay(lastCheckIn);
    final date2 = _startOfDay(now);
    return date2.difference(date1).inDays == 1;
  }

  int _calendarDaysDifference(DateTime a, DateTime b) {
    return _startOfDay(b).difference(_startOfDay(a)).inDays;
  }

  DateTime _startOfWeek(DateTime dt) {
    final mondayOffset = dt.weekday - 1;
    return DateTime(dt.year, dt.month, dt.day).subtract(Duration(days: mondayOffset));
  }

  /// Evaluates and corrects each streak's completedToday and currentStreak properties.
  Future<void> _syncStreakStates(String uid, List<StreakModel> streaks) async {
    // Seed/Update "Posting every day on X" streak as requested (Disabled)
    // await _checkAndSeedXStreak(uid, streaks);

    final now = DateTime.now();
    for (final streak in streaks) {
      if (streak.title.toLowerCase() == "posting every day on x") {
        continue;
      }
      bool expectedCompletedToday = false;
      int expectedCurrentStreak = streak.currentStreak;

      if (streak.frequency == 'daily') {
        if (streak.lastCheckIn == null) {
          expectedCompletedToday = false;
          expectedCurrentStreak = 0;
        } else if (_isSameDay(streak.lastCheckIn!, now)) {
          expectedCompletedToday = true;
        } else if (_isYesterday(streak.lastCheckIn!, now)) {
          expectedCompletedToday = false;
        } else {
          expectedCompletedToday = false;
          expectedCurrentStreak = 0;
        }
      } else if (streak.frequency == 'weekdays') {
        final weekday = now.weekday; // 1 = Monday, ..., 7 = Sunday
        if (weekday == 6 || weekday == 7) {
          // Weekend: check-in is excused/optional.
          // Setting completedToday = true keeps the user dashboard clean and avoids false breaks.
          expectedCompletedToday = true;
        } else {
          // Weekday
          if (streak.lastCheckIn == null) {
            expectedCompletedToday = false;
            expectedCurrentStreak = 0;
          } else if (_isSameDay(streak.lastCheckIn!, now)) {
            expectedCompletedToday = true;
          } else {
            // Check if last check-in was the last required weekday
            if (weekday == 1) {
              // Monday: last check-in must be Friday, Saturday, or Sunday.
              final daysDiff = _calendarDaysDifference(streak.lastCheckIn!, now);
              if (daysDiff <= 3 && daysDiff >= 1) {
                expectedCompletedToday = false;
              } else {
                expectedCompletedToday = false;
                expectedCurrentStreak = 0;
              }
            } else {
              // Tuesday-Friday: last check-in must be yesterday
              if (_isYesterday(streak.lastCheckIn!, now)) {
                expectedCompletedToday = false;
              } else {
                expectedCompletedToday = false;
                expectedCurrentStreak = 0;
              }
            }
          }
        }
      } else if (streak.frequency == 'weekly') {
        if (streak.lastCheckIn == null) {
          expectedCompletedToday = false;
          expectedCurrentStreak = 0;
        } else {
          final nowWeek = _startOfWeek(now);
          final checkInWeek = _startOfWeek(streak.lastCheckIn!);
          final diffDays = nowWeek.difference(checkInWeek).inDays;
          if (diffDays == 0) {
            expectedCompletedToday = true; // Completed this week
          } else if (diffDays == 7) {
            expectedCompletedToday = false; // Pending check-in for the new week
          } else {
            expectedCompletedToday = false;
            expectedCurrentStreak = 0; // Missed the previous week completely
          }
        }
      }

      // If database values are outdated, update them in Firestore
      if (streak.completedToday != expectedCompletedToday ||
          streak.currentStreak != expectedCurrentStreak) {
        debugPrint('Syncing streak "${streak.title}": '
            'completedToday: ${streak.completedToday} -> $expectedCompletedToday, '
            'currentStreak: ${streak.currentStreak} -> $expectedCurrentStreak');
        
        await _firestoreService.updateStreak(uid, streak.id, {
          'completedToday': expectedCompletedToday,
          'currentStreak': expectedCurrentStreak,
        });
      }
    }
  }



  /// Syncs local scheduled notifications with the current streaks from Firestore.
  Future<void> _syncNotifications(List<StreakModel> streaks) async {
    final notificationService = NotificationService();
    
    // 1. Clean up scheduled notifications for deleted or archived streaks
    final activeEnabledStreakIds = streaks
        .where((s) => s.reminderEnabled && !s.isArchived)
        .map((s) => s.id)
        .toList();
    await notificationService.syncActiveNotifications(activeEnabledStreakIds);

    // 2. Schedule or update notifications for active enabled streaks
    for (final streak in streaks) {
      if (streak.reminderEnabled && !streak.isArchived) {
        await notificationService.scheduleStreakReminder(
          streakId: streak.id,
          title: streak.title,
          emoji: streak.emoji,
          timeStr: streak.reminderTime,
        );
      }
    }
  }

  @override
  void dispose() {
    _streakSubscription?.cancel();
    super.dispose();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────
  
  /// Reorder active streaks list and save new positions to Firestore.
  Future<void> reorderStreaks(String uid, int oldIndex, int newIndex) async {
    final list = List<StreakModel>.from(activeStreaks);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    try {
      final userName = await _firestoreService.getUserName(uid);
      final batch = FirebaseFirestore.instance.batch();
      
      for (int i = 0; i < list.length; i++) {
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userName)
            .collection('streaks')
            .doc(list[i].id);
        batch.update(docRef, {'position': i});
      }
      
      await batch.commit();

      // Temporarily update local positions cache for immediate visual response
      final Map<String, int> positions = {};
      for (int i = 0; i < list.length; i++) {
        positions[list[i].id] = i;
      }
      
      _streaks.sort((a, b) {
        final posA = positions[a.id] ?? a.position;
        final posB = positions[b.id] ?? b.position;
        if (posA != posB) {
          return posA.compareTo(posB);
        }
        return b.createdAt.compareTo(a.createdAt);
      });
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Check in a streak.
  Future<void> checkIn(String uid, String streakId) async {
    try {
      final today = DateTime.now();
      final dateString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final checkin = CheckinModel(
        id: '', // auto-generated
        date: dateString,
        completed: true,
        completedAt: today,
        method: 'manual',
        mood: 'neutral',
      );

      await _firestoreService.addCheckin(
        uid: uid,
        streakId: streakId,
        checkin: checkin,
      );

      _lastCheckedInStreakId = streakId;
      notifyListeners();

      // Clear the animation trigger after a delay
      Future.delayed(const Duration(seconds: 2), () {
        _lastCheckedInStreakId = null;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Create a new streak.
  Future<String?> addStreak(String uid, StreakModel streak) async {
    try {
      final id = await _firestoreService.createStreak(uid, streak);
      return id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Delete a streak permanently.
  Future<void> deleteStreak(String uid, String streakId) async {
    try {
      await _firestoreService.deleteStreak(uid, streakId);
      await NotificationService().cancelStreakReminder(streakId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Archive a streak.
  Future<void> archiveStreak(String uid, String streakId) async {
    try {
      await _firestoreService.archiveStreak(uid, streakId);
      await NotificationService().cancelStreakReminder(streakId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Update a streak.
  Future<void> updateStreak(
    String uid,
    String streakId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestoreService.updateStreak(uid, streakId, data);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Clear data on sign out.
  void clear() {
    _streakSubscription?.cancel();
    _streaks = [];
    notifyListeners();
  }
}
