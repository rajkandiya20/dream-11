import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../data/models/group_model.dart';
import '../../domain/providers/group_provider.dart';

/// Group detail screen showing members, leaderboard, and actions.
class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupDetailScreen({
    super.key,
    required this.groupId,
  });

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(groupsProvider.notifier).loadGroupDetail(widget.groupId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupsState = ref.watch(groupsProvider);
    final group = groupsState.selectedGroup;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: group == null && groupsState.isLoading
          ? const _GroupDetailLoading()
          : group == null
              ? const Center(child: Text('Group not found'))
              : NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverAppBar(
                      expandedHeight: 200,
                      pinned: true,
                      backgroundColor: AppColors.secondary,
                      leading: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      actions: [
                        IconButton(
                          onPressed: () => _showGroupOptions(context, group),
                          icon:
                              const Icon(Icons.more_vert, color: Colors.white),
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          group.name,
                          style: AppTypography.titleMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1E293B),
                                Color(0xFF0F172A),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      group.name.isNotEmpty
                                          ? group.name[0].toUpperCase()
                                          : 'G',
                                      style:
                                          AppTypography.headlineLarge.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                AppSpacing.gapH8,
                                if (group.description != null)
                                  Text(
                                    group.description!,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      bottom: TabBar(
                        controller: _tabController,
                        indicatorColor: AppColors.primary,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white60,
                        tabs: const [
                          Tab(text: 'Members'),
                          Tab(text: 'Leaderboard'),
                          Tab(text: 'Info'),
                        ],
                      ),
                    ),
                  ],
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      // Members Tab
                      _MembersTab(members: group.members),
                      // Leaderboard Tab
                      _LeaderboardTab(groupId: widget.groupId),
                      // Info Tab
                      _InfoTab(group: group),
                    ],
                  ),
                ),
    );
  }

  void _showGroupOptions(BuildContext context, GroupModel group) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share Invite Link'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person_add_outlined),
              title: const Text('Invite Members'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: AppColors.error),
              title: Text(
                'Leave Group',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () async {
                Navigator.pop(context);
                final success = await ref
                    .read(groupsProvider.notifier)
                    .leaveGroup(widget.groupId);
                if (success && mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Members tab showing group members.
class _MembersTab extends StatelessWidget {
  final List<GroupMemberModel> members;

  const _MembersTab({required this.members});

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return Center(
        child: Text(
          'No members to display',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: members.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: AppColors.border.withOpacity(0.5),
      ),
      itemBuilder: (context, index) {
        final member = members[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: member.user?.avatarUrl != null
                ? NetworkImage(member.user!.avatarUrl!)
                : null,
            child: member.user?.avatarUrl == null
                ? Text(
                    member.displayName.isNotEmpty
                        ? member.displayName[0].toUpperCase()
                        : 'M',
                    style: TextStyle(color: AppColors.primary),
                  )
                : null,
          ),
          title: Text(
            member.displayName,
            style: AppTypography.titleSmall,
          ),
          subtitle: Text(
            member.role,
            style: AppTypography.labelSmall.copyWith(
              color: member.isAdmin ? AppColors.primary : AppColors.textTertiary,
            ),
          ),
          trailing: member.isAdmin
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                  child: Text(
                    'Admin',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}

/// Leaderboard tab placeholder.
class _LeaderboardTab extends StatelessWidget {
  final String groupId;

  const _LeaderboardTab({required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.leaderboard_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          AppSpacing.gapH16,
          Text(
            'Group Leaderboard',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.gapH8,
          Text(
            'Compete in contests to see rankings here',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Info tab showing group details.
class _InfoTab extends StatelessWidget {
  final GroupModel group;

  const _InfoTab({required this.group});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            icon: Icons.group_outlined,
            label: 'Members',
            value: '${group.memberCount}',
          ),
          AppSpacing.gapH16,
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Created',
            value: group.createdAt != null
                ? '${group.createdAt!.day}/${group.createdAt!.month}/${group.createdAt!.year}'
                : 'Unknown',
          ),
          AppSpacing.gapH16,
          if (group.description != null) ...[
            _InfoRow(
              icon: Icons.description_outlined,
              label: 'Description',
              value: group.description!,
            ),
            AppSpacing.gapH16,
          ],
          AppSpacing.gapH24,
          // Invite Link
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.05),
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: AppColors.info.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.link, color: AppColors.info),
                AppSpacing.gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invite Link',
                        style: AppTypography.titleSmall,
                      ),
                      Text(
                        'Share this link to invite friends',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.copy, color: AppColors.info, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        AppSpacing.gapW12,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            Text(value, style: AppTypography.titleSmall),
          ],
        ),
      ],
    );
  }
}

/// Loading state.
class _GroupDetailLoading extends StatelessWidget {
  const _GroupDetailLoading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          const SizedBox(height: 80),
          const ShimmerLoading(width: 64, height: 64),
          AppSpacing.gapH16,
          const ShimmerLoading(width: 150, height: 20),
          AppSpacing.gapH8,
          const ShimmerLoading(width: 200, height: 14),
          AppSpacing.gapH32,
          for (int i = 0; i < 5; i++) ...[
            const ShimmerLoading(width: double.infinity, height: 60),
            AppSpacing.gapH12,
          ],
        ],
      ),
    );
  }
}
