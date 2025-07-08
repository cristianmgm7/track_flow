import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart';
import 'package:trackflow/features/audio_context/domain/usecases/watch_track_context_usecase.dart';
import '../../domain/entities/track_context.dart';
import '../../domain/services/audio_context_service.dart';
import 'audio_context_event.dart';
import 'audio_context_state.dart';

/// BLoC for managing audio track business context using event-driven architecture
/// Separated from pure audio player to maintain SOLID principles
/// Handles: collaborators, project info, track metadata, business rules
@injectable
class AudioContextBloc extends Bloc<AudioContextEvent, AudioContextState> {
  final LoadTrackContextUseCase _loadTrackContextUseCase;
  final WatchTrackContextUseCase _watchTrackContextUseCase;

  AudioContextBloc({
    required LoadTrackContextUseCase loadTrackContextUseCase,
    required WatchTrackContextUseCase watchTrackContextUseCase,
  }) : _loadTrackContextUseCase = loadTrackContextUseCase,
       _watchTrackContextUseCase = watchTrackContextUseCase,
       super(const AudioContextInitial()) {
    // Register event handlers
    on<LoadTrackContextRequested>(_onLoadTrackContextRequested);
    on<ClearTrackContextRequested>(_onClearTrackContextRequested);
    on<StartWatchingTrackContextRequested>(
      _onStartWatchingTrackContextRequested,
    );
    on<StopWatchingTrackContextRequested>(_onStopWatchingTrackContextRequested);
  }

  StreamSubscription<TrackContext>? _contextSubscription;
  String? _currentTrackId;

  /// Load context for a specific track
  Future<void> _onLoadTrackContextRequested(
    LoadTrackContextRequested event,
    Emitter<AudioContextState> emit,
  ) async {
    if (_currentTrackId == event.trackId && state is AudioContextLoaded) {
      return; // Already loaded for this track
    }

    _currentTrackId = event.trackId;
    emit(AudioContextLoading(trackId: event.trackId));

    try {
      final context = await _loadTrackContextUseCase.call(event.trackId);

      if (context != null) {
        emit(AudioContextLoaded(context));
      } else {
        emit(AudioContextNotFound(event.trackId));
      }
    } catch (e) {
      emit(
        AudioContextError(
          'Failed to load track context: ${e.toString()}',
          trackId: event.trackId,
        ),
      );
    }
  }

  /// Clear current context
  void _onClearTrackContextRequested(
    ClearTrackContextRequested event,
    Emitter<AudioContextState> emit,
  ) {
    _stopWatching();
    _currentTrackId = null;
    emit(const AudioContextInitial());
  }

  /// Start watching context changes for current track
  void _onStartWatchingTrackContextRequested(
    StartWatchingTrackContextRequested event,
    Emitter<AudioContextState> emit,
  ) {
    if (_currentTrackId != null) {
      _stopWatching(); // Clean up previous subscription

      _contextSubscription = _watchTrackContextUseCase
          .call(_currentTrackId!)
          .listen(
            (context) {
              if (_currentTrackId == context.trackId) {
                emit(AudioContextLoaded(context));
              }
            },
            onError: (error) {
              emit(
                AudioContextError(
                  'Context watch error: ${error.toString()}',
                  trackId: _currentTrackId,
                ),
              );
            },
          );
    }
  }

  /// Stop watching context changes
  void _onStopWatchingTrackContextRequested(
    StopWatchingTrackContextRequested event,
    Emitter<AudioContextState> emit,
  ) {
    _stopWatching();
  }

  void _stopWatching() {
    _contextSubscription?.cancel();
    _contextSubscription = null;
  }

  /// Get current track ID
  String? get currentTrackId => _currentTrackId;

  /// Check if context is loaded
  bool get hasContext => state is AudioContextLoaded;

  /// Get current context (null if not loaded)
  TrackContext? get currentContext {
    if (state is AudioContextLoaded) {
      return (state as AudioContextLoaded).context;
    }
    return null;
  }

  /// Convenience getters for current context
  UserProfile? get collaborator => currentContext?.collaborator;
  String? get projectId => currentContext?.projectId;
  String? get projectName => currentContext?.projectName;
  DateTime? get uploadedAt => currentContext?.uploadedAt;
  List<String>? get tags => currentContext?.tags;
  String? get description => currentContext?.description;

  @override
  Future<void> close() {
    _stopWatching();
    return super.close();
  }
}
