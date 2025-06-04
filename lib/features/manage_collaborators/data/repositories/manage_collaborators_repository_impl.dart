import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/user_role.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/network/network_info.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart';
import 'package:trackflow/features/manage_collaborators/data/datasources/manage_collabolators_remote_datasource.dart';

@LazySingleton(as: ManageCollaboratorsRepository)
class ManageCollaboratorsRepositoryImpl
    implements ManageCollaboratorsRepository {
  final ManageCollaboratorsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ManageCollaboratorsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<UserProfile>>> getProjectCollaborators(
    ProjectId projectId,
    List<UserId> collaborators,
  ) async {
    final hasConnected = await networkInfo.isConnected;
    if (!hasConnected) {
      return left(DatabaseFailure('No internet connection'));
    }
    return await remoteDataSource.getProjectCollaborators(
      projectId,
      collaborators,
    );
  }

  @override
  Future<Either<Failure, void>> addCollaboratorWithUserId(
    ProjectId projectId,
    UserId collaboratorId,
  ) async {
    final hasConnected = await networkInfo.isConnected;
    if (!hasConnected) {
      return left(DatabaseFailure('No internet connection'));
    }
    return await remoteDataSource.addCollaboratorWithUserId(
      projectId,
      collaboratorId,
    );
  }

  @override
  Future<Either<Failure, void>> removeCollaborator(
    ProjectId projectId,
    UserId collaboratorId,
  ) async {
    final hasConnected = await networkInfo.isConnected;
    if (!hasConnected) {
      return left(DatabaseFailure('No internet connection'));
    }
    return await remoteDataSource.removeCollaborator(projectId, collaboratorId);
  }

  @override
  Future<Either<Failure, void>> updateCollaboratorRole(
    ProjectId projectId,
    UserId collaboratorId,
    UserRole role,
  ) async {
    return await remoteDataSource.updateCollaboratorRole(
      projectId,
      collaboratorId,
      role,
    );
  }
}
