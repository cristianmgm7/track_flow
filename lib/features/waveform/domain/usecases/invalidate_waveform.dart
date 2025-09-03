import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart';

@injectable
class InvalidateWaveform {
  final WaveformRepository _repository;
  InvalidateWaveform(this._repository);

  Future<Either<Failure, Unit>> call(AudioTrackId trackId) {
    return _repository.invalidate(trackId: trackId);
  }
}
