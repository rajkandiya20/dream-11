import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_nav_drawer.dart';
import '../widgets/chart_widget.dart';
import '../widgets/kpi_card.dart';

/// Admin dashboard with KPIs, charts, and quick actions.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminProvider);
    final analytics = adminState.analytics;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => ref.read(adminProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
          ),
        ],
      ),
      drawer: const AdminNavDrawer(currentRoute: '/admin'),
      body: adminState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(adminProvider.notifier).refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KPI Cards Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: [
                        KpiCard(
                          title: 'Total Users',
                          value: '${analytics.totalUsers}',
                          icon: Icons.people_outlined,
                          color: AppColors.info,
                          trend: '+12%',
                          isTrendPositive: true,
                        ),
                        KpiCard(
                          title: 'Revenue',
                          value:
                              '\u20B9${_formatNumber(analytics.totalRevenue)}',
                          icon: Icons.monetization_on_outlined,
                          color: AppColors.success,
                          trend: '+8%',
                          isTrendPositive: true,
                        ),
                        KpiCard(
                          title: 'Active Matches',
                          value: '${analytics.activeMatches}',
                          icon: Icons.sports_cricket_outlined,
                          color: AppColors.warning,
                        ),
                        KpiCard(
                          title: 'Total Contests',
                          value: '${analytics.totalContests}',
                          icon: Icons.emoji_events_outlined,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    AppSpacing.gapH24,
                    // Pending Actions
                    if (analytics.pendingDeposits > 0 ||
                        analytics.pendingWithdrawals > 0)
                      _PendingActionsCard(
                        pendingDeposits: analytics.pendingDeposits,
                        pendingWithdrawals: analytics.pendingWithdrawals,
                        onTap: () => context.push('/admin/wallet'),
                      ),
                    AppSpacing.gapH24,
                    // Revenue Chart
                    RevenueLineChart(
                      title: 'Revenue (Last 7 Days)',
                      data: const [
                        12000,
                        15000,
                        10000,
                        18000,
                        22000,
                        19000,
                        25000
                      ],
                      labels: const [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun'
                      ],
                    ),
                    AppSpacing.gapH16,
                    // User Registration Chart
                    StatsBarChart(
                      title: 'New Users (Last 7 Days)',
                      data: const [45, 62, 38, 71, 55, 89, 76],
                      labels: const [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun'
                      ],
                      barColor: AppColors.info,
                    ),
                    AppSpacing.gapH24,
                    // Quick Actions
                    Text('Quick Actions', style: AppTypography.titleLarge),
                    AppSpacing.gapH12,
                    _QuickActionsGrid(context: context),
                    AppSpacing.gapH24,
                    // Recent Activity
                    _RecentActivitySection(),
                    AppSpacing.gapH32,
                  ],
                ),
              ),
            ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 10000000) return '${(value / 10000000).toStringAsFixed(1)}Cr';
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
}

/// Pending actions alert card.
class _PendingActionsCard extends StatelessWidget {
  final int pendingDeposits;
  final int pendingWithdrawals;
  final VoidCallback onTap;

  const _PendingActionsCard({
    required this.pendingDeposits,
    required this.pendingWithdrawals,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.05),
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.15),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: const Center(
                child: Icon(Icons.pending_actions,
                    color: AppColors.warning, size: 22),
              ),
            ),
            AppSpacing.gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pending Approvals',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$pendingDeposits deposits, $pendingWithdrawals withdrawals',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.warning),
          ],
        ),
      ),
    );
  }
}

/// Quick actions grid.
class _QuickActionsGrid extends StatelessWidget {
  final BuildContext context;

  const _QuickActionsGrid({required this.context});

  @override
  Widget build(BuildContext _) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _QuickAction(
          icon: Icons.person_add_outlined,
          label: 'Manage Users',
          color: AppColors.info,
          onTap: () => context.push('/admin/users'),
        ),
        _QuickAction(
          icon: Icons.sports_cricket_outlined,
          label: 'Add Match',
          color: AppColors.success,
          onTap: () => context.push('/admin/matches'),
        ),
        _QuickAction(
          icon: Icons.emoji_events_outlined,
          label: 'Tournaments',
          color: AppColors.warning,
          onTap: () => context.push('/admin/tournaments'),
        ),
        _QuickAction(
          icon: Icons.scoreboard_outlined,
          label: 'Update Scores',
          color: AppColors.primary,
          onTap: () => context.push('/admin/scoreboard'),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusSm,
      child: Container(
        width: (MediaQuery.of(context).size.width - 56) / 2,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppSpacing.borderRadiusSm,
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Center(child: Icon(icon, color: color, size: 18)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Recent activity section.
class _RecentActivitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activity', style: AppTypography.titleLarge),
        AppSpacing.gapH12,
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              _ActivityItem(
                icon: Icons.person_add,
                color: AppColors.info,
                text: 'New user registered',
                time: '2 min ago',
              ),
              const Divider(height: 24),
              _ActivityItem(
                icon: Icons.sports_cricket,
                color: AppColors.success,
                text: 'Match IND vs AUS started',
                time: '15 min ago',
              ),
              const Divider(height: 24),
              _ActivityItem(
                icon: Icons.monetization_on,
                color: AppColors.warning,
                text: 'Deposit of \u20B95,000 approved',
                time: '1 hour ago',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.text,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(child: Icon(icon, color: color, size: 16)),
        ),
        AppSpacing.gapW12,
        Expanded(
          child: Text(text, style: AppTypography.bodySmall),
        ),
        Text(
          time,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
