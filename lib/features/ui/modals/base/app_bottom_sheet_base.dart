import 'package:flutter/material.dart';
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
            const _AppSheetIconButton(
              icon: Icons.close_rounded,
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

class _AppSheetIconButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;

  const _AppSheetIconButton({required this.icon, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: AppColors.textPrimary,
        size: Dimensions.iconMedium,
      ),
      onPressed: () => Navigator.of(context).pop(),
      tooltip: tooltip,
      constraints: BoxConstraints(
        minWidth: Dimensions.touchTargetMedium,
        minHeight: Dimensions.touchTargetMedium,
      ),
    );
  }
}
