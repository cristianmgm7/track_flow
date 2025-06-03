import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/entities/project_description.dart';
import 'package:trackflow/features/projects/domain/entities/project_name.dart';

abstract class ProjectDetailRemoteDataSource {
  Future<Either<Failure, Project>> fetchProjectById(ProjectId id);
  Future<Either<Failure, void>> addProjectParticipant(
    ProjectId id,
    UserId userId,
  );
  Future<Either<Failure, void>> removeProjectParticipant(
    ProjectId id,
    UserId userId,
  );
  Future<Either<Failure, void>> updateProjectParticipantRole(
    ProjectId id,
    UserId userId,
    UserRole role,
  );
}

@LazySingleton(as: ProjectDetailRemoteDataSource)
class ProjectDetailRemoteDataSourceImpl
    implements ProjectDetailRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProjectDetailRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<Either<Failure, Project>> fetchProjectById(ProjectId id) async {
    try {
      // Simulate fetching project by ID from remote source
      final project = Project(
        id: id,
        name: ProjectName('Sample Project'),
        description: ProjectDescription('Sample Description'),
        ownerId: UserId.fromUniqueString('ownerId'),
        createdAt: DateTime.now(),
        collaborators: [],
      );
      return Right(project);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addProjectParticipant(
    ProjectId id,
    UserId userId,
  ) async {
    try {
      // Simulate adding a participant to a project in remote source
      return Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeProjectParticipant(
    ProjectId id,
    UserId userId,
  ) async {
    try {
      // Simulate removing a participant from a project in remote source
      return Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProjectParticipantRole(
    ProjectId id,
    UserId userId,
    UserRole role,
  ) async {
    try {
      // Simulate updating a participant's role in a project in remote source
      return Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
