import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/audio_player_bloc.dart';
import '../../bloc/audio_player_state.dart';
import '../audio_controls.dart';
import '../playback_progress.dart';
import '../queue_controls.dart';
import 'track_info_widget.dart';
import 'modal_presentation_service.dart';

class MiniAudioPlayerConfig {
  final double height;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final bool showQueueControls;
  final bool showProgress;
  final bool showTrackInfo;

  const MiniAudioPlayerConfig({
    this.height = 80.0,
    this.padding = const EdgeInsets.all(12.0),
    this.backgroundColor,
    this.showQueueControls = true,
    this.showProgress = true,
    this.showTrackInfo = true,
  });
}

class MiniAudioPlayer extends StatelessWidget {
  const MiniAudioPlayer({
    super.key,
    this.config = const MiniAudioPlayerConfig(),
    this.modalService,
  });

  final MiniAudioPlayerConfig config;
  final IModalPresentationService? modalService;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modalPresentationService = modalService ?? ModalPresentationService();

    return Container(
      decoration: BoxDecoration(
        color: config.backgroundColor ?? theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: config.padding,
        child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // track info
                    if (config.showTrackInfo)
                      Expanded(
                        child: TrackInfoWidget(
                          state: state,
                          onTap:
                              () => modalPresentationService
                                  .showFullPlayerModal(context),
                        ),
                      ),
                    // audio controls
                    const AudioControls(size: 20.0, showStop: false),
                    const SizedBox(width: 8),
                    if (config.showQueueControls)
                      const QueueControls(
                        size: 18.0,
                        showRepeatMode: false,
                        showShuffleMode: false,
                      ),
                  ],
                ),
                // progress bar
                if (config.showProgress) ...[
                  const SizedBox(height: 8),
                  const PlaybackProgress(
                    height: 2.0,
                    thumbRadius: 6.0,
                    showTimeLabels: false,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
