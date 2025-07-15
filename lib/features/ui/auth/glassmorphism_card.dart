import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';

/// Glassmorphism card component for auth screens
class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blur;
  final double opacity;
  final Color? backgroundColor;
  final Border? border;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 10.0,
    this.opacity = 0.15,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.all(Dimensions.space16),
      child: ClipRRect(
        borderRadius:
            borderRadius ?? BorderRadius.circular(Dimensions.radiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? EdgeInsets.all(Dimensions.space24),
            decoration: BoxDecoration(
              color:
                  backgroundColor ??
                  AppColors.textPrimary.withValues(alpha: opacity),
              borderRadius:
                  borderRadius ?? BorderRadius.circular(Dimensions.radiusLarge),
              border:
                  border ??
                  Border.all(
                    color: AppColors.textPrimary.withValues(alpha: 0.2),
                    width: 1,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Glassmorphism button for auth screens
class GlassmorphismButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;

  const GlassmorphismButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? Dimensions.buttonHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color:
                  backgroundColor ??
                  AppColors.textPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
              border: Border.all(
                color: AppColors.textPrimary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading ? null : onPressed,
                borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                child: Center(
                  child:
                      isLoading
                          ? SizedBox(
                            width: Dimensions.iconMedium,
                            height: Dimensions.iconMedium,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                textColor ?? AppColors.textPrimary,
                              ),
                            ),
                          )
                          : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (icon != null) ...[
                                icon!,
                                SizedBox(width: Dimensions.space8),
                              ],
                              Text(
                                text,
                                style: TextStyle(
                                  color: textColor ?? AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
