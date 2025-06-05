import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/network/network_info.dart';
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/project_detail/data/datasource/project_detail_remote_datasource.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

@LazySingleton(as: ProjectDetailRepository)
class ProjectDetailRepositoryImpl implements ProjectDetailRepository {
  final ProjectDetailRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProjectDetailRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  @override
  Future<Either<Failure, List<UserProfile>>> getUserProfileCollaborators(
    Project project,
  ) async {
    final hasConnected = await networkInfo.isConnected;
    if (!hasConnected) {
      return left(DatabaseFailure('No internet connection'));
    }
    final failureOrUserProfiles = await remoteDataSource
        .getProjectCollaborators(project.id, project.collaborators);
    return failureOrUserProfiles.fold(
      (failure) => Left(failure),
      (userProfiles) => Right(userProfiles),
    );
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
