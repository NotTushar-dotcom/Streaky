import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user in the Streaky app.
///
/// Stored at: `users/{userId}`
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? password;
  final String avatar;
  final int currentLevel;
  final int totalXP;
  final int bestStreak;
  final DateTime joinedAt;
  final String theme;
  final String selectedMascot;
  final DateTime lastActive;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.password,
    this.avatar = 'avatar_1',
    this.currentLevel = 1,
    this.totalXP = 0,
    this.bestStreak = 0,
    DateTime? joinedAt,
    this.theme = 'arcade_dopamine',
    this.selectedMascot = 'fire_default',
    DateTime? lastActive,
  })  : joinedAt = joinedAt ?? DateTime.now(),
        lastActive = lastActive ?? DateTime.now();

  /// Convert to Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'password': password,
      'avatar': avatar,
      'currentLevel': currentLevel,
      'totalXP': totalXP,
      'bestStreak': bestStreak,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'theme': theme,
      'selectedMascot': selectedMascot,
      'lastActive': Timestamp.fromDate(lastActive),
    };
  }

  /// Create a UserModel from a Firestore document snapshot.
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      password: data['password'],
      avatar: data['avatar'] ?? 'avatar_1',
      currentLevel: data['currentLevel'] ?? 1,
      totalXP: data['totalXP'] ?? 0,
      bestStreak: data['bestStreak'] ?? 0,
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      theme: data['theme'] ?? 'arcade_dopamine',
      selectedMascot: data['selectedMascot'] ?? 'fire_default',
      lastActive:
          (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create a copy with updated fields.
  UserModel copyWith({
    String? name,
    String? email,
    String? password,
    String? avatar,
    int? currentLevel,
    int? totalXP,
    int? bestStreak,
    String? theme,
    String? selectedMascot,
    DateTime? lastActive,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      avatar: avatar ?? this.avatar,
      currentLevel: currentLevel ?? this.currentLevel,
      totalXP: totalXP ?? this.totalXP,
      bestStreak: bestStreak ?? this.bestStreak,
      joinedAt: joinedAt,
      theme: theme ?? this.theme,
      selectedMascot: selectedMascot ?? this.selectedMascot,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
