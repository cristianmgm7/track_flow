import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_player/bloc/audioplayer_bloc.dart';
import 'package:trackflow/features/audio_player/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_player/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/presentation/components/track_status_badge.dart';

class QueueDisplay extends StatelessWidget {
  const QueueDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if (state is! AudioPlayerActiveState) {
          return const Center(
            child: Text(
              'No queue available',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          );
        }

        final player = context.read<AudioPlayerBloc>();
        final queue = player.currentQueue;
        final currentIndex = player.currentIndex;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with queue info and controls
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Queue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${queue.length} tracks • Playing track ${currentIndex + 1}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Mode indicators
                  Row(
                    children: [
                      _buildModeChip(
                        icon: Icons.shuffle,
                        label: 'Shuffle',
                        isActive: player.queueMode == PlaybackQueueMode.shuffle,
                        onTap: () {
                          context.read<AudioPlayerBloc>().add(
                            ToggleShuffleRequested(),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildModeChip(
                        icon: _getRepeatIcon(player.repeatMode),
                        label: _getRepeatLabel(player.repeatMode),
                        isActive: player.repeatMode != RepeatMode.none,
                        onTap: () {
                          context.read<AudioPlayerBloc>().add(
                            ToggleRepeatModeRequested(),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Queue list
            Expanded(
              child: ListView.builder(
                itemCount: queue.length,
                itemBuilder: (context, index) {
                  final trackId = queue[index];
                  final isCurrent = index == currentIndex;
                  
                  return FutureBuilder<String>(
                    future: _getTrackName(trackId, context),
                    builder: (context, snapshot) {
                      final trackName = snapshot.data ?? 'Loading...';
                      
                      return Container(
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[800]!,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[700],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: isCurrent
                                  ? Icon(
                                      state is AudioPlayerPlaying
                                          ? Icons.volume_up
                                          : Icons.pause,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          title: Text(
                            trackName,
                            style: TextStyle(
                              color: isCurrent ? Colors.white : Colors.grey[300],
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TrackStatusBadge(
                                trackUrl: '', // Would need actual track URL
                                trackId: trackId,
                                size: 16,
                              ),
                              if (!isCurrent) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.play_arrow),
                                  color: Colors.grey[400],
                                  iconSize: 20,
                                  onPressed: () {
                                    // Would need to implement jump to track
                                    // This would require a new event like SkipToIndexRequested
                                  },
                                ),
                              ],
                            ],
                          ),
                          onTap: isCurrent
                              ? null
                              : () {
                                  // Same as above - would need SkipToIndexRequested event
                                },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModeChip({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue[600] : Colors.grey[700],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? Colors.blue[400]! : Colors.grey[600]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : Colors.grey[300],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[300],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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

  // This would need proper implementation with actual track repository
  Future<String> _getTrackName(String trackId, BuildContext context) async {
    try {
      // In a real implementation, you would:
      // final player = context.read<AudioPlayerBloc>();
      // final track = await player.getTrackById(trackId);
      // return track.name;
      
      // For now, return a placeholder
      return 'Track $trackId';
    } catch (e) {
      return 'Unknown Track';
    }
  }
}

// Helper function to show queue as modal bottom sheet
void showQueueDisplay(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: const QueueDisplay(),
    ),
  );
}