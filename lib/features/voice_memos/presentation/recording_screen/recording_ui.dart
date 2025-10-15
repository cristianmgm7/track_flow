import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../audio_recording/presentation/bloc/recording_bloc.dart';
import '../../../audio_recording/presentation/bloc/recording_event.dart';
import '../../../audio_recording/presentation/bloc/recording_state.dart';
import 'pulsing_circle_animator.dart';
import 'recording_timer.dart';

class RecordingUI extends StatelessWidget {
  final RecordingState state;

  const RecordingUI({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final session = state is RecordingInProgress
        ? (state as RecordingInProgress).session
        : (state as RecordingPaused).session;

    final amplitude = session.currentAmplitude ?? 0.0;
    final elapsed = session.elapsed;
    final isPaused = state is RecordingPaused;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pulsing circle
          PulsingCircleAnimator(
            amplitude: amplitude,
            isRecording: !isPaused,
          ),

          SizedBox(height: Dimensions.space48),

          // Timer
          RecordingTimer(elapsed: elapsed),

          SizedBox(height: Dimensions.space48),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cancel button
              IconButton(
                iconSize: 48,
                icon: Icon(Icons.close, color: AppColors.error),
                onPressed: () {
                  context.read<RecordingBloc>().add(
                    const CancelRecordingRequested(),
                  );
                  context.pop();
                },
              ),

              SizedBox(width: Dimensions.space32),

              // Pause/Resume button
              IconButton(
                iconSize: 48,
                icon: Icon(
                  isPaused ? Icons.play_arrow : Icons.pause,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {
                  if (isPaused) {
                    context.read<RecordingBloc>().add(
                      const ResumeRecordingRequested(),
                    );
                  } else {
                    context.read<RecordingBloc>().add(
                      const PauseRecordingRequested(),
                    );
                  }
                },
              ),

              SizedBox(width: Dimensions.space32),

              // Stop/Save button
              IconButton(
                iconSize: 48,
                icon: Icon(Icons.check, color: AppColors.success),
                onPressed: () {
                  // Dispatch stop event - BlocListener will handle navigation after RecordingCompleted
                  context.read<RecordingBloc>().add(
                    const StopRecordingRequested(),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: Dimensions.space24),

          // Instructions
          Text(
            isPaused ? 'Recording paused' : 'Recording in progress...',
            style: AppTextStyle.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
