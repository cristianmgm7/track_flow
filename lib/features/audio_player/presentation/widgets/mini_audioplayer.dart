import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_player/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_player/bloc/audioplayer_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/components/track_status_badge.dart';

class MiniAudioPlayer extends StatefulWidget {
  final VoidCallback onExpand;

  const MiniAudioPlayer({super.key, required this.onExpand});

  @override
  State<MiniAudioPlayer> createState() => _MiniAudioPlayerState();
}

class _MiniAudioPlayerState extends State<MiniAudioPlayer> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if (state is! AudioPlayerActiveState) return const SizedBox.shrink();
        final track = state.track;
        final collaborator = state.collaborator;
        final isPlaying = state is AudioPlayerPlaying;
        final isLoading = state is AudioPlayerLoading;
        final bloc = context.read<AudioPlayerBloc>();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: widget.onExpand,
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta! < -10) {
                  widget.onExpand();
                }
              },
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.surface,
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: TrackStatusBadge(
                            trackUrl: track.url,
                            trackId: track.id.value,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            collaborator.name,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap:
                            isLoading
                                ? null
                                : () {
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
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child:
                              isLoading
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Barra de progreso delgada
            StreamBuilder<Duration?>(
              stream: bloc.durationStream,
              builder: (context, durationSnapshot) {
                final duration = durationSnapshot.data ?? Duration.zero;
                return StreamBuilder<Duration>(
                  stream: bloc.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final progress =
                        (duration.inMilliseconds > 0)
                            ? position.inMilliseconds / duration.inMilliseconds
                            : 0.0;
                    return LinearProgressIndicator(
                      value: progress,
                      minHeight: 2,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blueAccent,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
