import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../audio_recording/presentation/bloc/recording_bloc.dart';
import '../../../audio_recording/presentation/bloc/recording_event.dart';
import '../../../audio_recording/presentation/bloc/recording_state.dart';
import '../../../ui/buttons/primary_button.dart';
import '../../../ui/navigation/app_bar.dart';
import '../../../ui/navigation/app_scaffold.dart';
import '../bloc/voice_memo_bloc.dart';
import '../bloc/voice_memo_event.dart';
import 'recording_ui.dart';

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
              return RecordingUI(state: state);
            }

            // Loading state
            return const Center(child: CircularProgressIndicator());
          },
        ),
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
