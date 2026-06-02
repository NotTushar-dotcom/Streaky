import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:streaky/models/user_model.dart';
import 'package:streaky/models/streak_model.dart';
import 'package:streaky/models/checkin_model.dart';

/// Handles all Firestore CRUD operations for Streaky.
///
/// Firestore structure:
/// ```
/// users/{userId}
/// users/{userId}/streaks/{streakId}
/// users/{userId}/streaks/{streakId}/checkins/{checkinId}
/// ```
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // In-memory cache for mapping Firebase Auth UIDs to user names (which serve as Firestore document IDs)
  static final Map<String, String> _uidToNameCache = {};

  /// Helper to resolve the user's document ID (name) from their Firebase Auth UID.
  Future<String> getUserName(String uid) async {
    if (_uidToNameCache.containsKey(uid)) {
      return _uidToNameCache[uid]!;
    }
    final snapshot = await _usersRef.where('uid', isEqualTo: uid).limit(1).get();
    if (snapshot.docs.isEmpty) return uid; // fallback
    final name = snapshot.docs.first.id;
    _uidToNameCache[uid] = name;
    return name;
  }

  // ===========================================================================
  // USERS — users/{userId}
  // ===========================================================================

  /// Reference to the users collection.
  CollectionReference get _usersRef => _db.collection('users');

  /// Create a new user document. Uses the user's name as the document ID.
  Future<void> createUser(UserModel user) async {
    final docId = user.name.trim();
    await _usersRef.doc(docId).set(user.toMap());
    _uidToNameCache[user.uid] = docId;
  }

  /// Get a user by their UID. Returns null if not found.
  Future<UserModel?> getUser(String uid) async {
    final userName = await getUserName(uid);
    final doc = await _usersRef.doc(userName).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Update specific fields on a user document.
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    final userName = await getUserName(uid);
    // Convert DateTime values to Timestamps for Firestore
    final firestoreData = data.map((key, value) {
      if (value is DateTime) {
        return MapEntry(key, Timestamp.fromDate(value));
      }
      return MapEntry(key, value);
    });
    await _usersRef.doc(userName).update(firestoreData);
  }

  /// Stream a user document in real-time.
  Stream<UserModel?> streamUser(String uid) {
    return _usersRef
        .where('uid', isEqualTo: uid)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return UserModel.fromFirestore(snapshot.docs.first);
    });
  }

  // ===========================================================================
  // STREAKS — users/{userId}/streaks/{streakId}
  // ===========================================================================

  /// Reference to a user's streaks subcollection.
  CollectionReference _streaksRef(String userName) {
    return _usersRef.doc(userName).collection('streaks');
  }

  /// Create a new streak. Uses the streak's title as the document ID.
  Future<String> createStreak(String uid, StreakModel streak) async {
    final userName = await getUserName(uid);
    final docId = streak.title.trim();
    await _streaksRef(userName).doc(docId).set(streak.toMap());
    return docId;
  }

  /// Get a single streak by ID.
  Future<StreakModel?> getStreak(String uid, String streakId) async {
    final userName = await getUserName(uid);
    final doc = await _streaksRef(userName).doc(streakId).get();
    if (!doc.exists) return null;
    return StreakModel.fromFirestore(doc);
  }

  /// Stream all active (non-archived) streaks for a user, ordered by creation.
  Stream<List<StreakModel>> streamStreaks(String uid) {
    return Stream.fromFuture(getUserName(uid)).asyncExpand((userName) {
      return _streaksRef(userName)
          .where('isArchived', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => StreakModel.fromFirestore(doc))
              .toList());
    });
  }

  /// Stream all streaks (including archived) for a user.
  Stream<List<StreakModel>> streamAllStreaks(String uid) {
    return Stream.fromFuture(getUserName(uid)).asyncExpand((userName) {
      return _streaksRef(userName)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => StreakModel.fromFirestore(doc))
              .toList());
    });
  }

  /// Update specific fields on a streak document.
  Future<void> updateStreak(
    String uid,
    String streakId,
    Map<String, dynamic> data,
  ) async {
    final userName = await getUserName(uid);
    final firestoreData = data.map((key, value) {
      if (value is DateTime) {
        return MapEntry(key, Timestamp.fromDate(value));
      }
      return MapEntry(key, value);
    });

    final String? newTitle = data['title']?.toString().trim();
    if (newTitle != null && newTitle != streakId) {
      // Renaming: Copy to new doc with newTitle ID and delete old doc
      final oldDocRef = _streaksRef(userName).doc(streakId);
      final newDocRef = _streaksRef(userName).doc(newTitle);

      final oldDoc = await oldDocRef.get();
      if (oldDoc.exists) {
        final Map<String, dynamic> oldData = oldDoc.data() as Map<String, dynamic>;
        final mergedData = {...oldData, ...firestoreData};

        // Write the new document with new ID
        await newDocRef.set(mergedData);

        // Copy checkins subcollection
        final checkinsSnapshot = await oldDocRef.collection('checkins').get();
        final batch = _db.batch();
        for (final checkinDoc in checkinsSnapshot.docs) {
          final newCheckinRef = newDocRef.collection('checkins').doc(checkinDoc.id);
          batch.set(newCheckinRef, checkinDoc.data());
          batch.delete(checkinDoc.reference);
        }
        // Delete the old document
        batch.delete(oldDocRef);
        await batch.commit();
        return;
      }
    }

    // Normal update (no renaming)
    await _streaksRef(userName).doc(streakId).update(firestoreData);
  }

  /// Delete a streak and all its checkins.
  Future<void> deleteStreak(String uid, String streakId) async {
    final userName = await getUserName(uid);
    // First delete all checkins in the subcollection
    final checkins = await _checkinsRef(userName, streakId).get();
    final batch = _db.batch();
    for (final doc in checkins.docs) {
      batch.delete(doc.reference);
    }
    // Then delete the streak itself
    batch.delete(_streaksRef(userName).doc(streakId));
    await batch.commit();
  }

  /// Archive a streak (soft delete).
  Future<void> archiveStreak(String uid, String streakId) async {
    await updateStreak(uid, streakId, {'isArchived': true});
  }

  // ===========================================================================
  // CHECKINS — users/{userId}/streaks/{streakId}/checkins/{checkinId}
  // ===========================================================================

  /// Reference to a streak's checkins subcollection.
  CollectionReference _checkinsRef(String userName, String streakId) {
    return _streaksRef(userName).doc(streakId).collection('checkins');
  }

  /// Add a check-in and update the parent streak's counters.
  /// This is the core action of the entire app.
  Future<void> addCheckin({
    required String uid,
    required String streakId,
    required CheckinModel checkin,
  }) async {
    final userName = await getUserName(uid);
    final batch = _db.batch();

    // 1. Add the checkin document
    final docId = (checkin.completedAt ?? DateTime.now()).toIso8601String();
    final checkinRef = _checkinsRef(userName, streakId).doc(docId);
    batch.set(checkinRef, checkin.toMap());

    // 2. Update the parent streak
    final streakRef = _streaksRef(userName).doc(streakId);
    batch.update(streakRef, {
      'completedToday': true,
      'lastCheckIn': Timestamp.fromDate(DateTime.now()),
      'totalCheckins': FieldValue.increment(1),
      'currentStreak': FieldValue.increment(1),
    });

    await batch.commit();

    // 3. Check if currentStreak > bestStreak and update if needed
    final updatedStreak = await getStreak(uid, streakId);
    if (updatedStreak != null &&
        updatedStreak.currentStreak > updatedStreak.bestStreak) {
      await updateStreak(uid, streakId, {
        'bestStreak': updatedStreak.currentStreak,
      });

      // Also update user's bestStreak if this is their all-time best
      final user = await getUser(uid);
      if (user != null && updatedStreak.currentStreak > user.bestStreak) {
        await updateUser(uid, {
          'bestStreak': updatedStreak.currentStreak,
        });
      }
    }
  }

  /// Get all check-ins for a streak, ordered by date.
  Future<List<CheckinModel>> getCheckins(String uid, String streakId) async {
    final userName = await getUserName(uid);
    final snapshot = await _checkinsRef(userName, streakId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => CheckinModel.fromFirestore(doc)).toList();
  }

  /// Stream check-ins for a streak in real-time.
  Stream<List<CheckinModel>> streamCheckins(String uid, String streakId) {
    return Stream.fromFuture(getUserName(uid)).asyncExpand((userName) {
      return _checkinsRef(userName, streakId)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => CheckinModel.fromFirestore(doc))
              .toList());
    });
  }

  /// Get check-ins within a date range (useful for heatmaps & analytics).
  Future<List<CheckinModel>> getCheckinsByDateRange({
    required String uid,
    required String streakId,
    required String startDate,
    required String endDate,
  }) async {
    final userName = await getUserName(uid);
    final snapshot = await _checkinsRef(userName, streakId)
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .orderBy('date')
        .get();
    return snapshot.docs.map((doc) => CheckinModel.fromFirestore(doc)).toList();
  }

  /// Check if a streak has been completed today.
  Future<bool> hasCheckedInToday(String uid, String streakId) async {
    final userName = await getUserName(uid);
    final today = DateTime.now();
    final dateString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final snapshot = await _checkinsRef(userName, streakId)
        .where('date', isEqualTo: dateString)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }
}
