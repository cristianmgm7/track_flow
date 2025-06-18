import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/network/network_info.dart';
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/project_detail/data/datasource/project_detail_remote_datasource.dart';

@LazySingleton(as: ProjectDetailRepository)
class ProjectDetailRepositoryImpl implements ProjectDetailRepository {
  final ProjectDetailRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProjectDetailRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  @override
  Future<Either<Failure, Project>> getProjectById(ProjectId projectId) async {
    final hasConnected = await networkInfo.isConnected;
    if (!hasConnected) {
      return left(DatabaseFailure('No internet connection'));
    }
    return await remoteDataSource.getProjectById(projectId);
  }
}
