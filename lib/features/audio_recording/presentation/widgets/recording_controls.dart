import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';

/// Reusable pause/resume/cancel controls for recording
class RecordingControls extends StatelessWidget {
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;
  final bool isPaused;

  const RecordingControls({
    super.key,
    this.onPause,
    this.onResume,
    this.onCancel,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pause/Resume button
        IconButton(
          onPressed: isPaused ? onResume : onPause,
          icon: Icon(
            isPaused ? Icons.play_arrow : Icons.pause,
            color: AppColors.primary,
          ),
          iconSize: Dimensions.iconLarge,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(Dimensions.space12),
          ),
        ),
        const SizedBox(width: Dimensions.space12),
        // Cancel button
        IconButton(
          onPressed: onCancel,
          icon: const Icon(
            Icons.close,
            color: AppColors.error,
          ),
          iconSize: Dimensions.iconLarge,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.error.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(Dimensions.space12),
          ),
        ),
      ],
    );
  }
}
