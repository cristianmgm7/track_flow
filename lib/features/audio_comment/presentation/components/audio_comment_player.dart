import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_event.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_state.dart';
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
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    final remoteUrl = widget.comment.audioStorageUrl;

    if (remoteUrl != null) {
      // Dispatch event to AudioCommentBloc to prepare playback
      final projectId = ProjectId.fromUniqueString(widget.comment.projectId.value);

      if (!mounted) return;

      context.read<AudioCommentBloc>().add(
        PrepareAudioCommentPlaybackEvent(
          commentId: widget.comment.id,
          projectId: projectId,
          remoteUrl: remoteUrl,
        ),
      );
    } else {
      // Check if we have a local path already
      final localPath = widget.comment.localAudioPath != null &&
          await File(widget.comment.localAudioPath!).exists()
          ? widget.comment.localAudioPath!
          : null;

      if (localPath != null) {
        if (!mounted) return;

        context.read<AudioPlayerBloc>().add(
          PlayAudioCommentRequested(
            localPath: localPath,
            remoteUrl: null,
            commentId: widget.comment.id.value,
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'No audio source available';
        });
      }
    }
  }

  void _togglePlayPause() {
    final audioPlayerBloc = context.read<AudioPlayerBloc>();

    if (_isPlaying) {
      audioPlayerBloc.add(const PauseAudioRequested());
    } else {
      audioPlayerBloc.add(const ResumeAudioRequested());
    }
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
    return BlocListener<AudioCommentBloc, AudioCommentState>(
      listener: (context, commentState) {
        // Listen for playback ready state from AudioCommentBloc
        if (commentState is AudioCommentPlaybackReady) {
          // Trigger AudioPlayerBloc to play the audio
          context.read<AudioPlayerBloc>().add(
            PlayAudioCommentRequested(
              localPath: commentState.localPath,
              remoteUrl: commentState.remoteUrl,
              commentId: commentState.commentId,
            ),
          );
        } else if (commentState is AudioCommentLoading) {
          setState(() => _isLoading = true);
        } else if (commentState is AudioCommentError) {
          setState(() {
            _errorMessage = commentState.message;
            _isLoading = false;
          });
        }
      },
      child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
        builder: (context, state) {
          // Update local state based on AudioPlayerBloc state
          if (state is AudioPlayerSessionState) {
            _isPlaying = state.session.state == PlaybackState.playing;
            _position = state.session.position;
            _duration = state.session.currentTrack?.duration ?? Duration.zero;
            if (_isLoading) {
              setState(() => _isLoading = false);
            }
          } else if (state is AudioPlayerError) {
            _errorMessage = state.failure.message;
            if (_isLoading) {
              setState(() => _isLoading = false);
            }
          }

        if (_isLoading) {
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

        if (_errorMessage != null) {
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
                    _errorMessage!,
                    style: AppTextStyle.labelSmall.copyWith(color: AppColors.error),
                  ),
                ),
              ],
            ),
          );
        }

        final displayDuration = _duration > Duration.zero
            ? _duration
            : widget.comment.audioDuration ?? Duration.zero;

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
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
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
                        value: _position.inMilliseconds.toDouble().clamp(
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
                            _formatDuration(_position),
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
      ),
    );
  }

  @override
  void dispose() {
    // No need to dispose anything - AudioPlayerBloc manages the audio player lifecycle
    super.dispose();
  }
}
