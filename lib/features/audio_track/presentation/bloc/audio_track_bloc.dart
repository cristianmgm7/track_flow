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
import 'package:trackflow/core/session_manager/sync_aware_mixin.dart';
import 'package:trackflow/core/session_manager/services/sync_state_manager.dart';

@injectable
class AudioTrackBloc extends Bloc<AudioTrackEvent, AudioTrackState> 
    with SyncAwareMixin {
  final WatchTracksByProjectIdUseCase watchAudioTracksByProject;
  final DeleteAudioTrack deleteAudioTrack;
  final UploadAudioTrackUseCase uploadAudioTrackUseCase;
  final EditAudioTrackUseCase editAudioTrackUseCase;
  final SyncStateManager _syncStateManager;

  StreamSubscription<Either<Failure, List<AudioTrack>>>? _trackSubscription;

  AudioTrackBloc({
    required this.watchAudioTracksByProject,
    required this.deleteAudioTrack,
    required this.uploadAudioTrackUseCase,
    required this.editAudioTrackUseCase,
    required SyncStateManager syncStateManager,
  }) : _syncStateManager = syncStateManager,
       super(AudioTrackInitial()) {
    initializeSyncAwareness(_syncStateManager);
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

    // Set up sync state listening for this session
    listenToSyncState(
      onSyncStarted: () {
        if (state is AudioTrackLoaded) {
          emit((state as AudioTrackLoaded).copyWith(isSyncing: true));
        }
      },
      onSyncProgress: (progress) {
        if (state is AudioTrackLoaded) {
          emit((state as AudioTrackLoaded).copyWith(
            isSyncing: true, 
            syncProgress: progress,
          ));
        }
      },
      onSyncCompleted: () {
        if (state is AudioTrackLoaded) {
          emit((state as AudioTrackLoaded).copyWith(
            isSyncing: false,
            syncProgress: 1.0,
          ));
        }
      },
      onSyncError: (error) {
        if (state is AudioTrackLoaded) {
          emit((state as AudioTrackLoaded).copyWith(isSyncing: false));
        }
      },
    );

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
        // Preserve sync state when updating tracks
        final currentSyncState = state is AudioTrackLoaded ? 
          (state as AudioTrackLoaded) : null;
        
        emit(AudioTrackLoaded(
          tracks: tracks,
          isSyncing: currentSyncState?.isSyncing ?? isSyncing,
          syncProgress: currentSyncState?.syncProgress,
        ));
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
