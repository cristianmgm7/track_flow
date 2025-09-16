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

/// Menu item data class for the menu API
class AppMenuItem<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? textColor;
  final bool enabled;

  const AppMenuItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.textColor,
    this.enabled = true,
  });

  AppMenuItem<T> copyWith({
    T? value,
    String? label,
    String? subtitle,
    IconData? icon,
    Color? iconColor,
    Color? textColor,
    bool? enabled,
  }) {
    return AppMenuItem<T>(
      value: value ?? this.value,
      label: label ?? this.label,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      textColor: textColor ?? this.textColor,
      enabled: enabled ?? this.enabled,
    );
  }
}

/// Unified Menu API for TrackFlow - Similar to Modal API pattern
Future<T?> showAppMenu<T>({
  required BuildContext context,
  required List<AppMenuItem<T>> items,
  required ValueChanged<T> onSelected,
  RelativeRect? position,
  Offset? positionOffset,
  Widget? icon,
  String? tooltip,
  double elevation = 6,
  VoidCallback? onOpened,
  VoidCallback? onClosed,
  bool useRootNavigator = true,
  Color? backgroundColor,
  BorderRadius? borderRadius,
}) {
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;

  final RelativeRect menuPosition =
      position ??
      RelativeRect.fromLTRB(
        positionOffset?.dx ?? 0,
        positionOffset?.dy ?? 0,
        overlay.size.width - (positionOffset?.dx ?? 0),
        overlay.size.height - (positionOffset?.dy ?? 0),
      );

  return showMenu<T>(
    context: context,
    position: menuPosition,
    color: backgroundColor ?? AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: borderRadius ?? AppBorders.medium,
    ),
    elevation: elevation,
    useRootNavigator: useRootNavigator,
    items:
        items.map((item) {
          return PopupMenuItem<T>(
            value: item.value,
            enabled: item.enabled,
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(
                    item.icon,
                    color: item.iconColor ?? AppColors.textPrimary,
                    size: Dimensions.iconMedium,
                  ),
                  SizedBox(width: Dimensions.space12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: AppTextStyle.bodyLarge.copyWith(
                          color: item.textColor ?? AppColors.textPrimary,
                        ),
                      ),
                      if (item.subtitle != null) ...[
                        SizedBox(height: Dimensions.space2),
                        Text(
                          item.subtitle!,
                          style: AppTextStyle.bodySmall.copyWith(
                            color:
                                item.textColor?.withValues(alpha: 0.7) ??
                                AppColors.textSecondary,
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
        }).toList(),
  ).then((value) {
    if (value != null) {
      onSelected(value);
    }
    onClosed?.call();
    return value;
  });
}

/// Convenience function for simple string-based menus
Future<String?> showAppStringMenu({
  required BuildContext context,
  required List<String> options,
  required ValueChanged<String> onSelected,
  RelativeRect? position,
  Offset? positionOffset,
  List<IconData>? icons,
  List<String>? subtitles,
  String? tooltip,
  double elevation = 6,
  VoidCallback? onOpened,
  VoidCallback? onClosed,
  bool useRootNavigator = true,
}) {
  final items = List<AppMenuItem<String>>.generate(
    options.length,
    (index) => AppMenuItem<String>(
      value: options[index],
      label: options[index],
      subtitle:
          subtitles != null && index < subtitles.length
              ? subtitles[index]
              : null,
      icon: icons != null && index < icons.length ? icons[index] : null,
    ),
  );

  return showAppMenu<String>(
    context: context,
    items: items,
    onSelected: onSelected,
    position: position,
    positionOffset: positionOffset,
    tooltip: tooltip,
    elevation: elevation,
    onOpened: onOpened,
    onClosed: onClosed,
    useRootNavigator: useRootNavigator,
  );
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
