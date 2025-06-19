import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/core/services/audio_player/audio_player_event.dart';
import 'package:trackflow/core/services/audio_player/audio_player_state.dart';
import 'package:trackflow/core/services/audio_player/audioplayer_bloc.dart';
import 'package:trackflow/features/audio_cache/domain/usecases/get_cached_audio_path.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/audio_cache/audio_cache_icon.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_cache/audio_cache_cubit.dart';
import 'package:trackflow/features/audio_cache/audio_cache_state.dart';

class TrackComponent extends StatelessWidget {
  final AudioTrack track;
  final UserProfile uploader;
  final VoidCallback? onPlay;
  final VoidCallback? onComment;

  const TrackComponent({
    super.key,
    required this.track,
    required this.uploader,
    this.onPlay,
    this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final createdAtStr = dateFormat.format(track.createdAt);
    final durationStr = _formatDuration(track.duration);

    return BlocProvider<AudioCacheCubit>(
      create: (context) => AudioCacheCubit(sl<GetCachedAudioPath>()),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        child: Card(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.97),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Controls section
                SizedBox(
                  width: 100, // Fixed width for controls
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BlocBuilder<AudioCacheCubit, AudioCacheState>(
                        builder: (context, state) {
                          final isReady = state is AudioCacheDownloaded;
                          return Material(
                            color: isReady ? Colors.blueAccent : Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: isReady ? onPlay : null,
                              child: Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      AudioCacheIcon(remoteUrl: track.url),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Info section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              track.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            durationStr,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundImage:
                                uploader.avatarUrl.isNotEmpty
                                    ? NetworkImage(uploader.avatarUrl)
                                    : null,
                            child:
                                uploader.avatarUrl.isEmpty
                                    ? Text(
                                      uploader.name.isNotEmpty
                                          ? uploader.name.substring(0, 1)
                                          : '?',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                    : null,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              uploader.name.isNotEmpty
                                  ? uploader.name
                                  : 'Unknown',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            createdAtStr,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.blueAccent),
                  onPressed:
                      () => context.read<AudioPlayerBloc>().add(
                        PlayAudioRequested(
                          source: PlaybackSource(
                            type: PlaybackSourceType.track,
                          ),
                          visualContext: PlayerVisualContext.miniPlayer,
                          track: track,
                          collaborator: uploader,
                        ),
                      ),
                  tooltip: 'Actions',
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
