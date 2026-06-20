import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/admin_nav_drawer.dart';

/// Admin settings screen - app settings and admin management.
class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          'Settings',
          style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
      ),
      drawer: const AdminNavDrawer(currentRoute: '/admin/settings'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Settings Section
            Text('App Settings', style: AppTypography.titleLarge),
            AppSpacing.gapH12,
            _SettingsCard(
              children: [
                _SettingsToggle(
                  title: 'Maintenance Mode',
                  subtitle: 'Disable app access for users during maintenance',
                  value: false,
                  onChanged: (val) {},
                ),
                const Divider(),
                _SettingsToggle(
                  title: 'Allow Registrations',
                  subtitle: 'Allow new users to register',
                  value: true,
                  onChanged: (val) {},
                ),
                const Divider(),
                _SettingsToggle(
                  title: 'Real-time Updates',
                  subtitle: 'Enable real-time score and match updates',
                  value: true,
                  onChanged: (val) {},
                ),
              ],
            ),
            AppSpacing.gapH24,
            // Notifications Settings
            Text('Notification Settings', style: AppTypography.titleLarge),
            AppSpacing.gapH12,
            _SettingsCard(
              children: [
                _SettingsToggle(
                  title: 'Push Notifications',
                  subtitle: 'Send push notifications to users',
                  value: true,
                  onChanged: (val) {},
                ),
                const Divider(),
                _SettingsToggle(
                  title: 'Email Notifications',
                  subtitle: 'Send email for important events',
                  value: true,
                  onChanged: (val) {},
                ),
              ],
            ),
            AppSpacing.gapH24,
            // Payment Settings
            Text('Payment Settings', style: AppTypography.titleLarge),
            AppSpacing.gapH12,
            _SettingsCard(
              children: [
                _SettingsItem(
                  title: 'Minimum Deposit',
                  trailing: '\u20B910',
                ),
                const Divider(),
                _SettingsItem(
                  title: 'Minimum Withdrawal',
                  trailing: '\u20B9100',
                ),
                const Divider(),
                _SettingsItem(
                  title: 'Maximum Withdrawal',
                  trailing: '\u20B91,00,000',
                ),
                const Divider(),
                _SettingsToggle(
                  title: 'Auto-approve Deposits',
                  subtitle: 'Automatically approve deposit requests',
                  value: false,
                  onChanged: (val) {},
                ),
              ],
            ),
            AppSpacing.gapH24,
            // Admin Management
            Text('Admin Management', style: AppTypography.titleLarge),
            AppSpacing.gapH12,
            _SettingsCard(
              children: [
                _SettingsItem(
                  title: 'Manage Admins',
                  subtitle: 'Add or remove admin users',
                  trailing: null,
                  onTap: () {},
                  showChevron: true,
                ),
                const Divider(),
                _SettingsItem(
                  title: 'Activity Log',
                  subtitle: 'View admin actions history',
                  trailing: null,
                  onTap: () {},
                  showChevron: true,
                ),
                const Divider(),
                _SettingsItem(
                  title: 'Permissions',
                  subtitle: 'Configure role-based permissions',
                  trailing: null,
                  onTap: () {},
                  showChevron: true,
                ),
              ],
            ),
            AppSpacing.gapH24,
            // Danger Zone
            Text(
              'Danger Zone',
              style: AppTypography.titleLarge.copyWith(color: AppColors.error),
            ),
            AppSpacing.gapH12,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.05),
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Clear All Data',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    subtitle: Text(
                      'Remove all user and match data permanently',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: const Text('Clear'),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapH32,
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppTypography.titleSmall),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  const _SettingsItem({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppTypography.titleSmall),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: trailing != null
          ? Text(trailing!, style: AppTypography.titleSmall)
          : showChevron
              ? const Icon(Icons.chevron_right, color: AppColors.textTertiary)
              : null,
      onTap: onTap,
    );
  }
}
