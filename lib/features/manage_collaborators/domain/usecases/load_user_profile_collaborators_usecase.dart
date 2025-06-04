import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

import 'package:equatable/equatable.dart';

@immutable
class ProjectWithCollaborators extends Equatable {
  final ProjectId projectId;
  final List<UserProfile> collaborators;

  const ProjectWithCollaborators({
    required this.projectId,
    required this.collaborators,
  });

  ProjectWithCollaborators copyWith({
    ProjectId? projectId,
    List<UserProfile>? collaborators,
  }) {
    return ProjectWithCollaborators(
      projectId: projectId ?? this.projectId,
      collaborators: collaborators ?? this.collaborators,
    );
  }

  @override
  List<Object?> get props => [projectId, collaborators];
}

@lazySingleton
class LoadUserProfileCollaboratorsUseCase {
  final ManageCollaboratorsRepository _repository;

  LoadUserProfileCollaboratorsUseCase(this._repository);

  Future<Either<Failure, List<UserProfile>>> call(
    ProjectWithCollaborators params,
  ) async {
    return await _repository.getProjectCollaborators(
      params.projectId,
      params.collaborators.map((e) => e.id).toList(),
    );
  }
}
