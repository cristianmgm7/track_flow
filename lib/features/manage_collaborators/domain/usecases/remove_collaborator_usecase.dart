import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart';

@immutable
class RemoveCollaboratorParams extends Equatable {
  final ProjectId projectId;
  final UserId collaboratorId;

  const RemoveCollaboratorParams({
    required this.projectId,
    required this.collaboratorId,
  });

  @override
  List<Object?> get props => [projectId, collaboratorId];
}

@lazySingleton
class RemoveCollaboratorUseCase {
  final ManageCollaboratorsRepository _repository;

  RemoveCollaboratorUseCase(this._repository);

  Future<Either<Failure, void>> call(RemoveCollaboratorParams params) async {
    return await _repository.removeCollaborator(
      params.projectId,
      params.collaboratorId,
    );
  }
}
