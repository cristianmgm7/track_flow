import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart';
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart';
import 'package:trackflow/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart';
import 'package:trackflow/features/audio_track/domain/usecases/edit_audio_track_usecase.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_event.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_state.dart';

@injectable
class AudioTrackBloc extends Bloc<AudioTrackEvent, AudioTrackState> {
  final WatchTracksByProjectIdUseCase watchAudioTracksByProject;
  final DeleteAudioTrack deleteAudioTrack;
  final UploadAudioTrackUseCase uploadAudioTrackUseCase;
  final EditAudioTrackUseCase editAudioTrackUseCase;

  StreamSubscription<Either<Failure, List<AudioTrack>>>? _trackSubscription;

  AudioTrackBloc({
    required this.watchAudioTracksByProject,
    required this.deleteAudioTrack,
    required this.uploadAudioTrackUseCase,
    required this.editAudioTrackUseCase,
  }) : super(AudioTrackInitial()) {
    on<WatchAudioTracksByProjectEvent>(_onWatchAudioTracksByProject);
    on<DeleteAudioTrackEvent>(_onDeleteAudioTrack);
    on<UploadAudioTrackEvent>(_onUploadAudioTrack);
    on<AudioTracksUpdated>(_onAudioTracksUpdated);
    on<EditAudioTrackEvent>(_onEditAudioTrack);
  }

  Future<void> _onUploadAudioTrack(
    UploadAudioTrackEvent event,
    Emitter<AudioTrackState> emit,
  ) async {
    emit(AudioTrackUploadLoading());
    final result = await uploadAudioTrackUseCase.call(
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
    emit(AudioTrackDeleteLoading());
    final result = await deleteAudioTrack.call(
      DeleteAudioTrackParams(
        trackId: event.trackId,
        projectId: event.projectId,
      ),
    );
    result.fold(
      (failure) => emit(AudioTrackError(message: failure.message)),
      (_) => emit(AudioTrackDeleteSuccess()),
    );
  }

  Future<void> _onWatchAudioTracksByProject(
    WatchAudioTracksByProjectEvent event,
    Emitter<AudioTrackState> emit,
  ) async {
    await _trackSubscription?.cancel();
    emit(AudioTrackLoading());

    _trackSubscription = watchAudioTracksByProject
        .call(WatchTracksByProjectIdParams(projectId: event.projectId))
        .listen((either) {
          add(AudioTracksUpdated(either));
        });
  }

  void _onAudioTracksUpdated(
    AudioTracksUpdated event,
    Emitter<AudioTrackState> emit,
  ) {
    event.tracks.fold(
      (failure) => emit(AudioTrackError(message: 'Failed to load tracks')),
      (tracks) {
        emit(
          AudioTrackLoaded(
            tracks: tracks,
            isSyncing: false,
            syncProgress: null,
          ),
        );
      },
    );
  }

  Future<void> _onEditAudioTrack(
    EditAudioTrackEvent event,
    Emitter<AudioTrackState> emit,
  ) async {
    emit(AudioTrackEditLoading());
    final result = await editAudioTrackUseCase.call(
      EditAudioTrackParams(
        trackId: event.trackId,
        projectId: event.projectId,
        newName: event.newName,
      ),
    );
    result.fold(
      (failure) => emit(AudioTrackEditError(message: failure.message)),
      (_) => emit(AudioTrackEditSuccess()),
    );
  }

  @override
  Future<void> close() {
    _trackSubscription?.cancel();
    return super.close();
  }
}
