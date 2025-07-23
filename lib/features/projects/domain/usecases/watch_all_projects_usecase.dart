import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/session/data/session_storage.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';

@lazySingleton
class WatchAllProjectsUseCase {
  final ProjectsRepository _projectsRepository;
  final SessionStorage _sessionStorage;

  WatchAllProjectsUseCase(this._projectsRepository, this._sessionStorage);

  Stream<Either<Failure, List<Project>>> call() async* {
    final userId = await _sessionStorage.getUserId();
    if (userId == null) {
      yield left(ServerFailure('No user found'));
      return;
    }
    final stream = _projectsRepository.watchLocalProjects(
      UserId.fromUniqueString(userId),
    );
    await for (final either in stream) {
      yield either.fold(
        (failure) => left(failure),
        (projects) => right(projects),
      );
    }
  }
}
