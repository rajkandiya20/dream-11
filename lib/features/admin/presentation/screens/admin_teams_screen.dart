import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_nav_drawer.dart';

/// Admin teams CRUD screen.
class AdminTeamsScreen extends ConsumerStatefulWidget {
  const AdminTeamsScreen({super.key});

  @override
  ConsumerState<AdminTeamsScreen> createState() => _AdminTeamsScreenState();
}

class _AdminTeamsScreenState extends ConsumerState<AdminTeamsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadTeams();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          ),
        ),
        title: Text(
          'Teams',
          style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
      ),
      drawer: const AdminNavDrawer(currentRoute: '/admin/teams'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(null),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Team', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AdminDataTable(
          title: 'All Teams',
          columns: const ['Name', 'Code', 'Tournament'],
          displayKeys: const ['name', 'code', 'tournament_id'],
          rows: adminState.teams,
          isLoading: adminState.teamsLoading,
          errorMessage: adminState.teamsError,
          emptyMessage: 'No teams created yet',
          emptyActionText: 'Add Team',
          onAdd: () => _showFormDialog(null),
          onEdit: (team) => _showFormDialog(team),
          onDelete: (team) => _confirmDelete(team),
          onRetry: () => ref.read(adminProvider.notifier).loadTeams(),
        ),
      ),
    );
  }

  void _showFormDialog(Map<String, dynamic>? team) {
    final isEditing = team != null;
    final nameController = TextEditingController(text: team?['name'] ?? '');
    final codeController = TextEditingController(text: team?['code'] ?? '');
    final logoController = TextEditingController(text: team?['logo'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLg),
        title: Text(
          isEditing ? 'Edit Team' : 'Create Team',
          style: AppTypography.titleLarge,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Team Name',
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                ),
              ),
              AppSpacing.gapH12,
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  labelText: 'Team Code (e.g., IND)',
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                ),
              ),
              AppSpacing.gapH12,
              TextField(
                controller: logoController,
                decoration: InputDecoration(
                  labelText: 'Logo URL',
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'name': nameController.text.trim(),
                'code': codeController.text.trim().toUpperCase(),
                'logo': logoController.text.trim(),
              };
              bool success;
              if (isEditing) {
                success = await ref
                    .read(adminProvider.notifier)
                    .updateTeam(team['id'], data);
              } else {
                success =
                    await ref.read(adminProvider.notifier).createTeam(data);
              }
              if (success && mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(
              isEditing ? 'Update' : 'Create',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Team'),
        content: Text('Are you sure you want to delete "${team['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(adminProvider.notifier)
                  .deleteTeam(team['id']);
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
