import 'package:injectable/injectable.dart';
import 'package:trackflow/features/projects/domain/entities/project_collaborator.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class CreateProjectParams extends Equatable {
  final ProjectName name;

  const CreateProjectParams({required this.name});

  @override
  List<Object?> get props => [name];
}

@lazySingleton
class CreateProjectUseCase {
  final ProjectsRepository _projectsRepository;
  final SessionStorage _sessionStorage;

  CreateProjectUseCase(this._projectsRepository, this._sessionStorage);

  Future<Either<Failure, Project>> call(CreateProjectParams params) async {
    final userId = (await _sessionStorage.getUserId()) ?? '';
    return await _projectsRepository.createProject(
      Project(
        id: ProjectId(),
        ownerId: UserId.fromUniqueString(userId),
        name: params.name,
        description: ProjectDescription.empty(),
        createdAt: DateTime.now(),
        collaborators: [
          ProjectCollaborator.create(
            userId: UserId.fromUniqueString(userId),
            role: ProjectRole.owner,
          ),
        ],
      ),
    );
  }
}
