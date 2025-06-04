import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/entities/user_role.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class ManageCollaboratorsRepository {
  Future<Either<Failure, List<UserProfile>>> getProjectParticipants(
    ProjectId projectId,
  );
  Future<Either<Failure, void>> addParticipant(
    ProjectId projectId,
    UserId userId,
  );
  Future<Either<Failure, void>> removeParticipant(
    ProjectId projectId,
    UserId userId,
  );
  Future<Either<Failure, void>> updateParticipantRole(
    ProjectId projectId,
    UserId userId,
    UserRole role,
  );
}
