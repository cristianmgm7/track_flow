import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:trackflow/core/utils/app_logger.dart';
import '../../domain/entities/playback_session.dart';
import '../../domain/entities/audio_queue.dart';
import '../../domain/entities/playback_state.dart';
import '../../domain/entities/repeat_mode.dart';
import '../../domain/repositories/playback_persistence_repository.dart';

/// Implementation of PlaybackPersistenceRepository using SharedPreferences
/// Provides basic persistence for playback state and queue
@LazySingleton(as: PlaybackPersistenceRepository)
class PlaybackPersistenceRepositoryImpl
    implements PlaybackPersistenceRepository {
  static const String _playbackStateKey = 'playback_state';
  static const String _queueKey = 'playback_queue';
  static const String _trackPositionsKey = 'track_positions';

  @override
  Future<void> savePlaybackState(PlaybackSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionData = {
        'currentTrackId': session.currentTrack?.id.value,
        'position': session.position.inMilliseconds,
        'state': session.state.name,
        'repeatMode': session.repeatMode.name,
        'playbackSpeed': session.playbackSpeed,
        'volume': session.volume,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await prefs.setString(_playbackStateKey, jsonEncode(sessionData));
    } catch (e) {
      // Log error but don't throw - persistence failures shouldn't break playback
      AppLogger.error('Failed to save playback state: $e', tag: 'PlaybackPersistenceRepositoryImpl');
    }
  }

  @override
  Future<PlaybackSession?> loadPlaybackState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionData = prefs.getString(_playbackStateKey);

      if (sessionData == null) return null;

      final data = jsonDecode(sessionData) as Map<String, dynamic>;
      final timestamp = data['timestamp'] as int;

      // Only restore if session is less than 1 hour old
      final sessionAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (sessionAge > const Duration(hours: 1).inMilliseconds) {
        await clearPlaybackState();
        return null;
      }

      // Create minimal session with saved state
      return PlaybackSession(
        currentTrack: null, // We don't persist full track metadata
        queue: AudioQueue.empty(), // Queue is handled separately
        state: PlaybackState.values.firstWhere(
          (e) => e.name == data['state'],
          orElse: () => PlaybackState.stopped,
        ),
        position: Duration(milliseconds: data['position'] as int),
        repeatMode: RepeatMode.values.firstWhere(
          (e) => e.name == data['repeatMode'],
          orElse: () => RepeatMode.none,
        ),
        playbackSpeed: (data['playbackSpeed'] as num?)?.toDouble() ?? 1.0,
        volume: (data['volume'] as num?)?.toDouble() ?? 1.0,
      );
    } catch (e) {
      AppLogger.error('Failed to load playback state: $e', tag: 'PlaybackPersistenceRepositoryImpl');
      return null;
    }
  }

  @override
  Future<void> clearPlaybackState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_playbackStateKey);
    } catch (e) {
      AppLogger.error('Failed to clear playback state: $e', tag: 'PlaybackPersistenceRepositoryImpl');
    }
  }

  @override
  Future<bool> hasPlaybackState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_playbackStateKey);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> saveQueue(List<String> trackIds, int currentIndex) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueData = {
        'trackIds': trackIds,
        'currentIndex': currentIndex,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await prefs.setString(_queueKey, jsonEncode(queueData));
    } catch (e) {
      AppLogger.error('Failed to save queue: $e', tag: 'PlaybackPersistenceRepositoryImpl');
    }
  }

  @override
  Future<({List<String> trackIds, int currentIndex})?> loadQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueData = prefs.getString(_queueKey);

      if (queueData == null) return null;

      final data = jsonDecode(queueData) as Map<String, dynamic>;
      final timestamp = data['timestamp'] as int;

      // Only restore if queue is less than 1 hour old
      final queueAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (queueAge > const Duration(hours: 1).inMilliseconds) {
        await prefs.remove(_queueKey);
        return null;
      }

      return (
        trackIds: List<String>.from(data['trackIds'] as List),
        currentIndex: data['currentIndex'] as int,
      );
    } catch (e) {
      AppLogger.error('Failed to load queue: $e', tag: 'PlaybackPersistenceRepositoryImpl');
      return null;
    }
  }

  @override
  Future<void> saveTrackPosition(String trackId, Duration position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positions = await _loadTrackPositions();
      positions[trackId] = position.inMilliseconds;
      await prefs.setString(_trackPositionsKey, jsonEncode(positions));
    } catch (e) {
      AppLogger.error('Failed to save track position: $e', tag: 'PlaybackPersistenceRepositoryImpl');
    }
  }

  @override
  Future<Duration?> loadTrackPosition(String trackId) async {
    try {
      final positions = await _loadTrackPositions();
      final positionMs = positions[trackId];
      return positionMs != null ? Duration(milliseconds: positionMs) : null;
    } catch (e) {
      AppLogger.error('Failed to load track position: $e', tag: 'PlaybackPersistenceRepositoryImpl');
      return null;
    }
  }

  @override
  Future<void> clearTrackPositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_trackPositionsKey);
    } catch (e) {
      AppLogger.error('Failed to clear track positions: $e', tag: 'PlaybackPersistenceRepositoryImpl');
    }
  }

  /// Helper method to load track positions map
  Future<Map<String, int>> _loadTrackPositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positionsData = prefs.getString(_trackPositionsKey);

      if (positionsData == null) return {};

      final data = jsonDecode(positionsData) as Map<String, dynamic>;
      return data.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      return {};
    }
  }
}
