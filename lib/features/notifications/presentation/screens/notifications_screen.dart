import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../data/models/notification_model.dart';
import '../../domain/providers/notification_provider.dart';
import '../widgets/notification_tile.dart';

/// Notifications screen with categories and mark all read.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = const [
    Tab(text: 'All'),
    Tab(text: 'Match'),
    Tab(text: 'Winning'),
    Tab(text: 'Bonus'),
    Tab(text: 'General'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Row(
          children: [
            Text(
              'Notifications',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            if (notifState.hasUnread) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Text(
                  '${notifState.unreadCount}',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (notifState.hasUnread)
            TextButton(
              onPressed: () =>
                  ref.read(notificationProvider.notifier).markAllAsRead(),
              child: Text(
                'Read All',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: AppTypography.labelMedium,
          tabs: _tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _NotificationList(
            notifications: notifState.notifications,
            isLoading: notifState.isLoading,
          ),
          _NotificationList(
            notifications: notifState.getByType(NotificationType.match),
            isLoading: notifState.isLoading,
          ),
          _NotificationList(
            notifications: notifState.getByType(NotificationType.winning),
            isLoading: notifState.isLoading,
          ),
          _NotificationList(
            notifications: notifState.getByType(NotificationType.bonus),
            isLoading: notifState.isLoading,
          ),
          _NotificationList(
            notifications: notifState.getByType(NotificationType.general),
            isLoading: notifState.isLoading,
          ),
        ],
      ),
    );
  }
}

class _NotificationList extends ConsumerWidget {
  final List<NotificationModel> notifications;
  final bool isLoading;

  const _NotificationList({
    required this.notifications,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return ListView.builder(
        padding: AppSpacing.screenPadding,
        itemCount: 6,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShimmerLoading(width: double.infinity, height: 70),
        ),
      );
    }

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            AppSpacing.gapH16,
            Text(
              'No notifications',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.gapH8,
            Text(
              'You are all caught up!',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(notificationProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: AppColors.border.withOpacity(0.5),
          indent: 72,
        ),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationTile(
            notification: notification,
            onTap: () {
              if (!notification.isRead) {
                ref
                    .read(notificationProvider.notifier)
                    .markAsRead(notification.id);
              }
            },
            onDismiss: () {
              ref
                  .read(notificationProvider.notifier)
                  .deleteNotification(notification.id);
            },
          );
        },
      ),
    );
  }
}
