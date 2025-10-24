import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/ui/audio/audio_play_pause_button.dart';
import 'package:trackflow/features/voice_memos/presentation/voice_memos_screen/components/voice_memo_playback_controls.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../domain/entities/voice_memo.dart';
import '../../bloc/voice_memo_bloc.dart';
import '../../bloc/voice_memo_event.dart';
import '../../widgets/voice_memo_rename_dialog.dart';
import 'voice_memo_waveform_display.dart';
import 'voice_memo_card_header.dart';

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
      constraints: BoxConstraints(
        minHeight: Dimensions.cardMinHeight,
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
                  borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusMedium)),
                ),
                padding: EdgeInsets.only(
                  left: Dimensions.space12,
                  right: Dimensions.space8,
                  top: Dimensions.space0,
                  bottom: Dimensions.space12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    VoiceMemoCardHeader(
                      memo: memo,
                      onRenamePressed: () => _showRenameDialog(context),
                      onDeletePressed: () => context.read<VoiceMemoBloc>().add(
                        DeleteVoiceMemoRequested(memo.id),
                      ),
                    ),
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
