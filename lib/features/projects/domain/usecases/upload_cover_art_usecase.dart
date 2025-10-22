import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';

@LazySingleton()
class UploadCoverArtUseCase {
  final ProjectsRepository _repository;

  UploadCoverArtUseCase(this._repository);

  /// Uploads cover art for a project and returns the URL
  Future<Either<Failure, String>> call(
    ProjectId projectId,
    File imageFile,
  ) async {
    try {
      return await _repository.uploadCoverArt(projectId, imageFile);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }
}
