import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

@LazySingleton(as: ProjectRepository)
class ProjectDetailRepositoryImpl implements ProjectRepository {
  @override
  Future<Either<Failure, Project>> getProjectById(ProjectId id) async {
    try {
      // Simulate fetching project by ID
      final project = Project(id: id, name: 'Sample Project');
      return Right(project);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addParticipant(
    ProjectId id,
    UserId userId,
  ) async {
    try {
      // Simulate adding a participant
      return Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> removeParticipant(
    ProjectId id,
    UserId userId,
  ) async {
    try {
      // Simulate removing a participant
      return Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateParticipantRole(
    ProjectId id,
    UserId userId,
    UserRole role,
  ) async {
    try {
      // Simulate updating a participant's role
      return Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, List<UserId>>> observeProjectParticipants(
    ProjectId id,
  ) async* {
    try {
      // Simulate observing project participants
      yield Right([UserId('user1'), UserId('user2')]);
    } catch (e) {
      yield Left(ServerFailure());
    }
  }
}
