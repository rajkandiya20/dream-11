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
      ),
      drawer: const AdminNavDrawer(currentRoute: '/admin/players'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AdminDataTable(
          title: 'Manage Players',
          columns: const ['Name', 'Role', 'Points', 'Credits'],
          displayKeys: const ['name', 'role', 'points', 'credits'],
          rows: adminState.players,
          isLoading: adminState.isLoading,
          onAdd: () => _showCreateDialog(),
          onEdit: (player) => _showEditDialog(player),
          onDelete: (player) async {
            await ref
                .read(adminProvider.notifier)
                .deletePlayer(player['id'] as String);
          },
        ),
      ),
    );
  }

  void _showCreateDialog() {
    final nameController = TextEditingController();
    final creditsController = TextEditingController(text: '8.0');
    String role = 'Batsman';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusLg,
          ),
          title: Text('Add Player', style: AppTypography.titleLarge),
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
                final success =
                    await ref.read(adminProvider.notifier).createPlayer({
                  'name': nameController.text.trim(),
                  'role': role,
                  'credits':
                      double.tryParse(creditsController.text) ?? 8.0,
                  'points': 0,
                  'is_playing': true,
                });
                if (success && mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              child:
                  const Text('Create', style: TextStyle(color: Colors.white)),
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
          title: Text('Edit Player', style: AppTypography.titleLarge),
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
                  controller: creditsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Credits',
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                  ),
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
                  'points':
                      int.tryParse(pointsController.text) ?? 0,
                });
                if (success && mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              child:
                  const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
