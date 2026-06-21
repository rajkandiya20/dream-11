import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_nav_drawer.dart';

/// Admin tournaments CRUD screen.
class AdminTournamentsScreen extends ConsumerStatefulWidget {
  const AdminTournamentsScreen({super.key});

  @override
  ConsumerState<AdminTournamentsScreen> createState() =>
      _AdminTournamentsScreenState();
}

class _AdminTournamentsScreenState
    extends ConsumerState<AdminTournamentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadTournaments();
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
          'Tournaments',
          style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
      ),
      drawer: const AdminNavDrawer(currentRoute: '/admin/tournaments'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(null),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AdminDataTable(
          title: 'All Tournaments',
          columns: const ['Name', 'Status', 'Start Date', 'End Date'],
          displayKeys: const ['name', 'status', 'start_date', 'end_date'],
          rows: adminState.tournaments,
          isLoading: adminState.isLoading,
          errorMessage: adminState.tournamentsError,
          emptyMessage: 'No tournaments yet',
          emptyActionText: 'Create Tournament',
          onAdd: () => _showFormDialog(null),
          onEdit: (tournament) => _showFormDialog(tournament),
          onDelete: (tournament) => _confirmDelete(tournament),
          onRetry: () => ref.read(adminProvider.notifier).loadTournaments(),
        ),
      ),
    );
  }

  void _showFormDialog(Map<String, dynamic>? tournament) {
    final isEditing = tournament != null;
    final nameController =
        TextEditingController(text: tournament?['name'] ?? '');
    final descController =
        TextEditingController(text: tournament?['description'] ?? '');
    String status = tournament?['status'] ?? 'upcoming';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusLg,
          ),
          title: Text(
            isEditing ? 'Edit Tournament' : 'Create Tournament',
            style: AppTypography.titleLarge,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Tournament Name',
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                  ),
                ),
                AppSpacing.gapH12,
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                  ),
                ),
                AppSpacing.gapH12,
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                  ),
                  items: ['upcoming', 'active', 'completed']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => status = v!),
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
                  'description': descController.text.trim(),
                  'status': status,
                };
                bool success;
                if (isEditing) {
                  success = await ref
                      .read(adminProvider.notifier)
                      .updateTournament(tournament['id'], data);
                } else {
                  success = await ref
                      .read(adminProvider.notifier)
                      .createTournament(data);
                }
                if (success && mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                isEditing ? 'Update' : 'Create',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> tournament) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tournament'),
        content: Text(
            'Are you sure you want to delete "${tournament['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(adminProvider.notifier)
                  .deleteTournament(tournament['id']);
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
