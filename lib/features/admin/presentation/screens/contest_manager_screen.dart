import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_nav_drawer.dart';

/// Contest manager admin screen - CRUD for contests.
class ContestManagerScreen extends ConsumerStatefulWidget {
  const ContestManagerScreen({super.key});

  @override
  ConsumerState<ContestManagerScreen> createState() =>
      _ContestManagerScreenState();
}

class _ContestManagerScreenState extends ConsumerState<ContestManagerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadContests();
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
          'Contest Manager',
          style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: () => ref.read(adminProvider.notifier).loadContests(),
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const AdminNavDrawer(currentRoute: '/admin/contests'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create Contest',
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
                onPressed: () => _showCreateDialog(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Create New Contest',
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
              title: 'All Contests',
              columns: const ['Name', 'Entry Fee', 'Prize Pool', 'Status'],
              displayKeys: const [
                'name',
                'entry_fee',
                'prize_pool',
                'status'
              ],
              rows: adminState.contests,
              isLoading: adminState.contestsLoading,
              errorMessage: adminState.contestsError,
              emptyMessage: 'No contests created yet',
              emptyActionText: 'Create Contest',
              onAdd: () => _showCreateDialog(),
              onEdit: (contest) => _showEditDialog(contest),
              onDelete: (contest) => _confirmDelete(contest),
              onRetry: () => ref.read(adminProvider.notifier).loadContests(),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> contest) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contest'),
        content: Text('Delete contest "${contest['name']}"?'),
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
                  .deleteContest(contest['id'] as String);
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

  void _showCreateDialog() {
    final nameController = TextEditingController();
    final entryFeeController = TextEditingController(text: '0');
    final prizePoolController = TextEditingController(text: '0');
    final maxTeamsController = TextEditingController(text: '100');
    String contestType = 'paid';
    String status = 'open';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusLg),
          title: Row(
            children: [
              const Icon(Icons.emoji_events, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Create Contest', style: AppTypography.titleLarge),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Contest Name',
                    prefixIcon:
                        const Icon(Icons.emoji_events, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                  ),
                ),
                AppSpacing.gapH12,
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: entryFeeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Entry Fee (₹)',
                          border: OutlineInputBorder(
                            borderRadius: AppSpacing.borderRadiusSm,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: prizePoolController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Prize Pool (₹)',
                          border: OutlineInputBorder(
                            borderRadius: AppSpacing.borderRadiusSm,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapH12,
                TextField(
                  controller: maxTeamsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Max Teams',
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                  ),
                ),
                AppSpacing.gapH12,
                DropdownButtonFormField<String>(
                  value: contestType,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                  ),
                  items: ['paid', 'free']
                      .map((t) =>
                          DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => contestType = v!),
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
                  items: ['open', 'closed', 'completed']
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => status = v!),
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
                        content: Text('Please enter contest name')),
                  );
                  return;
                }
                final success = await ref
                    .read(adminProvider.notifier)
                    .createContest({
                  'name': nameController.text.trim(),
                  'entry_fee':
                      double.tryParse(entryFeeController.text) ?? 0,
                  'prize_pool':
                      double.tryParse(prizePoolController.text) ?? 0,
                  'max_teams':
                      int.tryParse(maxTeamsController.text) ?? 100,
                  'contest_type': contestType,
                  'status': status,
                  'joined_teams': 0,
                });
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Contest created successfully!')),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Failed to create contest. Try again.')),
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

  void _showEditDialog(Map<String, dynamic> contest) {
    final nameController =
        TextEditingController(text: contest['name'] ?? '');
    final entryFeeController =
        TextEditingController(text: '${contest['entry_fee'] ?? 0}');
    final prizePoolController =
        TextEditingController(text: '${contest['prize_pool'] ?? 0}');
    String status = contest['status'] ?? 'open';

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
              Text('Edit Contest', style: AppTypography.titleLarge),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Contest Name',
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                  ),
                ),
                AppSpacing.gapH12,
                TextField(
                  controller: entryFeeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Entry Fee (₹)',
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                  ),
                ),
                AppSpacing.gapH12,
                TextField(
                  controller: prizePoolController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Prize Pool (₹)',
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
                  items: ['open', 'closed', 'completed']
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
                    .updateContest(contest['id'] as String, {
                  'name': nameController.text.trim(),
                  'entry_fee':
                      double.tryParse(entryFeeController.text) ?? 0,
                  'prize_pool':
                      double.tryParse(prizePoolController.text) ?? 0,
                  'status': status,
                });
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Contest updated successfully!')),
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
