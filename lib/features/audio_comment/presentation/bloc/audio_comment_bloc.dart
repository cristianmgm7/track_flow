import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart';
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_bundle_usecase.dart';
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart';
import 'audio_comment_event.dart';
import 'audio_comment_state.dart';

import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'dart:async';

@injectable
class AudioCommentBloc extends Bloc<AudioCommentEvent, AudioCommentState> {
  final AddAudioCommentUseCase addAudioCommentUseCase;
  final WatchAudioCommentsBundleUseCase watchAudioCommentsBundleUseCase;
  final DeleteAudioCommentUseCase deleteAudioCommentUseCase;
  StreamSubscription<Either<Failure, AudioCommentsBundle>>? _bundleSubscription;

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
    // Cancel any previous subscription to avoid cross-track leakage
    await _bundleSubscription?.cancel();
    _bundleSubscription = watchAudioCommentsBundleUseCase(
      projectId: event.projectId,
      trackId: event.trackId,
    ).listen(
      (either) => add(AudioCommentsBundleUpdated(either)),
      onError:
          (error, _) => add(
            AudioCommentsBundleUpdated(left(ServerFailure(error.toString()))),
          ),
      cancelOnError: false,
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

  @override
  Future<void> close() async {
    await _bundleSubscription?.cancel();
    return super.close();
  }
}
