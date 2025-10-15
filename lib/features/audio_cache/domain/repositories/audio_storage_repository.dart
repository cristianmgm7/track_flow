import 'package:dartz/dartz.dart';
import 'dart:io';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/infrastructure/domain/directory_service.dart';
import '../entities/cached_audio.dart';
import '../failures/cache_failure.dart';

/// Repository responsible for physical audio file storage operations
/// Follows Single Responsibility Principle - only handles file storage
abstract class AudioStorageRepository {
  // ===============================================
  // STORAGE OPERATIONS
  // ===============================================

  /// Store audio file in cache
  ///
  /// [trackId] - Unique identifier for the track
  /// [versionId] - Unique identifier for the track version
  /// [audioFile] - The audio file to store
  /// [directoryType] - Type of directory to store in (audioTracks or audioComments)
  ///
  /// Returns cached audio info or failure
  Future<Either<CacheFailure, CachedAudio>> storeAudio(
    AudioTrackId trackId,
    TrackVersionId versionId,
    File audioFile, {
    DirectoryType directoryType = DirectoryType.audioCache,
  });

  /// Get cached audio file path if exists
  ///
  /// Returns absolute file path or failure if not found
  Future<Either<CacheFailure, String>> getCachedAudioPath(
    AudioTrackId trackId, {
    TrackVersionId? versionId,
    DirectoryType directoryType = DirectoryType.audioCache,
  });

  /// Check if audio file exists and is valid
  Future<Either<CacheFailure, bool>> audioExists(AudioTrackId trackId);

  /// Check if specific version of audio file exists
  Future<Either<CacheFailure, bool>> audioVersionExists(
    AudioTrackId trackId,
    TrackVersionId versionId,
  );

  /// Get cached audio information
  Future<Either<CacheFailure, CachedAudio?>> getCachedAudio(
    AudioTrackId trackId,
  );

  /// Get cached audio information for specific version
  Future<Either<CacheFailure, CachedAudio?>> getCachedAudioByVersion(
    AudioTrackId trackId,
    TrackVersionId versionId,
  );

  /// Delete audio file from storage
  /// WARNING: This physically deletes the file - ensure reference counting first
  Future<Either<CacheFailure, Unit>> deleteAudioFile(AudioTrackId trackId);

  /// Delete specific version of audio file from storage
  Future<Either<CacheFailure, Unit>> deleteAudioVersionFile(
    AudioTrackId trackId,
    TrackVersionId versionId,
  );

  /// Validate and clean corrupted cache entries
  /// Returns the number of cleaned entries
  Future<Either<CacheFailure, int>> validateAndCleanCache();

  // Batch operations removed to simplify interface

  // ===============================================
  // STORAGE MONITORING
  // ===============================================

  /// Watch storage usage changes
  Stream<int> watchStorageUsage();

  /// Get current storage usage
  Future<Either<CacheFailure, int>> getStorageUsage();

  /// Get available storage space
  Future<Either<CacheFailure, int>> getAvailableStorage();

  /// Watch cache status for a single track or specific version
  Stream<bool> watchTrackCacheStatus(
    AudioTrackId trackId, {
    TrackVersionId? versionId,
  });

  /// Watch all cached audios reactively
  Stream<List<CachedAudio>> watchAllCachedAudios();
}
