import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_nav_drawer.dart';

/// Admin players CRUD screen with team assignment.
class AdminPlayersScreen extends ConsumerStatefulWidget {
  const AdminPlayersScreen({super.key});

  @override
  ConsumerState<AdminPlayersScreen> createState() =>
      _AdminPlayersScreenState();
}

class _AdminPlayersScreenState extends ConsumerState<AdminPlayersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadPlayers();
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
          'Players',
          style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
      ),
      drawer: const AdminNavDrawer(currentRoute: '/admin/players'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(null),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Player', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AdminDataTable(
          title: 'All Players',
          columns: const ['Name', 'Role', 'Points', 'Credits'],
          displayKeys: const ['name', 'role', 'points', 'credits'],
          rows: adminState.players,
          isLoading: adminState.isLoading,
          errorMessage: adminState.playersError,
          emptyMessage: 'No players added yet',
          emptyActionText: 'Add Player',
          onAdd: () => _showFormDialog(null),
          onEdit: (player) => _showFormDialog(player),
          onDelete: (player) => _confirmDelete(player),
          onRetry: () => ref.read(adminProvider.notifier).loadPlayers(),
        ),
      ),
    );
  }

  void _showFormDialog(Map<String, dynamic>? player) {
    final isEditing = player != null;
    final nameController =
        TextEditingController(text: player?['name'] ?? '');
    final pointsController = TextEditingController(
        text: '${player?['points'] ?? 0}');
    final creditsController = TextEditingController(
        text: '${player?['credits'] ?? 8.0}');
    String role = player?['role'] ?? 'Batsman';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusLg,
          ),
          title: Text(
            isEditing ? 'Edit Player' : 'Add Player',
            style: AppTypography.titleLarge,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Player Name',
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                  ),
                ),
                AppSpacing.gapH12,
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                  ),
                  items: ['Batsman', 'Bowler', 'All-rounder', 'WK']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => role = v!),
                ),
                AppSpacing.gapH12,
                TextField(
                  controller: pointsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Points',
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                  ),
                ),
                AppSpacing.gapH12,
                TextField(
                  controller: creditsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Credits',
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
                  'role': role,
                  'points': int.tryParse(pointsController.text) ?? 0,
                  'credits':
                      double.tryParse(creditsController.text) ?? 8.0,
                };
                bool success;
                if (isEditing) {
                  success = await ref
                      .read(adminProvider.notifier)
                      .updatePlayer(player['id'], data);
                } else {
                  success = await ref
                      .read(adminProvider.notifier)
                      .createPlayer(data);
                }
                if (success && mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
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

  void _confirmDelete(Map<String, dynamic> player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Player'),
        content: Text('Delete player "${player['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(adminProvider.notifier)
                  .deletePlayer(player['id']);
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
