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
      ),
      drawer: const AdminNavDrawer(currentRoute: '/admin/contests'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AdminDataTable(
          title: 'Manage Contests',
          columns: const ['Name', 'Entry Fee', 'Prize Pool', 'Status'],
          displayKeys: const ['name', 'entry_fee', 'prize_pool', 'status'],
          rows: adminState.contests,
          isLoading: adminState.isLoading,
          onAdd: () => _showCreateDialog(),
          onEdit: (contest) => _showEditDialog(contest),
          onDelete: (contest) async {
            await ref
                .read(adminProvider.notifier)
                .deleteContest(contest['id'] as String);
          },
        ),
      ),
    );
  }

  void _showCreateDialog() {
    final nameController = TextEditingController();
    final entryFeeController = TextEditingController(text: '0');
    final prizePoolController = TextEditingController(text: '0');
    final maxTeamsController = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLg),
        title: Text('Create Contest', style: AppTypography.titleLarge),
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
                  labelText: 'Entry Fee (\u20B9)',
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
                  labelText: 'Prize Pool (\u20B9)',
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                ),
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
                  await ref.read(adminProvider.notifier).createContest({
                'name': nameController.text.trim(),
                'entry_fee':
                    double.tryParse(entryFeeController.text) ?? 0,
                'prize_pool':
                    double.tryParse(prizePoolController.text) ?? 0,
                'max_teams':
                    int.tryParse(maxTeamsController.text) ?? 100,
                'contest_type': 'paid',
                'status': 'open',
                'joined_teams': 0,
              });
              if (success && mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
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
          title: Text('Edit Contest', style: AppTypography.titleLarge),
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
                    labelText: 'Entry Fee',
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
                    labelText: 'Prize Pool',
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
