import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/audio_player_bloc.dart';
import '../../bloc/audio_player_state.dart';
import '../audio_controls.dart';
import '../playback_progress.dart';
import '../queue_controls.dart';
import 'track_info_widget.dart';
import 'modal_presentation_service.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_colors.dart';

class MiniAudioPlayerConfig {
  final double height;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final bool showQueueControls;
  final bool showProgress;
  final bool showTrackInfo;

  const MiniAudioPlayerConfig({
    this.height = Dimensions.miniPlayerHeight,
    this.padding = const EdgeInsets.all(Dimensions.space12),
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
    final modalPresentationService = modalService ?? ModalPresentationService();

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          decoration: BoxDecoration(
            color: (config.backgroundColor ?? AppColors.surface).withValues(
              alpha: 0.15,
            ),
            border: Border(
              top: BorderSide(
                color: AppColors.textPrimary.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.grey900.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -1),
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
                        const AudioControls(
                          size: Dimensions.iconMedium,
                          showStop: false,
                        ),
                        SizedBox(width: Dimensions.space8),
                        if (config.showQueueControls)
                          const QueueControls(
                            size: Dimensions.iconSmall,
                            showRepeatMode: false,
                            showShuffleMode: false,
                          ),
                      ],
                    ),
                    // progress bar
                    if (config.showProgress) ...[
                      SizedBox(height: Dimensions.space8),
                      const PlaybackProgress(
                        height: Dimensions.space2,
                        thumbRadius: Dimensions.space6,
                        showTimeLabels: false,
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
