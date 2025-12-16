import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile_app/features/auth/data/auth_repository.dart';
import 'package:mobile_app/features/profile/data/user_repository.dart';

/// User data model
class User {
  final String id;
  final String name;
  final String? avatarUrl;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['fullName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Profile stats model
class ProfileStats {
  final double totalStudyHours;
  final int tasksCompleted;
  final int streakDays;

  ProfileStats({
    required this.totalStudyHours,
    required this.tasksCompleted,
    required this.streakDays,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      totalStudyHours: (json['totalStudyHours'] as num).toDouble(),
      tasksCompleted: json['tasksCompleted'] as int,
      streakDays: json['streakDays'] as int,
    );
  }
}

/// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Provider for AuthRepository (to get token)
final authRepositoryForProfileProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// FutureProvider for user profile data
final userProfileProvider = FutureProvider<User>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  final authRepo = ref.watch(authRepositoryForProfileProvider);
  
  // Get token to extract user ID if needed, but we'll use /users/me endpoint
  final profileData = await repository.getProfile();
  return User.fromJson(profileData);
});

/// FutureProvider for profile stats
final profileStatsProvider = FutureProvider<ProfileStats>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  final statsData = await repository.getProfileStats();
  return ProfileStats.fromJson(statsData);
});

/// Combined provider for user data with stats (for easy access in UI)
final userWithStatsProvider = FutureProvider<({User user, ProfileStats stats})>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  final stats = await ref.watch(profileStatsProvider.future);
  return (user: user, stats: stats);
});

