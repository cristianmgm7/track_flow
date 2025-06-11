import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';

class UploadAudioTrackParams {
  final File file;
  final String name;
  final Duration duration;
  final List<String> projectIds;

  UploadAudioTrackParams({
    required this.file,
    required this.name,
    required this.duration,
    required this.projectIds,
  });
}

@lazySingleton
class UploadAudioTrackUseCase {
  final AudioTrackRepository repository;
  final SessionStorage sessionStorage;

  UploadAudioTrackUseCase(this.repository, this.sessionStorage);

  Future<Either<Failure, Unit>> call(UploadAudioTrackParams params) async {
    final userId = sessionStorage.getUserId();
    if (userId == null) {
      return Left(ServerFailure('User not found'));
    }
    return repository.uploadAudioTrack(
      file: params.file,
      name: params.name,
      duration: params.duration,
      projectIds: params.projectIds,
      uploadedBy: userId,
    );
  }
}
