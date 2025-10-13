import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../audio_player/presentation/bloc/audio_player_bloc.dart';
import '../../../audio_player/presentation/bloc/audio_player_event.dart';
import '../../../audio_player/presentation/bloc/audio_player_state.dart';
import '../../domain/entities/voice_memo.dart';
import '../bloc/voice_memo_bloc.dart';
import '../bloc/voice_memo_event.dart';

class PlaybackControls extends StatelessWidget {
  final VoiceMemo memo;

  const PlaybackControls({super.key, required this.memo});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        final isCurrentMemo = state is AudioPlayerSessionState &&
            state.session.currentTrack?.id.value == memo.id.value;

        final isPlaying = isCurrentMemo &&
            state is AudioPlayerPlaying;

        final position = isCurrentMemo
            ? state.session.position
            : Duration.zero;

        final progress = memo.duration.inMilliseconds > 0
            ? position.inMilliseconds / memo.duration.inMilliseconds
            : 0.0;

        return Row(
          children: [
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColors.primary,
              ),
              onPressed: () => _togglePlayback(context, isPlaying),
            ),
            Expanded(
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: AppColors.surface,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                  SizedBox(height: Dimensions.space4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position),
                        style: AppTextStyle.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _formatDuration(memo.duration),
                        style: AppTextStyle.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _togglePlayback(BuildContext context, bool isPlaying) {
    if (isPlaying) {
      context.read<AudioPlayerBloc>().add(const PauseAudioRequested());
    } else {
      context.read<VoiceMemoBloc>().add(PlayVoiceMemoRequested(memo));
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
