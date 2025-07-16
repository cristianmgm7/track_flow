import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_event.dart';
import 'package:trackflow/features/audio_comment/presentation/components/header/audio_comment_header.dart';
import 'package:trackflow/features/audio_comment/presentation/components/header/waveform.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_comment/presentation/components/audio_comment_list_comments.dart';
import 'package:trackflow/features/audio_comment/presentation/components/audio_comment_input_comment_component.dart';

class AudioCommentsScreenArgs {
  final ProjectId projectId;
  final AudioTrack track;
  AudioCommentsScreenArgs({
    required this.projectId,
    required this.track,
  });
}

class AudioCommentsScreen extends StatefulWidget {
  final ProjectId projectId;
  final AudioTrack track;
  const AudioCommentsScreen({
    super.key,
    required this.projectId,
    required this.track,
  });
  @override
  State<AudioCommentsScreen> createState() => _AudioCommentsScreenState();
}

class _AudioCommentsScreenState extends State<AudioCommentsScreen> {
  final FocusNode _focusNode = FocusNode();
  Duration? _capturedTimestamp;
  bool _isInputFocused = false;

  @override
  void initState() {
    super.initState();
    context.read<AudioCommentBloc>().add(
      WatchCommentsByTrackEvent(widget.track.id),
    );
    _focusNode.addListener(_handleInputFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleInputFocus);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleInputFocus() {
    if (_focusNode.hasFocus) {
      final audioPlayerBloc = context.read<AudioPlayerBloc>();
      final state = audioPlayerBloc.state;
      if (state is AudioPlayerSessionState) {
        setState(() {
          _capturedTimestamp = state.session.position;
          _isInputFocused = true;
        });
        audioPlayerBloc.add(const PauseAudioRequested());
      }
    } else {
      setState(() {
        _isInputFocused = false;
        _capturedTimestamp = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Column(
              children: [
                AudioCommentHeader(
                  waveform: AudioCommentWaveformDisplay(
                    trackId: widget.track.id,
                  ),
                  trackId: widget.track.id,
                ),
                Expanded(
                  child: const AudioCommentCommentsList(),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AudioCommentInputComment(
                      focusNode: _focusNode,
                      header:
                          _isInputFocused && _capturedTimestamp != null
                              ? CommentInputHeader(
                                timestamp: _capturedTimestamp!,
                              )
                              : null,
                      onSend: (text) {
                        context.read<AudioCommentBloc>().add(
                          AddAudioCommentEvent(
                            widget.projectId,
                            widget.track.id,
                            text,
                            _capturedTimestamp ?? Duration.zero,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Header widget for the input modal, shows the timestamp
class CommentInputHeader extends StatelessWidget {
  final Duration timestamp;
  const CommentInputHeader({super.key, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    final minutes = timestamp.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = (timestamp.inSeconds % 60).toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        'Comment at $minutes:$seconds',
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
