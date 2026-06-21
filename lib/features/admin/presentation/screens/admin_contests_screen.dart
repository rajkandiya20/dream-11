import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_nav_drawer.dart';

/// Admin contests CRUD screen with match linkage.
class AdminContestsScreen extends ConsumerStatefulWidget {
  const AdminContestsScreen({super.key});

  @override
  ConsumerState<AdminContestsScreen> createState() =>
      _AdminContestsScreenState();
}

class _AdminContestsScreenState extends ConsumerState<AdminContestsScreen> {
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
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          ),
        ),
        title: Text(
          'Contests',
          style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
      ),
      drawer: const AdminNavDrawer(currentRoute: '/admin/contests'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(null),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AdminDataTable(
          title: 'All Contests',
          columns: const ['Name', 'Entry Fee', 'Prize Pool', 'Status'],
          displayKeys: const [
            'name',
            'entry_fee',
            'prize_pool',
            'status'
          ],
          rows: adminState.contests,
          isLoading: adminState.isLoading,
          errorMessage: adminState.contestsError,
          emptyMessage: 'No contests created yet',
          emptyActionText: 'Create Contest',
          onAdd: () => _showFormDialog(null),
          onEdit: (contest) => _showFormDialog(contest),
          onDelete: (contest) => _confirmDelete(contest),
          onRetry: () => ref.read(adminProvider.notifier).loadContests(),
        ),
      ),
    );
  }

  void _showFormDialog(Map<String, dynamic>? contest) {
    final isEditing = contest != null;
    final nameController =
        TextEditingController(text: contest?['name'] ?? '');
    final entryFeeController = TextEditingController(
        text: '${contest?['entry_fee'] ?? 0}');
    final prizePoolController = TextEditingController(
        text: '${contest?['prize_pool'] ?? 0}');
    final maxTeamsController = TextEditingController(
        text: '${contest?['max_teams'] ?? 100}');
    String status = contest?['status'] ?? 'open';
    String contestType = contest?['contest_type'] ?? 'paid';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusLg,
          ),
          title: Text(
            isEditing ? 'Edit Contest' : 'Create Contest',
            style: AppTypography.titleLarge,
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: entryFeeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Entry Fee (\u20B9)',
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
                          labelText: 'Prize Pool (\u20B9)',
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
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
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
                  'entry_fee':
                      double.tryParse(entryFeeController.text) ?? 0,
                  'prize_pool':
                      double.tryParse(prizePoolController.text) ?? 0,
                  'max_teams':
                      int.tryParse(maxTeamsController.text) ?? 100,
                  'contest_type': contestType,
                  'status': status,
                  'joined_teams': contest?['joined_teams'] ?? 0,
                };
                bool success;
                if (isEditing) {
                  success = await ref
                      .read(adminProvider.notifier)
                      .updateContest(contest['id'], data);
                } else {
                  success = await ref
                      .read(adminProvider.notifier)
                      .createContest(data);
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
              await ref
                  .read(adminProvider.notifier)
                  .deleteContest(contest['id']);
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
