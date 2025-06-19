import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/services/audio_player/audio_player_event.dart';
import 'package:trackflow/core/services/audio_player/audio_player_state.dart';
import 'package:trackflow/core/services/audio_player/audioplayer_bloc.dart';

class AudioPlayerScreen extends StatelessWidget {
  final ScrollController? scrollController;

  const AudioPlayerScreen({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if (state is! AudioPlayerActiveState) return const SizedBox.shrink();
        final track = state.track;
        final collaborator = state.collaborator;
        final isPlaying = state is AudioPlayerPlaying;
        return Container(
          color: Colors.black,
          child: SafeArea(
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.black,
                  leading: IconButton(
                    icon: const Icon(Icons.expand_more),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Column(
                    children: [
                      Text(
                        track.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        collaborator.name,
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
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
                        LinearProgressIndicator(
                          value: 0.3, // Reemplazar con progreso real
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
                              '0:00', // Reemplazar con tiempo actual
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            Text(
                              '3:45', // Reemplazar con duración
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
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
                              onPressed: () => context.push('/comments'),
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
