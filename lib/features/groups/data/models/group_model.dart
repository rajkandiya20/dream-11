/// Group model matching the groups table schema in Supabase.
///
/// Table schema:
/// id, name, description, avatar_url, created_by, member_count
class GroupModel {
  final String id;
  final String name;
  final String? description;
  final String? avatarUrl;
  final String createdBy;
  final int memberCount;
  final DateTime? createdAt;
  final List<GroupMemberModel> members;

  const GroupModel({
    required this.id,
    required this.name,
    this.description,
    this.avatarUrl,
    required this.createdBy,
    this.memberCount = 0,
    this.createdAt,
    this.members = const [],
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    // Handle nested group data from group_members join
    final groupData = json['group'] as Map<String, dynamic>?;
    final data = groupData ?? json;

    List<GroupMemberModel> members = [];
    if (data['group_members'] != null) {
      members = (data['group_members'] as List)
          .map((m) => GroupMemberModel.fromJson(m as Map<String, dynamic>))
          .toList();
    }

    return GroupModel(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      avatarUrl: data['avatar_url'] as String?,
      createdBy: data['created_by'] as String? ?? '',
      memberCount: data['member_count'] as int? ?? 0,
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'] as String)
          : null,
      members: members,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'created_by': createdBy,
      'member_count': memberCount,
    };
  }

  GroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? avatarUrl,
    String? createdBy,
    int? memberCount,
    DateTime? createdAt,
    List<GroupMemberModel>? members,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdBy: createdBy ?? this.createdBy,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? this.members,
    );
  }

  @override
  String toString() => 'GroupModel(id: $id, name: $name, members: $memberCount)';
}

/// Group member model matching group_members table.
///
/// Table schema:
/// id, group_id, user_id, role(admin/member)
class GroupMemberModel {
  final String id;
  final String groupId;
  final String userId;
  final String role;
  final GroupMemberUser? user;
  final DateTime? joinedAt;

  const GroupMemberModel({
    required this.id,
    required this.groupId,
    required this.userId,
    this.role = 'member',
    this.user,
    this.joinedAt,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      id: json['id'] as String? ?? '',
      groupId: json['group_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      role: json['role'] as String? ?? 'member',
      user: json['user'] != null
          ? GroupMemberUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      joinedAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'group_id': groupId,
      'user_id': userId,
      'role': role,
    };
  }

  bool get isAdmin => role == 'admin';
  String get displayName => user?.username ?? 'Member';
}

/// Lightweight user info for group member display.
class GroupMemberUser {
  final String? username;
  final String? avatarUrl;

  const GroupMemberUser({this.username, this.avatarUrl});

  factory GroupMemberUser.fromJson(Map<String, dynamic> json) {
    return GroupMemberUser(
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
