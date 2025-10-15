import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../ui/menus/app_popup_menu.dart';
import '../../../domain/entities/voice_memo.dart';

class VoiceMemoCardHeader extends StatelessWidget {
  final VoiceMemo memo;
  final VoidCallback onRenamePressed;
  final VoidCallback onDeletePressed;

  const VoiceMemoCardHeader({
    super.key,
    required this.memo,
    required this.onRenamePressed,
    required this.onDeletePressed,
  });

  bool get _fileExists {
    try {
      return File(memo.fileLocalPath).existsSync();
    } catch (e) {
      return false;
    }
  }

  void _showMenu(BuildContext context) {
    showAppMenu<String>(
      context: context,
      items: [
        AppMenuItem<String>(
          value: 'rename',
          label: 'Rename',
          icon: Icons.edit,
        ),
        AppMenuItem<String>(
          value: 'delete',
          label: 'Delete',
          icon: Icons.delete,
          iconColor: AppColors.error,
          textColor: AppColors.error,
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'rename':
            onRenamePressed();
            break;
          case 'delete':
            onDeletePressed();
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title with error indicator if file is missing
        Expanded(
          child: Row(
            children: [
              if (!_fileExists) ...[
                Icon(
                  Icons.warning_amber,
                  color: Colors.orange[300],
                  size: 16,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  memo.title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: _fileExists ? 1.0 : 0.6),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Menu Button
        IconButton(
          icon: const Icon(Icons.more_horiz, color: Colors.white),
          onPressed: () => _showMenu(context),
        ),
      ],
    );
  }
}
