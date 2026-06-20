import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_nav_drawer.dart';
import '../widgets/chart_widget.dart';
import '../widgets/kpi_card.dart';

/// Admin reports screen with revenue, user, and tournament metrics.
class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(adminAnalyticsProvider);

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
          'Reports & Analytics',
          style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
      ),
      drawer: const AdminNavDrawer(currentRoute: '/admin/reports'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary KPIs
            Text('Overview', style: AppTypography.titleLarge),
            AppSpacing.gapH12,
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                KpiCard(
                  title: 'Total Revenue',
                  value:
                      '\u20B9${_formatNumber(analytics.totalRevenue)}',
                  icon: Icons.monetization_on_outlined,
                  color: AppColors.success,
                  trend: '+15%',
                  isTrendPositive: true,
                ),
                KpiCard(
                  title: 'Total Users',
                  value: '${analytics.totalUsers}',
                  icon: Icons.people_outlined,
                  color: AppColors.info,
                  trend: '+22%',
                  isTrendPositive: true,
                ),
                KpiCard(
                  title: 'Tournaments',
                  value: '${analytics.totalTournaments}',
                  icon: Icons.emoji_events_outlined,
                  color: AppColors.warning,
                ),
                KpiCard(
                  title: 'Teams',
                  value: '${analytics.totalTeams}',
                  icon: Icons.groups_outlined,
                  color: AppColors.primary,
                ),
              ],
            ),
            AppSpacing.gapH24,
            // Revenue Chart
            RevenueLineChart(
              title: 'Monthly Revenue',
              data: const [
                45000,
                52000,
                48000,
                61000,
                55000,
                72000,
                68000,
                85000,
                79000,
                92000,
                88000,
                105000,
              ],
              labels: const [
                'Jan',
                'Feb',
                'Mar',
                'Apr',
                'May',
                'Jun',
                'Jul',
                'Aug',
                'Sep',
                'Oct',
                'Nov',
                'Dec',
              ],
            ),
            AppSpacing.gapH16,
            // User Registrations
            StatsBarChart(
              title: 'Monthly User Registrations',
              data: const [120, 180, 150, 220, 190, 280, 250, 310, 290, 350, 320, 400],
              labels: const [
                'Jan',
                'Feb',
                'Mar',
                'Apr',
                'May',
                'Jun',
                'Jul',
                'Aug',
                'Sep',
                'Oct',
                'Nov',
                'Dec',
              ],
              barColor: AppColors.info,
            ),
            AppSpacing.gapH16,
            // Contest Type Distribution
            DistributionPieChart(
              title: 'Contest Distribution',
              data: const {
                'Paid': 65,
                'Free': 35,
              },
            ),
            AppSpacing.gapH16,
            // Match Status Distribution
            DistributionPieChart(
              title: 'Match Status',
              data: const {
                'Upcoming': 40,
                'Live': 15,
                'Completed': 45,
              },
            ),
            AppSpacing.gapH32,
          ],
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
