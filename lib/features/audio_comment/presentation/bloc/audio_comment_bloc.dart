import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
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
  // No manual subscription; managed by emit.onEach with restartable transformer

  AudioCommentBloc({
    required this.addAudioCommentUseCase,
    required this.deleteAudioCommentUseCase,
    required this.watchAudioCommentsBundleUseCase,
  }) : super(const AudioCommentInitial()) {
    on<WatchAudioCommentsBundleEvent>(
      _onWatchBundle,
      transformer: _restartable(),
    );
    on<AddAudioCommentEvent>(_onAddAudioComment);
    on<DeleteAudioCommentEvent>(_onDeleteAudioComment);
  }

  Future<void> _onAddAudioComment(
    AddAudioCommentEvent event,
    Emitter<AudioCommentState> emit,
  ) async {
    final result = await addAudioCommentUseCase.call(
      AddAudioCommentParams(
        projectId: event.projectId,
        versionId: event.versionId,
        content: event.content,
        timestamp: event.timestamp,
        localAudioPath: event.localAudioPath,
        audioDuration: event.audioDuration,
        commentType: event.commentType,
      ),
    );
    result.fold(
      (failure) => emit(AudioCommentError(failure.message)),
      (_) => null,
    );
  }

  Future<void> _onDeleteAudioComment(
    DeleteAudioCommentEvent event,
    Emitter<AudioCommentState> emit,
  ) async {
    final result = await deleteAudioCommentUseCase(
      DeleteAudioCommentParams(
        projectId: event.projectId,
        commentId: event.commentId,
      ),
    );
    result.fold(
      (failure) => emit(AudioCommentError(failure.message)),
      (_) => null,
    );
  }

  Future<void> _onWatchBundle(
    WatchAudioCommentsBundleEvent event,
    Emitter<AudioCommentState> emit,
  ) async {
    emit(const AudioCommentLoading());
    final stream = watchAudioCommentsBundleUseCase.call(
      projectId: event.projectId,
      trackId: event.trackId,
      versionId: event.versionId,
    );

    await emit.onEach<Either<Failure, AudioCommentsBundle>>(
      stream,
      onData: (either) {
        either.fold((failure) => emit(AudioCommentError(failure.message)), (
          bundle,
        ) {
          final sorted = [...bundle.comments]
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
          emit(
            AudioCommentsLoaded(
              comments: sorted,
              collaborators: bundle.collaborators,
              isSyncing: false,
              syncProgress: null,
            ),
          );
        });
      },
      onError: (error, stackTrace) {
        emit(AudioCommentError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() async {
    // No manual subscription to cancel
    return super.close();
  }

  // Restartable transformer using RxDart's switchMap semantics
  EventTransformer<WatchAudioCommentsBundleEvent>
  _restartable<WatchAudioCommentsBundleEvent>() {
    return (events, mapper) => events.switchMap(mapper);
  }
}
