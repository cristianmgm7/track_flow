import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../audio_player/presentation/bloc/audio_player_bloc.dart';
import '../../../../audio_player/presentation/bloc/audio_player_event.dart';
import '../../../domain/entities/voice_memo.dart';
import '../../bloc/voice_memo_bloc.dart';
import '../../bloc/voice_memo_event.dart';
import '../../widgets/voice_memo_rename_dialog.dart';
import 'voice_memo_waveform_display.dart';
import 'voice_memo_card_header.dart';
import 'voice_memo_playback_controls.dart';

class VoiceMemoCard extends StatelessWidget {
  final VoiceMemo memo;

  const VoiceMemoCard({super.key, required this.memo});

  bool get _fileExists {
    try {
      return File(memo.fileLocalPath).existsSync();
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha:1),
            AppColors.primary.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.space12, vertical: Dimensions.space0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Title and Menu
            VoiceMemoCardHeader(
              memo: memo,
              onRenamePressed: () => _showRenameDialog(context),
              onDeletePressed: () => context.read<VoiceMemoBloc>().add(
                DeleteVoiceMemoRequested(memo.id),
              ),
            ),

            SizedBox(height: Dimensions.space8),

            // Waveform Display
            VoiceMemoWaveformDisplay(
              memo: memo,
              height: 50,
              fileExists: _fileExists,
            ),

            // SizedBox(height: Dimensions.space12),
            SizedBox(height: Dimensions.space4),

            // Playback Controls Row
            VoiceMemoPlaybackControls(
              memo: memo,
              onPlayPressed: () => context.read<VoiceMemoBloc>().add(PlayVoiceMemoRequested(memo)),
              onPausePressed: () => context.read<AudioPlayerBloc>().add(const PauseAudioRequested()),
            ),
          ],
        ),
      ),
    );
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


  
}
