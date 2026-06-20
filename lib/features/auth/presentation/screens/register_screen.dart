import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
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
import '../widgets/social_login_button.dart';

/// Registration screen with full validation and premium design.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isGoogleLoading = false;
  bool _isGitHubLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          username: _usernameController.text.trim(),
          phoneNumber: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
        );

    if (success && mounted) {
      ref.read(notificationControllerProvider.notifier).showSuccess(
            title: 'Account Created',
            message: 'Welcome to Dream Team Fantasy!',
          );
      context.go(AppRoutes.home);
    } else if (mounted) {
      final error = ref.read(authProvider).errorMessage;
      if (error != null) {
        ref.read(notificationControllerProvider.notifier).showError(
              title: 'Registration Failed',
              message: error,
            );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    final success = await ref.read(authProvider.notifier).signInWithGoogle();
    if (mounted) {
      setState(() => _isGoogleLoading = false);
      if (success) {
        context.go(AppRoutes.home);
      }
    }
  }

  Future<void> _handleGitHubSignIn() async {
    setState(() => _isGitHubLoading = true);
    final success = await ref.read(authProvider.notifier).signInWithGitHub();
    if (mounted) {
      setState(() => _isGitHubLoading = false);
      if (success) {
        context.go(AppRoutes.home);
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
                // Header
                const AuthHeader(
                  title: 'Create Account',
                  subtitle: 'Join thousands of cricket fans and win big!',
                ),
                const SizedBox(height: 32),

                // Username field
                AppTextField(
                  label: 'Username',
                  hint: 'Choose a username',
                  controller: _usernameController,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.person_outlined,
                  validator: Validators.username,
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
                AppSpacing.gapH16,

                // Email field
                AppTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.mail_outlined,
                  validator: Validators.email,
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
                AppSpacing.gapH16,

                // Phone field (optional)
                AppTextField(
                  label: 'Phone Number (Optional)',
                  hint: '+91 9876543210',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.phone_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    return Validators.phoneNumber(value);
                  },
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
                AppSpacing.gapH16,

                // Password field
                AppTextField(
                  label: 'Password',
                  hint: 'Create a strong password',
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.lock_outlined,
                  validator: Validators.strongPassword,
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
                AppSpacing.gapH16,

                // Confirm Password field
                AppTextField(
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: Icons.lock_outlined,
                  validator: (value) => Validators.confirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  onSubmitted: (_) => _handleRegister(),
                )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
                AppSpacing.gapH24,

                // Password requirements hint
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.05),
                    borderRadius: AppSpacing.borderRadiusMd,
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outlined,
                        size: 16,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Password must be 8+ chars with uppercase, lowercase, number & special character',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 750.ms, duration: 300.ms),
                AppSpacing.gapH24,

                // Register button
                AppButton(
                  text: 'Create Account',
                  onPressed: isLoading ? null : _handleRegister,
                  isLoading: isLoading,
                  variant: AppButtonVariant.gradient,
                  size: AppButtonSize.large,
                )
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
                AppSpacing.gapH24,

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Container(height: 1, color: AppColors.border),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or sign up with',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(height: 1, color: AppColors.border),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 850.ms, duration: 300.ms),
                AppSpacing.gapH24,

                // Social buttons
                SocialLoginButton(
                  provider: SocialProvider.google,
                  onPressed: _handleGoogleSignIn,
                  isLoading: _isGoogleLoading,
                )
                    .animate()
                    .fadeIn(delay: 900.ms, duration: 400.ms),
                AppSpacing.gapH12,
                SocialLoginButton(
                  provider: SocialProvider.github,
                  onPressed: _handleGitHubSignIn,
                  isLoading: _isGitHubLoading,
                )
                    .animate()
                    .fadeIn(delay: 950.ms, duration: 400.ms),
                AppSpacing.gapH24,

                // Login link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
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
                    .fadeIn(delay: 1000.ms, duration: 400.ms),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
