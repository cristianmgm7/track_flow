import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class WatchAllProjectsUseCase {
  final ProjectsRepository _repository;
  final AuthRepository _authRepository;

  WatchAllProjectsUseCase(this._repository, this._authRepository);

  Stream<Either<Failure, List<Project>>> call() async* {
    final userIdResult = await _authRepository.getSignedInUserId();
    yield* userIdResult.fold((failure) => Stream.value(left(failure)), (
      userIdString,
    ) {
      final userId = UserId.fromUniqueString(userIdString);
      return _repository.watchRemoteProjects(userId);
    });
  }
}
