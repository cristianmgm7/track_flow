import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/utils/audio_format_utils.dart';

/// Centralized Firebase Storage service for ALL audio operations
/// Handles upload, download, and delete for any audio file (tracks, comments, etc.) FirebaseAudioFileRepository
///
/// This service is storage-path agnostic - it doesn't care about folder structure.
/// Consumers (repositories, coordinators) decide the paths.
@LazySingleton()
class FirebaseAudioService {
  final FirebaseStorage _storage;
  final http.Client _httpClient;

  FirebaseAudioService(
    this._storage, {
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Upload audio file to Firebase Storage
  /// [audioFile] - Local file to upload
  /// [storagePath] - Firebase Storage path (e.g., 'audio_comments/{projectId}/{versionId}/{commentId}.m4a')
  /// [metadata] - Optional custom metadata
  /// Returns download URL on success
  Future<Either<Failure, String>> uploadAudioFile({
    required File audioFile,
    required String storagePath,
    Map<String, String>? metadata,
  }) async {
    try {
      final fileExtension = AudioFormatUtils.getFileExtension(audioFile.path);
      final ref = _storage.ref().child(storagePath);

      final uploadTask = ref.putFile(
        audioFile,
        SettableMetadata(
          contentType: AudioFormatUtils.getContentType(fileExtension),
          customMetadata: metadata,
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Upload failed: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Upload failed: ${e.toString()}'));
    }
  }

  /// Download audio file from Firebase Storage URL to local path
  /// [storageUrl] - Firebase Storage download URL
  /// [localPath] - Destination path for downloaded file
  /// Returns local file path on success
  Future<Either<Failure, String>> downloadAudioFile({
    required String storageUrl,
    required String localPath,
    // Removed onProgress parameter and tracking logic
  }) async {
    try {
      // Ensure parent directory exists
      final file = File(localPath);
      await file.parent.create(recursive: true);

      // Simple download: get and write the bytes in one go.
      final response = await _httpClient.get(Uri.parse(storageUrl));

      if (response.statusCode != 200) {
        return Left(ServerFailure(
          'Download failed with status ${response.statusCode}',
        ));
      }

      await file.writeAsBytes(response.bodyBytes);

      // Verify file was created
      if (!await file.exists()) {
        return Left(StorageFailure('Download completed but file not found'));
      }

      return Right(file.path);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Download failed: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Download failed: ${e.toString()}'));
    }
  }

  /// Delete audio file from Firebase Storage
  /// [storageUrl] - Firebase Storage download URL
  Future<Either<Failure, Unit>> deleteAudioFile({
    required String storageUrl,
  }) async {
    try {
      final ref = _storage.refFromURL(storageUrl);
      await ref.delete();
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Delete failed: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Delete failed: ${e.toString()}'));
    }
  }

  /// Check if a Firebase Storage file exists
  /// [storageUrl] - Firebase Storage download URL
  Future<Either<Failure, bool>> fileExists({
    required String storageUrl,
  }) async {
    try {
      final ref = _storage.refFromURL(storageUrl);
      await ref.getMetadata();
      return const Right(true);
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return const Right(false);
      }
      return Left(ServerFailure('File check failed: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('File check failed: ${e.toString()}'));
    }
  }

  void dispose() {
    _httpClient.close();
  }
}

// Legacy alias for backward compatibility
// TODO: Remove after updating all references
@Deprecated('Use FirebaseAudioService instead')
typedef FirebaseAudioUploadService = FirebaseAudioService;
