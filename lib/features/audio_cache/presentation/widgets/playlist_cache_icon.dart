import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_cache/presentation/bloc/audio_cache_bloc.dart';
import 'package:trackflow/features/audio_cache/presentation/bloc/audio_cache_event.dart';
import 'package:trackflow/features/audio_cache/presentation/bloc/audio_cache_state.dart';
import 'package:trackflow/features/audio_cache/domain/services/download_management_service.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';

class PlaylistCacheIcon extends StatefulWidget {
  final List<AudioTrack> tracks;
  final String playlistName;
  final double size;
  final Color? color;

  const PlaylistCacheIcon({
    super.key,
    required this.tracks,
    required this.playlistName,
    this.size = 24.0,
    this.color,
  });

  @override
  State<PlaylistCacheIcon> createState() => _PlaylistCacheIconState();
}

class _PlaylistCacheIconState extends State<PlaylistCacheIcon> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AudioCacheBloc, AudioCacheState>(
      listener: (context, state) {
        if (state is AudioCacheDownloaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.playlistName} downloads started'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is AudioCacheFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download error: ${state.error}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: BlocBuilder<AudioCacheBloc, AudioCacheState>(
        builder: (context, state) {
          return InkWell(
            onTap: () => _handlePlaylistAction(state),
            borderRadius: BorderRadius.circular(widget.size / 2),
            child: Container(
              width: widget.size + 8,
              height: widget.size + 8,
              padding: const EdgeInsets.all(4),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildPlaylistIcon(state),
                  // Show track count badge
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.tracks.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widget.size * 0.3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handlePlaylistAction(AudioCacheState state) {
    // Use events to trigger downloads for all tracks
    for (final track in widget.tracks) {
      context.read<AudioCacheBloc>().add(DownloadTrackRequested(
        trackId: track.id.value,
        trackUrl: track.url,
        trackName: track.name,
      ));
    }
  }

  Widget _buildPlaylistIcon(AudioCacheState state) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.primaryColor;

    if (state is AudioCacheLoading) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color,
        ),
      );
    } else if (state is AudioCacheProgress) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(
          value: state.progress,
          strokeWidth: 2,
          color: color,
        ),
      );
    }

    // Default download icon
    return Icon(
      Icons.download,
      color: color.withValues(alpha: 0.7),
      size: widget.size,
    );
  }
}