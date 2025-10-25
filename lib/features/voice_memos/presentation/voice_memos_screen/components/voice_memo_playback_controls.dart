import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/ui/audio/audio_play_pause_button.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../audio_player/presentation/bloc/audio_player_bloc.dart';
import '../../../../audio_player/presentation/bloc/audio_player_state.dart';
import '../../../domain/entities/voice_memo.dart';

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

  

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, audioState) {
        final isCurrentMemo = audioState is AudioPlayerSessionState &&
            audioState.session.currentTrack?.id.value == memo.id.value;

        final isPlaying = isCurrentMemo &&
            audioState is AudioPlayerPlaying;

      

        return Column(
          children: [
            // Play/Pause Button using AudioPlayPauseButton
            AudioPlayPauseButton(
              isPlaying: isPlaying,
              isBuffering: false,
              onPressed: _fileExists
                  ? () {
                      if (isPlaying) {
                        onPausePressed();
                      } else {
                        onPlayPressed();
                      }
                    }
                  : null,
              size: Dimensions.iconLarge,
              iconSize: Dimensions.iconMedium,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              iconColor: Colors.white,
            ),
          ],
        );
      }, 
    );
  }
}
