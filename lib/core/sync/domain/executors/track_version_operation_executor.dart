import 'dart:convert';
import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';
import 'package:trackflow/core/sync/domain/executors/operation_executor.dart';
import 'package:trackflow/features/track_version/data/datasources/track_version_remote_datasource.dart';
import 'package:trackflow/features/track_version/data/models/track_version_dto.dart';
import 'package:trackflow/features/track_version/data/datasources/track_version_local_data_source.dart';

/// Handles sync operations for TrackVersion entities
///
/// This executor is responsible for translating sync operations
/// into appropriate calls to the TrackVersionRemoteDataSource.
/// It handles the upload of audio files to Firebase Storage and
/// metadata synchronization to Firestore.
@injectable
class TrackVersionOperationExecutor implements OperationExecutor {
  final TrackVersionRemoteDataSource _remoteDataSource;
  final TrackVersionLocalDataSource _localDataSource;

  TrackVersionOperationExecutor(this._remoteDataSource, this._localDataSource);

  @override
  String get entityType => 'track_version';

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
          'Unknown track version operation: ${operation.operationType}',
        );
    }
  }

  /// Execute track version creation (upload audio file + metadata)
  Future<void> _executeCreate(
    SyncOperationDocument operation,
    Map<String, dynamic> operationData,
  ) async {
    try {
      // Extract version data from operation
      final versionId = operationData['versionId'] as String;
      final trackId = operationData['trackId'] as String;
      final versionNumber = operationData['versionNumber'] as int;
      final label = operationData['label'] as String?;
      final fileLocalPath = operationData['fileLocalPath'] as String?;
      final durationMs = operationData['durationMs'] as int?;
      final createdBy = operationData['createdBy'] as String;
      final createdAt = DateTime.parse(operationData['createdAt'] as String);

      // Create DTO for upload
      final versionDTO = TrackVersionDTO(
        id: versionId,
        trackId: trackId,
        versionNumber: versionNumber,
        label: label,
        fileLocalPath: fileLocalPath,
        fileRemoteUrl: null, // Will be set after upload
        durationMs: durationMs,
        status: 'processing',
        createdAt: createdAt,
        createdBy: createdBy,
      );

      // Get the audio file
      if (fileLocalPath == null) {
        throw Exception('No audio file path provided for track version upload');
      }

      final audioFile = File(fileLocalPath);
      if (!await audioFile.exists()) {
        throw Exception('Audio file not found at path: $fileLocalPath');
      }

      // Upload to remote (Firebase Storage + Firestore)
      final uploadResult = await _remoteDataSource.uploadTrackVersion(
        versionDTO,
        audioFile,
      );

      if (uploadResult.isLeft()) {
        throw Exception(
          'Failed to upload track version: ${uploadResult.fold((l) => l.message, (r) => '')}',
        );
      }

      final uploadedVersion = uploadResult.getOrElse(() => throw Exception());

      // Update local cache with remote URL
      await _localDataSource.cacheVersion(uploadedVersion);
    } catch (e) {
      throw Exception('Track version creation failed: $e');
    }
  }

  /// Execute track version update
  Future<void> _executeUpdate(
    SyncOperationDocument operation,
    Map<String, dynamic> operationData,
  ) async {
    try {
      final versionId = operationData['versionId'] as String;

      // Get current version from local cache
      final currentVersionResult = await _localDataSource.getVersionById(
        versionId,
      );
      if (currentVersionResult.isLeft()) {
        throw Exception('Version not found locally: $versionId');
      }

      final currentVersion = currentVersionResult.getOrElse(() => null);
      if (currentVersion == null) {
        throw Exception('Version not found: $versionId');
      }

      // Create updated DTO
      final updatedVersionDTO = TrackVersionDTO(
        id: currentVersion.id,
        trackId: currentVersion.trackId,
        versionNumber: currentVersion.versionNumber,
        label: operationData['label'] ?? currentVersion.label,
        fileLocalPath: currentVersion.fileLocalPath,
        fileRemoteUrl: currentVersion.fileRemoteUrl,
        durationMs: currentVersion.durationMs,
        status: operationData['status'] ?? currentVersion.status,
        createdAt: currentVersion.createdAt,
        createdBy: currentVersion.createdBy,
        version: (currentVersion.version ?? 1) + 1,
        lastModified: DateTime.now(),
      );

      // Update in Firestore (metadata only, no file re-upload)
      await _remoteDataSource.updateTrackVersionMetadata(updatedVersionDTO);

      // Update local cache
      await _localDataSource.cacheVersion(updatedVersionDTO);
    } catch (e) {
      throw Exception('Track version update failed: $e');
    }
  }

  /// Execute track version deletion
  Future<void> _executeDelete(SyncOperationDocument operation) async {
    try {
      final versionId = operation.entityId;

      // Delete from remote (Firebase Storage + Firestore)
      final deleteResult = await _remoteDataSource.deleteTrackVersion(
        versionId,
      );

      if (deleteResult.isLeft()) {
        throw Exception(
          'Failed to delete track version from remote: ${deleteResult.fold((l) => l.message, (r) => '')}',
        );
      }

      // Delete from local cache
      await _localDataSource.deleteVersion(
        TrackVersionId.fromUniqueString(versionId),
      );
    } catch (e) {
      throw Exception('Track version deletion failed: $e');
    }
  }
}
