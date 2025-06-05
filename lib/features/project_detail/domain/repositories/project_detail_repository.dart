import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class ProjectDetailRepository {
  Future<Either<Failure, List<UserProfile>>> getUserProfileCollaborators(
    Project project,
  );

  Future<Either<Failure, Unit>> leaveProject({
    required ProjectId projectId,
    required UserId userId,
  });
}
