import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_player/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_player/bloc/audioplayer_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/components/queue_display.dart';

class ProAudioPlayer extends StatelessWidget {
  final ScrollController? scrollController;
  const ProAudioPlayer({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if (state is! AudioPlayerActiveState) return const SizedBox.shrink();
        final isPlaying = state is AudioPlayerPlaying;
        final player = context.read<AudioPlayerBloc>();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Portada y controles principales
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.music_note,
                  size: 80,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Queue position display
            if (player.currentQueue.length > 1)
              Text(
                'Track ${player.currentIndex + 1} of ${player.currentQueue.length}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 16),
            // Progreso y tiempos
            StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = state.track.duration;
                final progress =
                    (duration.inMilliseconds > 0)
                        ? position.inMilliseconds / duration.inMilliseconds
                        : 0.0;
                return Column(
                  children: [
                    GestureDetector(
                      onTapDown: (details) {
                        final box = context.findRenderObject() as RenderBox;
                        final localPosition = box.globalToLocal(details.globalPosition);
                        final tapProgress = localPosition.dx / box.size.width;
                        final seekPosition = Duration(
                          milliseconds: (tapProgress * duration.inMilliseconds).round(),
                        );
                        context.read<AudioPlayerBloc>().add(
                          SeekToPositionRequested(seekPosition),
                        );
                      },
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[800],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(position),
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        Text(
                          _formatDuration(duration),
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            // Controles de reproducción
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: player.hasPrevious
                      ? () {
                          context.read<AudioPlayerBloc>().add(
                            SkipToPreviousRequested(),
                          );
                        }
                      : null,
                  color: player.hasPrevious ? Colors.white : Colors.grey[600],
                  iconSize: 36,
                ),
                FloatingActionButton(
                  onPressed: () {
                    if (isPlaying) {
                      context.read<AudioPlayerBloc>().add(
                        PauseAudioRequested(),
                      );
                    } else {
                      context.read<AudioPlayerBloc>().add(
                        ResumeAudioRequested(),
                      );
                    }
                  },
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 32,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: player.hasNext
                      ? () {
                          context.read<AudioPlayerBloc>().add(
                            SkipToNextRequested(),
                          );
                        }
                      : null,
                  color: player.hasNext ? Colors.white : Colors.grey[600],
                  iconSize: 36,
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Controles adicionales
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.shuffle),
                  onPressed: () {
                    context.read<AudioPlayerBloc>().add(
                      ToggleShuffleRequested(),
                    );
                  },
                  color: player.queueMode == PlaybackQueueMode.shuffle
                      ? Colors.blueAccent
                      : Colors.grey[400],
                ),
                IconButton(
                  icon: Icon(_getRepeatIcon(player.repeatMode)),
                  onPressed: () {
                    context.read<AudioPlayerBloc>().add(
                      ToggleRepeatModeRequested(),
                    );
                  },
                  color: player.repeatMode != RepeatMode.none
                      ? Colors.blueAccent
                      : Colors.grey[400],
                ),
                IconButton(
                  icon: const Icon(Icons.queue_music),
                  onPressed: () => showQueueDisplay(context),
                  color: player.currentQueue.length > 1 
                      ? Colors.white 
                      : Colors.grey[400],
                ),
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: () {},
                  color: Colors.grey[400],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

String _formatDuration(Duration d) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(d.inMinutes.remainder(60));
  final seconds = twoDigits(d.inSeconds.remainder(60));
  return '$minutes:$seconds';
}

IconData _getRepeatIcon(RepeatMode mode) {
  switch (mode) {
    case RepeatMode.none:
      return Icons.repeat;
    case RepeatMode.single:
      return Icons.repeat_one;
    case RepeatMode.queue:
      return Icons.repeat;
  }
}
