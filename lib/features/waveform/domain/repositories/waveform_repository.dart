import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';

abstract class WaveformRepository {
  Future<Either<Failure, AudioWaveform>> getWaveformByVersionId(
    TrackVersionId versionId,
  );
  Future<Either<Failure, Unit>> saveWaveform(AudioWaveform waveform);
  Future<Either<Failure, Unit>> deleteWaveformsForVersion(
    TrackVersionId versionId,
  );
  Stream<AudioWaveform> watchWaveformChanges(TrackVersionId versionId);

  Future<Either<Failure, AudioWaveform>> getOrGenerate({
    required TrackVersionId versionId,
    String? audioFilePath,
    required String audioSourceHash,
    required int algorithmVersion,
    int? targetSampleCount,
    bool forceRefresh = false,
  });

  Future<Either<Failure, Unit>> invalidate({required TrackVersionId versionId});
}
