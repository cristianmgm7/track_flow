import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/playlist/domain/entities/playlist.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audioplayer_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_track/presentation/component/track_component.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/audio_cache/playlist/presentation/widgets/playlist_cache_icon.dart';
import 'package:trackflow/features/audio_cache/track/presentation/widgets/smart_track_cache_icon.dart';
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_bloc.dart';
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart';
import 'package:trackflow/core/di/injection.dart';

class PlaylistWidget extends StatelessWidget {
  final Playlist playlist;
  final List<AudioTrack> tracks;
  final Map<String, UserProfile>? collaboratorsByTrackId;
  final bool showPlayAll;
  final String? projectId;

  const PlaylistWidget({
    super.key,
    required this.playlist,
    required this.tracks,
    this.collaboratorsByTrackId,
    this.showPlayAll = true,
    this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, playerState) {
        final player = context.read<AudioPlayerBloc>();
        final isPlayingFromThisPlaylist =
            playerState is AudioPlayerActiveState &&
            player.currentQueue.isNotEmpty &&
            _isCurrentPlaylist(player.currentQueue);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Playlist controls - always visible
            Row(
              children: [
                ElevatedButton.icon(
                  icon: Icon(
                    isPlayingFromThisPlaylist ? Icons.pause : Icons.play_arrow,
                  ),
                  label: Text(isPlayingFromThisPlaylist ? 'Pause' : 'Play All'),
                  onPressed: () {
                    if (isPlayingFromThisPlaylist &&
                        playerState is AudioPlayerPlaying) {
                      context.read<AudioPlayerBloc>().add(
                        PauseAudioRequested(),
                      );
                    } else {
                      context.read<AudioPlayerBloc>().add(
                        PlayPlaylistRequested(playlist),
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),
                // Shuffle control - always visible
                InkWell(
                  onTap: () {
                    context.read<AudioPlayerBloc>().add(
                      ToggleShuffleRequested(),
                    );
                  },
                  child: _buildModeIndicator(
                    icon: Icons.shuffle,
                    isActive: player.queueMode == PlaybackQueueMode.shuffle,
                    label: 'Shuffle',
                  ),
                ),
                const SizedBox(width: 8),
                // Repeat control - always visible
                InkWell(
                  onTap: () {
                    context.read<AudioPlayerBloc>().add(
                      ToggleRepeatModeRequested(),
                    );
                  },
                  child: _buildModeIndicator(
                    icon: _getRepeatIcon(player.repeatMode),
                    isActive: player.repeatMode != RepeatMode.none,
                    label: _getRepeatLabel(player.repeatMode),
                  ),
                ),
                const Spacer(),
                // Simplified cache control for playlist
                BlocProvider(
                  create: (context) => sl<PlaylistCacheBloc>(),
                  child: PlaylistCacheIcon(
                    playlistId: playlist.id,
                    trackUrlPairs: Map.fromEntries(
                      tracks.map(
                        (track) => MapEntry(track.id.value, track.url),
                      ),
                    ),
                    playlistName: playlist.name,
                    size: 28.0,
                  ),
                ),
              ],
            ),
            if (isPlayingFromThisPlaylist)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Playing from this playlist • Track ${player.currentIndex + 1} of ${player.currentQueue.length}',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tracks.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final track = tracks[index];
                final uploader = collaboratorsByTrackId?[track.id.value];
                // Always show queue position since we're always in playlist mode
                final queuePosition = index + 1;

                return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                  builder: (context, state) {
                    final isCurrent =
                        state is AudioPlayerActiveState &&
                        state.track.id == track.id;

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
                          // Always show queue position
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
                                      isCurrent
                                          ? Colors.white
                                          : Colors.grey[600],
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
                                    playlist,
                                    startIndex: index,
                                  ),
                                );
                              },
                            ),
                          ),
                          // Add Smart Cache Icon for individual track
                          BlocProvider(
                            create: (context) => sl<TrackCacheBloc>(),
                            child: SmartTrackCacheIcon(
                              trackId: track.id.value,
                              audioUrl: track.url,
                              size: 20.0,
                              onSuccess: (message) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              onError: (message) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 3),
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
            ),
          ],
        );
      },
    );
  }

  bool _isCurrentPlaylist(List<String> currentQueue) {
    if (currentQueue.length != playlist.trackIds.length) return false;
    return playlist.trackIds.every((trackId) => currentQueue.contains(trackId));
  }

  Widget _buildModeIndicator({
    required IconData icon,
    required bool isActive,
    required String label,
  }) {
    return Tooltip(
      message: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue[600] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive ? Colors.white : Colors.grey[600],
        ),
      ),
    );
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

  String _getRepeatLabel(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.none:
        return 'No Repeat';
      case RepeatMode.single:
        return 'Repeat One';
      case RepeatMode.queue:
        return 'Repeat All';
    }
  }
}
