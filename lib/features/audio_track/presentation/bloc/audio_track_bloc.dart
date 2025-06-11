import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart';
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart';
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_event.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_state.dart';

@injectable
class AudioTrackBloc extends Bloc<AudioTrackEvent, AudioTrackState> {
  final WatchAudioTracksByProject watchAudioTracksByProject;
  final DeleteAudioTrack deleteAudioTrack;
  final UploadAudioTrackUseCase uploadAudioTrackUseCase;

  AudioTrackBloc({
    required this.watchAudioTracksByProject,
    required this.deleteAudioTrack,
    required this.uploadAudioTrackUseCase,
  }) : super(AudioTrackInitial()) {
    on<WatchAudioTracksByProjectEvent>(_onWatchAudioTracksByProject);
    on<DeleteAudioTrackEvent>(_onDeleteAudioTrack);
    on<UploadAudioTrackEvent>(_onUploadAudioTrack);
  }

  Future<void> _onWatchAudioTracksByProject(
    WatchAudioTracksByProjectEvent event,
    Emitter<AudioTrackState> emit,
  ) async {
    emit(AudioTrackLoading());
    try {
      final stream = watchAudioTracksByProject(event.projectId);
      await emit.forEach(
        stream,
        onData:
            (data) => data.fold(
              (failure) => AudioTrackError(message: 'Failed to load tracks'),
              (tracks) => AudioTrackLoaded(tracks: tracks),
            ),
      );
    } catch (e) {
      emit(AudioTrackError(message: 'An error occurred'));
    }
  }

  Future<void> _onUploadAudioTrack(
    UploadAudioTrackEvent event,
    Emitter<AudioTrackState> emit,
  ) async {
    emit(AudioTrackLoading());
    final result = await uploadAudioTrackUseCase(
      UploadAudioTrackParams(
        file: event.file,
        name: event.name,
        duration: event.duration,
        projectId: event.projectId,
      ),
    );
    result.fold(
      (failure) => emit(AudioTrackError(message: failure.message)),
      (_) => emit(AudioTrackUploadSuccess()),
    );
  }

  Future<void> _onDeleteAudioTrack(
    DeleteAudioTrackEvent event,
    Emitter<AudioTrackState> emit,
  ) async {
    emit(AudioTrackLoading());
    final result = await deleteAudioTrack(
      DeleteAudioTrackParams(
        trackId: event.trackId,
        projectId: event.projectId,
      ),
    );
    result.fold(
      (failure) => emit(AudioTrackError(message: 'Failed to delete track')),
      (_) => emit(AudioTrackDeleteSuccess()),
    );
  }
}
