import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart';
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_bundle_usecase.dart';
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart';
import 'audio_comment_event.dart';
import 'audio_comment_state.dart';

import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';

@injectable
class AudioCommentBloc extends Bloc<AudioCommentEvent, AudioCommentState> {
  final AddAudioCommentUseCase addAudioCommentUseCase;
  final WatchAudioCommentsBundleUseCase watchAudioCommentsBundleUseCase;
  final DeleteAudioCommentUseCase deleteAudioCommentUseCase;

  AudioCommentBloc({
    required this.addAudioCommentUseCase,
    required this.deleteAudioCommentUseCase,
    required this.watchAudioCommentsBundleUseCase,
  }) : super(const AudioCommentInitial()) {
    on<WatchAudioCommentsBundleEvent>(_onWatchBundle);
    on<AddAudioCommentEvent>(_onAddAudioComment);
    on<DeleteAudioCommentEvent>(_onDeleteAudioComment);
    on<AudioCommentsBundleUpdated>(_onBundleUpdated);
  }

  Future<void> _onAddAudioComment(
    AddAudioCommentEvent event,
    Emitter<AudioCommentState> emit,
  ) async {
    emit(const AudioCommentLoading());
    final result = await addAudioCommentUseCase.call(
      AddAudioCommentParams(
        projectId: event.projectId,
        trackId: event.trackId,
        content: event.content,
        timestamp: event.timestamp,
      ),
    );
    result.fold(
      (failure) => emit(AudioCommentError(failure.message)),
      (_) => emit(
        const AudioCommentOperationSuccess('Comment added successfully'),
      ),
    );
  }

  Future<void> _onDeleteAudioComment(
    DeleteAudioCommentEvent event,
    Emitter<AudioCommentState> emit,
  ) async {
    emit(const AudioCommentLoading());
    final result = await deleteAudioCommentUseCase(
      DeleteAudioCommentParams(
        projectId: event.projectId,
        trackId: event.trackId,
        commentId: event.commentId,
      ),
    );
    result.fold(
      (failure) => emit(AudioCommentError(failure.message)),
      (_) => emit(
        const AudioCommentOperationSuccess('Comment deleted successfully'),
      ),
    );
  }

  Future<void> _onWatchBundle(
    WatchAudioCommentsBundleEvent event,
    Emitter<AudioCommentState> emit,
  ) async {
    emit(const AudioCommentLoading());
    await emit.onEach<Either<Failure, AudioCommentsBundle>>(
      watchAudioCommentsBundleUseCase(
        projectId: event.projectId,
        trackId: event.trackId,
      ),
      onData: (either) => add(AudioCommentsBundleUpdated(either)),
      onError: (error, stackTrace) {
        emit(AudioCommentError(error.toString()));
      },
    );
  }

  void _onBundleUpdated(
    AudioCommentsBundleUpdated event,
    Emitter<AudioCommentState> emit,
  ) {
    event.result.fold(
      (failure) => emit(AudioCommentError(failure.message)),
      (bundle) => emit(
        AudioCommentsLoaded(
          comments: bundle.comments,
          collaborators: bundle.collaborators,
          isSyncing: false,
          syncProgress: null,
        ),
      ),
    );
  }
}
