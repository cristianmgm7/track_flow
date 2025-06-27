import 'package:flutter/material.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/presentation/widgets/trackflow_action_botton_sheet.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audioplayer_bloc.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/presentation/widgets/audio_track_actions.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_cache/presentation/bloc/audio_cache_bloc.dart';
import 'package:trackflow/features/audio_cache/presentation/widgets/smart_cache_icon.dart';
import 'package:trackflow/features/audio_player/presentation/components/track_status_badge.dart';

class TrackComponent extends StatefulWidget {
  final AudioTrack track;
  final UserProfile? uploader;
  final VoidCallback? onPlay;
  final VoidCallback? onComment;
  final ProjectId projectId;

  const TrackComponent({
    super.key,
    required this.track,
    required this.uploader,
    this.onPlay,
    this.onComment,
    required this.projectId,
  });

  @override
  State<TrackComponent> createState() => _TrackComponentState();
}

class _TrackComponentState extends State<TrackComponent> {
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _playTrack(BuildContext context) {
    if (widget.uploader == null) return;
    context.read<AudioPlayerBloc>().add(
      PlayAudioRequested(
        source: PlaybackSource(type: PlaybackSourceType.track),
        visualContext: PlayerVisualContext.miniPlayer,
        track: widget.track,
        collaborator: widget.uploader!,
      ),
    );
  }

  void _openTrackActionsSheet(BuildContext context) {
    showTrackFlowActionSheet(
      title: widget.track.name,
      context: context,
      actions: TrackActions.forTrack(
        context,
        widget.projectId,
        widget.track,
        widget.uploader != null ? [widget.uploader!] : [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final durationStr = _formatDuration(widget.track.duration);

    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, playerState) {
        final isCurrent =
            playerState is AudioPlayerActiveState &&
            playerState.track.id == widget.track.id;
        final isPlaying = isCurrent && playerState is AudioPlayerPlaying;
        return Card(
          color:
              isCurrent
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surface,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.space4),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Play/Pause button
                Material(
                  color:
                      widget.uploader != null ? Colors.blueAccent : Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap:
                        widget.uploader != null
                            ? () => _playTrack(context)
                            : null,
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child:
                            isCurrent
                                ? (isPlaying
                                    ? const Icon(
                                      Icons.pause,
                                      color: Colors.white,
                                      size: 28,
                                      key: ValueKey('pause'),
                                    )
                                    : const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 28,
                                      key: ValueKey('play'),
                                    ))
                                : const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 28,
                                  key: ValueKey('play'),
                                ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info principal (nombre y debajo: icono + colaborador)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.track.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          TrackStatusBadge(
                            trackUrl: widget.track.url,
                            trackId: widget.track.id.value,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.uploader?.name ?? 'Unknown User',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Duración
                Text(
                  durationStr,
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                const SizedBox(width: 8),
                // Smart Cache Icon with BLoC provider
                BlocProvider(
                  create: (context) => sl<AudioCacheBloc>(),
                  child: SmartCacheIcon(
                    trackId: widget.track.id.value,
                    trackUrl: widget.track.url,
                    trackName: widget.track.name,
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
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.blueAccent),
                  onPressed: () => _openTrackActionsSheet(context),
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
        );
      },
    );
  }
}
