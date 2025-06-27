import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_cache/presentation/bloc/audio_cache_bloc.dart';
import 'package:trackflow/features/audio_cache/presentation/bloc/audio_cache_event.dart';
import 'package:trackflow/features/audio_cache/presentation/bloc/audio_cache_state.dart';

class SmartCacheIcon extends StatefulWidget {
  // Track identification (simplified for single tracks)
  final String trackId;
  final String trackUrl;
  final String trackName;
  
  // Visual configuration
  final double size;
  final Color? color;
  final bool showProgress;
  final bool enableHapticFeedback;
  final Duration undoDuration;
  
  // Callbacks
  final VoidCallback? onStateChanged;
  final Function(String message)? onSuccess;
  final Function(String message)? onError;

  const SmartCacheIcon({
    super.key,
    required this.trackId,
    required this.trackUrl,
    required this.trackName,
    this.size = 24.0,
    this.color,
    this.showProgress = true,
    this.enableHapticFeedback = true,
    this.undoDuration = const Duration(seconds: 3),
    this.onStateChanged,
    this.onSuccess,
    this.onError,
  });

  @override
  State<SmartCacheIcon> createState() => _SmartCacheIconState();
}

class _SmartCacheIconState extends State<SmartCacheIcon> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Check initial cache status
    context.read<AudioCacheBloc>().add(CheckCacheStatusRequested(widget.trackUrl));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap(AudioCacheState currentState) {
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }

    // Animate for immediate feedback
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    final bloc = context.read<AudioCacheBloc>();

    if (currentState is AudioCacheInitial) {
      // Not cached - start download
      bloc.add(DownloadTrackRequested(
        trackId: widget.trackId,
        trackUrl: widget.trackUrl,
        trackName: widget.trackName,
      ));
    } else if (currentState is AudioCacheLoading || currentState is AudioCacheProgress) {
      // Downloading - cancel
      bloc.add(CancelDownloadRequested(widget.trackId));
    } else if (currentState is AudioCacheDownloaded) {
      // Cached - remove from cache
      bloc.add(RemoveFromCacheRequested(widget.trackUrl));
      _showUndoSnackBar();
    } else if (currentState is AudioCacheFailure) {
      // Error - retry
      bloc.add(RetryDownloadRequested(
        trackId: widget.trackId,
        trackUrl: widget.trackUrl,
        trackName: widget.trackName,
      ));
    }
    
    widget.onStateChanged?.call();
  }

  void _showUndoSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.trackName} removed from cache'),
        backgroundColor: Colors.green,
        duration: widget.undoDuration,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () => _undoRemoval(),
        ),
      ),
    );
  }

  void _undoRemoval() {
    // Re-download the removed content
    context.read<AudioCacheBloc>().add(DownloadTrackRequested(
      trackId: widget.trackId,
      trackUrl: widget.trackUrl,
      trackName: widget.trackName,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AudioCacheBloc, AudioCacheState>(
      listener: (context, state) {
        if (state is AudioCacheDownloaded) {
          widget.onSuccess?.call('${widget.trackName} downloaded successfully');
        } else if (state is AudioCacheFailure) {
          widget.onError?.call(state.error);
        }
      },
      child: BlocBuilder<AudioCacheBloc, AudioCacheState>(
        builder: (context, state) {
          return InkWell(
            onTap: () => _handleTap(state),
            borderRadius: BorderRadius.circular(widget.size / 2),
            child: Container(
              width: widget.size + 8,
              height: widget.size + 8,
              padding: const EdgeInsets.all(4),
              child: _buildMainIcon(state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainIcon(AudioCacheState state) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.primaryColor;

    if (state is AudioCacheInitial) {
      // Not cached
      return ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.8).animate(_animationController),
        child: Icon(
          Icons.download,
          color: color.withValues(alpha: 0.7),
          size: widget.size,
        ),
      );
    } else if (state is AudioCacheLoading) {
      // Starting download
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color,
        ),
      );
    } else if (state is AudioCacheProgress) {
      // Downloading with progress
      if (widget.showProgress && state.progress > 0) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: CircularProgressIndicator(
                value: state.progress,
                strokeWidth: 2,
                color: color,
                backgroundColor: color.withValues(alpha: 0.2),
              ),
            ),
            Icon(
              Icons.close,
              color: color,
              size: widget.size * 0.6,
            ),
          ],
        );
      } else {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: color,
          ),
        );
      }
    } else if (state is AudioCacheDownloaded) {
      // Cached
      return ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.2).animate(_animationController),
        child: Icon(
          Icons.download_done,
          color: Colors.green,
          size: widget.size,
        ),
      );
    } else if (state is AudioCacheFailure) {
      // Error
      return ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.9).animate(_animationController),
        child: Icon(
          Icons.refresh,
          color: Colors.red,
          size: widget.size,
        ),
      );
    }

    // Fallback
    return Icon(
      Icons.download,
      color: color.withValues(alpha: 0.7),
      size: widget.size,
    );
  }

}