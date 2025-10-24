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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.space12, vertical: Dimensions.space0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Playback controls on the left
            VoiceMemoPlaybackControls(
              memo: memo,
              onPlayPressed: () => context.read<VoiceMemoBloc>().add(PlayVoiceMemoRequested(memo)),
              onPausePressed: () => context.read<AudioPlayerBloc>().add(const PauseAudioRequested()),
            ),

            SizedBox(width: Dimensions.space12),

            // Right side: header and waveform
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(Dimensions.radiusMedium),
                    bottomRight: Radius.circular(Dimensions.radiusMedium),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.space12,
                  vertical: Dimensions.space8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    VoiceMemoCardHeader(
                      memo: memo,
                      onRenamePressed: () => _showRenameDialog(context),
                      onDeletePressed: () => context.read<VoiceMemoBloc>().add(
                        DeleteVoiceMemoRequested(memo.id),
                      ),
                    ),

                    SizedBox(height: Dimensions.space8),

                    VoiceMemoWaveformDisplay(
                      memo: memo,
                      height: 50,
                      fileExists: _fileExists,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  
}
