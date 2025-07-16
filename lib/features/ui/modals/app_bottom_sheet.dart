import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_animations.dart';
import 'package:trackflow/core/theme/app_borders.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_shadows.dart';
import 'package:trackflow/core/theme/app_text_style.dart';

class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? header;
  final List<Widget>? actions;
  final bool showHandle;
  final bool showCloseButton;
  final bool isScrollControlled;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final bool isDismissible;
  final bool enableDrag;
  final VoidCallback? onClose;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.header,
    this.actions,
    this.showHandle = true,
    this.showCloseButton = false,
    this.isScrollControlled = true,
    this.initialChildSize = 0.6,
    this.minChildSize = 0.3,
    this.maxChildSize = 0.9,
    this.isDismissible = true,
    this.enableDrag = true,
    this.onClose,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: borderRadius ?? AppBorders.topLarge,
        boxShadow: AppShadows.bottomSheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle) _buildHandle(),
          if (title != null || showCloseButton) _buildHeader(context),
          if (header != null) _buildCustomHeader(),
          if (title != null || header != null) _buildDivider(),
          Flexible(
            child: Container(
              padding:
                  padding ??
                  EdgeInsets.fromLTRB(
                    Dimensions.space16,
                    Dimensions.space0,
                    Dimensions.space16,
                    Dimensions.space32,
                  ),
              child: child,
            ),
          ),
          if (actions != null) _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: Dimensions.bottomSheetHandleWidth,
      height: Dimensions.bottomSheetHandleHeight,
      margin: EdgeInsets.only(
        top: Dimensions.space12,
        bottom: Dimensions.space16,
      ),
      decoration: BoxDecoration(
        color: AppColors.textSecondary,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.space16,
        vertical: Dimensions.space8,
      ),
      child: Row(
        children: [
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: AppTextStyle.headlineMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (showCloseButton)
            AppIconButton(
              icon: Icons.close_rounded,
              onPressed: onClose ?? () => Navigator.of(context).pop(),
              tooltip: 'Close',
            ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.space16,
        vertical: Dimensions.space12,
      ),
      child: header!,
    );
  }

  Widget _buildDivider() {
    return Container(
      height: Dimensions.dividerHeight,
      color: AppColors.border,
      margin: EdgeInsets.only(bottom: Dimensions.space16),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: EdgeInsets.all(Dimensions.space16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: Dimensions.dividerThickness,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children:
            actions!
                .map(
                  (action) => Padding(
                    padding: EdgeInsets.only(left: Dimensions.space8),
                    child: action,
                  ),
                )
                .toList(),
      ),
    );
  }
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

// Convenience function to show bottom sheet
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  Widget? header,
  List<Widget>? actions,
  bool showHandle = true,
  bool showCloseButton = false,
  bool isScrollControlled = true,
  double initialChildSize = 0.6,
  double minChildSize = 0.3,
  double maxChildSize = 0.9,
  bool isDismissible = true,
  bool enableDrag = true,
  VoidCallback? onClose,
  EdgeInsetsGeometry? padding,
  Color? backgroundColor,
  BorderRadius? borderRadius,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: true,
    builder: (context) {
      if (isScrollControlled) {
        return DraggableScrollableSheet(
          initialChildSize: initialChildSize,
          minChildSize: minChildSize,
          maxChildSize: maxChildSize,
          expand: false,
          builder: (context, scrollController) {
            return AppBottomSheet(
              title: title,
              header: header,
              actions: actions,
              showHandle: showHandle,
              showCloseButton: showCloseButton,
              onClose: onClose,
              padding: padding,
              backgroundColor: backgroundColor,
              borderRadius: borderRadius,
              child: child,
            );
          },
        );
      }

      return AppBottomSheet(
        title: title,
        header: header,
        actions: actions,
        showHandle: showHandle,
        showCloseButton: showCloseButton,
        onClose: onClose,
        padding: padding,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        child: child,
      );
    },
  );
}

// Convenience function to show action sheet
Future<T?> showAppActionSheet<T>({
  required BuildContext context,
  required List<AppBottomSheetAction> actions,
  String? title,
  Widget? header,
  Widget? body,
  bool showHandle = true,
  bool showCloseButton = false,
  bool isScrollControlled = true,
  double? initialChildSize,
  double minChildSize = 0.3,
  double maxChildSize = 0.9,
  bool isDismissible = true,
  bool enableDrag = true,
  VoidCallback? onClose,
}) {
  final itemCount = actions.length;
  final calculatedInitialSize =
      initialChildSize ??
      (itemCount <= 3
          ? 0.3
          : itemCount <= 6
          ? 0.5
          : 0.65);

  return showAppBottomSheet<T>(
    context: context,
    title: title,
    header: header,
    showHandle: showHandle,
    showCloseButton: showCloseButton,
    isScrollControlled: isScrollControlled,
    initialChildSize: body != null ? 0.6 : calculatedInitialSize,
    minChildSize: minChildSize,
    maxChildSize: maxChildSize,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    onClose: onClose,
    child: body ?? AppBottomSheetList(actions: actions),
  );
}
