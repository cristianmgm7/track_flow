import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart';

@injectable
class GetWaveformByVersion {
  final WaveformRepository _repository;
  GetWaveformByVersion(this._repository);

  Future<Either<Failure, AudioWaveform>> call(TrackVersionId versionId) {
    return _repository.getWaveformByVersionId(versionId);
  }
}
