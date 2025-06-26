import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_player/domain/services/playback_state_persistence.dart';

@Injectable(as: PlaybackStatePersistence)
class PlaybackStatePersistenceImpl implements PlaybackStatePersistence {
  static const String _playbackStateKey = 'playback_state';
  static const String _lastPositionKey = 'last_position';
  
  @override
  Future<Either<Failure, Unit>> savePlaybackState(PersistedPlaybackState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = jsonEncode(state.toJson());
      await prefs.setString(_playbackStateKey, stateJson);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to save playback state: $e'));
    }
  }

  @override
  Future<Either<Failure, PersistedPlaybackState?>> restorePlaybackState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = prefs.getString(_playbackStateKey);
      
      if (stateJson == null) {
        return const Right(null);
      }
      
      final stateMap = jsonDecode(stateJson) as Map<String, dynamic>;
      final state = PersistedPlaybackState.fromJson(stateMap);
      
      // Check if state is recent (within last 24 hours)
      final hoursSinceUpdate = DateTime.now().difference(state.lastUpdated).inHours;
      if (hoursSinceUpdate > 24) {
        // Clear old state
        await clearPlaybackState();
        return const Right(null);
      }
      
      return Right(state);
    } catch (e) {
      return Left(CacheFailure('Failed to restore playback state: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearPlaybackState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_playbackStateKey);
      await prefs.remove(_lastPositionKey);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to clear playback state: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> savePosition(Duration position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastPositionKey, position.inMilliseconds);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to save position: $e'));
    }
  }
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}