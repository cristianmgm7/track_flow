import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_event.dart';
import 'package:trackflow/features/audio_comment/presentation/components/waveform.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_comment/presentation/components/audio_comment_waveform_display.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/audio_comment/presentation/components/audio_comment_comments_component.dart';
import 'package:trackflow/features/audio_comment/presentation/components/audio_comment_input_comment_component.dart';

class AudioCommentsScreenArgs {
  final ProjectId projectId;
  final AudioTrack track;
  final List<UserProfile> collaborators;
  AudioCommentsScreenArgs({
    required this.projectId,
    required this.track,
    required this.collaborators,
  });
}

class AudioCommentsScreen extends StatefulWidget {
  final ProjectId projectId;
  final AudioTrack track;
  final List<UserProfile> collaborators;
  const AudioCommentsScreen({
    super.key,
    required this.projectId,
    required this.track,
    required this.collaborators,
  });
  @override
  State<AudioCommentsScreen> createState() => _AudioCommentsScreenState();
}

class _AudioCommentsScreenState extends State<AudioCommentsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AudioCommentBloc>().add(
      WatchCommentsByTrackEvent(widget.track.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Waveform with controls and back button
          Expanded(
            flex: 5, // Larger proportion for the waveform
            child: Stack(
              children: [
                // Waveform occupying all available space
                AudioWaveformHeader(
                  waveform: AudioCommentWaveformDisplay(
                    trackId: widget.track.id,
                  ),
                  onBack: () => Navigator.of(context).pop(),
                  onPlay:
                      () => context.read<AudioPlayerBloc>().add(
                        PlayAudioRequested(widget.track.id),
                      ),
                ),

                // Back button (top-left) - with SafeArea
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(179), // 0.7 * 255 = 178.5
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3, // Proportion for comments
            child: Container(
              color: AppColors.background,
              child: AudioCommentCommentsList(
                collaborators: widget.collaborators,
              ),
            ),
          ),

          // Persistent modal at the bottom (as in the screenshot)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AudioCommentInputComment(
                  onSend: (text) {
                    context.read<AudioCommentBloc>().add(
                      AddAudioCommentEvent(
                        widget.projectId,
                        widget.track.id,
                        text,
                        Duration(milliseconds: 0),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
