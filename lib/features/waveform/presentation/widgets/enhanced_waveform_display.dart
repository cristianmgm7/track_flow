import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/waveform/presentation/bloc/waveform_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/waveform/presentation/widgets/generated_waveform_display.dart';

class EnhancedWaveformDisplay extends StatefulWidget {
  final AudioTrack track;
  final TrackVersionId? versionId;
  final double height;
  final Duration? trackDuration;

  const EnhancedWaveformDisplay({
    super.key,
    required this.track,
    this.versionId,
    this.height = 80.0,
    this.trackDuration,
  });

  @override
  State<EnhancedWaveformDisplay> createState() =>
      _EnhancedWaveformDisplayState();
}

class _EnhancedWaveformDisplayState extends State<EnhancedWaveformDisplay> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.versionId != null) {
        context.read<WaveformBloc>().add(LoadWaveform(widget.versionId!));
      }
    });
  }

  @override
  void didUpdateWidget(EnhancedWaveformDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.versionId != widget.versionId && widget.versionId != null) {
      context.read<WaveformBloc>().add(LoadWaveform(widget.versionId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WaveformBloc, WaveformState>(
      builder: (context, state) {
        switch (state.status) {
          case WaveformStatus.loading:
            return _buildLoadingState();
          case WaveformStatus.error:
            // Fallback to old system when error occurs
            return _buildFallbackWaveform();
          case WaveformStatus.ready:
            if (state.waveform != null) {
              return GeneratedWaveformDisplay(
                waveform: state.waveform!,
                state: state,
                height: widget.height,
              );
            } else {
              return _buildFallbackWaveform();
            }
          default:
            return _buildInitialState();
        }
      },
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: widget.height,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(height: 8),
            Text(
              'Generating waveform...',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return SizedBox(
      height: widget.height,
      child: const Center(
        child: Text(
          'Initializing...',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildFallbackWaveform() {
    // Minimal empty state when waveform isn't ready
    return SizedBox(height: widget.height);
  }


  // Note: No internal drag state; gestures are handled in WaveformGestures
}
