import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';

class UploadAudioTrackParams {
  final File file;
  final String name;
  final Duration duration;
  final List<String> projectIds;
  final String uploadedBy;

  UploadAudioTrackParams({
    required this.file,
    required this.name,
    required this.duration,
    required this.projectIds,
    required this.uploadedBy,
  });
}

class UploadAudioTrackUseCase {
  final AudioTrackRepository repository;

  UploadAudioTrackUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required File file,
    required String name,
    required Duration duration,
    required List<String> projectIds,
    required String uploadedBy,
  }) {
    return repository.uploadAudioTrack(
      file: file,
      name: name,
      duration: duration,
      projectIds: projectIds,
      uploadedBy: uploadedBy,
    );
  }
}
