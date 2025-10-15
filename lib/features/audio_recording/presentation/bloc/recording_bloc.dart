import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/recording_session.dart' as domain;
import '../../domain/services/recording_service.dart';
import '../../domain/usecases/cancel_recording_usecase.dart';
import '../../domain/usecases/start_recording_usecase.dart';
import '../../domain/usecases/stop_recording_usecase.dart';
import 'recording_event.dart';
import 'recording_state.dart';

@injectable
class RecordingBloc extends Bloc<RecordingEvent, RecordingState> {
  final StartRecordingUseCase _startRecordingUseCase;
  final StopRecordingUseCase _stopRecordingUseCase;
  final CancelRecordingUseCase _cancelRecordingUseCase;
  final RecordingService _recordingService;

  StreamSubscription<domain.RecordingSession>? _sessionSubscription;

  RecordingBloc(
    this._startRecordingUseCase,
    this._stopRecordingUseCase,
    this._cancelRecordingUseCase,
    this._recordingService,
  ) : super(const RecordingInitial()) {
    on<StartRecordingRequested>(_onStartRecording);
    on<StopRecordingRequested>(_onStopRecording);
    on<PauseRecordingRequested>(_onPauseRecording);
    on<ResumeRecordingRequested>(_onResumeRecording);
    on<CancelRecordingRequested>(_onCancelRecording);
    on<RecordingSessionUpdated>(_onSessionUpdated);

    // Listen to recording session updates
    _sessionSubscription = _recordingService.sessionStream.listen((session) {
      add(RecordingSessionUpdated(session));
    });
  }

  Future<void> _onStartRecording(
    StartRecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    final result = await _startRecordingUseCase(
      customOutputPath: event.customOutputPath,
    );

    result.fold(
      (failure) => emit(RecordingError(failure.message)),
      (_) {}, // State updated via session stream
    );
  }

  Future<void> _onStopRecording(
    StopRecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    final result = await _stopRecordingUseCase();

    result.fold(
      (failure) => emit(RecordingError(failure.message)),
      (recording) => emit(RecordingCompleted(recording)),
    );
  }

  Future<void> _onPauseRecording(
    PauseRecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    final result = await _recordingService.pauseRecording();

    result.fold(
      (failure) => emit(RecordingError(failure.message)),
      (_) {}, // State updated via session stream
    );
  }

  Future<void> _onResumeRecording(
    ResumeRecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    final result = await _recordingService.resumeRecording();

    result.fold(
      (failure) => emit(RecordingError(failure.message)),
      (_) {}, // State updated via session stream
    );
  }

  Future<void> _onCancelRecording(
    CancelRecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    final result = await _cancelRecordingUseCase();

    result.fold(
      (failure) => emit(RecordingError(failure.message)),
      (_) => emit(const RecordingInitial()),
    );
  }

  void _onSessionUpdated(
    RecordingSessionUpdated event,
    Emitter<RecordingState> emit,
  ) {
    final session = event.session;

    if (session.state == domain.RecordingState.recording) {
      emit(RecordingInProgress(session));
    } else if (session.state == domain.RecordingState.paused) {
      emit(RecordingPaused(session));
    } else if (session.state == domain.RecordingState.idle) {
      emit(const RecordingInitial());
    }
  }

  @override
  Future<void> close() {
    _sessionSubscription?.cancel();
    return super.close();
  }
}
