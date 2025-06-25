import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_player/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_player/bloc/audioplayer_bloc.dart';

class ProAudioPlayer extends StatelessWidget {
  final ScrollController? scrollController;
  const ProAudioPlayer({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if (state is! AudioPlayerActiveState) return const SizedBox.shrink();
        final isPlaying = state is AudioPlayerPlaying;
        final player = context.read<AudioPlayerBloc>().player;
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
            const SizedBox(height: 32),
            // Progreso y tiempos
            StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = player.duration ?? Duration.zero;
                final progress =
                    (duration.inMilliseconds > 0)
                        ? position.inMilliseconds / duration.inMilliseconds
                        : 0.0;
                return Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
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
                  onPressed: () {},
                  color: Colors.white,
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
                  onPressed: () {},
                  color: Colors.white,
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
                  onPressed: () {},
                  color: Colors.grey[400],
                ),
                IconButton(
                  icon: const Icon(Icons.repeat),
                  onPressed: () {},
                  color: Colors.grey[400],
                ),
                IconButton(
                  icon: const Icon(Icons.queue_music),
                  onPressed: () {},
                  color: Colors.grey[400],
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
