import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client.dart';
import '../models/fantasy_team_model.dart';

/// Repository for fantasy team CRUD operations with Supabase.
class FantasyRepository {
  final SupabaseClient _client;

  FantasyRepository(this._client);

  /// Create a fantasy team and insert team players.
  Future<FantasyTeamModel?> createFantasyTeam({
    required String userId,
    required String matchId,
    String? contestId,
    required String teamName,
    required String captainId,
    required String viceCaptainId,
    required List<String> playerIds,
  }) async {
    try {
      // Insert the fantasy team.
      final teamResponse = await _client.from('fantasy_teams').insert({
        'user_id': userId,
        'match_id': matchId,
        if (contestId != null) 'contest_id': contestId,
        'team_name': teamName,
        'captain_id': captainId,
        'vice_captain_id': viceCaptainId,
        'total_points': 0,
      }).select().single();

      final teamId = teamResponse['id'] as String;

      // Insert fantasy team players.
      final playerInserts = playerIds.map((playerId) {
        return {
          'fantasy_team_id': teamId,
          'player_id': playerId,
          'is_captain': playerId == captainId,
          'is_vice_captain': playerId == viceCaptainId,
          'points': 0,
        };
      }).toList();

      await _client.from('fantasy_team_players').insert(playerInserts);

      return FantasyTeamModel.fromJson(teamResponse);
    } catch (e) {
      return null;
    }
  }

  /// Update an existing fantasy team.
  Future<FantasyTeamModel?> updateFantasyTeam({
    required String teamId,
    String? teamName,
    String? captainId,
    String? viceCaptainId,
    List<String>? playerIds,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (teamName != null) updates['team_name'] = teamName;
      if (captainId != null) updates['captain_id'] = captainId;
      if (viceCaptainId != null) updates['vice_captain_id'] = viceCaptainId;

      if (updates.isNotEmpty) {
        await _client
            .from('fantasy_teams')
            .update(updates)
            .eq('id', teamId);
      }

      // Replace players if new list provided.
      if (playerIds != null) {
        // Delete existing players.
        await _client
            .from('fantasy_team_players')
            .delete()
            .eq('fantasy_team_id', teamId);

        // Insert new players.
        final playerInserts = playerIds.map((playerId) {
          return {
            'fantasy_team_id': teamId,
            'player_id': playerId,
            'is_captain': playerId == captainId,
            'is_vice_captain': playerId == viceCaptainId,
            'points': 0,
          };
        }).toList();

        await _client.from('fantasy_team_players').insert(playerInserts);
      }

      // Fetch updated team.
      return getFantasyTeamById(teamId);
    } catch (e) {
      return null;
    }
  }

  /// Fetch a single fantasy team by ID with players.
  Future<FantasyTeamModel?> getFantasyTeamById(String teamId) async {
    try {
      final response = await _client
          .from('fantasy_teams')
          .select(
              '*, fantasy_team_players(*, player:players(name, role, team:teams(name)))')
          .eq('id', teamId)
          .single();

      return FantasyTeamModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Fetch all fantasy teams for a user.
  Future<List<FantasyTeamModel>> getUserFantasyTeams(String userId) async {
    try {
      final response = await _client
          .from('fantasy_teams')
          .select(
              '*, fantasy_team_players(*, player:players(name, role, team:teams(name)))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) =>
              FantasyTeamModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch user fantasy teams for a specific match.
  Future<List<FantasyTeamModel>> getUserTeamsForMatch({
    required String userId,
    required String matchId,
  }) async {
    try {
      final response = await _client
          .from('fantasy_teams')
          .select(
              '*, fantasy_team_players(*, player:players(name, role, team:teams(name)))')
          .eq('user_id', userId)
          .eq('match_id', matchId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) =>
              FantasyTeamModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Delete a fantasy team.
  Future<bool> deleteFantasyTeam(String teamId) async {
    try {
      // Delete players first (cascade may handle this).
      await _client
          .from('fantasy_team_players')
          .delete()
          .eq('fantasy_team_id', teamId);

      await _client.from('fantasy_teams').delete().eq('id', teamId);
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Provider for the fantasy repository.
final fantasyRepositoryProvider = Provider<FantasyRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return FantasyRepository(client);
});
