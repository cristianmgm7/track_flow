import 'package:flutter/material.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../core/theme/app_borders.dart';

/// Enhanced form field component following TrackFlow design system
class AppFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final bool isRequired;
  final bool isEnabled;
  final bool isObscure;
  final bool isReadOnly;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final TextCapitalization? textCapitalization;

  const AppFormField({
    super.key,
    required this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.isRequired = false,
    this.isEnabled = true,
    this.isObscure = false,
    this.isReadOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.textCapitalization,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          _buildLabel(theme),
          SizedBox(height: Dimensions.space8),
        ],

        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          enabled: isEnabled,
          obscureText: isObscure,
          readOnly: isReadOnly,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          focusNode: focusNode,
          style: AppTextStyle.bodyMedium,
          textCapitalization: textCapitalization ?? TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyle.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            errorText: errorText,
            errorStyle: AppTextStyle.bodySmall.copyWith(color: AppColors.error),
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: AppBorders.medium,
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
                width: AppBorders.widthThin,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppBorders.medium,
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
                width: AppBorders.widthThin,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppBorders.medium,
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: AppBorders.widthMedium,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppBorders.medium,
              borderSide: BorderSide(
                color: AppColors.error,
                width: AppBorders.widthMedium,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppBorders.medium,
              borderSide: BorderSide(
                color: AppColors.error,
                width: AppBorders.widthMedium,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: AppBorders.medium,
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                width: AppBorders.widthThin,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: Dimensions.space16,
              vertical: Dimensions.space12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(ThemeData theme) {
    return RichText(
      text: TextSpan(
        text: label,
        style: AppTextStyle.labelMedium.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        children: [
          if (isRequired)
            TextSpan(
              text: ' *',
              style: AppTextStyle.labelMedium.copyWith(color: AppColors.error),
            ),
        ],
      ),
    );
  }
}

/// Password field with show/hide functionality
class AppPasswordField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool isRequired;
  final bool isEnabled;
  final FocusNode? focusNode;

  const AppPasswordField({
    super.key,
    required this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.isRequired = false,
    this.isEnabled = true,
    this.focusNode,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return AppFormField(
      label: widget.label,
      hint: widget.hint,
      errorText: widget.errorText,
      controller: widget.controller,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      isRequired: widget.isRequired,
      isEnabled: widget.isEnabled,
      isObscure: _isObscure,
      focusNode: widget.focusNode,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      suffixIcon: IconButton(
        icon: Icon(
          _isObscure ? Icons.visibility : Icons.visibility_off,
          size: Dimensions.iconMedium,
        ),
        onPressed: () {
          setState(() {
            _isObscure = !_isObscure;
          });
        },
      ),
    );
  }
}

/// Search field with search icon
class AppSearchField extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool isEnabled;
  final FocusNode? focusNode;

  const AppSearchField({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.isEnabled = true,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return AppFormField(
      label: '',
      hint: hint ?? 'Search...',
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      isEnabled: isEnabled,
      focusNode: focusNode,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      prefixIcon: Icon(Icons.search, size: Dimensions.iconMedium),
      suffixIcon:
          controller?.text.isNotEmpty == true
              ? IconButton(
                icon: Icon(Icons.clear, size: Dimensions.iconMedium),
                onPressed:
                    onClear ??
                    () {
                      controller?.clear();
                      onChanged?.call('');
                    },
              )
              : null,
    );
  }
}
