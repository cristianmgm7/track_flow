import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_animations.dart';
import 'package:trackflow/core/theme/app_borders.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';

class AppTextField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final String? prefixText;
  final String? suffixText;
  final FocusNode? focusNode;
  final TextStyle? textStyle;
  final TextAlign textAlign;
  final bool showCursor;
  final double? height;
  final EdgeInsetsGeometry? contentPadding;

  const AppTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
    this.onSubmitted,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.prefixText,
    this.suffixText,
    this.focusNode,
    this.textStyle,
    this.textAlign = TextAlign.start,
    this.showCursor = true,
    this.height,
    this.contentPadding,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    
    _animationController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _borderAnimation = Tween<double>(
      begin: AppBorders.widthThin,
      end: AppBorders.widthMedium,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.easeOut,
    ));
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Color get _borderColor {
    if (widget.errorText != null) return AppColors.error;
    if (_isFocused) return AppColors.primary;
    return AppColors.border;
  }

  double get _inputHeight {
    if (widget.height != null) return widget.height!;
    if (widget.maxLines != null && widget.maxLines! > 1) {
      return Dimensions.inputHeight * (widget.maxLines! * 0.6);
    }
    return Dimensions.inputHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: AppTextStyle.labelMedium.copyWith(
              color: widget.errorText != null 
                  ? AppColors.error 
                  : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: Dimensions.space8),
        ],
        
        AnimatedBuilder(
          animation: _borderAnimation,
          builder: (context, child) {
            return Container(
              height: widget.maxLines == 1 ? _inputHeight : null,
              constraints: widget.maxLines == 1 
                  ? null 
                  : BoxConstraints(
                      minHeight: _inputHeight,
                    ),
              decoration: BoxDecoration(
                color: widget.enabled ? AppColors.surface : AppColors.disabled.withOpacity(0.1),
                borderRadius: AppBorders.medium,
                border: Border.all(
                  color: _borderColor,
                  width: _borderAnimation.value,
                ),
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                onChanged: widget.onChanged,
                onTap: widget.onTap,
                onEditingComplete: widget.onEditingComplete,
                onFieldSubmitted: widget.onSubmitted,
                obscureText: widget.obscureText,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                autofocus: widget.autofocus,
                maxLines: widget.maxLines,
                minLines: widget.minLines,
                maxLength: widget.maxLength,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                textAlign: widget.textAlign,
                showCursor: widget.showCursor,
                style: widget.textStyle ?? AppTextStyle.bodyMedium.copyWith(
                  color: widget.enabled ? AppColors.textPrimary : AppColors.disabled,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: AppTextStyle.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: widget.contentPadding ?? EdgeInsets.symmetric(
                    horizontal: Dimensions.space16,
                    vertical: Dimensions.space12,
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: _borderColor,
                          size: Dimensions.iconMedium,
                        )
                      : null,
                  suffixIcon: widget.suffixIcon != null
                      ? IconButton(
                          icon: Icon(
                            widget.suffixIcon,
                            color: _borderColor,
                            size: Dimensions.iconMedium,
                          ),
                          onPressed: widget.onSuffixIconPressed,
                        )
                      : null,
                  prefixText: widget.prefixText,
                  suffixText: widget.suffixText,
                  prefixStyle: AppTextStyle.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  suffixStyle: AppTextStyle.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  counterText: '',
                ),
              ),
            );
          },
        ),
        
        if (widget.errorText != null) ...[
          SizedBox(height: Dimensions.space4),
          Text(
            widget.errorText!,
            style: AppTextStyle.caption.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
        
        if (widget.helperText != null && widget.errorText == null) ...[
          SizedBox(height: Dimensions.space4),
          Text(
            widget.helperText!,
            style: AppTextStyle.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}