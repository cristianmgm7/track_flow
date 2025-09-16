import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';
import 'package:trackflow/core/sync/domain/executors/operation_executor.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';
import 'package:trackflow/features/waveform/domain/value_objects/waveform_data.dart';
import 'package:trackflow/features/waveform/domain/value_objects/waveform_metadata.dart';
import 'package:trackflow/features/waveform/data/datasources/waveform_remote_datasource.dart';

@injectable
class WaveformOperationExecutor implements OperationExecutor {
  final WaveformRemoteDataSource _remoteDataSource;

  WaveformOperationExecutor(this._remoteDataSource);

  @override
  String get entityType => 'audio_waveform';

  @override
  Future<void> execute(SyncOperationDocument operation) async {
    final Map<String, dynamic> data =
        operation.operationData != null
            ? jsonDecode(operation.operationData!) as Map<String, dynamic>
            : <String, dynamic>{};

    switch (operation.operationType) {
      case 'create':
      case 'update':
        await _executeUpsert(operation, data);
        break;
      case 'delete':
        await _executeDelete(operation, data);
        break;
      default:
        throw UnsupportedError(
          'Unknown audio_waveform operation: ${operation.operationType}',
        );
    }
  }

  Future<void> _executeUpsert(
    SyncOperationDocument operation,
    Map<String, dynamic> data,
  ) async {
    final String? trackId = data['trackId'] as String?;
    if (trackId == null || trackId.isEmpty) {
      throw Exception('Waveform upsert missing trackId');
    }

    final waveform = AudioWaveform(
      id: AudioWaveformId.fromUniqueString(data['id'] as String),
      versionId: TrackVersionId.fromUniqueString(data['versionId'] as String),
      data: WaveformData(
        amplitudes:
            (data['amplitudes'] as List)
                .cast<num>()
                .map((e) => e.toDouble())
                .toList(),
        sampleRate: data['sampleRate'] as int,
        duration: Duration(milliseconds: data['durationMs'] as int),
        targetSampleCount: data['targetSampleCount'] as int,
      ),
      metadata: WaveformMetadata(
        maxAmplitude: (data['maxAmplitude'] as num).toDouble(),
        rmsLevel: (data['rmsLevel'] as num).toDouble(),
        compressionLevel: data['compressionLevel'] as int,
        generationMethod: data['generationMethod'] as String,
      ),
      generatedAt: DateTime.parse(data['generatedAt'] as String),
    );

    await _remoteDataSource.uploadCanonical(
      trackId: trackId,
      waveform: waveform,
    );
  }

  Future<void> _executeDelete(
    SyncOperationDocument operation,
    Map<String, dynamic> data,
  ) async {
    final String? trackId = data['trackId'] as String?;
    if (trackId == null || trackId.isEmpty) {
      throw Exception('Waveform delete missing trackId');
    }

    await _remoteDataSource.deleteWaveformsForVersion(
      trackId: trackId,
      versionId: TrackVersionId.fromUniqueString(operation.entityId),
    );
  }
}
