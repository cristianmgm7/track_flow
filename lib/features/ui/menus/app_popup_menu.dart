import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_borders.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'dart:ui';

/// Reusable popup menu button styled with TrackFlow design system.
class AppPopupMenuButton<T> extends StatelessWidget {
  final Widget? icon;
  final String? tooltip;
  final List<AppPopupMenuItem<T>> items;
  final ValueChanged<T> onSelected;
  final T? initialValue;
  final double elevation;
  final VoidCallback? onOpened;
  final VoidCallback? onClosed; // called on cancel or after select

  const AppPopupMenuButton({
    super.key,
    this.icon,
    this.tooltip,
    required this.items,
    required this.onSelected,
    this.initialValue,
    this.elevation = 6,
    this.onOpened,
    this.onClosed,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      tooltip: tooltip,
      initialValue: initialValue,
      elevation: elevation,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppBorders.medium),
      icon:
          icon ?? const Icon(Icons.sort_rounded, color: AppColors.textPrimary),
      onSelected: (value) {
        onSelected(value);
        onClosed?.call();
      },
      onOpened: onOpened,
      onCanceled: () => onClosed?.call(),
      itemBuilder: (context) {
        return [
          // Backdrop diffusion effect behind the menu (placed first)
          ...items.map((item) => item._build(context)),
        ];
      },
    );
  }
}

class AppPopupMenuItem<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;

  const AppPopupMenuItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });

  PopupMenuItem<T> _build(BuildContext context) {
    return PopupMenuItem<T>(
      value: value,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: AppColors.textPrimary,
              size: Dimensions.iconMedium,
            ),
            SizedBox(width: Dimensions.space12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyle.bodyLarge),
                if (subtitle != null) ...[
                  SizedBox(height: Dimensions.space2),
                  Text(
                    subtitle!,
                    style: AppTextStyle.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// An overlay route to create a soft diffusion blur behind popup menus.
/// Use with showMenu by wrapping root with this barrier before the menu opens
/// if a manual effect is required elsewhere.
class AppBlurBackdrop extends StatelessWidget {
  final Widget child;
  const AppBlurBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            color: AppColors.background.withValues(alpha: 0.05),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.transparent),
          ),
        ),
        child,
      ],
    );
  }
}
