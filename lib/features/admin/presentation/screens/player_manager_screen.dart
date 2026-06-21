import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_nav_drawer.dart';

/// Player manager admin screen - CRUD for players with team assignment.
class PlayerManagerScreen extends ConsumerStatefulWidget {
  const PlayerManagerScreen({super.key});

  @override
  ConsumerState<PlayerManagerScreen> createState() =>
      _PlayerManagerScreenState();
}

class _PlayerManagerScreenState extends ConsumerState<PlayerManagerScreen> {
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
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text(
          'Player Manager',
          style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: () => ref.read(adminProvider.notifier).loadPlayers(),
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const AdminNavDrawer(currentRoute: '/admin/players'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Add Player',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Always visible Add button at the top
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showCreateDialog(),
                icon: const Icon(Icons.person_add, color: Colors.white),
                label: const Text(
                  'Add New Player',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AdminDataTable(
              title: 'All Players',
              columns: const ['Name', 'Role', 'Points', 'Credits'],
              displayKeys: const ['name', 'role', 'points', 'credits'],
              rows: adminState.players,
              isLoading: adminState.playersLoading,
              errorMessage: adminState.playersError,
              emptyMessage: 'No players added yet',
              emptyActionText: 'Add Player',
              onAdd: () => _showCreateDialog(),
              onEdit: (player) => _showEditDialog(player),
              onDelete: (player) => _confirmDelete(player),
              onRetry: () => ref.read(adminProvider.notifier).loadPlayers(),
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
              Navigator.pop(context);
              await ref
                  .read(adminProvider.notifier)
                  .deletePlayer(player['id'] as String);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    final nameController = TextEditingController();
    final creditsController = TextEditingController(text: '8.0');
    final pointsController = TextEditingController(text: '0');
    String role = 'Batsman';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusLg),
          title: Row(
            children: [
              const Icon(Icons.person_add, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Add Player', style: AppTypography.titleLarge),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Player Name',
                    prefixIcon: const Icon(Icons.person, size: 18),
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
                    prefixIcon:
                        const Icon(Icons.sports_cricket, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                  ),
                  items: ['Batsman', 'Bowler', 'All-rounder', 'WK']
                      .map((r) =>
                          DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => role = v!),
                ),
                AppSpacing.gapH12,
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: creditsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Credits',
                          border: OutlineInputBorder(
                            borderRadius: AppSpacing.borderRadiusSm,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: pointsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Points',
                          border: OutlineInputBorder(
                            borderRadius: AppSpacing.borderRadiusSm,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter player name')),
                  );
                  return;
                }
                final success =
                    await ref.read(adminProvider.notifier).createPlayer({
                  'name': nameController.text.trim(),
                  'role': role,
                  'credits':
                      double.tryParse(creditsController.text) ?? 8.0,
                  'points': int.tryParse(pointsController.text) ?? 0,
                  'is_playing': true,
                });
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Player added successfully!')),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Failed to add player. Try again.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              child:
                  const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> player) {
    final nameController =
        TextEditingController(text: player['name'] ?? '');
    final creditsController =
        TextEditingController(text: '${player['credits'] ?? 8.0}');
    final pointsController =
        TextEditingController(text: '${player['points'] ?? 0}');
    String role = player['role'] ?? 'Batsman';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusLg,
          ),
          title: Row(
            children: [
              const Icon(Icons.edit, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Edit Player', style: AppTypography.titleLarge),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Player Name',
                    prefixIcon: const Icon(Icons.person, size: 18),
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
                      .map((r) =>
                          DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => role = v!),
                ),
                AppSpacing.gapH12,
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: creditsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Credits',
                          border: OutlineInputBorder(
                            borderRadius: AppSpacing.borderRadiusSm,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: pointsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Points',
                          border: OutlineInputBorder(
                            borderRadius: AppSpacing.borderRadiusSm,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                final success = await ref
                    .read(adminProvider.notifier)
                    .updatePlayer(player['id'] as String, {
                  'name': nameController.text.trim(),
                  'role': role,
                  'credits':
                      double.tryParse(creditsController.text) ?? 8.0,
                  'points': int.tryParse(pointsController.text) ?? 0,
                });
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Player updated successfully!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              child: const Text('Update',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
