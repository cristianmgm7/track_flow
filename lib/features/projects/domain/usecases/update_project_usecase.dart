import 'package:injectable/injectable.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';

@LazySingleton()
class UpdateProjectUseCase {
  final ProjectsRepository _repository;

  UpdateProjectUseCase(this._repository);

  /// Updates an existing project.

  Future<Either<Failure, Unit>> call(Project project) async {
    return await _repository.updateProject(project);
  }
}
