import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';
import 'package:trackflow/core/sync/domain/executors/operation_executor.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';
import 'package:trackflow/features/audio_comment/data/services/audio_comment_storage_coordinator.dart';

/// Handles sync operations for AudioComment entities
///
/// This executor is responsible for translating sync operations
/// into appropriate calls to the AudioCommentRemoteDataSource.
/// Also handles audio file uploads to Firebase Storage.
@injectable
class AudioCommentOperationExecutor implements OperationExecutor {
  final AudioCommentRemoteDataSource _remoteDataSource;
  final AudioCommentStorageCoordinator _storageCoordinator;

  AudioCommentOperationExecutor(
    this._remoteDataSource,
    this._storageCoordinator,
  );

  @override
  String get entityType => 'audio_comment';

  @override
  Future<void> execute(SyncOperationDocument operation) async {
    final operationData =
        operation.operationData != null
            ? jsonDecode(operation.operationData!) as Map<String, dynamic>
            : <String, dynamic>{};

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
      final uploadResult = await _storageCoordinator.uploadCommentAudio(
        localPath: operationData['localAudioPath'] as String,
        projectId: ProjectId.fromUniqueString(operationData['projectId'] as String),
        versionId: TrackVersionId.fromUniqueString(operationData['trackId'] as String),
        commentId: AudioCommentId.fromUniqueString(operation.entityId),
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
      await _storageCoordinator.deleteCommentAudio(
        storageUrl: audioStorageUrl,
      );
    }
  }
}
