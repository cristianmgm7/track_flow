import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';

/// Reusable button to start/stop recording
class RecordingButton extends StatelessWidget {
  final VoidCallback? onStartRecording;
  final VoidCallback? onStopRecording;
  final bool isRecording;
  final String? startLabel;
  final String? stopLabel;

  const RecordingButton({
    super.key,
    this.onStartRecording,
    this.onStopRecording,
    required this.isRecording,
    this.startLabel,
    this.stopLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isRecording ? onStopRecording : onStartRecording,
      icon: Icon(
        isRecording ? Icons.stop : Icons.fiber_manual_record,
        color: isRecording ? AppColors.error : AppColors.primary,
      ),
      label: Text(
        isRecording
            ? (stopLabel ?? 'Stop Recording')
            : (startLabel ?? 'Start Recording'),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isRecording
            ? AppColors.error.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.1),
        foregroundColor: isRecording ? AppColors.error : AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.space24,
          vertical: Dimensions.space12,
        ),
        minimumSize: const Size(Dimensions.buttonMinWidth, Dimensions.buttonHeight),
      ),
    );
  }
}
