import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_player/domain/entities/playback_state.dart';

/// Widget to play audio from an audio comment
/// Supports both local cache and remote streaming
class AudioCommentPlayer extends StatefulWidget {
  final AudioComment comment;

  const AudioCommentPlayer({
    super.key,
    required this.comment,
  });

  @override
  State<AudioCommentPlayer> createState() => _AudioCommentPlayerState();
}

class _AudioCommentPlayerState extends State<AudioCommentPlayer> {
  // This widget derives UI from AudioPlayerBloc state; no local playback state needed

  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    // Prefer local cached path if available; otherwise use remote URL
    final String? localPath = widget.comment.localAudioPath != null &&
        await File(widget.comment.localAudioPath!).exists()
        ? widget.comment.localAudioPath!
        : null;
    final String? remoteUrl = widget.comment.audioStorageUrl;

    if (localPath != null || remoteUrl != null) {
      if (!mounted) return;
      context.read<AudioPlayerBloc>().add(
        PlayAudioCommentRequested(
          localPath: localPath,
          remoteUrl: remoteUrl,
          commentId: widget.comment.id.value,
        ),
      );
    } else {
      // No source available; rely on UI to show fallback message
    }
  }

  void _togglePlayPause() {
    final audioPlayerBloc = context.read<AudioPlayerBloc>();
    final currentState = audioPlayerBloc.state;
    final isPlaying = currentState is AudioPlayerSessionState &&
        currentState.session.state == PlaybackState.playing;
    audioPlayerBloc.add(isPlaying ? const PauseAudioRequested() : const ResumeAudioRequested());
  }

  void _onSeek(double value) {
    context.read<AudioPlayerBloc>().add(
      SeekToPositionRequested(Duration(milliseconds: value.toInt())),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        // Loading indicator while audio service buffers/loads
        if (state is AudioPlayerBuffering) {
          return Container(
            height: 56,
            padding: EdgeInsets.all(Dimensions.space12),
            decoration: BoxDecoration(
              color: AppColors.grey800,
              borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
            ),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        // Error display from audio player
        if (state is AudioPlayerError) {
          return Container(
            padding: EdgeInsets.all(Dimensions.space12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 20),
                SizedBox(width: Dimensions.space8),
                Expanded(
                  child: Text(
                    state.failure.message,
                    style: AppTextStyle.labelSmall.copyWith(color: AppColors.error),
                  ),
                ),
              ],
            ),
          );
        }

        // Derive session info if available
        Duration position = Duration.zero;
        Duration duration = widget.comment.audioDuration ?? Duration.zero;
        bool isPlaying = false;
        if (state is AudioPlayerSessionState) {
          position = state.session.position;
          duration = state.session.currentTrack?.duration ?? duration;
          isPlaying = state.session.state == PlaybackState.playing;
        }

        final displayDuration = duration;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.space12,
            vertical: Dimensions.space8,
          ),
          decoration: BoxDecoration(
            color: AppColors.grey800,
            borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
          ),
          child: Row(
            children: [
              // Play/Pause Button
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: _togglePlayPause,
                color: AppColors.primary,
                iconSize: 28,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              SizedBox(width: Dimensions.space8),

              // Progress and Time
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress Slider
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                      ),
                      child: Slider(
                        value: position.inMilliseconds.toDouble().clamp(
                          0.0,
                          displayDuration.inMilliseconds.toDouble(),
                        ),
                        max: displayDuration.inMilliseconds.toDouble(),
                        onChanged: _onSeek,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.grey700,
                      ),
                    ),

                    // Time Display
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.space4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(position),
                            style: AppTextStyle.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            _formatDuration(displayDuration),
                            style: AppTextStyle.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // No need to dispose anything - AudioPlayerBloc manages the audio player lifecycle
    super.dispose();
  }
}
