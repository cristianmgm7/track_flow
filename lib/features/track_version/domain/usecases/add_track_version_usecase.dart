import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';

class AddTrackVersionParams {
  final AudioTrackId trackId;
  final File file;
  final String? label;

  AddTrackVersionParams({
    required this.trackId,
    required this.file,
    this.label,
  });
}

@lazySingleton
class AddTrackVersionUseCase {
  final TrackVersionRepository repository;
  AddTrackVersionUseCase(this.repository);

  Future<Either<Failure, TrackVersion>> call(AddTrackVersionParams params) {
    return repository.addVersion(
      trackId: params.trackId,
      file: params.file,
      label: params.label,
    );
  }
}
