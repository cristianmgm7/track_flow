import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/core/error/failures.dart';

abstract class ManageCollaboratorsRepository {
  Future<Either<Failure, void>> joinProjectWithId(
    ProjectId projectId,
    UserId userId,
  );

  Future<Either<Failure, void>> updateProject(Project project);
}
