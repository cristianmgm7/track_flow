import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/voice_memo.dart';
import '../../domain/usecases/create_voice_memo_usecase.dart';
import '../../domain/usecases/delete_voice_memo_usecase.dart';
import '../../domain/usecases/play_voice_memo_usecase.dart';
import '../../domain/usecases/update_voice_memo_usecase.dart';
import '../../domain/usecases/watch_voice_memos_usecase.dart';
import 'voice_memo_event.dart';
import 'voice_memo_state.dart';

@injectable
class VoiceMemoBloc extends Bloc<VoiceMemoEvent, VoiceMemoState> {
  final WatchVoiceMemosUseCase _watchVoiceMemosUseCase;
  final CreateVoiceMemoUseCase _createVoiceMemoUseCase;
  final UpdateVoiceMemoUseCase _updateVoiceMemoUseCase;
  final DeleteVoiceMemoUseCase _deleteVoiceMemoUseCase;
  final PlayVoiceMemoUseCase _playVoiceMemoUseCase;

  VoiceMemoBloc(
    this._watchVoiceMemosUseCase,
    this._createVoiceMemoUseCase,
    this._updateVoiceMemoUseCase,
    this._deleteVoiceMemoUseCase,
    this._playVoiceMemoUseCase,
  ) : super(const VoiceMemoInitial()) {
    on<WatchVoiceMemosRequested>(_onWatchMemos);
    on<CreateVoiceMemoRequested>(_onCreateMemo);
    on<PlayVoiceMemoRequested>(_onPlayMemo);
    on<UpdateVoiceMemoRequested>(_onUpdateMemo);
    on<DeleteVoiceMemoRequested>(_onDeleteMemo);
  }

  Future<void> _onWatchMemos(
    WatchVoiceMemosRequested event,
    Emitter<VoiceMemoState> emit,
  ) async {
    emit(const VoiceMemoLoading());

    await emit.onEach<Either<Failure, List<VoiceMemo>>>(
      _watchVoiceMemosUseCase(),
      onData: (either) {
        either.fold(
          (failure) => emit(VoiceMemoError(failure.message)),
          (memos) => emit(VoiceMemosLoaded(memos)),
        );
      },
      onError: (error, stackTrace) {
        emit(VoiceMemoError(error.toString()));
      },
    );
  }

  Future<void> _onCreateMemo(
    CreateVoiceMemoRequested event,
    Emitter<VoiceMemoState> emit,
  ) async {
    final result = await _createVoiceMemoUseCase(event.recording);

    result.fold(
      (failure) => emit(VoiceMemoError(failure.message)),
      (memo) => emit(const VoiceMemoActionSuccess('Voice memo saved')),
    );
  }

  Future<void> _onPlayMemo(
    PlayVoiceMemoRequested event,
    Emitter<VoiceMemoState> emit,
  ) async {
    final result = await _playVoiceMemoUseCase(event.memo);

    result.fold(
      (failure) => emit(VoiceMemoError(failure.message)),
      (_) => null, // Playback state handled by AudioPlayerBloc
    );
  }

  Future<void> _onUpdateMemo(
    UpdateVoiceMemoRequested event,
    Emitter<VoiceMemoState> emit,
  ) async {
    final updatedMemo = event.memo.copyWith(title: event.newTitle);
    final result = await _updateVoiceMemoUseCase(updatedMemo);

    result.fold(
      (failure) => emit(VoiceMemoError(failure.message)),
      (_) => emit(const VoiceMemoActionSuccess('Memo renamed')),
    );
  }

  Future<void> _onDeleteMemo(
    DeleteVoiceMemoRequested event,
    Emitter<VoiceMemoState> emit,
  ) async {
    final result = await _deleteVoiceMemoUseCase(event.memoId);

    result.fold(
      (failure) => emit(VoiceMemoError(failure.message)),
      (_) => emit(const VoiceMemoActionSuccess('Memo deleted')),
    );
  }
}
