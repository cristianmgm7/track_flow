import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../ui/buttons/primary_button.dart';
import '../../../ui/inputs/app_text_field.dart';
import '../../domain/entities/voice_memo.dart';

class VoiceMemoRenameDialog extends StatefulWidget {
  final VoiceMemo memo;
  final Function(String newTitle) onRename;

  const VoiceMemoRenameDialog({
    super.key,
    required this.memo,
    required this.onRename,
  });

  @override
  State<VoiceMemoRenameDialog> createState() => _VoiceMemoRenameDialogState();
}

class _VoiceMemoRenameDialogState extends State<VoiceMemoRenameDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.memo.title);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text('Rename Voice Memo', style: AppTextStyle.titleLarge),
      content: AppTextField(
        controller: _controller,
        hintText: 'Enter new title',
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        PrimaryButton(
          text: 'Rename',
          onPressed: () {
            final newTitle = _controller.text.trim();
            if (newTitle.isNotEmpty) {
              widget.onRename(newTitle);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
