import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';
import 'package:trackflow/core/sync/domain/executors/operation_executor.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart';

/// Handles sync operations for AudioTrack entities
///
/// This executor is responsible for translating sync operations
/// into appropriate calls to the AudioTrackRemoteDataSource.
@injectable
class AudioTrackOperationExecutor implements OperationExecutor {
  final AudioTrackRemoteDataSource _remoteDataSource;
  final AudioTrackLocalDataSource _localDataSource;

  AudioTrackOperationExecutor(this._remoteDataSource, this._localDataSource);

  @override
  String get entityType => 'audio_track';

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
        await _executeDelete(operation, operationData);
        break;

      default:
        throw UnsupportedError(
          'Unknown audio track operation: ${operation.operationType}',
        );
    }
  }

  /// Execute audio track creation (upload)
  Future<void> _executeCreate(
    SyncOperationDocument operation,
    Map<String, dynamic> operationData,
  ) async {
    final audioTrackDto = AudioTrackDTO(
      id: AudioTrackId.fromUniqueString(operation.entityId),
      name: operationData['name'] ?? '',
      url: operationData['filePath'] ?? '', // Local file path for upload
      duration: operationData['duration'] ?? 0,
      projectId: ProjectId.fromUniqueString(operationData['projectId'] ?? ''),
      uploadedBy: UserId.fromUniqueString(operationData['uploadedBy'] ?? ''),
      createdAt:
          operationData['createdAt'] != null
              ? DateTime.parse(operationData['createdAt'])
              : DateTime.now(),
      extension: operationData['extension'] ?? 'mp3',
    );

    final result = await _remoteDataSource.createAudioTrack(audioTrackDto);
    result.fold(
      (failure) => throw Exception('Upload failed: ${failure.message}'),
      (uploadedDto) async {
        // Update local cached track URL to remote download URL
        await _localDataSource.updateTrackUrl(
          uploadedDto.id.value,
          uploadedDto.url,
        );
      },
    );
  }

  /// Execute audio track update (edit name or active version)
  Future<void> _executeUpdate(
    SyncOperationDocument operation,
    Map<String, dynamic> operationData,
  ) async {
    final trackId = operation.entityId;
    final field = operationData['field'] ?? '';

    switch (field) {
      case 'name':
        final projectId = operationData['projectId'] ?? '';
        final newName = operationData['newName'] ?? '';
        await _remoteDataSource.editTrackName(trackId, projectId, newName);
        break;

      case 'activeVersion':
        final activeVersionId = operationData['activeVersionId'] ?? '';
        final result = await _remoteDataSource.updateActiveVersion(
          trackId,
          activeVersionId,
        );
        result.fold(
          (failure) =>
              throw Exception(
                'Update active version failed: ${failure.message}',
              ),
          (_) {
            // Successfully updated active version
          },
        );
        break;

      default:
        throw UnsupportedError('Unknown audio track update field: $field');
    }
  }

  /// Execute audio track deletion (soft delete)
  Future<void> _executeDelete(
    SyncOperationDocument operation,
    Map<String, dynamic> operationData,
  ) async {
    // Create AudioTrackDTO with isDeleted: true for soft delete
    final audioTrackDto = AudioTrackDTO(
      id: AudioTrackId.fromUniqueString(operation.entityId),
      name: operationData['name'] ?? '',
      url: operationData['url'] ?? '',
      duration: operationData['duration'] ?? 0,
      projectId: ProjectId.fromUniqueString(operationData['projectId'] ?? ''),
      uploadedBy: UserId.fromUniqueString(operationData['uploadedBy'] ?? ''),
      createdAt:
          operationData['createdAt'] != null
              ? DateTime.parse(operationData['createdAt'])
              : DateTime.now(),
      extension: operationData['extension'] ?? 'mp3',
      isDeleted: true, // Soft delete
      lastModified: DateTime.now().toUtc(),
    );

    // Use updateTrack for soft delete instead of deleteAudioTrack
    final result = await _remoteDataSource.updateTrack(audioTrackDto);
    result.fold(
      (failure) => throw Exception('Soft delete failed: ${failure.message}'),
      (_) {
        // Successfully soft deleted
      },
    );
  }
}
