import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/core/entities/unique_id.dart';

abstract class ProjectsRepository {
  Future<Either<Failure, Project>> createProject(Project project);
  Future<Either<Failure, Unit>> updateProject(Project project);
  Future<Either<Failure, Unit>> deleteProject(UniqueId id);

  /// Streams all projects.
  Stream<Either<Failure, List<Project>>> watchAllProjects(UserId ownerId);
}
