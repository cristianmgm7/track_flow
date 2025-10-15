import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/audio_player_bloc.dart';
import '../bloc/audio_player_event.dart';
import '../bloc/audio_player_state.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget for volume control with slider and visual feedback
class VolumeControl extends StatelessWidget {
  const VolumeControl({
    super.key,
    required this.state,
  });

  final AudioPlayerState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    double volume = 1.0;

    if (state is AudioPlayerSessionState) {
      final sessionState = state as AudioPlayerSessionState;
      volume = sessionState.session.volume;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          volume == 0 ? Icons.volume_off : Icons.volume_up,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.primary,
            ),
            child: Slider(
              value: volume,
              onChanged: (value) {
                context.read<AudioPlayerBloc>().add(SetVolumeRequested(value));
              },
            ),
          ),
        ),
        Text(
          '${(volume * 100).round()}%',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
