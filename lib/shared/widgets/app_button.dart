import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Button variant types.
enum AppButtonVariant { primary, secondary, outline, ghost, gradient }

/// Button size options.
enum AppButtonSize { small, medium, large }

/// Premium button widget with loading state, haptic feedback, and gradient variants.
class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final double? width;
  final LinearGradient? gradient;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.gradient,
  });

  /// Factory for gradient button.
  factory AppButton.gradient({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? prefixIcon,
    IconData? suffixIcon,
    double? width,
    LinearGradient? gradient,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.gradient,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      width: width,
      gradient: gradient,
    );
  }

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _isEnabled => !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

  void _handleTapDown(TapDownDetails details) {
    if (_isEnabled) {
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  void _handleTap() {
    if (_isEnabled) {
      HapticFeedback.lightImpact();
      widget.onPressed?.call();
    }
  }

  double get _height {
    switch (widget.size) {
      case AppButtonSize.small:
        return 36.0;
      case AppButtonSize.medium:
        return 48.0;
      case AppButtonSize.large:
        return 56.0;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  TextStyle get _textStyle {
    switch (widget.size) {
      case AppButtonSize.small:
        return AppTypography.buttonSmall;
      case AppButtonSize.medium:
        return AppTypography.buttonMedium;
      case AppButtonSize.large:
        return AppTypography.buttonLarge;
    }
  }

  Color get _backgroundColor {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return AppColors.primary;
      case AppButtonVariant.secondary:
        return AppColors.secondary;
      case AppButtonVariant.outline:
      case AppButtonVariant.ghost:
      case AppButtonVariant.gradient:
        return Colors.transparent;
    }
  }

  Color get _foregroundColor {
    switch (widget.variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
      case AppButtonVariant.gradient:
        return AppColors.textOnPrimary;
      case AppButtonVariant.outline:
      case AppButtonVariant.ghost:
        return AppColors.primary;
    }
  }

  BorderSide? get _borderSide {
    if (widget.variant == AppButtonVariant.outline) {
      return const BorderSide(color: AppColors.primary, width: 1.5);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = widget.gradient ?? AppColors.primaryGradient;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: AnimatedOpacity(
          opacity: _isEnabled ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: widget.width ?? double.infinity,
            height: _height,
            decoration: BoxDecoration(
              color: widget.variant != AppButtonVariant.gradient
                  ? _backgroundColor
                  : null,
              gradient: widget.variant == AppButtonVariant.gradient
                  ? effectiveGradient
                  : null,
              borderRadius: AppSpacing.borderRadiusMd,
              border: _borderSide != null
                  ? Border.fromBorderSide(_borderSide!)
                  : null,
              boxShadow: widget.variant == AppButtonVariant.primary ||
                      widget.variant == AppButtonVariant.gradient
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            padding: _padding,
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _foregroundColor,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.prefixIcon != null) ...[
                          Icon(
                            widget.prefixIcon,
                            size: widget.size == AppButtonSize.small ? 16 : 20,
                            color: _foregroundColor,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            widget.text,
                            style: _textStyle.copyWith(color: _foregroundColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.suffixIcon != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            widget.suffixIcon,
                            size: widget.size == AppButtonSize.small ? 16 : 20,
                            color: _foregroundColor,
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
