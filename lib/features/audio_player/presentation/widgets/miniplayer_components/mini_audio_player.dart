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
import 'package:trackflow/features/ui/track/track_cover_art.dart';
import '../../../../../core/theme/app_borders.dart';

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
      borderRadius: AppBorders.large,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          decoration: BoxDecoration(
            color: (config.backgroundColor ?? AppColors.surface).withValues(
              alpha: 0.15,
            ),
            borderRadius: AppBorders.large,
            boxShadow: [
              BoxShadow(
                color: AppColors.grey900.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: config.padding,
                    child: Row(
                      children: [
                        // Cover art for AudioTrackMetadata
                        if (state is AudioPlayerSessionState &&
                            state.session.currentTrack != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              right: Dimensions.space12,
                            ),
                            child: TrackCoverArt(
                              metadata: state.session.currentTrack,
                              size: Dimensions.avatarLarge,
                            ),
                          ),
                        // track info
                        if (config.showTrackInfo)
                          Expanded(
                            child: TrackInfoWidget(
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
                  ),
                  // progress bar at the very bottom, full width
                  if (config.showProgress)
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: PlaybackProgress(
                        height: Dimensions.space2,
                        thumbRadius: Dimensions.space6,
                        showTimeLabels: false,
                        // The progress bar will stretch to the card's width
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
