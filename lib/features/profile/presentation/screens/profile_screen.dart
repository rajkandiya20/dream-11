import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../wallet/domain/providers/wallet_provider.dart';
import '../../domain/providers/profile_provider.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/stats_card.dart';

/// Premium profile screen with user info, stats, rank, achievements.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final walletState = ref.watch(walletProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: profileState.isLoading
          ? const _ProfileLoadingState()
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => ref.read(profileProvider.notifier).refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // Profile Header
                  SliverToBoxAdapter(
                    child: _ProfileHeader(
                      username: profileState.user?.displayName ?? 'User',
                      email: profileState.user?.email ?? '',
                      avatarUrl: profileState.user?.avatarUrl,
                      tier: profileState.stats.tier,
                      onEditProfile: () =>
                          context.push(AppRoutes.editProfile),
                    ),
                  ),
                  // Wallet Summary
                  SliverToBoxAdapter(
                    child: _WalletSummary(
                      totalBalance: walletState.totalBalance,
                      onTap: () => context.go(AppRoutes.wallet),
                    ),
                  ),
                  // Admin Panel Button (only for admin users)
                  if (authState.isAdmin)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: GestureDetector(
                          onTap: () => context.push(AppRoutes.adminDashboard),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: AppSpacing.borderRadiusMd,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: AppSpacing.borderRadiusSm,
                                  ),
                                  child: const Icon(
                                    Icons.admin_panel_settings,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                AppSpacing.gapW12,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Admin Panel',
                                        style: AppTypography.titleSmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        'Manage app settings & users',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Stats Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your Stats', style: AppTypography.titleLarge),
                          AppSpacing.gapH16,
                          StatsGrid(
                            matchesPlayed: profileState.stats.matchesPlayed,
                            contestsWon: profileState.stats.contestsWon,
                            totalWinnings: profileState.stats.totalWinnings,
                            teamsCreated:
                                profileState.stats.fantasyTeamsCreated,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Achievements Section
                  if (profileState.achievements.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                        child: Row(
                          children: [
                            Icon(Icons.emoji_events_outlined,
                                size: 20, color: AppColors.warning),
                            AppSpacing.gapW8,
                            Text(
                              'Achievements',
                              style: AppTypography.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: AchievementBadge(
                              achievement: profileState.achievements[index],
                            ),
                          );
                        },
                        childCount: profileState.achievements.length,
                      ),
                    ),
                  ],
                  // Settings & Actions
                  SliverToBoxAdapter(
                    child: _SettingsSection(
                      isAdmin: authState.isAdmin,
                      onLogout: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          context.go(AppRoutes.login);
                        }
                      },
                    ),
                  ),
                  // Bottom spacing
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Profile header with avatar, name, tier.
class _ProfileHeader extends StatelessWidget {
  final String username;
  final String email;
  final String? avatarUrl;
  final String tier;
  final VoidCallback onEditProfile;

  const _ProfileHeader({
    required this.username,
    required this.email,
    this.avatarUrl,
    required this.tier,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Top row with edit button
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: onEditProfile,
              icon: const Icon(Icons.edit_outlined, color: Colors.white70),
            ),
          ),
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 3),
              image: avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: avatarUrl == null ? AppColors.secondaryLight : null,
            ),
            child: avatarUrl == null
                ? Center(
                    child: Text(
                      username.isNotEmpty
                          ? username[0].toUpperCase()
                          : 'U',
                      style: AppTypography.headlineLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  )
                : null,
          ),
          AppSpacing.gapH12,
          // Name
          Text(
            username,
            style: AppTypography.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          AppSpacing.gapH12,
          // Tier badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _getTierColor().withOpacity(0.15),
              borderRadius: AppSpacing.borderRadiusFull,
              border: Border.all(color: _getTierColor().withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium, color: _getTierColor(), size: 16),
                const SizedBox(width: 6),
                Text(
                  '$tier Player',
                  style: AppTypography.labelMedium.copyWith(
                    color: _getTierColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTierColor() {
    switch (tier) {
      case 'Diamond':
        return const Color(0xFFB9F2FF);
      case 'Platinum':
        return const Color(0xFFE5E4E2);
      case 'Gold':
        return AppColors.warning;
      case 'Silver':
        return const Color(0xFFC0C0C0);
      default:
        return const Color(0xFFCD7F32);
    }
  }
}

/// Wallet summary card.
class _WalletSummary extends StatelessWidget {
  final double totalBalance;
  final VoidCallback onTap;

  const _WalletSummary({
    required this.totalBalance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: const Center(
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.success,
                    size: 22,
                  ),
                ),
              ),
              AppSpacing.gapW12,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wallet Balance',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '\u20B9${totalBalance.toStringAsFixed(2)}',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Settings and actions section.
class _SettingsSection extends StatelessWidget {
  final bool isAdmin;
  final VoidCallback onLogout;

  const _SettingsSection({
    required this.isAdmin,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: AppTypography.titleLarge),
          AppSpacing.gapH12,
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () => context.push(AppRoutes.editProfile),
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () => context.push(AppRoutes.notifications),
          ),
          _SettingsTile(
            icon: Icons.group_outlined,
            title: 'My Groups',
            onTap: () => context.push(AppRoutes.groups),
          ),
          if (isAdmin)
            _SettingsTile(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Admin Dashboard',
              onTap: () => context.push(AppRoutes.adminDashboard),
              color: AppColors.primary,
            ),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {},
          ),
          AppSpacing.gapH8,
          _SettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            onTap: onLogout,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color ?? AppColors.textSecondary, size: 22),
      title: Text(
        title,
        style: AppTypography.titleSmall.copyWith(
          color: color ?? AppColors.textPrimary,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}

/// Loading state skeleton.
class _ProfileLoadingState extends StatelessWidget {
  const _ProfileLoadingState();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          const SizedBox(height: 40),
          const ShimmerLoading(width: 80, height: 80),
          AppSpacing.gapH16,
          const ShimmerLoading(width: 150, height: 20),
          AppSpacing.gapH8,
          const ShimmerLoading(width: 200, height: 14),
          AppSpacing.gapH32,
          const ShimmerLoading(width: double.infinity, height: 80),
          AppSpacing.gapH16,
          const ShimmerLoading(width: double.infinity, height: 200),
        ],
      ),
    );
  }
}
