import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Navigation drawer for admin sections.
class AdminNavDrawer extends StatelessWidget {
  final String currentRoute;

  const AdminNavDrawer({
    super.key,
    this.currentRoute = '/admin',
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.admin_panel_settings,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  AppSpacing.gapH12,
                  Text(
                    'Admin Panel',
                    style: AppTypography.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'DreamTeam Fantasy',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _NavItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    route: '/admin',
                    isSelected: currentRoute == '/admin',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/admin');
                    },
                  ),
                  _NavItem(
                    icon: Icons.people_outlined,
                    label: 'Users',
                    route: '/admin/users',
                    isSelected: currentRoute == '/admin/users',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/users');
                    },
                  ),
                  _NavItem(
                    icon: Icons.emoji_events_outlined,
                    label: 'Tournaments',
                    route: '/admin/tournaments',
                    isSelected: currentRoute == '/admin/tournaments',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/tournaments');
                    },
                  ),
                  _NavItem(
                    icon: Icons.sports_cricket_outlined,
                    label: 'Matches',
                    route: '/admin/matches',
                    isSelected: currentRoute == '/admin/matches',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/matches');
                    },
                  ),
                  _NavItem(
                    icon: Icons.groups_outlined,
                    label: 'Teams',
                    route: '/admin/teams',
                    isSelected: currentRoute == '/admin/teams',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/teams');
                    },
                  ),
                  _NavItem(
                    icon: Icons.person_outlined,
                    label: 'Players',
                    route: '/admin/players',
                    isSelected: currentRoute == '/admin/players',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/players');
                    },
                  ),
                  _NavItem(
                    icon: Icons.sports_esports_outlined,
                    label: 'Contests',
                    route: '/admin/contests',
                    isSelected: currentRoute == '/admin/contests',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/contests');
                    },
                  ),
                  _NavItem(
                    icon: Icons.scoreboard_outlined,
                    label: 'Scoreboard',
                    route: '/admin/scoreboard',
                    isSelected: currentRoute == '/admin/scoreboard',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/scoreboard');
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  _NavItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Wallet Management',
                    route: '/admin/wallet',
                    isSelected: currentRoute == '/admin/wallet',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/wallet');
                    },
                  ),
                  _NavItem(
                    icon: Icons.bar_chart_outlined,
                    label: 'Reports',
                    route: '/admin/reports',
                    isSelected: currentRoute == '/admin/reports',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/reports');
                    },
                  ),
                  _NavItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    route: '/admin/settings',
                    isSelected: currentRoute == '/admin/settings',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/settings');
                    },
                  ),
                ],
              ),
            ),
            // Back to App
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/');
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to App'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        size: 22,
      ),
      title: Text(
        label,
        style: AppTypography.titleSmall.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      onTap: onTap,
    );
  }
}
