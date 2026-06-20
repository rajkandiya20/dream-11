import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Skeleton loading widget for lists, cards, and profiles.
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius,
    this.margin,
  });

  /// Circular shimmer for avatars.
  factory ShimmerLoading.circular({
    Key? key,
    double size = 48,
    EdgeInsets? margin,
  }) {
    return ShimmerLoading(
      key: key,
      width: size,
      height: size,
      borderRadius: AppSpacing.borderRadiusFull,
      margin: margin,
    );
  }

  /// Rectangular shimmer for text lines.
  factory ShimmerLoading.text({
    Key? key,
    double width = 120,
    double height = 14,
    EdgeInsets? margin,
  }) {
    return ShimmerLoading(
      key: key,
      width: width,
      height: height,
      borderRadius: AppSpacing.borderRadiusSm,
      margin: margin,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: borderRadius ?? AppSpacing.borderRadiusMd,
        ),
      ),
    );
  }
}

/// Shimmer loading for a card-shaped placeholder.
class ShimmerCard extends StatelessWidget {
  final double? height;
  final EdgeInsets? margin;

  const ShimmerCard({
    super.key,
    this.height = 120,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        height: height,
        margin: margin ?? const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: AppSpacing.borderRadiusMd,
        ),
      ),
    );
  }
}

/// Shimmer loading for a list of items.
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsets? padding;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? AppSpacing.horizontalLg,
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Shimmer.fromColors(
            baseColor: AppColors.shimmerBase,
            highlightColor: AppColors.shimmerHighlight,
            child: Container(
              height: itemHeight,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.shimmerBase,
                borderRadius: AppSpacing.borderRadiusMd,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading for a profile section.
class ShimmerProfile extends StatelessWidget {
  const ShimmerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.shimmerBase,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 16),
            // Name
            Container(
              width: 150,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.shimmerBase,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
            ),
            const SizedBox(height: 8),
            // Email
            Container(
              width: 200,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.shimmerBase,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
            ),
            const SizedBox(height: 24),
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                3,
                (_) => Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.shimmerBase,
                    borderRadius: AppSpacing.borderRadiusMd,
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
