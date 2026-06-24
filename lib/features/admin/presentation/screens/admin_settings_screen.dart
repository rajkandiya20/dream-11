import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../features/notifications/services/push_notification_service.dart';
import '../widgets/admin_nav_drawer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Settings state & provider
// ─────────────────────────────────────────────────────────────────────────────

class AppSettings {
  final bool maintenanceMode;
  final bool allowRegistrations;
  final bool realTimeUpdates;
  final bool pushNotifications;
  final bool emailNotifications;
  final bool autoApproveDeposits;
  final double minDeposit;
  final double minWithdrawal;
  final double maxWithdrawal;
  final String supportUpiId;
  final String supportPhone;

  const AppSettings({
    this.maintenanceMode    = false,
    this.allowRegistrations = true,
    this.realTimeUpdates    = true,
    this.pushNotifications  = true,
    this.emailNotifications = true,
    this.autoApproveDeposits = false,
    this.minDeposit    = 10,
    this.minWithdrawal = 100,
    this.maxWithdrawal = 100000,
    this.supportUpiId  = '7259293140@ybl',
    this.supportPhone  = '7259293140',
  });

  AppSettings copyWith({
    bool? maintenanceMode,
    bool? allowRegistrations,
    bool? realTimeUpdates,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? autoApproveDeposits,
    double? minDeposit,
    double? minWithdrawal,
    double? maxWithdrawal,
    String? supportUpiId,
    String? supportPhone,
  }) => AppSettings(
    maintenanceMode:     maintenanceMode    ?? this.maintenanceMode,
    allowRegistrations:  allowRegistrations ?? this.allowRegistrations,
    realTimeUpdates:     realTimeUpdates    ?? this.realTimeUpdates,
    pushNotifications:   pushNotifications  ?? this.pushNotifications,
    emailNotifications:  emailNotifications ?? this.emailNotifications,
    autoApproveDeposits: autoApproveDeposits ?? this.autoApproveDeposits,
    minDeposit:    minDeposit    ?? this.minDeposit,
    minWithdrawal: minWithdrawal ?? this.minWithdrawal,
    maxWithdrawal: maxWithdrawal ?? this.maxWithdrawal,
    supportUpiId:  supportUpiId  ?? this.supportUpiId,
    supportPhone:  supportPhone  ?? this.supportPhone,
  );

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    maintenanceMode:     json['maintenance_mode']    as bool? ?? false,
    allowRegistrations:  json['allow_registrations'] as bool? ?? true,
    realTimeUpdates:     json['realtime_updates']    as bool? ?? true,
    pushNotifications:   json['push_notifications']  as bool? ?? true,
    emailNotifications:  json['email_notifications'] as bool? ?? true,
    autoApproveDeposits: json['auto_approve_deposits'] as bool? ?? false,
    minDeposit:    (json['min_deposit']    as num?)?.toDouble() ?? 10,
    minWithdrawal: (json['min_withdrawal'] as num?)?.toDouble() ?? 100,
    maxWithdrawal: (json['max_withdrawal'] as num?)?.toDouble() ?? 100000,
    supportUpiId:  json['support_upi_id']  as String? ?? '7259293140@ybl',
    supportPhone:  json['support_phone']   as String? ?? '7259293140',
  );

  Map<String, dynamic> toJson() => {
    'maintenance_mode':     maintenanceMode,
    'allow_registrations':  allowRegistrations,
    'realtime_updates':     realTimeUpdates,
    'push_notifications':   pushNotifications,
    'email_notifications':  emailNotifications,
    'auto_approve_deposits': autoApproveDeposits,
    'min_deposit':    minDeposit,
    'min_withdrawal': minWithdrawal,
    'max_withdrawal': maxWithdrawal,
    'support_upi_id': supportUpiId,
    'support_phone':  supportPhone,
  };
}

class _SettingsNotifier extends StateNotifier<AsyncValue<AppSettings>> {
  final SupabaseClient _client;
  _SettingsNotifier(this._client) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final row = await _client
          .from('app_settings')
          .select()
          .eq('id', 1)
          .maybeSingle();
      state = AsyncValue.data(
        row != null ? AppSettings.fromJson(row) : const AppSettings(),
      );
    } catch (e) {
      state = AsyncValue.data(const AppSettings());
    }
  }

  Future<void> update(AppSettings settings) async {
    state = AsyncValue.data(settings);
    try {
      await _client.from('app_settings').upsert(
        {'id': 1, ...settings.toJson()},
        onConflict: 'id',
      );
    } catch (e) {
      debugPrint('Settings save error: $e');
    }
  }
}

final _settingsProvider =
    StateNotifierProvider<_SettingsNotifier, AsyncValue<AppSettings>>((ref) {
  return _SettingsNotifier(ref.watch(supabaseClientProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(_settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            onPressed: () => Scaffold.of(ctx).openDrawer(),
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          ),
        ),
        title: Text('Settings',
            style: AppTypography.titleLarge
                .copyWith(color: AppColors.textPrimary)),
        actions: [
          if (settingsAsync is AsyncData)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text('Auto-saved',
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.success)),
              ),
            ),
        ],
      ),
      drawer: const AdminNavDrawer(currentRoute: '/admin/settings'),
      body: settingsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (settings) => _SettingsBody(settings: settings),
      ),
    );
  }
}

class _SettingsBody extends ConsumerStatefulWidget {
  final AppSettings settings;
  const _SettingsBody({required this.settings});

  @override
  ConsumerState<_SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends ConsumerState<_SettingsBody> {
  late AppSettings _s;
  final _minDepositCtrl    = TextEditingController();
  final _minWithdrawCtrl   = TextEditingController();
  final _maxWithdrawCtrl   = TextEditingController();
  final _upiCtrl           = TextEditingController();
  final _phoneCtrl         = TextEditingController();
  final _broadcastTitleCtrl= TextEditingController();
  final _broadcastMsgCtrl  = TextEditingController();
  bool _sendingBroadcast   = false;

  @override
  void initState() {
    super.initState();
    _s = widget.settings;
    _minDepositCtrl.text  = _s.minDeposit.toStringAsFixed(0);
    _minWithdrawCtrl.text = _s.minWithdrawal.toStringAsFixed(0);
    _maxWithdrawCtrl.text = _s.maxWithdrawal.toStringAsFixed(0);
    _upiCtrl.text         = _s.supportUpiId;
    _phoneCtrl.text       = _s.supportPhone;
  }

  @override
  void dispose() {
    _minDepositCtrl.dispose();
    _minWithdrawCtrl.dispose();
    _maxWithdrawCtrl.dispose();
    _upiCtrl.dispose();
    _phoneCtrl.dispose();
    _broadcastTitleCtrl.dispose();
    _broadcastMsgCtrl.dispose();
    super.dispose();
  }

  void _save(AppSettings updated) {
    setState(() => _s = updated);
    ref.read(_settingsProvider.notifier).update(updated);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── App Settings ─────────────────────────────────────────────
          _SectionTitle('App Settings'),
          _Card(children: [
            _Toggle(
              title: 'Maintenance Mode',
              subtitle: 'Block all users from accessing the app',
              value: _s.maintenanceMode,
              activeColor: AppColors.error,
              onChanged: (v) => _save(_s.copyWith(maintenanceMode: v)),
            ),
            const Divider(),
            _Toggle(
              title: 'Allow Registrations',
              subtitle: 'Let new users sign up',
              value: _s.allowRegistrations,
              onChanged: (v) => _save(_s.copyWith(allowRegistrations: v)),
            ),
            const Divider(),
            _Toggle(
              title: 'Real-time Updates',
              subtitle: 'Enable live score & match updates',
              value: _s.realTimeUpdates,
              onChanged: (v) => _save(_s.copyWith(realTimeUpdates: v)),
            ),
          ]),
          AppSpacing.gapH24,

          // ── Notification Settings ────────────────────────────────────
          _SectionTitle('Notifications'),
          _Card(children: [
            _Toggle(
              title: 'Push Notifications',
              subtitle: 'Send FCM push to user devices',
              value: _s.pushNotifications,
              onChanged: (v) => _save(_s.copyWith(pushNotifications: v)),
            ),
            const Divider(),
            _Toggle(
              title: 'Email Notifications',
              subtitle: 'Send email for wins & deposits',
              value: _s.emailNotifications,
              onChanged: (v) =>
                  _save(_s.copyWith(emailNotifications: v)),
            ),
          ]),
          AppSpacing.gapH16,

          // Send broadcast notification
          _Card(children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('Send Broadcast Notification',
                  style: AppTypography.titleSmall),
            ),
            AppSpacing.gapH8,
            TextField(
              controller: _broadcastTitleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            AppSpacing.gapH8,
            TextField(
              controller: _broadcastMsgCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            AppSpacing.gapH12,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white),
                icon: _sendingBroadcast
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send, size: 18),
                label: Text(_sendingBroadcast
                    ? 'Sending...'
                    : 'Send to All Users'),
                onPressed: _sendingBroadcast ? null : _sendBroadcast,
              ),
            ),
          ]),
          AppSpacing.gapH24,

          // ── Payment Settings ─────────────────────────────────────────
          _SectionTitle('Payment Settings'),
          _Card(children: [
            _Toggle(
              title: 'Auto-approve Deposits',
              subtitle: 'Skip admin approval for deposits',
              value: _s.autoApproveDeposits,
              onChanged: (v) =>
                  _save(_s.copyWith(autoApproveDeposits: v)),
            ),
            const Divider(),
            _NumField(
              label: 'Minimum Deposit (₹)',
              controller: _minDepositCtrl,
              onChanged: (v) {
                final d = double.tryParse(v);
                if (d != null) _save(_s.copyWith(minDeposit: d));
              },
            ),
            const Divider(),
            _NumField(
              label: 'Minimum Withdrawal (₹)',
              controller: _minWithdrawCtrl,
              onChanged: (v) {
                final d = double.tryParse(v);
                if (d != null) _save(_s.copyWith(minWithdrawal: d));
              },
            ),
            const Divider(),
            _NumField(
              label: 'Maximum Withdrawal (₹)',
              controller: _maxWithdrawCtrl,
              onChanged: (v) {
                final d = double.tryParse(v);
                if (d != null) _save(_s.copyWith(maxWithdrawal: d));
              },
            ),
          ]),
          AppSpacing.gapH24,

          // ── Support / UPI ─────────────────────────────────────────────
          _SectionTitle('Support & Payment UPI'),
          _Card(children: [
            _TextField(
              label: 'Support UPI ID',
              controller: _upiCtrl,
              hint: '9876543210@ybl',
              onChanged: (v) => _save(_s.copyWith(supportUpiId: v)),
            ),
            const Divider(),
            _TextField(
              label: 'Support Phone',
              controller: _phoneCtrl,
              hint: '9876543210',
              onChanged: (v) => _save(_s.copyWith(supportPhone: v)),
            ),
          ]),
          AppSpacing.gapH24,

          // ── Danger Zone ───────────────────────────────────────────────
          _SectionTitle('Danger Zone', color: AppColors.error),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.05),
              borderRadius: AppSpacing.borderRadiusMd,
              border:
                  Border.all(color: AppColors.error.withOpacity(0.2)),
            ),
            child: Column(children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Clear Notification Queue',
                    style: AppTypography.titleSmall
                        .copyWith(color: AppColors.error)),
                subtitle: Text('Delete all pending notifications',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
                trailing: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  onPressed: () => _clearNotificationQueue(context),
                  child: const Text('Clear'),
                ),
              ),
            ]),
          ),
          AppSpacing.gapH32,
        ],
      ),
    );
  }

  Future<void> _sendBroadcast() async {
    final title = _broadcastTitleCtrl.text.trim();
    final msg   = _broadcastMsgCtrl.text.trim();
    if (title.isEmpty || msg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter title and message'),
      ));
      return;
    }
    setState(() => _sendingBroadcast = true);
    await ref.read(pushNotificationServiceProvider).sendBroadcast(
      title: title,
      message: msg,
      type: 'offer',
    );
    setState(() => _sendingBroadcast = false);
    _broadcastTitleCtrl.clear();
    _broadcastMsgCtrl.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✅ Broadcast notification queued!'),
        backgroundColor: AppColors.success,
      ));
    }
  }

  Future<void> _clearNotificationQueue(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Queue?'),
        content: const Text(
            'This will delete all pending notification queue entries.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref
          .read(supabaseClientProvider)
          .from('notification_queue')
          .delete()
          .eq('status', 'pending');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Notification queue cleared'),
          backgroundColor: AppColors.success,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  final Color? color;
  const _SectionTitle(this.text, {this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text,
            style: AppTypography.titleLarge.copyWith(
                color: color ?? AppColors.textPrimary)),
      );
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Column(children: children),
      );
}

class _Toggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;

  const _Toggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: AppTypography.titleSmall),
        subtitle: Text(subtitle,
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textSecondary)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: activeColor ?? AppColors.primary,
        ),
      );
}

class _NumField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _NumField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: AppTypography.titleSmall),
        trailing: SizedBox(
          width: 110,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            onChanged: onChanged,
            decoration: InputDecoration(
              isDense: true,
              prefixText: '₹',
              border: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusSm),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 6),
            ),
          ),
        ),
      );
}

class _TextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _TextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: AppTypography.titleSmall),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              border: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusSm),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 8),
            ),
          ),
        ),
      );
}
