import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_event.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_state.dart';
import 'package:trackflow/features/project_detail/aplication/audioplayer_bloc.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

// --- NUEVO ENUM Y WIDGET ---
enum PlayerViewMode { mini, expanded }

class AudioPlayerSheet extends StatelessWidget {
  final PlayerViewMode mode;
  const AudioPlayerSheet({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if (state is! AudioPlayerActiveState) return const SizedBox.shrink();
        final track = state.track;
        final collaborator = state.collaborator;
        if (mode == PlayerViewMode.mini) {
          return _buildMiniPlayer(context, track, collaborator, state);
        } else {
          return _buildExpandedPlayer(context, track, collaborator, state);
        }
      },
    );
  }

  Widget _buildMiniPlayer(
    BuildContext context,
    AudioTrack track,
    UserProfile collaborator,
    AudioPlayerActiveState state,
  ) {
    final isPlaying = state is AudioPlayerPlaying;
    final isLoading = state is AudioPlayerLoading;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder:
              (_) => BlocProvider.value(
                value: context.read<AudioPlayerBloc>(),
                child: const AudioPlayerSheet(mode: PlayerViewMode.expanded),
              ),
        );
      },
      child: Container(
        height: 64,
        color: Colors.grey[900],
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
              child: Text(
                track.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildExpandedPlayer(
    BuildContext context,
    AudioTrack track,
    UserProfile collaborator,
    AudioPlayerActiveState state,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildProPlayer(track, collaborator, state),
        ListTile(
          title: const Text("Comentarios"),
          onTap: () => context.push("/comments"),
        ),
        ListTile(title: const Text("Team"), onTap: () => context.push("/team")),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }

  Widget _buildProPlayer(
    AudioTrack track,
    UserProfile collaborator,
    AudioPlayerActiveState state,
  ) {
    // Aquí puedes poner tu vista pro, slider, controles, etc.
    return Container(
      height: 200,
      color: Colors.black,
      child: Center(
        child: Text(
          "Player Pro View\n${track.name} - ${collaborator.name}",
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
