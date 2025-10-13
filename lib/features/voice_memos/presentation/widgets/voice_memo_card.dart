import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../ui/cards/base_card.dart';
import '../../../ui/menus/app_popup_menu.dart';
import '../../domain/entities/voice_memo.dart';
import '../bloc/voice_memo_bloc.dart';
import '../bloc/voice_memo_event.dart';
import 'playback_controls.dart';
import 'voice_memo_rename_dialog.dart';

class VoiceMemoCard extends StatelessWidget {
  final VoiceMemo memo;

  const VoiceMemoCard({super.key, required this.memo});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(memo.id.value),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: Dimensions.space20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
        ),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (direction) {
        context.read<VoiceMemoBloc>().add(
          DeleteVoiceMemoRequested(memo.id),
        );
      },
      child: BaseCard(
        padding: EdgeInsets.all(Dimensions.space12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: Dimensions.space12),
            PlaybackControls(memo: memo),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onLongPress: () => _showRenameDialog(context),
                child: Text(
                  memo.title,
                  style: AppTextStyle.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: Dimensions.space4),
              Text(
                dateFormat.format(memo.recordedAt),
                style: AppTextStyle.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
          onPressed: () => _showMenu(context),
        ),
      ],
    );
  }



  void _showRenameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => VoiceMemoRenameDialog(
        memo: memo,
        onRename: (newTitle) {
          context.read<VoiceMemoBloc>().add(
            UpdateVoiceMemoRequested(memo, newTitle),
          );
        },
      ),
    );
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
            _showRenameDialog(context);
            break;
          case 'delete':
            context.read<VoiceMemoBloc>().add(
              DeleteVoiceMemoRequested(memo.id),
            );
            break;
        }
      },
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete Voice Memo?', style: AppTextStyle.titleLarge),
        content: Text(
          'This action cannot be undone.',
          style: AppTextStyle.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    ) ?? false;
  }

}
