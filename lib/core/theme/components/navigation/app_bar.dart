import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_shadows.dart';
import 'package:trackflow/core/theme/app_text_style.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool showShadow;
  final PreferredSizeWidget? bottom;

  const AppAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = false,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.showShadow = false,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        boxShadow: showShadow ? AppShadows.appBar : null,
      ),
      child: AppBar(
        title: titleWidget ?? (title != null 
            ? Text(
                title!,
                style: AppTextStyle.headlineMedium.copyWith(
                  color: foregroundColor ?? AppColors.textPrimary,
                ),
              )
            : null),
        actions: actions?.map((action) => _wrapAction(action)).toList(),
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        centerTitle: centerTitle,
        backgroundColor: backgroundColor ?? AppColors.surface,
        foregroundColor: foregroundColor ?? AppColors.textPrimary,
        elevation: elevation,
        toolbarHeight: Dimensions.appBarHeight,
        iconTheme: IconThemeData(
          color: foregroundColor ?? AppColors.textPrimary,
          size: Dimensions.iconMedium,
        ),
        actionsIconTheme: IconThemeData(
          color: foregroundColor ?? AppColors.textPrimary,
          size: Dimensions.iconMedium,
        ),
        bottom: bottom,
      ),
    );
  }

  Widget _wrapAction(Widget action) {
    return Container(
      width: Dimensions.touchTargetMedium,
      height: Dimensions.touchTargetMedium,
      margin: EdgeInsets.only(right: Dimensions.space8),
      child: action,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    Dimensions.appBarHeight + (bottom?.preferredSize.height ?? 0),
  );
}

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final double? size;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: color ?? AppColors.textPrimary,
        size: size ?? Dimensions.iconMedium,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
      constraints: BoxConstraints(
        minWidth: Dimensions.touchTargetMedium,
        minHeight: Dimensions.touchTargetMedium,
      ),
    );
  }
}