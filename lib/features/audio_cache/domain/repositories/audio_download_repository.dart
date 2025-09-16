import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import '../entities/download_progress.dart';
import '../failures/cache_failure.dart';

/// Repository responsible for audio download operations
/// Follows Single Responsibility Principle - only handles downloading
abstract class AudioDownloadRepository {
  // ===============================================
  // DOWNLOAD OPERATION (MINIMAL API)
  // ===============================================

  /// Download audio file
  ///
  /// [trackId] - Unique identifier for the track
  /// [audioUrl] - Source URL for the audio file
  /// [progressCallback] - Optional callback for download progress
  ///
  /// Returns file path or failure
  Future<Either<CacheFailure, String>> downloadAudio(
    AudioTrackId trackId,
    String audioUrl, {
    void Function(DownloadProgress)? progressCallback,
  });
}
