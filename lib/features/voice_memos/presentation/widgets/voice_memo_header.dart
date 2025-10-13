import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../domain/entities/voice_memo.dart';

class VoiceMemoHeader extends StatelessWidget {
  final VoiceMemo memo;
  final VoidCallback onRename;
  final VoidCallback onShowMenu;

  const VoiceMemoHeader({
    super.key,
    required this.memo,
    required this.onRename,
    required this.onShowMenu,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onLongPress: onRename,
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
          onPressed: onShowMenu,
        ),
      ],
    );
  }
}
