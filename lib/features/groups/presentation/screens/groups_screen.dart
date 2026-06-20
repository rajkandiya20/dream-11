import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../domain/providers/group_provider.dart';
import '../widgets/group_card.dart';

/// Groups screen showing user's groups with create option.
class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsState = ref.watch(groupsProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text(
          'My Groups',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showCreateGroupDialog(context, ref),
            icon: const Icon(Icons.add, color: AppColors.primary),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(groupsProvider.notifier).refresh(),
        child: groupsState.isLoading
            ? _buildLoadingState()
            : groupsState.groups.isEmpty
                ? _buildEmptyState(context, ref)
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: groupsState.groups.length,
                    separatorBuilder: (_, __) => AppSpacing.gapH12,
                    itemBuilder: (context, index) {
                      final group = groupsState.groups[index];
                      return GroupCard(
                        group: group,
                        onTap: () => context.push('/groups/${group.id}'),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGroupDialog(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.group_add, color: Colors.white),
        label: Text(
          'Create Group',
          style: AppTypography.labelMedium.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ShimmerLoading(width: double.infinity, height: 80),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups_outlined,
            size: 72,
            color: AppColors.textTertiary,
          ),
          AppSpacing.gapH16,
          Text(
            'No Groups Yet',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.gapH8,
          Text(
            'Create a group or join one to compete\nwith friends!',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          AppSpacing.gapH24,
          ElevatedButton.icon(
            onPressed: () => _showCreateGroupDialog(context, ref),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'Create Your First Group',
              style: AppTypography.labelMedium.copyWith(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.borderRadiusMd,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLg,
        ),
        title: Text('Create Group', style: AppTypography.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                hintText: 'Enter group name',
                border: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
              ),
            ),
            AppSpacing.gapH12,
            TextField(
              controller: descController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'What is this group about?',
                border: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final success = await ref.read(groupsProvider.notifier).createGroup(
                name: name,
                description: descController.text.trim().isNotEmpty
                    ? descController.text.trim()
                    : null,
              );
              if (success && context.mounted) {
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
