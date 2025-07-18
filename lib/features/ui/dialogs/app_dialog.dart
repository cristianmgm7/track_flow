import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../core/theme/app_shadows.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';

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
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: Dimensions.dialogMaxWidth,
          minWidth: Dimensions.dialogMinWidth,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.textPrimary.withValues(alpha: 0.15),
                    AppColors.textPrimary.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                border: Border.all(
                  color: AppColors.textPrimary.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: AppShadows.modal,
              ),
              child: Padding(
                padding: EdgeInsets.all(Dimensions.space24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyle.headlineMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: Dimensions.space16),
                    customContent ??
                        Text(
                          content,
                          style: AppTextStyle.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    if (_buildActions().isNotEmpty) ...[
                      SizedBox(height: Dimensions.space24),
                      ..._buildActions(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    final actions = <Widget>[];

    if (secondaryButtonText != null) {
      actions.add(
        SecondaryButton(
          text: secondaryButtonText!,
          onPressed: isLoading ? null : onSecondaryPressed,
          isDisabled: isLoading,
          size: ButtonSize.small,
        ),
      );
    }

    if (primaryButtonText != null) {
      if (actions.isNotEmpty) {
        actions.add(SizedBox(width: Dimensions.space12));
      }

      actions.add(
        PrimaryButton(
          text: primaryButtonText!,
          onPressed: onPrimaryPressed,
          isLoading: isLoading,
          isDisabled: isLoading,
          size: ButtonSize.small,
          isDestructive: isDestructive,
        ),
      );
    }

    return actions.isNotEmpty
        ? [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions,
            ),
          ),
        ]
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
