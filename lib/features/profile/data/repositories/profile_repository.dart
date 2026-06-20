import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client.dart';
import '../../../auth/data/models/user_model.dart';

/// User statistics model.
class UserStats {
  final int matchesPlayed;
  final int contestsJoined;
  final int contestsWon;
  final double totalWinnings;
  final int fantasyTeamsCreated;
  final int rank;
  final String tier;

  const UserStats({
    this.matchesPlayed = 0,
    this.contestsJoined = 0,
    this.contestsWon = 0,
    this.totalWinnings = 0.0,
    this.fantasyTeamsCreated = 0,
    this.rank = 0,
    this.tier = 'Bronze',
  });

  factory UserStats.fromData({
    required int matchesPlayed,
    required int contestsJoined,
    required int contestsWon,
    required double totalWinnings,
    required int fantasyTeamsCreated,
  }) {
    // Calculate tier based on winnings
    String tier;
    if (totalWinnings >= 100000) {
      tier = 'Diamond';
    } else if (totalWinnings >= 50000) {
      tier = 'Platinum';
    } else if (totalWinnings >= 10000) {
      tier = 'Gold';
    } else if (totalWinnings >= 1000) {
      tier = 'Silver';
    } else {
      tier = 'Bronze';
    }

    return UserStats(
      matchesPlayed: matchesPlayed,
      contestsJoined: contestsJoined,
      contestsWon: contestsWon,
      totalWinnings: totalWinnings,
      fantasyTeamsCreated: fantasyTeamsCreated,
      rank: 0,
      tier: tier,
    );
  }
}

/// Achievement model.
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final double progress;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    this.icon = 'emoji_events',
    this.isUnlocked = false,
    this.progress = 0.0,
  });
}

/// Repository for profile operations.
class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  /// Get user profile by UID.
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final response = await _client
          .from('users')
          .select('*')
          .eq('uid', uid)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Update user profile.
  Future<UserModel?> updateProfile({
    required String uid,
    String? username,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (username != null) updateData['username'] = username;
      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

      if (updateData.isEmpty) return null;

      final response = await _client
          .from('users')
          .update(updateData)
          .eq('uid', uid)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Get user statistics from multiple tables.
  Future<UserStats> getUserStats(String userId) async {
    try {
      // Fetch fantasy teams count (represents matches played)
      final fantasyTeams = await _client
          .from('fantasy_teams')
          .select('id')
          .eq('user_id', userId);

      // Fetch leaderboard entries (contests joined)
      final leaderboard = await _client
          .from('leaderboard')
          .select('id, prize_won')
          .eq('user_id', userId);

      final int matchesPlayed = (fantasyTeams as List).length;
      final int contestsJoined = (leaderboard as List).length;
      final int contestsWon = (leaderboard)
          .where((e) => (e['prize_won'] as num?)?.toDouble() ?? 0 > 0)
          .length;
      final double totalWinnings = (leaderboard).fold<double>(
        0,
        (sum, e) => sum + ((e['prize_won'] as num?)?.toDouble() ?? 0),
      );

      return UserStats.fromData(
        matchesPlayed: matchesPlayed,
        contestsJoined: contestsJoined,
        contestsWon: contestsWon,
        totalWinnings: totalWinnings,
        fantasyTeamsCreated: matchesPlayed,
      );
    } catch (e) {
      return const UserStats();
    }
  }

  /// Get user achievements based on stats.
  List<Achievement> getAchievements(UserStats stats) {
    return [
      Achievement(
        id: 'first_team',
        title: 'First Team',
        description: 'Create your first fantasy team',
        icon: 'sports_cricket',
        isUnlocked: stats.fantasyTeamsCreated >= 1,
        progress: stats.fantasyTeamsCreated >= 1 ? 1.0 : 0.0,
      ),
      Achievement(
        id: 'contest_warrior',
        title: 'Contest Warrior',
        description: 'Join 10 contests',
        icon: 'military_tech',
        isUnlocked: stats.contestsJoined >= 10,
        progress: (stats.contestsJoined / 10).clamp(0.0, 1.0),
      ),
      Achievement(
        id: 'winner',
        title: 'First Win',
        description: 'Win your first contest',
        icon: 'emoji_events',
        isUnlocked: stats.contestsWon >= 1,
        progress: stats.contestsWon >= 1 ? 1.0 : 0.0,
      ),
      Achievement(
        id: 'big_earner',
        title: 'Big Earner',
        description: 'Win \u20B910,000 in total',
        icon: 'monetization_on',
        isUnlocked: stats.totalWinnings >= 10000,
        progress: (stats.totalWinnings / 10000).clamp(0.0, 1.0),
      ),
      Achievement(
        id: 'veteran',
        title: 'Veteran',
        description: 'Play 50 matches',
        icon: 'verified',
        isUnlocked: stats.matchesPlayed >= 50,
        progress: (stats.matchesPlayed / 50).clamp(0.0, 1.0),
      ),
      Achievement(
        id: 'team_builder',
        title: 'Team Builder',
        description: 'Create 25 fantasy teams',
        icon: 'groups',
        isUnlocked: stats.fantasyTeamsCreated >= 25,
        progress: (stats.fantasyTeamsCreated / 25).clamp(0.0, 1.0),
      ),
    ];
  }
}

/// Provider for the profile repository.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProfileRepository(client);
});
