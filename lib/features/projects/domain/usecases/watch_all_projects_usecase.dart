import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';

@lazySingleton
class WatchAllProjectsUseCase {
  final ProjectsRepository _repository;

  WatchAllProjectsUseCase(this._repository);

  Stream<Either<Failure, List<Project>>> call() {
    return _repository.watchAllProjects();
  }
}
