import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

abstract class ProjectRepository {
  Future<Either<Failure, Project>> fetchProjectDetails(ProjectId projectId);

  Future<Either<Failure, Unit>> leaveProject({
    required ProjectId projectId,
    required UserId userId,
  });
}
