import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_style.dart';

/// Header widget for the comment input modal that displays a close button
/// and timestamp when the input is focused
class CommentInputHeader extends StatelessWidget {
  final Duration? timestamp;
  final VoidCallback onClose;

  const CommentInputHeader({
    super.key,
    required this.timestamp,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (timestamp == null) return const SizedBox.shrink();

    final minutes = timestamp!.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = (timestamp!.inSeconds % 60).toString().padLeft(2, '0');

    return SizedBox(
      height: Dimensions.space40,
      child: Row(
        children: [
          // X button to close
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: Dimensions.space40,
              minHeight: Dimensions.space40,
            ),
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: Dimensions.iconMedium,
            ),
            onPressed: onClose,
          ),

          // Centered timestamp
          Expanded(
            child: Center(
              child: Text(
                'Comment at $minutes:$seconds',
                style: AppTextStyle.labelLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Spacer for symmetry
          SizedBox(width: Dimensions.space40),
        ],
      ),
    );
  }
}
