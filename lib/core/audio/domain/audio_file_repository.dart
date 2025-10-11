import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_cache/domain/entities/download_progress.dart';

/// Repository contract for audio file operations
/// Handles upload, download, deletion, and existence checks
/// with integrated caching and progress tracking
abstract class AudioFileRepository {
  /// Upload audio file to Firebase Storage
  ///
  /// [audioFile] - Local file to upload
  /// [storagePath] - Complete Firebase Storage path
  /// [metadata] - Optional custom metadata
  /// [onProgress] - Optional callback for upload progress
  ///
  /// Returns download URL on success
  Future<Either<Failure, String>> uploadAudioFile({
    required File audioFile,
    required String storagePath,
    Map<String, String>? metadata,
    void Function(DownloadProgress)? onProgress,
  });

  /// Download audio file from Firebase Storage with caching
  ///
  /// Implements cache-first strategy:
  /// 1. Check if file exists in cache
  /// 2. If cached, return local path immediately
  /// 3. If not cached, download and cache for future use
  ///
  /// [storageUrl] - Firebase Storage download URL
  /// [localPath] - Destination path for downloaded file
  /// [trackId] - Track identifier for caching
  /// [versionId] - Version identifier for caching
  /// [onProgress] - Optional callback for download progress
  ///
  /// Returns local file path on success
  Future<Either<Failure, String>> downloadAudioFile({
    required String storageUrl,
    required String localPath,
    String? trackId,
    String? versionId,
    void Function(DownloadProgress)? onProgress,
  });

  /// Delete audio file from Firebase Storage
  ///
  /// [storageUrl] - Firebase Storage download URL
  ///
  /// Returns Unit on successful deletion
  Future<Either<Failure, Unit>> deleteAudioFile({
    required String storageUrl,
  });

  /// Check if audio file exists in Firebase Storage
  ///
  /// [storageUrl] - Firebase Storage download URL
  ///
  /// Returns true if file exists, false otherwise
  Future<Either<Failure, bool>> fileExists({
    required String storageUrl,
  });

  /// Get cached audio file path without downloading
  ///
  /// [trackId] - Track identifier
  /// [versionId] - Optional version identifier
  ///
  /// Returns local file path if cached, null otherwise
  Future<Either<Failure, String?>> getCachedAudioPath({
    required String trackId,
    String? versionId,
  });

  /// Check if audio file is cached locally
  ///
  /// [trackId] - Track identifier
  /// [versionId] - Optional version identifier
  ///
  /// Returns true if cached, false otherwise
  Future<Either<Failure, bool>> isAudioCached({
    required String trackId,
    String? versionId,
  });

  /// Clear local cache for specific audio
  ///
  /// [trackId] - Track identifier
  /// [versionId] - Optional version identifier (if null, clears entire track)
  ///
  /// Returns Unit on successful deletion
  Future<Either<Failure, Unit>> clearCache({
    required String trackId,
    String? versionId,
  });

  /// Dispose resources (HTTP clients, etc.)
  void dispose();
}
