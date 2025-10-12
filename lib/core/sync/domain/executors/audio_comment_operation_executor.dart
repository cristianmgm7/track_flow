import 'dart:convert';
import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/audio/domain/audio_file_repository.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';
import 'package:trackflow/core/sync/domain/executors/operation_executor.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';

/// Handles sync operations for AudioComment entities
///
/// This executor is responsible for translating sync operations
/// into appropriate calls to the AudioCommentRemoteDataSource.
/// Also handles audio file uploads to Firebase Storage.
@injectable
class AudioCommentOperationExecutor implements OperationExecutor {
  final AudioCommentRemoteDataSource _remoteDataSource;
  final AudioFileRepository _audioFileRepository;

  AudioCommentOperationExecutor(
    this._remoteDataSource,
    this._audioFileRepository,
  );

  @override
  String get entityType => 'audio_comment';

  @override
  Future<void> execute(SyncOperationDocument operation) async {
    final operationData =
        operation.operationData != null
            ? jsonDecode(operation.operationData!) as Map<String, dynamic>
            : <String, dynamic>{};

    // Handle special entity type for bulk deletions
    if (operation.entityType == 'audio_comment_by_version') {
      await _executeDeleteByVersion(operation);
      return;
    }

    switch (operation.operationType) {
      case 'create':
        await _executeCreate(operation, operationData);
        break;

      case 'update':
        await _executeUpdate(operation, operationData);
        break;

      case 'delete':
        await _executeDelete(operation);
        break;

      default:
        throw UnsupportedError(
          'Unknown audio comment operation: ${operation.operationType}',
        );
    }
  }

  /// Execute audio comment creation
  Future<void> _executeCreate(
    SyncOperationDocument operation,
    Map<String, dynamic> operationData,
  ) async {
    // 1. Upload audio file if present
    String? audioStorageUrl;
    if (operationData['localAudioPath'] != null) {
      final localPath = operationData['localAudioPath'] as String;
      final audioFile = File(localPath);

      // Build storage path: audio_comments/{trackId}/{versionId}/{commentId}.m4a
      final trackId = AudioTrackId.fromUniqueString(operationData['trackId'] as String);
      final versionId = TrackVersionId.fromUniqueString(operationData['trackId'] as String);
      final commentId = AudioCommentId.fromUniqueString(operation.entityId);
      final storagePath = 'audio_comments/${trackId.value}/${versionId.value}/${commentId.value}.m4a';

      final metadata = {
        'trackId': trackId.value,
        'versionId': versionId.value,
        'commentId': commentId.value,
        'type': 'audio_comment',
      };

      final uploadResult = await _audioFileRepository.uploadAudioFile(
        audioFile: audioFile,
        storagePath: storagePath,
        metadata: metadata,
      );

      audioStorageUrl = await uploadResult.fold(
        (failure) => throw Exception('Audio upload failed: ${failure.message}'),
        (url) => url,
      );
    }

    // 2. Create DTO with audio URL
    final audioCommentDto = AudioCommentDTO(
      id: operation.entityId,
      content: operationData['content'] ?? '',
      trackId: operationData['trackId'] ?? '',
      projectId: operationData['projectId'] ?? '',
      createdBy: operationData['createdBy'] ?? '',
      timestamp: operationData['timestamp'] ?? 0,
      createdAt: operationData['createdAt'] ?? DateTime.now().toIso8601String(),
      audioStorageUrl: audioStorageUrl,
      audioDurationMs: operationData['audioDurationMs'] as int?,
      commentType: operationData['commentType'] as String? ?? 'text',
    );

    // 3. Create Firestore document
    final result = await _remoteDataSource.addComment(audioCommentDto);
    result.fold(
      (failure) =>
          throw Exception('Comment creation failed: ${failure.message}'),
      (_) {
        // Successfully created
      },
    );
  }

  /// Execute audio comment update
  Future<void> _executeUpdate(
    SyncOperationDocument operation,
    Map<String, dynamic> operationData,
  ) async {
    final audioCommentDto = AudioCommentDTO(
      id: operation.entityId,
      content: operationData['content'] ?? '',
      trackId: operationData['trackId'] ?? '',
      projectId: operationData['projectId'] ?? '',
      createdBy: operationData['createdBy'] ?? '',
      timestamp: operationData['timestamp'] ?? 0,
      createdAt: operationData['createdAt'] ?? DateTime.now().toIso8601String(),
    );

    final result = await _remoteDataSource.addComment(audioCommentDto);
    result.fold(
      (failure) => throw Exception('Comment update failed: ${failure.message}'),
      (_) {
        // Successfully updated
      },
    );
  }

  /// Execute audio comment deletion
  Future<void> _executeDelete(SyncOperationDocument operation) async {
    // Get operation data to check for audio URL
    final operationData =
        operation.operationData != null
            ? jsonDecode(operation.operationData!) as Map<String, dynamic>
            : <String, dynamic>{};

    // 1. Delete Firestore document
    final result = await _remoteDataSource.deleteComment(operation.entityId);
    result.fold(
      (failure) =>
          throw Exception('Comment deletion failed: ${failure.message}'),
      (_) {
        // Successfully deleted
      },
    );

    // 2. Delete audio file from Firebase Storage if exists
    final audioStorageUrl = operationData['audioStorageUrl'] as String?;
    if (audioStorageUrl != null) {
      final deleteResult = await _audioFileRepository.deleteAudioFile(
        storageUrl: audioStorageUrl,
      );

      deleteResult.fold(
        (failure) {
          // Log but don't fail - Firestore document is already deleted
          // Audio file cleanup can be handled by storage rules or manual cleanup
        },
        (_) {
          // Successfully deleted audio file
        },
      );
    }
  }

  /// Execute bulk deletion of all audio comments for a version
  /// This is used when deleting a track version or track entirely
  Future<void> _executeDeleteByVersion(SyncOperationDocument operation) async {
    // operation.entityId contains the versionId
    final versionId = operation.entityId;

    // Delete all comments for this version from Firestore
    final result = await _remoteDataSource.deleteByVersionId(versionId);
    result.fold(
      (failure) =>
          throw Exception('Bulk comment deletion failed: ${failure.message}'),
      (_) {
        // Successfully deleted all comments for version
        // Note: Audio files will be cleaned up by Firebase Storage lifecycle rules
        // or can be handled by a cloud function
      },
    );
  }
}
