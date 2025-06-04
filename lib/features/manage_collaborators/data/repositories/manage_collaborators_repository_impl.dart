import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/entities/user_role.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart';

class ManageCollaboratorsRepositoryImpl
    implements ManageCollaboratorsRepository {
  @override
  Future<Either<Failure, List<UserProfile>>> getProjectParticipants(
    ProjectId projectId,
  ) async {
    try {
      // TODO: Replace with real source (e.g., Firestore)
      return right([]);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addParticipant(
    ProjectId projectId,
    UserId userId,
  ) async {
    try {
      // TODO: Implement add participant logic
      return right(unit);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateParticipantRole(
    ProjectId projectId,
    UserId userId,
    UserRole role,
  ) async {
    try {
      // TODO: Implement role update logic
      return right(unit);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeParticipant(
    ProjectId projectId,
    UserId userId,
  ) async {
    try {
      // TODO: Implement removal logic
      return right(unit);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }
}
