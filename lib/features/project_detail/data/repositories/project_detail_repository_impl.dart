import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/network/network_info.dart';
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/project_detail/data/datasource/project_detail_remote_datasource.dart';

@LazySingleton(as: ProjectRepository)
class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectDetailRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProjectRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Project>> fetchProjectDetails(
    ProjectId projectId,
  ) async {
    final hasConnected = await networkInfo.isConnected;
    if (hasConnected) {
      final failureOrProject = await remoteDataSource.fetchProjectDetails(
        projectId,
      );
      return failureOrProject.fold(
        (failure) => Left(failure),
        (project) => Right(project),
      );
    } else {
      return Left(DatabaseFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Unit>> leaveProject({
    required ProjectId projectId,
    required UserId userId,
  }) async {
    final hasConnected = await networkInfo.isConnected;
    if (hasConnected) {
      final failureOrUnit = await remoteDataSource.leaveProject(
        projectId: projectId,
        userId: userId,
      );
      return failureOrUnit.fold(
        (failure) => Left(failure),
        (unit) => Right(unit),
      );
    } else {
      return Left(DatabaseFailure('No internet connection'));
    }
  }
}
