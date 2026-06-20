import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_nav_drawer.dart';

/// Admin users management screen with search, filters, and role management.
class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadUsers();
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
          'User Management',
          style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
      ),
      drawer: const AdminNavDrawer(currentRoute: '/admin/users'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AdminDataTable(
          title: 'All Users',
          columns: const ['Username', 'Email', 'Role', 'Balance'],
          displayKeys: const ['username', 'email', 'role', 'balance'],
          rows: adminState.users,
          isLoading: adminState.isLoading,
          searchHint: 'Search by username or email...',
          onSearch: (query) {
            ref.read(adminProvider.notifier).loadUsers(search: query);
          },
          onEdit: (user) => _showRoleDialog(user),
          onDelete: null,
        ),
      ),
    );
  }

  void _showRoleDialog(Map<String, dynamic> user) {
    final currentRole = user['role'] as String? ?? 'user';
    String selectedRole = currentRole;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusLg,
          ),
          title: Text('Update Role', style: AppTypography.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User: ${user['username'] ?? user['email']}',
                style: AppTypography.bodyMedium,
              ),
              AppSpacing.gapH16,
              ...['user', 'admin', 'super_admin'].map((role) {
                return RadioListTile<String>(
                  title: Text(role),
                  value: role,
                  groupValue: selectedRole,
                  onChanged: (value) {
                    setDialogState(() => selectedRole = value!);
                  },
                  activeColor: AppColors.primary,
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(adminProvider.notifier).updateUserRole(
                      user['id'] as String,
                      selectedRole,
                    );
                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
