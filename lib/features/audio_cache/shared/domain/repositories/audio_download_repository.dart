import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import '../entities/download_progress.dart';
import '../failures/cache_failure.dart';

/// Repository responsible for audio download operations
/// Follows Single Responsibility Principle - only handles downloading
abstract class AudioDownloadRepository {
  // ===============================================
  // DOWNLOAD OPERATIONS
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

  /// Download multiple audio files with progress tracking
  Future<Either<CacheFailure, Map<AudioTrackId, String>>> downloadMultipleAudios(
    Map<AudioTrackId, String> trackUrlPairs, { // trackId -> audioUrl
    void Function(AudioTrackId trackId, DownloadProgress)? progressCallback,
  });

  // ===============================================
  // DOWNLOAD MANAGEMENT
  // ===============================================

  /// Cancel ongoing download for a track
  Future<Either<CacheFailure, Unit>> cancelDownload(AudioTrackId trackId);

  /// Pause download (if supported)
  Future<Either<CacheFailure, Unit>> pauseDownload(AudioTrackId trackId);

  /// Resume paused download
  Future<Either<CacheFailure, Unit>> resumeDownload(AudioTrackId trackId);

  /// Get current download progress for a track
  Future<Either<CacheFailure, DownloadProgress?>> getDownloadProgress(
    AudioTrackId trackId,
  );

  /// Get all currently active downloads
  Future<Either<CacheFailure, List<DownloadProgress>>> getActiveDownloads();

  // ===============================================
  // REACTIVE STREAMS
  // ===============================================

  /// Watch download progress for a specific track
  Stream<DownloadProgress> watchDownloadProgress(AudioTrackId trackId);

  /// Watch all active downloads
  Stream<List<DownloadProgress>> watchActiveDownloads();
}