import 'package:flutter/material.dart';
import '../../app_dimensions.dart';
import '../../app_colors.dart';
import '../../app_text_style.dart';
import '../../app_animations.dart';

/// Button component with loading state following TrackFlow design system
class AppLoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final bool isDestructive;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final Widget? icon;
  final ButtonStyle? style;

  const AppLoadingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.isDestructive = false,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.icon,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = !isEnabled || isLoading;
    
    final effectiveBackgroundColor = backgroundColor ?? 
        (isDestructive ? AppColors.error : theme.colorScheme.primary);
    
    final effectiveForegroundColor = foregroundColor ?? 
        (isDestructive ? Colors.white : theme.colorScheme.onPrimary);

    return SizedBox(
      width: width,
      height: height ?? Dimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: style ?? ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveForegroundColor,
          disabledBackgroundColor: effectiveBackgroundColor.withValues(alpha: 0.5),
          disabledForegroundColor: effectiveForegroundColor.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
          ),
          textStyle: AppTextStyle.labelLarge,
        ),
        child: AnimatedSwitcher(
          duration: AppAnimations.fast,
          child: isLoading
              ? _buildLoadingContent()
              : _buildButtonContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return SizedBox(
      height: Dimensions.iconMedium,
      width: Dimensions.iconMedium,
      child: const CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          SizedBox(width: Dimensions.space8),
          Text(text),
        ],
      );
    }
    
    return Text(text);
  }
}

/// Primary loading button
class AppPrimaryLoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double? height;
  final Widget? icon;

  const AppPrimaryLoadingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppLoadingButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      width: width,
      height: height,
      icon: icon,
    );
  }
}

/// Secondary loading button
class AppSecondaryLoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double? height;
  final Widget? icon;

  const AppSecondaryLoadingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppLoadingButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      width: width,
      height: height,
      icon: icon,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.primary,
        disabledBackgroundColor: Colors.transparent,
        disabledForegroundColor: theme.colorScheme.primary.withValues(alpha: 0.5),
        side: BorderSide(
          color: theme.colorScheme.primary,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
        ),
        textStyle: AppTextStyle.labelLarge,
      ),
    );
  }
}

/// Destructive loading button
class AppDestructiveLoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double? height;
  final Widget? icon;

  const AppDestructiveLoadingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppLoadingButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      width: width,
      height: height,
      icon: icon,
      isDestructive: true,
    );
  }
}

/// Full width loading button
class AppFullWidthLoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final bool isDestructive;
  final double? height;
  final Widget? icon;

  const AppFullWidthLoadingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.isDestructive = false,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppLoadingButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      isDestructive: isDestructive,
      width: double.infinity,
      height: height,
      icon: icon,
    );
  }
}