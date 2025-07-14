import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_animations.dart';
import 'package:trackflow/core/theme/app_borders.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_shadows.dart';
import 'package:trackflow/core/theme/app_text_style.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool iconRight;
  final ButtonSize size;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.icon,
    this.iconRight = false,
    this.size = ButtonSize.medium,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
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
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double get _buttonHeight {
    if (widget.height != null) return widget.height!;
    return switch (widget.size) {
      ButtonSize.small => Dimensions.buttonHeightSmall,
      ButtonSize.medium => Dimensions.buttonHeight,
      ButtonSize.large => Dimensions.buttonHeightLarge,
    };
  }

  double get _buttonMinWidth {
    return switch (widget.size) {
      ButtonSize.small => Dimensions.buttonMinWidthSmall,
      ButtonSize.medium => Dimensions.buttonMinWidth,
      ButtonSize.large => Dimensions.buttonMinWidth,
    };
  }

  TextStyle get _textStyle {
    return switch (widget.size) {
      ButtonSize.small => AppTextStyle.buttonSmall,
      ButtonSize.medium => AppTextStyle.button,
      ButtonSize.large => AppTextStyle.button,
    };
  }

  double get _iconSize {
    return switch (widget.size) {
      ButtonSize.small => Dimensions.iconSmall,
      ButtonSize.medium => Dimensions.iconMedium,
      ButtonSize.large => Dimensions.iconMedium,
    };
  }

  bool get _isDisabled => widget.isDisabled || widget.isLoading;

  void _onTapDown(TapDownDetails details) {
    if (_isDisabled) return;
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (_isDisabled) return;
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    if (_isDisabled) return;
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isPressed ? _scaleAnimation.value : AppAnimations.scaleNormal,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: _isDisabled ? null : widget.onPressed,
            child: AnimatedContainer(
              duration: AppAnimations.fast,
              width: widget.width,
              height: _buttonHeight,
              constraints: BoxConstraints(
                minWidth: _buttonMinWidth,
                maxWidth: widget.width ?? double.infinity,
              ),
              decoration: BoxDecoration(
                color: _isDisabled 
                    ? AppColors.disabled 
                    : AppColors.primary,
                borderRadius: AppBorders.medium,
                boxShadow: _isDisabled 
                    ? AppShadows.none 
                    : (_isPressed ? AppShadows.buttonPressed : AppShadows.button),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: AppBorders.medium,
                  onTap: _isDisabled ? null : widget.onPressed,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.space16,
                      vertical: Dimensions.space12,
                    ),
                    child: widget.isLoading
                        ? Center(
                            child: SizedBox(
                              width: _iconSize,
                              height: _iconSize,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.onPrimary,
                                ),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.icon != null && !widget.iconRight) ...[
                                Icon(
                                  widget.icon,
                                  size: _iconSize,
                                  color: AppColors.onPrimary,
                                ),
                                SizedBox(width: Dimensions.space8),
                              ],
                              Flexible(
                                child: Text(
                                  widget.text,
                                  style: _textStyle.copyWith(
                                    color: AppColors.onPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.icon != null && widget.iconRight) ...[
                                SizedBox(width: Dimensions.space8),
                                Icon(
                                  widget.icon,
                                  size: _iconSize,
                                  color: AppColors.onPrimary,
                                ),
                              ],
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

enum ButtonSize {
  small,
  medium,
  large,
}