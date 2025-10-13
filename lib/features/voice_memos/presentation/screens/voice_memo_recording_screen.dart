import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../audio_recording/presentation/bloc/recording_bloc.dart';
import '../../../audio_recording/presentation/bloc/recording_event.dart';
import '../../../audio_recording/presentation/bloc/recording_state.dart';
import '../../../ui/buttons/primary_button.dart';
import '../../../ui/navigation/app_bar.dart';
import '../../../ui/navigation/app_scaffold.dart';
import '../bloc/voice_memo_bloc.dart';
import '../bloc/voice_memo_event.dart';
import '../widgets/pulsing_circle_animator.dart';
import '../widgets/recording_timer.dart';

class VoiceMemoRecordingScreen extends StatefulWidget {
  const VoiceMemoRecordingScreen({super.key});

  @override
  State<VoiceMemoRecordingScreen> createState() =>
      _VoiceMemoRecordingScreenState();
}

class _VoiceMemoRecordingScreenState extends State<VoiceMemoRecordingScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-start recording when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RecordingBloc>().add(const StartRecordingRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecordingBloc, RecordingState>(
      listener: (context, state) {
        if (state is RecordingCompleted) {
          // Save the memo
          context.read<VoiceMemoBloc>().add(
            CreateVoiceMemoRequested(state.recording),
          );
          // Navigate back to list
          context.pop();
        } else if (state is RecordingError) {
          // Check if permission error
          if (state.message.contains('Permission') ||
              state.message.contains('permission')) {
            _showPermissionDialog(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
            context.pop();
          }
        }
      },
      child: AppScaffold(
        appBar: AppAppBar(
          title: 'Recording',
          leading: AppIconButton(
            icon: Icons.arrow_back_ios_rounded,
            onPressed: () {
              context.read<RecordingBloc>().add(const CancelRecordingRequested());
              context.pop();
            },
          ),
        ),
        body: BlocBuilder<RecordingBloc, RecordingState>(
          builder: (context, state) {
            if (state is RecordingInProgress || state is RecordingPaused) {
              return _buildRecordingUI(context, state);
            }

            // Loading state
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildRecordingUI(BuildContext context, RecordingState state) {
    final session = state is RecordingInProgress
        ? state.session
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

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Microphone Permission Required', style: AppTextStyle.titleLarge),
        content: Text(
          'TrackFlow needs microphone access to record voice memos. '
          'Please enable microphone permission in your device settings.',
          style: AppTextStyle.bodyMedium,
        ),
        actions: [
          PrimaryButton(
            text: 'OK',
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}
