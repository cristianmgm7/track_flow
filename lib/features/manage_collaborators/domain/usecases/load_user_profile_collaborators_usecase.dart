import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

@immutable
class LoadCollaboratorsParams extends Equatable {
  final ProjectId projectId;
  final List<UserId> collaborators;

  const LoadCollaboratorsParams({
    required this.projectId,
    required this.collaborators,
  });

  @override
  List<Object?> get props => [projectId, collaborators];
}

@lazySingleton
class LoadUserProfileCollaboratorsUseCase {
  final ManageCollaboratorsRepository _repository;

  LoadUserProfileCollaboratorsUseCase(this._repository);

  Future<Either<Failure, List<UserProfile>>> call(
    LoadCollaboratorsParams params,
  ) async {
    return await _repository.getProjectCollaborators(
      params.projectId,
      params.collaborators,
    );
  }
}
