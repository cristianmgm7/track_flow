import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart';
import 'package:trackflow/features/audio_player/bloc/audioplayer_bloc.dart';
import 'package:trackflow/features/audio_player/bloc/audio_player_state.dart';

class TrackStatusBadge extends StatefulWidget {
  final String trackUrl;
  final String trackId;
  final double size;
  final bool showText;

  const TrackStatusBadge({
    super.key,
    required this.trackUrl,
    required this.trackId,
    this.size = 16,
    this.showText = false,
  });

  @override
  State<TrackStatusBadge> createState() => _TrackStatusBadgeState();
}

class _TrackStatusBadgeState extends State<TrackStatusBadge> {
  CacheStatus _cacheStatus = CacheStatus.notCached;

  @override
  void initState() {
    super.initState();
    _checkCacheStatus();
  }

  Future<void> _checkCacheStatus() async {
    final audioSourceResolver = context.read<AudioSourceResolver>();
    final status = await audioSourceResolver.getCacheStatus(widget.trackUrl);
    if (mounted) {
      setState(() {
        _cacheStatus = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, playerState) {
        final isCurrentTrack = playerState is AudioPlayerActiveState &&
            playerState.track.id.value == widget.trackId;
        final isPlaying = playerState is AudioPlayerPlaying && isCurrentTrack;
        final isLoading = playerState is AudioPlayerLoading && isCurrentTrack;

        // Priority: Playing state > Loading state > Cache status
        if (isPlaying) {
          return _buildBadge(
            icon: Icons.volume_up,
            color: Colors.green,
            text: 'Playing',
          );
        }

        if (isLoading) {
          return _buildBadge(
            icon: Icons.hourglass_empty,
            color: Colors.orange,
            text: 'Loading',
            isAnimated: true,
          );
        }

        switch (_cacheStatus) {
          case CacheStatus.cached:
            return _buildBadge(
              icon: Icons.offline_pin,
              color: Colors.blue,
              text: 'Cached',
            );
          case CacheStatus.caching:
            return _buildBadge(
              icon: Icons.download,
              color: Colors.orange,
              text: 'Downloading',
              isAnimated: true,
            );
          case CacheStatus.corrupted:
            return _buildBadge(
              icon: Icons.error_outline,
              color: Colors.red,
              text: 'Error',
            );
          case CacheStatus.notCached:
            return _buildBadge(
              icon: Icons.cloud,
              color: Colors.grey,
              text: 'Streaming',
            );
        }
      },
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required Color color,
    required String text,
    bool isAnimated = false,
  }) {
    Widget iconWidget = Icon(
      icon,
      size: widget.size,
      color: color,
    );

    if (isAnimated) {
      iconWidget = AnimatedRotation(
        turns: 1,
        duration: const Duration(seconds: 2),
        child: iconWidget,
      );
    }

    if (widget.showText) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: widget.size * 0.75,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Container(
      width: widget.size + 4,
      height: widget.size + 4,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(widget.size / 2 + 2),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Center(child: iconWidget),
    );
  }
}