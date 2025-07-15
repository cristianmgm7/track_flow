import 'package:flutter/material.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../core/theme/app_borders.dart';

/// Base dialog component following TrackFlow design system
class AppDialog extends StatelessWidget {
  final String title;
  final String content;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final Widget? customContent;
  final bool isDestructive;
  final bool isLoading;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.customContent,
    this.isDestructive = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppBorders.large),
      titlePadding: EdgeInsets.fromLTRB(
        Dimensions.space24,
        Dimensions.space24,
        Dimensions.space24,
        Dimensions.space16,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: Dimensions.space24,
        vertical: Dimensions.space8,
      ),
      actionsPadding: EdgeInsets.fromLTRB(
        Dimensions.space24,
        Dimensions.space16,
        Dimensions.space24,
        Dimensions.space24,
      ),
      title: Text(title, style: AppTextStyle.headlineMedium),
      content:
          customContent ??
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Dimensions.dialogMaxWidth),
            child: Text(content, style: AppTextStyle.bodyMedium),
          ),
      actions: _buildActions(),
    );
  }

  List<Widget> _buildActions() {
    final actions = <Widget>[];

    if (secondaryButtonText != null) {
      actions.add(
        TextButton(
          onPressed: isLoading ? null : onSecondaryPressed,
          child: Text(secondaryButtonText!),
        ),
      );
    }

    if (primaryButtonText != null) {
      actions.add(SizedBox(width: Dimensions.space12));

      actions.add(
        ElevatedButton(
          onPressed: isLoading ? null : onPrimaryPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive ? AppColors.error : null,
            foregroundColor: isDestructive ? Colors.white : null,
          ),
          child:
              isLoading
                  ? SizedBox(
                    height: Dimensions.iconMedium,
                    width: Dimensions.iconMedium,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : Text(primaryButtonText!),
        ),
      );
    }

    return actions.isNotEmpty
        ? [Row(mainAxisAlignment: MainAxisAlignment.end, children: actions)]
        : [];
  }
}

/// Confirmation dialog for common use cases
class AppConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final bool isLoading;

  const AppConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: title,
      content: message,
      primaryButtonText: confirmText,
      secondaryButtonText: cancelText,
      onPrimaryPressed: onConfirm,
      onSecondaryPressed: onCancel ?? () => Navigator.of(context).pop(),
      isDestructive: isDestructive,
      isLoading: isLoading,
    );
  }
}

/// Error dialog for displaying errors
class AppErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;

  const AppErrorDialog({
    super.key,
    this.title = 'Error',
    required this.message,
    this.buttonText = 'OK',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: title,
      content: message,
      primaryButtonText: buttonText,
      onPrimaryPressed: onPressed ?? () => Navigator.of(context).pop(),
    );
  }
}

/// Success dialog for displaying success messages
class AppSuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;

  const AppSuccessDialog({
    super.key,
    this.title = 'Success',
    required this.message,
    this.buttonText = 'OK',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: title,
      content: message,
      primaryButtonText: buttonText,
      onPrimaryPressed: onPressed ?? () => Navigator.of(context).pop(),
    );
  }
}
