import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_nav_drawer.dart';

/// Admin matches CRUD screen with team selection and status management.
class AdminMatchesScreen extends ConsumerStatefulWidget {
  const AdminMatchesScreen({super.key});

  @override
  ConsumerState<AdminMatchesScreen> createState() =>
      _AdminMatchesScreenState();
}

class _AdminMatchesScreenState extends ConsumerState<AdminMatchesScreen> {
  String? _statusFilter;

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
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          ),
        ),
        title: Text(
          'Matches',
          style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: AppColors.textSecondary),
            onSelected: (status) {
              setState(() => _statusFilter = status == 'all' ? null : status);
              ref
                  .read(adminProvider.notifier)
                  .loadMatches(status: _statusFilter);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'upcoming', child: Text('Upcoming')),
              const PopupMenuItem(value: 'live', child: Text('Live')),
              const PopupMenuItem(value: 'completed', child: Text('Completed')),
            ],
          ),
        ],
      ),
      drawer: const AdminNavDrawer(currentRoute: '/admin/matches'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(null),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AdminDataTable(
          title: 'All Matches',
          columns: const ['Team A', 'Team B', 'Status', 'Date'],
          displayKeys: const [
            'team_a_name',
            'team_b_name',
            'status',
            'date_time'
          ],
          rows: adminState.matches,
          isLoading: adminState.matchesLoading,
          errorMessage: adminState.matchesError,
          emptyMessage: 'No matches scheduled',
          emptyActionText: 'Create Match',
          onAdd: () => _showFormDialog(null),
          onEdit: (match) => _showFormDialog(match),
          onDelete: (match) => _confirmDelete(match),
          onRetry: () => ref.read(adminProvider.notifier).loadMatches(status: _statusFilter),
        ),
      ),
    );
  }

  void _showFormDialog(Map<String, dynamic>? match) {
    final isEditing = match != null;
    final teamAController =
        TextEditingController(text: match?['team_a_name'] ?? '');
    final teamBController =
        TextEditingController(text: match?['team_b_name'] ?? '');
    final venueController =
        TextEditingController(text: match?['venue'] ?? '');
    String status = match?['status'] ?? 'upcoming';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusLg,
          ),
          title: Text(
            isEditing ? 'Edit Match' : 'Create Match',
            style: AppTypography.titleLarge,
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
                  'team_a_name': teamAController.text.trim(),
                  'team_b_name': teamBController.text.trim(),
                  'venue': venueController.text.trim(),
                  'status': status,
                };
                bool success;
                if (isEditing) {
                  success = await ref
                      .read(adminProvider.notifier)
                      .updateMatch(match['id'], data);
                } else {
                  success = await ref
                      .read(adminProvider.notifier)
                      .createMatch(data);
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

  void _confirmDelete(Map<String, dynamic> match) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Match'),
        content: Text(
            'Delete match "${match['team_a_name']} vs ${match['team_b_name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(adminProvider.notifier)
                  .deleteMatch(match['id']);
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
