import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/providers/profile_provider.dart';

/// Edit profile screen.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final profileState = ref.read(profileProvider);
    _usernameController =
        TextEditingController(text: profileState.user?.username ?? '');
    _phoneController =
        TextEditingController(text: profileState.user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text(
          'Edit Profile',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondaryLight,
                        border:
                            Border.all(color: AppColors.primary, width: 3),
                        image: profileState.user?.avatarUrl != null
                            ? DecorationImage(
                                image: NetworkImage(
                                    profileState.user!.avatarUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: profileState.user?.avatarUrl == null
                          ? Center(
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 48,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.surface, width: 2),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapH32,
              // Username
              Text('Username', style: AppTypography.titleSmall),
              AppSpacing.gapH8,
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Enter your username',
                  prefixIcon:
                      const Icon(Icons.person_outline, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppSpacing.borderRadiusMd,
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username is required';
                  }
                  return null;
                },
              ),
              AppSpacing.gapH20,
              // Phone
              Text('Phone Number', style: AppTypography.titleSmall),
              AppSpacing.gapH8,
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter your phone number',
                  prefixIcon:
                      const Icon(Icons.phone_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppSpacing.borderRadiusMd,
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              AppSpacing.gapH20,
              // Email (read-only)
              Text('Email', style: AppTypography.titleSmall),
              AppSpacing.gapH8,
              TextFormField(
                initialValue: profileState.user?.email ?? '',
                readOnly: true,
                decoration: InputDecoration(
                  prefixIcon:
                      const Icon(Icons.email_outlined, size: 20),
                  filled: true,
                  fillColor: AppColors.scaffoldBackground,
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.borderRadiusMd,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              AppSpacing.gapH32,
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: profileState.isUpdating
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          final success = await ref
                              .read(profileProvider.notifier)
                              .updateProfile(
                                username: _usernameController.text.trim(),
                                phoneNumber: _phoneController.text.trim(),
                              );
                          if (success && mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Profile updated successfully!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderRadiusMd,
                    ),
                  ),
                  child: profileState.isUpdating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: AppTypography.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
