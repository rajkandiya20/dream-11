import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Network image widget with placeholder, error state, and caching.
class CachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;
  final double placeholderIconSize;

  const CachedImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.image_outlined,
    this.placeholderIconSize = 32,
  });

  /// Circular avatar image.
  factory CachedImage.avatar({
    Key? key,
    String? imageUrl,
    double size = 48,
  }) {
    return CachedImage(
      key: key,
      imageUrl: imageUrl,
      width: size,
      height: size,
      borderRadius: AppSpacing.borderRadiusFull,
      placeholderIcon: Icons.person_outlined,
      placeholderIconSize: size * 0.5,
    );
  }

  /// Team logo image.
  factory CachedImage.teamLogo({
    Key? key,
    String? imageUrl,
    double size = 40,
  }) {
    return CachedImage(
      key: key,
      imageUrl: imageUrl,
      width: size,
      height: size,
      borderRadius: AppSpacing.borderRadiusSm,
      placeholderIcon: Icons.sports_cricket,
      placeholderIconSize: size * 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _buildLoadingPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Center(
        child: Icon(
          placeholderIcon,
          size: placeholderIconSize,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }
}
