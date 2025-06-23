import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';

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
  final UserProfileRepository _repositoryUserProfile;
  final UserProfileRepository _userProfileRepository;

  LoadUserProfileCollaboratorsUseCase(
    this._repositoryUserProfile,
    this._userProfileRepository,
  );

  Future<Either<Failure, List<UserProfile>>> call(
    ProjectWithCollaborators params,
  ) async {
    final result = await _repositoryUserProfile.getUserProfilesByIds(
      params.project.collaborators.map((e) => e.id.value).toList(),
    );
    return await result.fold((failure) => left(failure), (profiles) async {
      await _userProfileRepository.cacheUserProfiles(profiles);
      return right(profiles);
    });
  }
}
