import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';

abstract class WaveformRepository {
  Future<Either<Failure, AudioWaveform>> getWaveformByVersionId(
    TrackVersionId versionId,
  );
  Future<Either<Failure, Unit>> deleteWaveformsForVersion(
    TrackVersionId versionId,
  );
  Stream<AudioWaveform> watchWaveformChanges(TrackVersionId versionId);

  Future<Either<Failure, Unit>> clearAllWaveforms();

  /// Store waveform locally and upload to canonical remote path
  /// waveforms/{trackId}/{versionId}.json
  Future<Either<Failure, Unit>> storeCanonicalWaveform({
    required AudioTrackId trackId,
    required AudioWaveform waveform,
  });
}
