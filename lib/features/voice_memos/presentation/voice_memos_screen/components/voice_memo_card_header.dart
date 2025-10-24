import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
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
        Text(
          memo.title,
          style: AppTextStyle.titleXSmall,
          overflow: TextOverflow.ellipsis,
        ),

        // Menu Button
        IconButton(
          iconSize: Dimensions.iconSmall,
          padding: EdgeInsets.all(Dimensions.space0),
          icon: const Icon(Icons.more_horiz, color: Colors.white),
          onPressed: () => _showMenu(context),
        ),
      ],
    );
  }
}
