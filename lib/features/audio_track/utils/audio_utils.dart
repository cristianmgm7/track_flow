import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:trackflow/features/audio_track/domain/services/audio_metadata_service.dart';

/// Utility class for audio operations
/// Note: For new code, prefer using AudioMetadataService directly
class AudioUtils {
  static final _metadataService = AudioMetadataService();

  /// Extract duration from an audio file
  /// @deprecated Use AudioMetadataService.extractDuration() instead
  static Future<Duration> getAudioDuration(String filePath) async {
    final player = AudioPlayer();
    try {
      await player
          .setFilePath(filePath)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Audio loading timed out'),
          );
      return player.duration ?? Duration.zero;
    } finally {
      await player.dispose();
    }
  }

  /// Extract duration using the domain service (recommended)
  static Future<Duration> getAudioDurationWithService(String filePath) async {
    final result = await _metadataService.extractDuration(File(filePath));
    return result.fold((failure) => Duration.zero, (duration) => duration);
  }
}
