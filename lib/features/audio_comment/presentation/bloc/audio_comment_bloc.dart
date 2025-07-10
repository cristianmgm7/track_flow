import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart';
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_usecase.dart';
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart';
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
  }) : super(AudioCommentInitial()) {
    on<WatchCommentsByTrackEvent>(_onWatchCommentsByTrack);
    on<AddAudioCommentEvent>(_onAddAudioComment);
    on<DeleteAudioCommentEvent>(_onDeleteAudioComment);
    on<AudioCommentsUpdated>(_onAudioCommentsUpdated);
  }

  Future<void> _onAddAudioComment(
    AddAudioCommentEvent event,
    Emitter<AudioCommentState> emit,
  ) async {
    emit(AudioCommentLoading());
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
      (_) => emit(AudioCommentOperationSuccess('Comment added successfully')),
    );
  }

  Future<void> _onDeleteAudioComment(
    DeleteAudioCommentEvent event,
    Emitter<AudioCommentState> emit,
  ) async {
    emit(AudioCommentLoading());
    final result = await deleteAudioCommentUseCase(
      DeleteAudioCommentParams(
        projectId: event.projectId,
        trackId: event.trackId,
        commentId: event.commentId,
      ),
    );
    result.fold(
      (failure) => emit(AudioCommentError(failure.message)),
      (_) => emit(AudioCommentOperationSuccess('Comment deleted successfully')),
    );
  }

  void _onWatchCommentsByTrack(
    WatchCommentsByTrackEvent event,
    Emitter<AudioCommentState> emit,
  ) async {
    await _commentsSubscription?.cancel();
    emit(AudioCommentLoading());

    _commentsSubscription = watchCommentsByTrackUseCase
        .call(WatchCommentsByTrackParams(trackId: event.trackId))
        .listen((either) {
          add(AudioCommentsUpdated(either));
        });
  }

  void _onAudioCommentsUpdated(
    AudioCommentsUpdated event,
    Emitter<AudioCommentState> emit,
  ) {
    event.comments.fold(
      (failure) => emit(AudioCommentError(failure.message)),
      (comments) => emit(AudioCommentsLoaded(comments)),
    );
  }

  @override
  Future<void> close() {
    _commentsSubscription?.cancel();
    return super.close();
  }
}
