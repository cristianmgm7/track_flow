import 'package:flutter/foundation.dart';
import '../../domain/entities/track_context.dart';
import '../../domain/services/audio_context_service.dart';

/// Provider for audio track business context
/// Separated from pure audio player to maintain SOLID principles
/// Provides collaboration and business domain information externally
class AudioContextProvider extends ChangeNotifier {
  AudioContextProvider({
    required AudioContextService audioContextService,
  }) : _audioContextService = audioContextService;

  final AudioContextService _audioContextService;

  // Current context state
  TrackContext? _currentContext;
  String? _currentTrackId;
  bool _isLoading = false;
  String? _error;

  // Getters for current state
  TrackContext? get currentContext => _currentContext;
  String? get currentTrackId => _currentTrackId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasContext => _currentContext != null;

  // Convenience getters from current context
  UserProfile? get collaborator => _currentContext?.collaborator;
  String? get projectId => _currentContext?.projectId;
  String? get projectName => _currentContext?.projectName;
  DateTime? get uploadedAt => _currentContext?.uploadedAt;
  List<String>? get tags => _currentContext?.tags;
  String? get description => _currentContext?.description;

  /// Load context for a specific track
  /// This is called externally when track changes in audio player
  Future<void> loadContext(String trackId) async {
    if (_currentTrackId == trackId && _currentContext != null) {
      return; // Already loaded
    }

    _isLoading = true;
    _error = null;
    _currentTrackId = trackId;
    notifyListeners();

    try {
      final context = await _audioContextService.getTrackContext(trackId);
      _currentContext = context;
      _error = null;
    } catch (e) {
      _error = 'Failed to load track context: ${e.toString()}';
      _currentContext = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear current context
  void clearContext() {
    _currentContext = null;
    _currentTrackId = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Update context information
  Future<void> updateContext(TrackContext context) async {
    try {
      await _audioContextService.updateTrackContext(context);
      if (_currentTrackId == context.trackId) {
        _currentContext = context;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update context: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Watch context changes for current track
  void startWatching() {
    if (_currentTrackId != null) {
      _audioContextService.watchTrackContext(_currentTrackId!).listen(
        (context) {
          _currentContext = context;
          _error = null;
          notifyListeners();
        },
        onError: (e) {
          _error = 'Context watch error: ${e.toString()}';
          notifyListeners();
        },
      );
    }
  }

  @override
  void dispose() {
    clearContext();
    super.dispose();
  }
}