import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_nav_drawer.dart';

/// Admin payment methods screen - manage payment methods where user deposits go.
class AdminPaymentMethodsScreen extends ConsumerStatefulWidget {
  const AdminPaymentMethodsScreen({super.key});

  @override
  ConsumerState<AdminPaymentMethodsScreen> createState() =>
      _AdminPaymentMethodsScreenState();
}

class _AdminPaymentMethodsScreenState
    extends ConsumerState<AdminPaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(adminProvider.notifier).loadPaymentMethods(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final paymentMethods = adminState.paymentMethods;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Payment Methods',
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
            onPressed: () => _showAddMethodDialog(context),
            icon: const Icon(Icons.add, color: AppColors.primary),
          ),
        ],
      ),
      drawer: const AdminNavDrawer(currentRoute: '/admin/payment-methods'),
      body: adminState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : paymentMethods.isEmpty
              ? _EmptyState(onAdd: () => _showAddMethodDialog(context))
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(adminProvider.notifier).loadPaymentMethods(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: paymentMethods.length,
                    itemBuilder: (context, index) {
                      final method = paymentMethods[index];
                      return _PaymentMethodCard(
                        method: method,
                        onDelete: () => _deleteMethod(method['id'] as String),
                      );
                    },
                  ),
                ),
    );
  }

  void _showAddMethodDialog(BuildContext context) {
    final nameController = TextEditingController();
    final detailsController = TextEditingController();
    String selectedType = 'upi';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Add Payment Method', style: AppTypography.titleLarge),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Method Type', style: AppTypography.titleSmall),
                AppSpacing.gapH8,
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'upi', child: Text('UPI')),
                    DropdownMenuItem(
                        value: 'bank_account', child: Text('Bank Account')),
                    DropdownMenuItem(value: 'phonepe', child: Text('PhonePe')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => selectedType = value ?? 'upi');
                  },
                ),
                AppSpacing.gapH16,
                Text('Display Name', style: AppTypography.titleSmall),
                AppSpacing.gapH8,
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: _getHintForType(selectedType),
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                  ),
                ),
                AppSpacing.gapH16,
                Text('Details (ID/Number)', style: AppTypography.titleSmall),
                AppSpacing.gapH8,
                TextField(
                  controller: detailsController,
                  decoration: InputDecoration(
                    hintText: _getDetailHintForType(selectedType),
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
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    detailsController.text.isEmpty) {
                  return;
                }
                Navigator.pop(dialogContext);
                await ref
                    .read(adminProvider.notifier)
                    .createPaymentMethod({
                  'type': selectedType,
                  'label': nameController.text.trim(),
                  'details': _buildDetails(
                    selectedType,
                    detailsController.text.trim(),
                  ),
                  'is_active': true,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  String _getHintForType(String type) {
    switch (type) {
      case 'upi':
        return 'e.g., Admin UPI';
      case 'bank_account':
        return 'e.g., Admin Bank Account';
      case 'phonepe':
        return 'e.g., Admin PhonePe';
      default:
        return 'Name';
    }
  }

  String _getDetailHintForType(String type) {
    switch (type) {
      case 'upi':
        return 'e.g., admin@paytm';
      case 'bank_account':
        return 'e.g., 1234567890 (IFSC: SBIN0001234)';
      case 'phonepe':
        return 'e.g., 9876543210';
      default:
        return 'Details';
    }
  }

  Map<String, dynamic> _buildDetails(String type, String value) {
    switch (type) {
      case 'upi':
        return {'upi_id': value};
      case 'bank_account':
        return {'account_number': value};
      case 'phonepe':
        return {'phone': value};
      default:
        return {'value': value};
    }
  }

  Future<void> _deleteMethod(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content:
            const Text('Are you sure you want to remove this payment method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(adminProvider.notifier).deletePaymentMethod(id);
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          AppSpacing.gapH16,
          Text(
            'No payment methods configured',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.gapH8,
          Text(
            'Add payment methods where users can deposit',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          AppSpacing.gapH24,
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Payment Method',
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.borderRadiusSm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final Map<String, dynamic> method;
  final VoidCallback onDelete;

  const _PaymentMethodCard({
    required this.method,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final methodType = method['type'] as String? ?? 'upi';
    final displayName = method['label'] as String? ?? 'Payment Method';
    final details = method['details'] as Map<String, dynamic>? ?? {};
    final isActive = method['is_active'] as bool? ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: isActive
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getColorForType(methodType).withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Center(
              child: Icon(
                _getIconForType(methodType),
                color: _getColorForType(methodType),
                size: 22,
              ),
            ),
          ),
          AppSpacing.gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getDetailString(methodType, details),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Inactive',
                    style: AppTypography.labelSmall.copyWith(
                      color: isActive ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'upi':
        return Icons.account_balance_wallet;
      case 'bank_account':
        return Icons.account_balance;
      case 'phonepe':
        return Icons.phone_android;
      default:
        return Icons.payment;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'upi':
        return AppColors.primary;
      case 'bank_account':
        return AppColors.info;
      case 'phonepe':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getDetailString(String type, Map<String, dynamic> details) {
    switch (type) {
      case 'upi':
        return details['upi_id'] as String? ?? 'UPI ID';
      case 'bank_account':
        return details['account_number'] as String? ?? 'Bank Account';
      case 'phonepe':
        return details['phone'] as String? ?? 'Phone Number';
      default:
        return details.values.firstOrNull?.toString() ?? '';
    }
  }
}
