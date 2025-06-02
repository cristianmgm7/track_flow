import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

abstract class ProjectRepository {
  Future<Either<Failure, Project>> getProjectById(ProjectId id);
  Future<Either<Failure, void>> addParticipant(ProjectId id, UserId userId);
  Future<Either<Failure, void>> removeParticipant(ProjectId id, UserId userId);
  Future<Either<Failure, void>> updateParticipantRole(
    ProjectId id,
    UserId userId,
    UserRole role,
  );
  Stream<Either<Failure, List<UserId>>> observeProjectParticipants(
    ProjectId id,
  ); // optional for real-time
}
