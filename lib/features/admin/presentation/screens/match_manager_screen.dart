import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_nav_drawer.dart';

/// Match manager admin screen - CRUD for matches with team selection.
class MatchManagerScreen extends ConsumerStatefulWidget {
  const MatchManagerScreen({super.key});

  @override
  ConsumerState<MatchManagerScreen> createState() =>
      _MatchManagerScreenState();
}

class _MatchManagerScreenState extends ConsumerState<MatchManagerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadMatches();
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
          'Match Manager',
          style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: () => ref.read(adminProvider.notifier).loadMatches(),
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const AdminNavDrawer(currentRoute: '/admin/matches'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateMatchDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create Match',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Always visible Create button at the top
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showCreateMatchDialog(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Create New Match',
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
              title: 'All Matches',
              columns: const ['Team A', 'Team B', 'Status', 'Venue'],
              displayKeys: const [
                'team_a_name',
                'team_b_name',
                'status',
                'venue'
              ],
              rows: adminState.matches,
              isLoading: adminState.isLoading,
              errorMessage: adminState.matchesError,
              emptyMessage: 'No matches created yet',
              emptyActionText: 'Create Match',
              onAdd: () => _showCreateMatchDialog(),
              onEdit: (match) => _showEditMatchDialog(match),
              onDelete: (match) => _confirmDelete(match),
              onRetry: () => ref.read(adminProvider.notifier).loadMatches(),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> match) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Match'),
        content: Text(
            'Delete "${match['team_a_name']} vs ${match['team_b_name']}"?'),
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
                  .deleteMatch(match['id'] as String);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child:
                const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateMatchDialog() {
    final teamAController = TextEditingController();
    final teamBController = TextEditingController();
    final venueController = TextEditingController();
    String status = 'upcoming';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLg),
          title: Row(
            children: [
              const Icon(Icons.add_circle, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Create Match', style: AppTypography.titleLarge),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: teamAController,
                  decoration: InputDecoration(
                    labelText: 'Team A Name',
                    prefixIcon: const Icon(Icons.sports_cricket, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                  ),
                ),
                AppSpacing.gapH12,
                TextField(
                  controller: teamBController,
                  decoration: InputDecoration(
                    labelText: 'Team B Name',
                    prefixIcon: const Icon(Icons.sports_cricket, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                  ),
                ),
                AppSpacing.gapH12,
                TextField(
                  controller: venueController,
                  decoration: InputDecoration(
                    labelText: 'Venue',
                    prefixIcon: const Icon(Icons.location_on, size: 18),
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
                  items: ['upcoming', 'live', 'completed']
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text(s)))
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
                if (teamAController.text.trim().isEmpty ||
                    teamBController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter both team names')),
                  );
                  return;
                }
                final success =
                    await ref.read(adminProvider.notifier).createMatch({
                  'team_a_name': teamAController.text.trim(),
                  'team_b_name': teamBController.text.trim(),
                  'venue': venueController.text.trim(),
                  'status': status,
                });
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Match created successfully!')),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Failed to create match. Try again.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              child: const Text('Create',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditMatchDialog(Map<String, dynamic> match) {
    final teamAController =
        TextEditingController(text: match['team_a_name'] ?? '');
    final teamBController =
        TextEditingController(text: match['team_b_name'] ?? '');
    final venueController =
        TextEditingController(text: match['venue'] ?? '');
    String status = match['status'] ?? 'upcoming';

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
              Text('Edit Match', style: AppTypography.titleLarge),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: teamAController,
                  decoration: InputDecoration(
                    labelText: 'Team A Name',
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                  ),
                ),
                AppSpacing.gapH12,
                TextField(
                  controller: teamBController,
                  decoration: InputDecoration(
                    labelText: 'Team B Name',
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                  ),
                ),
                AppSpacing.gapH12,
                TextField(
                  controller: venueController,
                  decoration: InputDecoration(
                    labelText: 'Venue',
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
                  items: ['upcoming', 'live', 'completed']
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text(s)))
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
                final success = await ref
                    .read(adminProvider.notifier)
                    .updateMatch(match['id'] as String, {
                  'team_a_name': teamAController.text.trim(),
                  'team_b_name': teamBController.text.trim(),
                  'venue': venueController.text.trim(),
                  'status': status,
                });
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Match updated successfully!')),
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
