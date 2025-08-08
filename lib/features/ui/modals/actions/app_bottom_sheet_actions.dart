import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_animations.dart';
import 'package:trackflow/core/theme/app_borders.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/ui/modals/app_bottom_sheet.dart';

class AppBottomSheetAction {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget Function(BuildContext)? childSheetBuilder;
  final bool showTrailingIcon;
  final Color? iconColor;
  final Color? textColor;

  AppBottomSheetAction({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.childSheetBuilder,
    this.showTrailingIcon = true,
    this.iconColor,
    this.textColor,
  });
}

class AppBottomSheetList extends StatelessWidget {
  final List<AppBottomSheetAction> actions;
  final ScrollController? scrollController;

  const AppBottomSheetList({
    super.key,
    required this.actions,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      shrinkWrap: true,
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _AppBottomSheetListItem(
          action: action,
          onTap: () => _handleTap(context, action),
        );
      },
    );
  }

  void _handleTap(BuildContext context, AppBottomSheetAction action) {
    Navigator.of(context).pop();
    if (action.childSheetBuilder != null) {
      showAppBottomSheet(
        context: context,
        title: action.title,
        child: action.childSheetBuilder!(context),
      );
    } else {
      action.onTap?.call();
    }
  }
}

class _AppBottomSheetListItem extends StatefulWidget {
  final AppBottomSheetAction action;
  final VoidCallback onTap;

  const _AppBottomSheetListItem({required this.action, required this.onTap});

  @override
  State<_AppBottomSheetListItem> createState() =>
      _AppBottomSheetListItemState();
}

class _AppBottomSheetListItemState extends State<_AppBottomSheetListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: AppAnimations.scaleNormal,
      end: AppAnimations.scaleDown,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isNavigable = widget.action.childSheetBuilder != null;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isPressed ? _scaleAnimation.value : AppAnimations.scaleNormal,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap,
            child: Container(
              margin: EdgeInsets.only(bottom: Dimensions.space4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: AppBorders.medium,
                  onTap: widget.onTap,
                  child: Container(
                    padding: EdgeInsets.all(Dimensions.space16),
                    child: Row(
                      children: [
                        Icon(
                          widget.action.icon,
                          color:
                              widget.action.iconColor ?? AppColors.textPrimary,
                          size: Dimensions.iconMedium,
                        ),
                        SizedBox(width: Dimensions.space16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.action.title,
                                style: AppTextStyle.bodyLarge.copyWith(
                                  color:
                                      widget.action.textColor ??
                                      AppColors.textPrimary,
                                ),
                              ),
                              if (widget.action.subtitle != null) ...[
                                SizedBox(height: Dimensions.space4),
                                Text(
                                  widget.action.subtitle!,
                                  style: AppTextStyle.bodyMedium,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isNavigable && widget.action.showTrailingIcon)
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                            size: Dimensions.iconMedium,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
