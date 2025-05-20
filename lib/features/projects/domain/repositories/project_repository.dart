import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/core/entities/unique_id.dart';

abstract class ProjectRepository {
  Future<Either<Failure, Unit>> createProject(Project project);
  Future<Either<Failure, Unit>> updateProject(Project project);
  Future<Either<Failure, Unit>> deleteProject(UniqueId id);
  Future<Either<Failure, List<Project>>> getAllProjects();
  Future<Either<Failure, Project>> getProjectById(String id);
}
