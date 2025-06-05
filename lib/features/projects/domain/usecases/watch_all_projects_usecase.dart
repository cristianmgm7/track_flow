import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';

@lazySingleton
class WatchAllProjectsUseCase {
  final ProjectsRepository _repository;
  final SessionStorage _sessionManager;

  WatchAllProjectsUseCase(this._repository, this._sessionManager);

  Stream<Either<Failure, List<Project>>> call() async* {
    final userId = _sessionManager.getUserId();
    yield* _repository.watchRemoteProjects(UserId.fromUniqueString(userId!));
  }
}
