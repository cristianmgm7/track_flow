import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/entities/project_description.dart';
import 'package:trackflow/features/projects/domain/entities/project_name.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  @override
  Future<Either<Failure, Project>> fetchProjectById(ProjectId projectId) async {
    try {
      // TODO: Replace with real data source
      final dummyProject = Project(
        id: projectId,
        ownerId: UserId(),
        name: ProjectName('Demo Project'),
        description: ProjectDescription('Sample project'),
        createdAt: DateTime.now(),
      );
      return right(dummyProject);
    } catch (e) {
      return left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> leaveProject({
    required ProjectId projectId,
    required UserId userId,
  }) async {
    try {
      // TODO: Implement real logic
      return right(unit);
    } catch (e) {
      return left(UnexpectedFailure());
    }
  }
}
