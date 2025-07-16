import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
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
    this.centerTitle = true, // Default to true for iOS feel
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
        boxShadow:
            showShadow
                ? [
                  BoxShadow(
                    color: AppColors.grey900.withValues(alpha: 0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
                : null,
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (backgroundColor ?? AppColors.surface).withValues(alpha: 0.9),
                  (backgroundColor ?? AppColors.surface).withValues(alpha: 0.8),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.textPrimary.withValues(alpha: 0.05),
                  width: 0.5,
                ),
              ),
            ),
            child: AppBar(
              title:
                  titleWidget ??
                  (title != null
                      ? Text(
                        title!,
                        style: AppTextStyle.headlineMedium.copyWith(
                          color: foregroundColor ?? AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 18, // Slightly larger for iOS feel
                        ),
                      )
                      : null),
              actions: actions?.map((action) => _wrapAction(action)).toList(),
              leading: leading ?? (automaticallyImplyLeading && Navigator.canPop(context)
                  ? AppIconButton(
                      icon: Icons.arrow_back_ios_rounded, // iOS-style chevron
                      onPressed: () => Navigator.pop(context),
                    )
                  : null),
              automaticallyImplyLeading: automaticallyImplyLeading,
              centerTitle: centerTitle,
              backgroundColor: Colors.transparent,
              foregroundColor: foregroundColor ?? AppColors.textPrimary,
              elevation: 0,
              toolbarHeight: 60, // Slightly taller for iOS feel
              iconTheme: IconThemeData(
                color: foregroundColor ?? AppColors.textPrimary,
                size: 24, // Standard iOS icon size
              ),
              actionsIconTheme: IconThemeData(
                color: foregroundColor ?? AppColors.textPrimary,
                size: 24,
              ),
              bottom: bottom,
              titleSpacing: 0, // Better spacing for centered title
            ),
          ),
        ),
      ),
    );
  }

  Widget _wrapAction(Widget action) {
    return Container(
      width: 44, // iOS standard touch target
      height: 44,
      margin: EdgeInsets.only(right: Dimensions.space4),
      child: action,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    60 + (bottom?.preferredSize.height ?? 0), // Match the iOS toolbar height
  );
}

class AppIconButton extends StatefulWidget {
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
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onPressed,
            child: Container(
              width: 44, // iOS standard touch target
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.transparent,
              ),
              child: Icon(
                widget.icon,
                color: widget.color ?? AppColors.textPrimary,
                size: widget.size ?? 24, // iOS standard icon size
              ),
            ),
          ),
        );
      },
    );
  }
}
