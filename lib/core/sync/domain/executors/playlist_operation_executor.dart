import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';
import 'package:trackflow/core/sync/domain/executors/operation_executor.dart';
import 'package:trackflow/features/playlist/data/datasources/playlist_remote_data_source.dart';
import 'package:trackflow/features/playlist/data/models/playlist_dto.dart';

/// Handles sync operations for Playlist entities
///
/// This executor is responsible for translating sync operations
/// into appropriate calls to the PlaylistRemoteDataSource.
@injectable
class PlaylistOperationExecutor implements OperationExecutor {
  final PlaylistRemoteDataSource _remoteDataSource;

  PlaylistOperationExecutor(this._remoteDataSource);

  @override
  String get entityType => 'playlist';

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
          'Unknown playlist operation: ${operation.operationType}',
        );
    }
  }

  /// Execute playlist creation
  Future<void> _executeCreate(
    SyncOperationDocument operation,
    Map<String, dynamic> operationData,
  ) async {
    final playlistDto = PlaylistDto(
      id: operation.entityId,
      name: operationData['name'] ?? '',
      trackIds: List<String>.from(operationData['trackIds'] ?? []),
      playlistSource: operationData['playlistSource'] ?? 'user',
    );

    final result = await _remoteDataSource.addPlaylist(playlistDto);
    result.fold(
      (failure) => throw Exception('Create failed: ${failure.message}'),
      (_) {
        // Successfully created
      },
    );
  }

  /// Execute playlist update
  Future<void> _executeUpdate(
    SyncOperationDocument operation,
    Map<String, dynamic> operationData,
  ) async {
    final playlistDto = PlaylistDto(
      id: operation.entityId,
      name: operationData['name'] ?? '',
      trackIds: List<String>.from(operationData['trackIds'] ?? []),
      playlistSource: operationData['playlistSource'] ?? 'user',
    );

    final result = await _remoteDataSource.updatePlaylist(playlistDto);
    result.fold(
      (failure) => throw Exception('Update failed: ${failure.message}'),
      (_) {
        // Successfully updated
      },
    );
  }

  /// Execute playlist deletion
  Future<void> _executeDelete(SyncOperationDocument operation) async {
    final result = await _remoteDataSource.deletePlaylist(operation.entityId);
    result.fold(
      (failure) => throw Exception('Delete failed: ${failure.message}'),
      (_) {
        // Successfully deleted
      },
    );
  }
}
