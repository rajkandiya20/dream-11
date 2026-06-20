import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/components/notification_controller.dart';
import '../../../../shared/components/top_notification.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/providers/auth_provider.dart';
import '../widgets/auth_header.dart';

/// Forgot password screen with email-based password reset.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).forgotPassword(
          email: _emailController.text.trim(),
        );

    if (mounted) {
      if (success) {
        setState(() => _emailSent = true);
        ref.read(notificationControllerProvider.notifier).showSuccess(
              title: 'Email Sent',
              message: 'Check your inbox for the reset link.',
            );
      } else {
        final error = ref.read(authProvider).errorMessage;
        if (error != null) {
          ref.read(notificationControllerProvider.notifier).showError(
                title: 'Reset Failed',
                message: error,
              );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header
                AuthHeader(
                  title: _emailSent ? 'Check Your Email' : 'Reset Password',
                  subtitle: _emailSent
                      ? 'We sent a password reset link to your email. Follow the instructions to reset your password.'
                      : "Enter the email address associated with your account and we'll send you a link to reset your password.",
                ),
                const SizedBox(height: 40),

                if (!_emailSent) ...[
                  // Email field
                  AppTextField(
                    label: 'Email',
                    hint: 'Enter your email address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icons.mail_outlined,
                    validator: Validators.email,
                    onSubmitted: (_) => _handleResetPassword(),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),
                  AppSpacing.gapH32,

                  // Reset button
                  AppButton(
                    text: 'Send Reset Link',
                    onPressed: isLoading ? null : _handleResetPassword,
                    isLoading: isLoading,
                    variant: AppButtonVariant.gradient,
                    size: AppButtonSize.large,
                  )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),
                ] else ...[
                  // Success state
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mark_email_read_outlined,
                        size: 48,
                        color: AppColors.success,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.8, 0.8)),
                  AppSpacing.gapH32,

                  // Resend button
                  AppButton(
                    text: 'Resend Email',
                    onPressed: isLoading ? null : _handleResetPassword,
                    isLoading: isLoading,
                    variant: AppButtonVariant.outline,
                    size: AppButtonSize.medium,
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 400.ms),
                  AppSpacing.gapH16,

                  // Back to login
                  AppButton(
                    text: 'Back to Sign In',
                    onPressed: () => context.pop(),
                    variant: AppButtonVariant.ghost,
                    size: AppButtonSize.medium,
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms),
                ],
                AppSpacing.gapH24,

                if (!_emailSent)
                  // Back to login link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Remember your password? ',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Text(
                            'Sign In',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
