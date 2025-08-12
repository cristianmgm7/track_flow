import 'package:dartz/dartz.dart';
import 'dart:io';
import 'package:trackflow/core/entities/unique_id.dart';
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
  /// [audioFile] - The downloaded audio file to store
  ///
  /// Returns cached audio info or failure
  Future<Either<CacheFailure, CachedAudio>> storeAudio(
    AudioTrackId trackId,
    File audioFile, {
    String? referenceId,
    bool canDelete = true,
  });

  /// Get cached audio file path if exists
  ///
  /// Returns absolute file path or failure if not found
  Future<Either<CacheFailure, String>> getCachedAudioPath(AudioTrackId trackId);

  /// Check if audio file exists and is valid
  Future<Either<CacheFailure, bool>> audioExists(AudioTrackId trackId);

  /// Get cached audio information
  Future<Either<CacheFailure, CachedAudio?>> getCachedAudio(
    AudioTrackId trackId,
  );

  /// Delete audio file from storage
  /// WARNING: This physically deletes the file - ensure reference counting first
  Future<Either<CacheFailure, Unit>> deleteAudioFile(AudioTrackId trackId);

  // ===============================================
  // BATCH OPERATIONS
  // ===============================================

  /// Get cached audio info for multiple tracks
  Future<Either<CacheFailure, Map<AudioTrackId, CachedAudio>>>
  getMultipleCachedAudios(List<AudioTrackId> trackIds);

  /// Delete multiple audio files
  Future<Either<CacheFailure, List<AudioTrackId>>> deleteMultipleAudioFiles(
    List<AudioTrackId> trackIds,
  );

  /// Check existence of multiple audio files
  Future<Either<CacheFailure, Map<AudioTrackId, bool>>>
  checkMultipleAudioExists(List<AudioTrackId> trackIds);

  // ===============================================
  // STORAGE MONITORING
  // ===============================================

  /// Watch storage usage changes
  Stream<int> watchStorageUsage();

  /// Get current storage usage
  Future<Either<CacheFailure, int>> getStorageUsage();

  /// Get available storage space
  Future<Either<CacheFailure, int>> getAvailableStorage();

  /// Watch cache status for a single track
  Stream<bool> watchTrackCacheStatus(AudioTrackId trackId);
}
