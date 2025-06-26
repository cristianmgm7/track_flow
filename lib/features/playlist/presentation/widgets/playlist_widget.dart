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
import 'package:trackflow/features/audio_cache/presentation/components/batch_download_button.dart';
import 'package:trackflow/features/audio_cache/domain/usecases/enhanced_download_manager.dart';
import 'package:trackflow/features/audio_cache/domain/services/storage_management_service.dart';
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
                // Download controls
                PopupMenuButton<String>(
                  icon: const Icon(Icons.download),
                  onSelected: (value) async {
                    if (value == 'download_all') {
                      await _downloadAllTracks(context);
                    } else if (value == 'clear_cache') {
                      await _clearPlaylistCache(context);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'download_all',
                          child: ListTile(
                            leading: Icon(Icons.download),
                            title: Text('Download All'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'clear_cache',
                          child: ListTile(
                            leading: Icon(Icons.clear),
                            title: Text('Clear Cache'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                ),
              ],
            ),
            // Download button component
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: BatchDownloadButton(
                tracks: tracks,
                buttonText: 'Download Playlist',
              ),
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
                    // Show all tracks as part of the playlist queue
                    final isInCurrentQueue =
                        isPlayingFromThisPlaylist &&
                        player.currentQueue.contains(track.id.value);

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
                                  ).colorScheme.primary.withOpacity(0.3),
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

  Future<void> _downloadAllTracks(BuildContext context) async {
    try {
      final downloadManager = sl<EnhancedDownloadManager>();
      final requests =
          tracks
              .map(
                (track) => DownloadTaskRequest(
                  trackId: track.id.value,
                  trackUrl: track.url,
                  trackName: track.name,
                  priority: DownloadPriority.normal,
                ),
              )
              .toList();

      final result = await downloadManager.downloadTracks(requests);

      if (context.mounted) {
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Download failed: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          },
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Started downloading ${tracks.length} tracks'),
                backgroundColor: Colors.green,
              ),
            );
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearPlaylistCache(BuildContext context) async {
    try {
      final storageService = sl<StorageManagementService>();
      final trackUrls = tracks.map((track) => track.url).toList();

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Clear Playlist Cache'),
              content: Text(
                'This will remove ${tracks.length} cached tracks from this playlist. Are you sure?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Clear'),
                ),
              ],
            ),
      );

      if (confirmed == true && context.mounted) {
        await storageService.removeCachedTracks(trackUrls);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Playlist cache cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Clear cache error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
