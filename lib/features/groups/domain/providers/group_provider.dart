import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/models/group_model.dart';
import '../../data/repositories/group_repository.dart';

/// Groups state.
class GroupsState {
  final List<GroupModel> groups;
  final GroupModel? selectedGroup;
  final bool isLoading;
  final bool isCreating;
  final String? errorMessage;

  const GroupsState({
    this.groups = const [],
    this.selectedGroup,
    this.isLoading = false,
    this.isCreating = false,
    this.errorMessage,
  });

  GroupsState copyWith({
    List<GroupModel>? groups,
    GroupModel? selectedGroup,
    bool? isLoading,
    bool? isCreating,
    String? errorMessage,
  }) {
    return GroupsState(
      groups: groups ?? this.groups,
      selectedGroup: selectedGroup ?? this.selectedGroup,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      errorMessage: errorMessage,
    );
  }
}

/// Groups state notifier.
class GroupsNotifier extends StateNotifier<GroupsState> {
  final GroupRepository _repository;
  final String? _userId;

  GroupsNotifier(this._repository, this._userId) : super(const GroupsState()) {
    if (_userId != null) {
      loadGroups();
    }
  }

  /// Load user's groups.
  Future<void> loadGroups() async {
    if (_userId == null) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    final groups = await _repository.getUserGroups(_userId!);

    state = state.copyWith(
      groups: groups,
      isLoading: false,
    );
  }

  /// Load group details.
  Future<void> loadGroupDetail(String groupId) async {
    state = state.copyWith(isLoading: true);

    final group = await _repository.getGroupById(groupId);

    state = state.copyWith(
      selectedGroup: group,
      isLoading: false,
    );
  }

  /// Create a new group.
  Future<bool> createGroup({
    required String name,
    String? description,
  }) async {
    if (_userId == null) return false;
    state = state.copyWith(isCreating: true, errorMessage: null);

    final group = await _repository.createGroup(
      name: name,
      createdBy: _userId!,
      description: description,
    );

    if (group != null) {
      state = state.copyWith(
        groups: [...state.groups, group],
        isCreating: false,
      );
      return true;
    } else {
      state = state.copyWith(
        isCreating: false,
        errorMessage: 'Failed to create group.',
      );
      return false;
    }
  }

  /// Join a group.
  Future<bool> joinGroup(String groupId) async {
    if (_userId == null) return false;

    final success = await _repository.joinGroup(
      groupId: groupId,
      userId: _userId!,
    );

    if (success) {
      await loadGroups();
    }
    return success;
  }

  /// Leave a group.
  Future<bool> leaveGroup(String groupId) async {
    if (_userId == null) return false;

    final success = await _repository.leaveGroup(
      groupId: groupId,
      userId: _userId!,
    );

    if (success) {
      state = state.copyWith(
        groups: state.groups.where((g) => g.id != groupId).toList(),
      );
    }
    return success;
  }

  /// Refresh groups.
  Future<void> refresh() async {
    await loadGroups();
  }
}

/// Provider for groups state.
final groupsProvider =
    StateNotifierProvider<GroupsNotifier, GroupsState>((ref) {
  final repository = ref.watch(groupRepositoryProvider);
  final authState = ref.watch(authProvider);
  final userId = authState.user?.id;
  return GroupsNotifier(repository, userId);
});

/// Provider for group detail.
final groupDetailProvider =
    FutureProvider.family<GroupModel?, String>((ref, groupId) async {
  final repository = ref.watch(groupRepositoryProvider);
  return repository.getGroupById(groupId);
});
