import 'package:flutter/material.dart';
import 'cache_dialog_data.dart';

/// Builder class responsible for creating cache-related dialogs
class CacheDialogBuilder {
  const CacheDialogBuilder();

  /// Shows a confirmation dialog based on CacheDialogData
  Future<bool?> showConfirmationDialog(
    BuildContext context,
    CacheDialogData data,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => _buildConfirmationDialog(context, data),
    );
  }

  Widget _buildConfirmationDialog(BuildContext context, CacheDialogData data) {
    return AlertDialog(
      title: Text(data.title),
      content: _buildDialogContent(context, data),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: data.isDestructive ? _destructiveButtonStyle() : null,
          child: Text(data.actionLabel),
        ),
      ],
    );
  }

  Widget _buildDialogContent(BuildContext context, CacheDialogData data) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(data.message),
        if (data.subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            data.subtitle!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  ButtonStyle _destructiveButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    );
  }
}