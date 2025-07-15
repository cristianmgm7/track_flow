import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import '../../../../audio_context/presentation/bloc/audio_context_bloc.dart';
import '../../../../audio_context/presentation/bloc/audio_context_event.dart';

abstract class ITrackContextService {
  void loadTrackContext(BuildContext context, String trackId);
}

class TrackContextService implements ITrackContextService {
  @override
  void loadTrackContext(BuildContext context, String trackId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AudioContextBloc>().add(
        LoadTrackContextRequested(AudioTrackId.fromUniqueString(trackId)),
      );
    });
  }
}