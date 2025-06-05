import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/user_creative_role.dart';
import 'package:trackflow/core/entities/user_role.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/entities/project_name.dart';
import 'package:trackflow/features/projects/domain/entities/project_description.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class CreateProjectParams extends Equatable {
  final ProjectName name;
  final ProjectDescription description;

  const CreateProjectParams({required this.name, required this.description});

  @override
  List<Object?> get props => [name, description];
}

@lazySingleton
class CreateProjectUseCase {
  final ProjectsRepository _repository;
  final SessionStorage _sessionStorage;

  CreateProjectUseCase(this._repository, this._sessionStorage);

  Future<Either<Failure, Project>> call(CreateProjectParams params) async {
    final userId = _sessionStorage.getUserId() ?? '';
    return await _repository.createProject(
      Project(
        id: ProjectId(),
        ownerId: UserId.fromUniqueString(userId),
        name: params.name,
        description: params.description,
        createdAt: DateTime.now(),
        collaborators: [UserId.fromUniqueString(userId)],
        roles: {UserId.fromUniqueString(userId): UserRole.owner},
        members: {UserId.fromUniqueString(userId): UserCreativeRole.musician},
      ),
    );
  }
}
