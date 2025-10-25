import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/audio_comment/presentation/models/audio_comment_ui_model.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_comment/presentation/cubit/comment_audio_cubit.dart';
import 'package:trackflow/features/audio_comment/infrastructure/services/comment_audio_playback_service_impl.dart';

/// Widget to play audio from an audio comment
/// Supports both local cache and remote streaming
class AudioCommentPlayer extends StatefulWidget {
  final AudioCommentUiModel comment;

  const AudioCommentPlayer({
    super.key,
    required this.comment,
  });

  @override
  State<AudioCommentPlayer> createState() => _AudioCommentPlayerState();
}

class _AudioCommentPlayerState extends State<AudioCommentPlayer> {
  late final CommentAudioCubit _commentCubit;

  @override
  void initState() {
    super.initState();
    _commentCubit = CommentAudioCubit(CommentAudioPlaybackServiceImpl());
  }

  void _onPlayPause(CommentAudioState cState) {
    if (cState is CommentAudioPlaying) {
      _commentCubit.pause();
      return;
    }

    // Not playing: start playback for this comment (prefer local path)
    final String? localPath = widget.comment.localAudioPath != null &&
            File(widget.comment.localAudioPath!).existsSync()
        ? widget.comment.localAudioPath!
        : null;
    final String? remoteUrl = widget.comment.audioStorageUrl;

    _commentCubit.play(
      localPath: localPath,
      remoteUrl: remoteUrl,
      commentId: widget.comment.id,
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
    return BlocProvider.value(
      value: _commentCubit,
      child: BlocListener<CommentAudioCubit, CommentAudioState>(
        listener: (context, cState) {
          if (cState is CommentAudioPlaying) {
            // Pause main waveform/track playback when a comment starts
            context.read<AudioPlayerBloc>().add(const PauseAudioRequested());
          }
        },
        child: BlocBuilder<CommentAudioCubit, CommentAudioState>(
          builder: (context, cState) {
            // Error display for comment playback
            if (cState is CommentAudioError) {
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
                        cState.message,
                        style: AppTextStyle.labelSmall.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Derive session info if available
            Duration position = Duration.zero;
            Duration duration = Duration.zero;
            bool isPlaying = false;
            bool isBuffering = cState is CommentAudioBuffering;

            // Get duration from comment first, then from session if available
            duration = widget.comment.audioDuration ?? Duration.zero;

            if (cState is CommentAudioPlaying) {
              position = cState.session.position;
              // Use session track duration if available and valid
              if (cState.session.currentTrack?.duration != null &&
                  cState.session.currentTrack!.duration > Duration.zero) {
                duration = cState.session.currentTrack!.duration;
              }
              isPlaying = true;
            } else if (cState is CommentAudioPaused) {
              position = cState.session.position;
              // Use session track duration if available and valid
              if (cState.session.currentTrack?.duration != null &&
                  cState.session.currentTrack!.duration > Duration.zero) {
                duration = cState.session.currentTrack!.duration;
              }
              isPlaying = false;
            }

            // Ensure we have a valid duration for the progress bar
            final displayDuration = duration > Duration.zero ? duration : Duration.zero;

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
                    icon: isBuffering
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          )
                        : Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: isBuffering ? null : () => _onPlayPause(cState),
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
                        // Progress Slider - only show if we have a valid duration
                        if (displayDuration > Duration.zero) ...[
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
                              onChanged: isBuffering ? null : (v) => _commentCubit.seek(Duration(milliseconds: v.toInt())),
                              activeColor: AppColors.primary,
                              inactiveColor: AppColors.grey700,
                            ),
                          ),
                        ],

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
                                displayDuration > Duration.zero ? _formatDuration(displayDuration) : '--:--',
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
      ),
    );
  }

  @override
  void dispose() {
    _commentCubit.close();
    super.dispose();
  }
}
