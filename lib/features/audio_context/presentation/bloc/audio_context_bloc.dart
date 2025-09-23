import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_context/domain/usecases/load_track_context_usecase.dart';
import '../../domain/entities/track_context.dart';
import 'audio_context_event.dart';
import 'audio_context_state.dart';

/// BLoC for managing audio track business context using event-driven architecture
/// Separated from pure audio player to maintain SOLID principles
/// Handles: collaborators, project info, track metadata, business rules
@injectable
class AudioContextBloc extends Bloc<AudioContextEvent, AudioContextState> {
  final LoadTrackContextUseCase _loadTrackContextUseCase;

  AudioContextBloc({required LoadTrackContextUseCase loadTrackContextUseCase})
    : _loadTrackContextUseCase = loadTrackContextUseCase,
      super(const AudioContextInitial()) {
    // Register event handlers
    on<LoadTrackContextRequested>(_onLoadTrackContextRequested);
  }

  AudioTrackId? _currentTrackId;

  /// Load context for a specific track
  Future<void> _onLoadTrackContextRequested(
    LoadTrackContextRequested event,
    Emitter<AudioContextState> emit,
  ) async {
    if (_currentTrackId == event.trackId && state is AudioContextLoaded) {
      return; // Already loaded for this track
    }

    _currentTrackId = event.trackId;
    emit(AudioContextLoading(trackId: event.trackId.value));

    try {
      final result = await _loadTrackContextUseCase.call(event.trackId);

      result.fold(
        (failure) {
          emit(
            AudioContextError(
              'Failed to load track context: ${failure.message}',
              trackId: event.trackId.value,
            ),
          );
        },
        (context) {
          emit(AudioContextLoaded(context));
        },
      );
    } catch (e) {
      emit(
        AudioContextError(
          'Unexpected error: ${e.toString()}',
          trackId: event.trackId.value,
        ),
      );
    }
  }

  /// Get current track ID
  AudioTrackId? get currentTrackId => _currentTrackId;

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
  TrackContextCollaborator? get collaborator => currentContext?.collaborator;
  String? get projectId => currentContext?.projectId;
  String? get projectName => currentContext?.projectName;
  DateTime? get uploadedAt => currentContext?.uploadedAt;
  List<String>? get tags => currentContext?.tags;
  String? get description => currentContext?.description;
}
