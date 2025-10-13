import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_text_style.dart';

/// Dedicated widget for the delete confirmation dialog
class VoiceMemoDeleteConfirmationDialog extends StatelessWidget {
  const VoiceMemoDeleteConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text('Delete Voice Memo?', style: AppTextStyle.titleLarge),
      content: Text(
        'This action cannot be undone.',
        style: AppTextStyle.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Delete', style: TextStyle(color: AppColors.error)),
        ),
      ],
    );
  }
}
