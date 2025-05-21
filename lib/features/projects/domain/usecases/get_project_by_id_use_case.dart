import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';

class GetProjectByIdUseCase {
  final ProjectsRepository _repository;

  GetProjectByIdUseCase(this._repository);

  Future<Either<Failure, Project>> call(String id) async {
    return await _repository.getProjectById(id);
  }
}
