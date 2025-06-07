import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/core/error/failures.dart';

abstract class ManageCollaboratorsRepository {
  Future<Either<Failure, void>> addCollaboratorWithUserId(
    ProjectId projectId,
    UserId collaboratorId,
  );

  Future<Either<Failure, void>> joinProjectWithId(
    ProjectId projectId,
    UserId userId,
  );

  Future<Either<Failure, void>> removeCollaborator(
    ProjectId projectId,
    UserId collaboratorId,
  );
  Future<Either<Failure, void>> updateCollaboratorRole(
    ProjectId projectId,
    UserId userId,
    ProjectRole role,
  );
}
