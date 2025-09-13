import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cached_audio.dart';
import '../bloc/track_cache_bloc.dart';
import '../bloc/track_cache_state.dart';
import 'track_cache_icon_builder.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import '../bloc/track_cache_event.dart';

class SmartTrackCacheIcon extends StatefulWidget {
  // Identification
  final String trackId;
  final String versionId;
  final String remoteUrl;

  // Visual configuration
  final double size;
  final Color? color;
  final bool showProgress;

  // Callbacks
  final Function(String message)? onSuccess;
  final Function(String message)? onError;

  const SmartTrackCacheIcon({
    super.key,
    required this.trackId,
    required this.versionId,
    required this.remoteUrl,
    this.size = 24.0,
    this.color,
    this.showProgress = true,
    this.onSuccess,
    this.onError,
  });

  @override
  State<SmartTrackCacheIcon> createState() => _SmartTrackCacheIconState();
}

class _SmartTrackCacheIconState extends State<SmartTrackCacheIcon> {
  late final TrackCacheIconBuilder _iconBuilder;

  @override
  void initState() {
    super.initState();

    _iconBuilder = const TrackCacheIconBuilder();

    // Check initial cache status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrackCacheBloc>().add(
        WatchTrackCacheStatusRequested(
          AudioTrackId.fromUniqueString(widget.trackId),
          versionId: TrackVersionId.fromUniqueString(widget.versionId),
        ),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleTap(TrackCacheState currentState) {
    final bloc = context.read<TrackCacheBloc>();

    if (currentState is TrackCacheStatusLoaded) {
      if (currentState.status == CacheStatus.cached) {
        bloc.add(
          RemoveTrackCacheRequested(
            trackId: widget.trackId,
            versionId: widget.versionId,
          ),
        );
      } else {
        bloc.add(
          CacheTrackRequested(
            trackId: widget.trackId,
            versionId: widget.versionId,
            audioUrl: widget.remoteUrl,
          ),
        );
      }
    } else {
      bloc.add(
        CacheTrackRequested(
          trackId: widget.trackId,
          versionId: widget.versionId,
          audioUrl: widget.remoteUrl,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackCacheBloc, TrackCacheState>(
      builder: (context, state) {
        CacheStatus status;
        if (state is TrackCacheStatusLoaded) {
          status = state.status;
        } else {
          status = CacheStatus.notCached;
        }

        final iconConfig = TrackCacheIconConfig(
          size: widget.size,
          color: widget.color,
          showProgress: widget.showProgress,
        );

        return InkWell(
          onTap: () => _handleTap(state),
          borderRadius: BorderRadius.circular(widget.size / 2),
          splashColor: (widget.color ?? Theme.of(context).primaryColor)
              .withValues(alpha: 0.2),
          highlightColor: (widget.color ?? Theme.of(context).primaryColor)
              .withValues(alpha: 0.1),
          child: Container(
            width: widget.size + 8,
            height: widget.size + 8,
            padding: const EdgeInsets.all(4),
            child: _iconBuilder.buildIcon(
              state,
              iconConfig,
              context,
              lastKnownStatus: status,
            ),
          ),
        );
      },
    );
  }
}
