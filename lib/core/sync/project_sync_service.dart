import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';

@injectable
class ProjectSyncService {
  final ProjectsRepository _repository;
  final ProjectsLocalDataSource _localDataSource;

  StreamSubscription? _subscription;

  ProjectSyncService({
    required ProjectsRepository repository,
    required ProjectsLocalDataSource localDataSource,
  }) : _repository = repository,
       _localDataSource = localDataSource;

  void start(UserId userId) {
    _subscription = _repository.watchLocalProjects(userId).listen((either) {
      either.fold((failure) => debugPrint('Sync error: $failure'), (projects) {
        for (final project in projects) {
          _localDataSource.cacheProject(ProjectDTO.fromDomain(project));
        }
      });
    });
  }

  void stop() {
    _subscription?.cancel();
  }
}
