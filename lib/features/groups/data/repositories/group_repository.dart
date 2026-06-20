import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client.dart';
import '../models/group_model.dart';

/// Repository for group operations with Supabase.
class GroupRepository {
  final SupabaseClient _client;

  GroupRepository(this._client);

  /// Get all groups the user belongs to.
  Future<List<GroupModel>> getUserGroups(String userId) async {
    try {
      final response = await _client
          .from('group_members')
          .select('*, group:groups(*)')
          .eq('user_id', userId);

      return (response as List)
          .map((json) => GroupModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get group details with members.
  Future<GroupModel?> getGroupById(String groupId) async {
    try {
      final response = await _client
          .from('groups')
          .select('*, group_members(*, user:users(username, avatar_url))')
          .eq('id', groupId)
          .single();

      return GroupModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Create a new group.
  Future<GroupModel?> createGroup({
    required String name,
    required String createdBy,
    String? description,
    String? avatarUrl,
  }) async {
    try {
      final groupResponse = await _client.from('groups').insert({
        'name': name,
        'description': description,
        'avatar_url': avatarUrl,
        'created_by': createdBy,
        'member_count': 1,
      }).select().single();

      final groupId = groupResponse['id'] as String;

      // Add creator as admin member
      await _client.from('group_members').insert({
        'group_id': groupId,
        'user_id': createdBy,
        'role': 'admin',
      });

      return GroupModel.fromJson(groupResponse);
    } catch (e) {
      return null;
    }
  }

  /// Join an existing group.
  Future<bool> joinGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      // Check if already a member
      final existing = await _client
          .from('group_members')
          .select('id')
          .eq('group_id', groupId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) return true; // Already a member

      // Add member
      await _client.from('group_members').insert({
        'group_id': groupId,
        'user_id': userId,
        'role': 'member',
      });

      // Increment member count
      final group = await _client
          .from('groups')
          .select('member_count')
          .eq('id', groupId)
          .single();

      final currentCount = group['member_count'] as int? ?? 0;
      await _client
          .from('groups')
          .update({'member_count': currentCount + 1})
          .eq('id', groupId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Leave a group.
  Future<bool> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      await _client
          .from('group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', userId);

      // Decrement member count
      final group = await _client
          .from('groups')
          .select('member_count')
          .eq('id', groupId)
          .single();

      final currentCount = group['member_count'] as int? ?? 1;
      await _client
          .from('groups')
          .update({'member_count': (currentCount - 1).clamp(0, 99999)})
          .eq('id', groupId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a group (admin only).
  Future<bool> deleteGroup(String groupId) async {
    try {
      await _client.from('group_members').delete().eq('group_id', groupId);
      await _client.from('groups').delete().eq('id', groupId);
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Provider for the group repository.
final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return GroupRepository(client);
});
