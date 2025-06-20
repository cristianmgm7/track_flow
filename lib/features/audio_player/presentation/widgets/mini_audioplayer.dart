import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/services/audio_player/audio_player_event.dart';
import 'package:trackflow/core/services/audio_player/audio_player_state.dart';
import 'package:trackflow/core/services/audio_player/audioplayer_bloc.dart';

class MiniAudioPlayer extends StatelessWidget {
  final VoidCallback onExpand;

  const MiniAudioPlayer({super.key, required this.onExpand});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if (state is! AudioPlayerActiveState) return const SizedBox.shrink();
        final track = state.track;
        final collaborator = state.collaborator;
        final isPlaying = state is AudioPlayerPlaying;
        final isLoading = state is AudioPlayerLoading;
        final player = context.read<AudioPlayerBloc>().player;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onExpand,
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta! < -10) {
                  onExpand();
                }
              },
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage:
                          collaborator.avatarUrl.isNotEmpty
                              ? NetworkImage(collaborator.avatarUrl)
                              : null,
                      child:
                          collaborator.avatarUrl.isEmpty
                              ? Text(
                                collaborator.name.isNotEmpty
                                    ? collaborator.name.substring(0, 1)
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                              : null,
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
            StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = player.duration ?? Duration.zero;
                final progress =
                    (duration.inMilliseconds > 0)
                        ? position.inMilliseconds / duration.inMilliseconds
                        : 0.0;
                return LinearProgressIndicator(
                  value: progress,
                  minHeight: 2,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
