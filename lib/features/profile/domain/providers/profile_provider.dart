import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/repositories/profile_repository.dart';

/// Profile state.
class ProfileState {
  final UserModel? user;
  final UserStats stats;
  final List<Achievement> achievements;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;

  const ProfileState({
    this.user,
    this.stats = const UserStats(),
    this.achievements = const [],
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    UserModel? user,
    UserStats? stats,
    List<Achievement>? achievements,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
  }) {
    return ProfileState(
      user: user ?? this.user,
      stats: stats ?? this.stats,
      achievements: achievements ?? this.achievements,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: errorMessage,
    );
  }
}

/// Profile state notifier.
class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;
  final String? _uid;
  final String? _userId;

  ProfileNotifier(this._repository, this._uid, this._userId)
      : super(const ProfileState()) {
    if (_uid != null) {
      loadProfile();
    }
  }

  /// Load user profile and stats.
  Future<void> loadProfile() async {
    if (_uid == null) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = await _repository.getUserProfile(_uid!);
      UserStats stats = const UserStats();
      List<Achievement> achievements = [];

      if (user != null && _userId != null) {
        stats = await _repository.getUserStats(_userId!);
        achievements = _repository.getAchievements(stats);
      }

      state = state.copyWith(
        user: user,
        stats: stats,
        achievements: achievements,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load profile.',
      );
    }
  }

  /// Update profile fields.
  Future<bool> updateProfile({
    String? username,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    if (_uid == null) return false;
    state = state.copyWith(isUpdating: true, errorMessage: null);

    final updatedUser = await _repository.updateProfile(
      uid: _uid!,
      username: username,
      phoneNumber: phoneNumber,
      avatarUrl: avatarUrl,
    );

    if (updatedUser != null) {
      state = state.copyWith(user: updatedUser, isUpdating: false);
      return true;
    } else {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'Failed to update profile.',
      );
      return false;
    }
  }

  /// Refresh profile data.
  Future<void> refresh() async {
    await loadProfile();
  }
}

/// Provider for profile state.
final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  final authState = ref.watch(authProvider);
  final uid = authState.user?.uid;
  final userId = authState.user?.id;
  return ProfileNotifier(repository, uid, userId);
});

/// Provider for user stats.
final userStatsProvider = Provider<UserStats>((ref) {
  return ref.watch(profileProvider).stats;
});

/// Provider for achievements.
final achievementsProvider = Provider<List<Achievement>>((ref) {
  return ref.watch(profileProvider).achievements;
});
