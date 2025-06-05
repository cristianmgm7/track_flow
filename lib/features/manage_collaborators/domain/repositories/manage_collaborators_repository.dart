import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/entities/user_role.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class ManageCollaboratorsRepository {
  Future<Either<Failure, List<UserProfile>>> getProjectCollaborators(
    ProjectId projectId,
    List<UserId> collaborators,
  );
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
    UserRole role,
  );
}
