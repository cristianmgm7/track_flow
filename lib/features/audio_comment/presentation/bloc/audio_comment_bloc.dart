import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart';
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_usecase.dart';
import 'package:trackflow/features/audio_comment/domain/usecases/delete_audio_comement_usecase.dart';
import 'audio_comment_event.dart';
import 'audio_comment_state.dart';

@injectable
class AudioCommentBloc extends Bloc<AudioCommentEvent, AudioCommentState> {
  final AddAudioCommentUseCase addAudioCommentUseCase;
  final WatchCommentsByTrackUseCase watchCommentsByTrackUseCase;
  final DeleteAudioCommentUseCase deleteAudioCommentUseCase;

  AudioCommentBloc({
    required this.addAudioCommentUseCase,
    required this.watchCommentsByTrackUseCase,
    required this.deleteAudioCommentUseCase,
  }) : super(WatchingAudioCommentsState(comments: [])) {
    on<AddAudioCommentEvent>(_onAddAudioComment);
    on<DeleteAudioCommentEvent>(_onDeleteAudioComment);
    on<WatchCommentsByTrackEvent>(_onWatchCommentsByTrack);
  }

  void _onAddAudioComment(
    AddAudioCommentEvent event,
    Emitter<AudioCommentState> emit,
  ) async {
    emit(AddingAudioCommentState(isAdding: true));
    final result = await addAudioCommentUseCase.call(
      AddAudioCommentParams(comment: event.comment),
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
      DeleteAudioCommentParams(commentId: event.commentId),
    );
    result.fold(
      (failure) =>
          emit(RemovingAudioCommentState(isRemoving: false, failure: failure)),
      (_) => emit(RemovingAudioCommentState(isRemoving: false)),
    );
  }

  void _onWatchCommentsByTrack(
    WatchCommentsByTrackEvent event,
    Emitter<AudioCommentState> emit,
  ) async {
    emit(WatchingAudioCommentsState(comments: [], isLoading: true));
    final result = watchCommentsByTrackUseCase.call(
      WatchCommentsByTrackParams(trackId: event.trackId),
    );
  }
}
