import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart';
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_usecase.dart';
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comement_usecase.dart';
import 'audio_comment_event.dart';
import 'audio_comment_state.dart';
import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';

@injectable
class AudioCommentBloc extends Bloc<AudioCommentEvent, AudioCommentState> {
  final AddAudioCommentUseCase addAudioCommentUseCase;
  final WatchCommentsByTrackUseCase watchCommentsByTrackUseCase;
  final DeleteAudioCommentUseCase deleteAudioCommentUseCase;

  StreamSubscription<Either<Failure, List<AudioComment>>>?
  _commentsSubscription;

  AudioCommentBloc({
    required this.watchCommentsByTrackUseCase,
    required this.addAudioCommentUseCase,
    required this.deleteAudioCommentUseCase,
  }) : super(WatchingAudioCommentsState(comments: [])) {
    on<WatchCommentsByTrackEvent>(_onWatchCommentsByTrack);
    on<AddAudioCommentEvent>(_onAddAudioComment);
    on<DeleteAudioCommentEvent>(_onDeleteAudioComment);
  }

  void _onWatchCommentsByTrack(
    WatchCommentsByTrackEvent event,
    Emitter<AudioCommentState> emit,
  ) async {
    await _commentsSubscription?.cancel();
    emit(WatchingAudioCommentsState(comments: [], isLoading: true));

    _commentsSubscription = watchCommentsByTrackUseCase
        .call(WatchCommentsByTrackParams(trackId: event.trackId))
        .listen((either) {
          either.fold(
            (failure) => emit(
              WatchingAudioCommentsState(
                comments: [],
                isLoading: false,
                failure: failure,
              ),
            ),
            (comments) => emit(
              WatchingAudioCommentsState(comments: comments, isLoading: false),
            ),
          );
        });
  }

  void _onAddAudioComment(
    AddAudioCommentEvent event,
    Emitter<AudioCommentState> emit,
  ) async {
    emit(AddingAudioCommentState(isAdding: true));
    final result = await addAudioCommentUseCase.call(
      AddAudioCommentParams(
        projectId: event.projectId,
        trackId: event.trackId,
        content: event.content,
      ),
    );
    result.fold(
      (failure) =>
          emit(AddingAudioCommentState(isAdding: false, failure: failure)),
      (_) => emit(AddingAudioCommentState(isAdding: false)),
    );
  }

  void _onDeleteAudioComment(
    DeleteAudioCommentEvent event,
    Emitter<AudioCommentState> emit,
  ) async {
    emit(RemovingAudioCommentState(isRemoving: true));
    final result = await deleteAudioCommentUseCase(
      DeleteAudioCommentParams(
        projectId: event.projectId,
        trackId: event.trackId,
        commentId: event.commentId,
      ),
    );
    result.fold(
      (failure) =>
          emit(RemovingAudioCommentState(isRemoving: false, failure: failure)),
      (_) => emit(RemovingAudioCommentState(isRemoving: false)),
    );
  }

  @override
  Future<void> close() {
    _commentsSubscription?.cancel();
    return super.close();
  }
}
