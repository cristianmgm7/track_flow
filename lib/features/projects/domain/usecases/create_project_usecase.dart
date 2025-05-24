import 'package:injectable/injectable.dart';
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
  final UserId ownerId;
  final ProjectName name;
  final ProjectDescription description;

  const CreateProjectParams({
    required this.ownerId,
    required this.name,
    required this.description,
  });

  @override
  List<Object?> get props => [ownerId, name, description];
}

@lazySingleton
class CreateProjectUseCase {
  final ProjectsRepository _repository;

  CreateProjectUseCase(this._repository);

  Future<Either<Failure, Unit>> call(CreateProjectParams params) async {
    final project = Project(
      id: UniqueId(),
      ownerId: params.ownerId,
      name: params.name,
      description: params.description,
      createdAt: DateTime.now(),
    );
    return await _repository.createProject(project);
  }
}
