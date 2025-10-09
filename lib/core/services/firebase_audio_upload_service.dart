import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/utils/audio_format_utils.dart';

/// Shared Firebase Storage upload service for all audio features
/// Extracted from track_version feature for reusability
@LazySingleton()
class FirebaseAudioUploadService {
  final FirebaseStorage _storage;

  FirebaseAudioUploadService(this._storage);

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
}
