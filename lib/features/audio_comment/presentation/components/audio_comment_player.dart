import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';

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
  late AudioPlayer _player;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    // Listen to player state changes
    _player.positionStream.listen((position) {
      if (mounted) setState(() => _position = position);
    });

    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          // Auto-reset to beginning when playback completes
          if (state.processingState == ProcessingState.completed) {
            _player.seek(Duration.zero);
            _player.pause();
          }
        });
      }
    });

    _player.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() => _duration = duration);
      }
    });

    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Try local cache first
      if (widget.comment.localAudioPath != null &&
          await File(widget.comment.localAudioPath!).exists()) {
        await _player.setFilePath(widget.comment.localAudioPath!);
      }
      // Otherwise stream from Firebase Storage
      else if (widget.comment.audioStorageUrl != null) {
        await _player.setUrl(widget.comment.audioStorageUrl!);
      } else {
        throw Exception('No audio source available');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load audio: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void _onSeek(double value) {
    _player.seek(Duration(milliseconds: value.toInt()));
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
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
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
