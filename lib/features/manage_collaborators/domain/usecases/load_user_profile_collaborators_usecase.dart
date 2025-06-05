import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

import 'package:equatable/equatable.dart';

@immutable
class ProjectWithCollaborators extends Equatable {
  final Project project;

  const ProjectWithCollaborators({required this.project});

  ProjectWithCollaborators copyWith({Project? project}) {
    return ProjectWithCollaborators(project: project ?? this.project);
  }

  @override
  List<Object?> get props => [project];
}

@lazySingleton
class LoadUserProfileCollaboratorsUseCase {
  final ManageCollaboratorsRepository _repository;

  LoadUserProfileCollaboratorsUseCase(this._repository);

  Future<Either<Failure, List<UserProfile>>> call(
    ProjectWithCollaborators params,
  ) async {
    return await _repository.getProjectCollaborators(
      params.project.id,
      params.project.collaborators,
    );
  }
}
