import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../audio_player/presentation/bloc/audio_player_bloc.dart';
import '../../../audio_player/presentation/bloc/audio_player_state.dart';
import '../../domain/entities/voice_memo.dart';
import 'voice_memo_progress_bar.dart';

class VoiceMemoPlaybackControls extends StatelessWidget {
  final VoiceMemo memo;
  final VoidCallback onPlayPressed;
  final VoidCallback onPausePressed;

  const VoiceMemoPlaybackControls({
    super.key,
    required this.memo,
    required this.onPlayPressed,
    required this.onPausePressed,
  });

  bool get _fileExists {
    try {
      return File(memo.fileLocalPath).existsSync();
    } catch (e) {
      return false;
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, audioState) {
        final isCurrentMemo = audioState is AudioPlayerSessionState &&
            audioState.session.currentTrack?.id.value == memo.id.value;

        final isPlaying = isCurrentMemo &&
            audioState is AudioPlayerPlaying;

        final position = isCurrentMemo
            ? audioState.session.position
            : Duration.zero;

        return Row(
          children: [
            // Play/Pause Button
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: _fileExists
                    ? () {
                        if (isPlaying) {
                          onPausePressed();
                        } else {
                          onPlayPressed();
                        }
                      }
                    : null,
              ),
            ),

            SizedBox(width: Dimensions.space12),

            // Progress Bar
            Expanded(
              child: VoiceMemoProgressBar(
                position: position,
                totalDuration: memo.duration,
              ),
            ),

            SizedBox(width: Dimensions.space12),

            // Duration
            Text(
              _formatDuration(memo.duration),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}
