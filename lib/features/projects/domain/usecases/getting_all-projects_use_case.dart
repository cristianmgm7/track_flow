import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';

class GetAllProjectsUseCase {
  final ProjectsRepository repository;
  GetAllProjectsUseCase(this.repository);

  Future<Either<Failure, List<Project>>> call() {
    return repository.getAllProjects();
  }
}
