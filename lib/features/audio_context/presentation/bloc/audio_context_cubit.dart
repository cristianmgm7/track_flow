import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/track_context.dart';
import '../../domain/services/audio_context_service.dart';
import 'audio_context_state.dart';

/// Cubit for managing audio track business context
/// Separated from pure audio player to maintain SOLID principles
/// Handles: collaborators, project info, track metadata, business rules
class AudioContextCubit extends Cubit<AudioContextState> {
  AudioContextCubit({
    required AudioContextService audioContextService,
  }) : _audioContextService = audioContextService,
       super(const AudioContextInitial());

  final AudioContextService _audioContextService;
  StreamSubscription<TrackContext>? _contextSubscription;
  String? _currentTrackId;

  /// Load context for a specific track
  /// Called when track changes in audio player
  Future<void> loadTrackContext(String trackId) async {
    if (_currentTrackId == trackId && state is AudioContextLoaded) {
      return; // Already loaded for this track
    }

    _currentTrackId = trackId;
    emit(AudioContextLoading(trackId: trackId));

    try {
      final context = await _audioContextService.getTrackContext(trackId);
      
      if (context != null) {
        emit(AudioContextLoaded(context));
      } else {
        emit(AudioContextNotFound(trackId));
      }
    } catch (e) {
      emit(AudioContextError(
        'Failed to load track context: ${e.toString()}',
        trackId: trackId,
      ));
    }
  }

  /// Update track context information
  Future<void> updateTrackContext(TrackContext context) async {
    try {
      await _audioContextService.updateTrackContext(context);
      
      // Update state if this is the current track
      if (_currentTrackId == context.trackId) {
        emit(AudioContextLoaded(context));
      }
    } catch (e) {
      emit(AudioContextError(
        'Failed to update track context: ${e.toString()}',
        trackId: context.trackId,
      ));
    }
  }

  /// Start watching context changes for current track
  /// Useful for real-time collaboration updates
  void startWatchingCurrentTrack() {
    if (_currentTrackId != null) {
      _stopWatching(); // Clean up previous subscription
      
      _contextSubscription = _audioContextService
          .watchTrackContext(_currentTrackId!)
          .listen(
            (context) {
              if (_currentTrackId == context.trackId) {
                emit(AudioContextLoaded(context));
              }
            },
            onError: (error) {
              emit(AudioContextError(
                'Context watch error: ${error.toString()}',
                trackId: _currentTrackId,
              ));
            },
          );
    }
  }

  /// Stop watching context changes
  void stopWatching() {
    _stopWatching();
  }

  void _stopWatching() {
    _contextSubscription?.cancel();
    _contextSubscription = null;
  }

  /// Clear current context
  void clearContext() {
    _stopWatching();
    _currentTrackId = null;
    emit(const AudioContextInitial());
  }

  /// Get collaborators for a project
  Future<List<UserProfile>> getProjectCollaborators(String projectId) async {
    try {
      return await _audioContextService.getProjectCollaborators(projectId);
    } catch (e) {
      // Don't emit error state for this helper method
      return [];
    }
  }

  /// Check if user has permission to access track
  Future<bool> canAccessTrack(String trackId, String userId) async {
    try {
      return await _audioContextService.canAccessTrack(trackId, userId);
    } catch (e) {
      return false;
    }
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