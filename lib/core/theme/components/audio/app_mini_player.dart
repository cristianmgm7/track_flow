import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app_dimensions.dart';
import '../../app_colors.dart';
import '../../app_shadows.dart';
import '../../app_borders.dart';
import '../../app_animations.dart';
import 'app_audio_controls.dart';
import '../../../../features/audio_player/presentation/bloc/audio_player_bloc.dart';
import '../../../../features/audio_player/presentation/bloc/audio_player_state.dart';
import '../../../../features/audio_player/presentation/widgets/playback_progress.dart';
import '../../../../features/audio_player/presentation/widgets/queue_controls.dart';
import '../../../../features/audio_player/presentation/widgets/miniplayer_components/track_info_widget.dart';
import '../../../../features/audio_player/presentation/widgets/miniplayer_components/modal_presentation_service.dart';

/// Configuration for MiniAudioPlayer component
class AppMiniPlayerConfig {
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool showQueueControls;
  final bool showProgress;
  final bool showTrackInfo;
  final double? elevation;
  final BorderRadius? borderRadius;

  const AppMiniPlayerConfig({
    this.height,
    this.padding,
    this.backgroundColor,
    this.showQueueControls = true,
    this.showProgress = true,
    this.showTrackInfo = true,
    this.elevation,
    this.borderRadius,
  });
}

/// Mini audio player component following TrackFlow design system
/// Replaces hardcoded values with design system constants
class AppMiniPlayer extends StatelessWidget {
  const AppMiniPlayer({
    super.key,
    this.config = const AppMiniPlayerConfig(),
    this.modalService,
  });

  final AppMiniPlayerConfig config;
  final IModalPresentationService? modalService;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modalPresentationService = modalService ?? ModalPresentationService();

    return AnimatedContainer(
      duration: AppAnimations.normal,
      curve: Curves.easeInOut,
      height: config.height ?? Dimensions.miniPlayerHeight,
      decoration: BoxDecoration(
        color: config.backgroundColor ?? theme.colorScheme.surface,
        borderRadius: config.borderRadius ?? BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusLarge),
          topRight: Radius.circular(Dimensions.radiusLarge),
        ),
        boxShadow: AppShadows.elevation8,
        border: AppBorders.subtleBorder(context),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: config.padding ?? EdgeInsets.all(Dimensions.space16),
          child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar for swipe gesture indication
                  _buildHandleBar(context),
                  
                  SizedBox(height: Dimensions.space8),
                  
                  // Main content row
                  Row(
                    children: [
                      // Track info
                      if (config.showTrackInfo)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => modalPresentationService
                                .showFullPlayerModal(context),
                            child: TrackInfoWidget(
                              state: state,
                              onTap: () => modalPresentationService
                                  .showFullPlayerModal(context),
                            ),
                          ),
                        ),
                      
                      SizedBox(width: Dimensions.space12),
                      
                      // Audio controls
                      AppAudioControls(
                        size: Dimensions.iconMedium,
                        showStop: false,
                        spacing: Dimensions.space8,
                      ),
                      
                      if (config.showQueueControls) ...[
                        SizedBox(width: Dimensions.space12),
                        _buildQueueControls(),
                      ],
                    ],
                  ),
                  
                  // Progress bar
                  if (config.showProgress) ...[
                    SizedBox(height: Dimensions.space12),
                    _buildProgressBar(),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHandleBar(BuildContext context) {
    return Container(
      width: Dimensions.space48,
      height: Dimensions.space4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(Dimensions.radiusRound),
      ),
    );
  }

  Widget _buildQueueControls() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.space8,
        vertical: Dimensions.space4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
        border: AppBorders.subtleBorder(null),
      ),
      child: QueueControls(
        size: Dimensions.iconSmall,
        showRepeatMode: false,
        showShuffleMode: false,
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.space4),
      child: PlaybackProgress(
        height: Dimensions.space2,
        thumbRadius: Dimensions.space6,
        showTimeLabels: false,
      ),
    );
  }
}

/// Backward compatibility wrapper for existing MiniAudioPlayer
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
    return AppMiniPlayer(
      config: config,
      modalService: modalService,
    );
  }
}