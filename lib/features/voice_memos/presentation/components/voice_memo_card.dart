import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../audio_player/presentation/bloc/audio_player_bloc.dart';
import '../../../audio_player/presentation/bloc/audio_player_event.dart';
import '../../../audio_player/presentation/bloc/audio_player_state.dart';
import '../../../ui/menus/app_popup_menu.dart';
import '../../domain/entities/voice_memo.dart';
import '../bloc/voice_memo_bloc.dart';
import '../bloc/voice_memo_event.dart';
import '../widgets/voice_memo_delete_background.dart';
import '../widgets/voice_memo_delete_confirmation_dialog.dart';
import '../widgets/voice_memo_rename_dialog.dart';
import '../widgets/voice_memo_waveform_display.dart';

class VoiceMemoCard extends StatelessWidget {
  final VoiceMemo memo;

  const VoiceMemoCard({super.key, required this.memo});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(memo.id.value),
      direction: DismissDirection.endToStart,
      background: const VoiceMemoDeleteBackground(),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (direction) {
        context.read<VoiceMemoBloc>().add(
          DeleteVoiceMemoRequested(memo.id),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: Dimensions.space16,
          vertical: Dimensions.space8,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.8),
              AppColors.primary.withValues(alpha: 0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        ),
        child: Padding(
          padding: EdgeInsets.all(Dimensions.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title and Menu
              _buildHeader(context),

              SizedBox(height: Dimensions.space16),

              // Waveform Display
              VoiceMemoWaveformDisplay(
                memo: memo,
                height: 100,
                onSeek: (position) => _handleSeek(context, position),
              ),

              SizedBox(height: Dimensions.space12),

              // Playback Controls Row
              _buildPlaybackControls(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title
        Expanded(
          child: Text(
            memo.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Menu Button
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () => _showMenu(context),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, audioState) {
        final isCurrentMemo = audioState is AudioPlayerSessionState &&
            audioState.session.currentTrack?.id.value == memo.id.value;

        final isPlaying = isCurrentMemo &&
            audioState is AudioPlayerPlaying;

        final position = isCurrentMemo
            ? audioState.session.position
            : Duration.zero;

        return Row(
          children: [
            // Play/Pause Button
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () => _togglePlayback(context, isPlaying),
              ),
            ),

            SizedBox(width: Dimensions.space12),

            // Progress Bar
            Expanded(
              child: _buildProgressBar(position),
            ),

            SizedBox(width: Dimensions.space12),

            // Duration
            Text(
              _formatDuration(memo.duration),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressBar(Duration position) {
    final progress = memo.duration.inMilliseconds > 0
        ? position.inMilliseconds / memo.duration.inMilliseconds
        : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Background bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Progress bar
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Playhead circle
            if (progress > 0)
              Positioned(
                left: (progress * maxWidth).clamp(0.0, maxWidth - 12),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _togglePlayback(BuildContext context, bool isPlaying) {
    if (isPlaying) {
      context.read<AudioPlayerBloc>().add(const PauseAudioRequested());
    } else {
      context.read<VoiceMemoBloc>().add(PlayVoiceMemoRequested(memo));
    }
  }

  void _handleSeek(BuildContext context, Duration position) {
    context.read<AudioPlayerBloc>().add(SeekToPositionRequested(position));
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showRenameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => VoiceMemoRenameDialog(
        memo: memo,
        onRename: (newTitle) {
          context.read<VoiceMemoBloc>().add(
            UpdateVoiceMemoRequested(memo, newTitle),
          );
        },
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showAppMenu<String>(
      context: context,
      items: [
        AppMenuItem<String>(
          value: 'rename',
          label: 'Rename',
          icon: Icons.edit,
        ),
        AppMenuItem<String>(
          value: 'delete',
          label: 'Delete',
          icon: Icons.delete,
          iconColor: AppColors.error,
          textColor: AppColors.error,
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'rename':
            _showRenameDialog(context);
            break;
          case 'delete':
            context.read<VoiceMemoBloc>().add(
              DeleteVoiceMemoRequested(memo.id),
            );
            break;
        }
      },
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => const VoiceMemoDeleteConfirmationDialog(),
    ) ?? false;
  }
}
