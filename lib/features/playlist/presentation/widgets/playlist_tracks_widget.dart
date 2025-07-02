import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/playlist/domain/entities/playlist.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_track/presentation/component/track_component.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/playlist/presentation/utils/playlist_utils.dart';

class PlaylistTracksWidget extends StatelessWidget {
  final Playlist playlist;
  final List<AudioTrack> tracks;
  final Map<String, UserProfile>? collaboratorsByTrackId;
  final String? projectId;

  const PlaylistTracksWidget({
    super.key,
    required this.playlist,
    required this.tracks,
    this.collaboratorsByTrackId,
    this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, playerState) {
        final player = context.read<AudioPlayerBloc>();
        final session = player.currentSession;
        final isPlayingFromThisPlaylist =
            playerState is AudioPlayerSessionState &&
            session.queue.isNotEmpty &&
            PlaylistUtils.isPlayingFromPlaylist(
              session.queue.sources.map((s) => s.metadata.id.value).toList(),
              playlist,
            );

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tracks.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final track = tracks[index];
            final uploader = collaboratorsByTrackId?[track.id.value];
            final queuePosition = index + 1;

            return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
              builder: (context, state) {
                final isCurrent =
                    state is AudioPlayerSessionState &&
                    state.session.currentTrack?.id.value == track.id.value;

                return Container(
                  decoration: BoxDecoration(
                    color:
                        isCurrent
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                    border:
                        isPlayingFromThisPlaylist && !isCurrent
                            ? Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.3),
                              width: 1,
                            )
                            : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.only(left: 8, right: 8),
                        decoration: BoxDecoration(
                          color:
                              isCurrent
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            queuePosition.toString(),
                            style: TextStyle(
                              color:
                                  isCurrent ? Colors.white : Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TrackComponent(
                          track: track,
                          uploader: uploader,
                          projectId:
                              projectId != null
                                  ? ProjectId.fromUniqueString(projectId!)
                                  : track.projectId,
                          onPlay: () {
                            context.read<AudioPlayerBloc>().add(
                              PlayPlaylistRequested(
                                playlist.id,
                                startIndex: index,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
