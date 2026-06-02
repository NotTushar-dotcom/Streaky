import 'dart:async';
import 'package:flutter/material.dart';
import 'package:streaky/models/user_model.dart';
import 'package:streaky/services/firestore_service.dart';

/// User state provider — manages current user data and XP/level system.
class UserProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _user;
  StreamSubscription? _userSubscription;

  UserModel? get user => _user;
  bool get hasUser => _user != null;

  // ─── XP & Level Constants ─────────────────────────────────────────────────

  /// XP required per level = base * level multiplier.
  static const int xpPerCheckin = 10;
  static const int xpStreakBonus7 = 50;
  static const int xpStreakBonus14 = 100;
  static const int xpStreakBonus30 = 250;

  /// XP needed to reach a given level.
  static int xpForLevel(int level) => level * 100;

  /// Current level based on total XP.
  static int levelFromXP(int totalXP) {
    int level = 1;
    int xpAccumulated = 0;
    while (xpAccumulated + xpForLevel(level) <= totalXP) {
      xpAccumulated += xpForLevel(level);
      level++;
    }
    return level;
  }

  /// XP progress within current level (0.0 to 1.0).
  double get levelProgress {
    if (_user == null) return 0.0;
    int level = 1;
    int xpAccumulated = 0;
    while (xpAccumulated + xpForLevel(level) <= _user!.totalXP) {
      xpAccumulated += xpForLevel(level);
      level++;
    }
    final xpInCurrentLevel = _user!.totalXP - xpAccumulated;
    return xpInCurrentLevel / xpForLevel(level);
  }

  /// XP remaining to next level.
  int get xpToNextLevel {
    if (_user == null) return 100;
    int level = 1;
    int xpAccumulated = 0;
    while (xpAccumulated + xpForLevel(level) <= _user!.totalXP) {
      xpAccumulated += xpForLevel(level);
      level++;
    }
    return xpForLevel(level) - (_user!.totalXP - xpAccumulated);
  }

  // ─── Init / Dispose ───────────────────────────────────────────────────────

  /// Start listening to user data.
  void init(String uid) {
    _userSubscription?.cancel();
    _userSubscription = _firestoreService.streamUser(uid).listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  /// Add XP to the user and update level if needed.
  Future<void> addXP(String uid, int amount) async {
    if (_user == null) return;
    final newTotalXP = _user!.totalXP + amount;
    final newLevel = levelFromXP(newTotalXP);

    await _firestoreService.updateUser(uid, {
      'totalXP': newTotalXP,
      'currentLevel': newLevel,
      'lastActive': DateTime.now(),
    });
  }

  /// Update user profile fields.
  Future<void> updateProfile(
      String uid, Map<String, dynamic> updates) async {
    await _firestoreService.updateUser(uid, updates);
  }

  /// Clear user data on sign out.
  void clear() {
    _userSubscription?.cancel();
    _user = null;
    notifyListeners();
  }
}
