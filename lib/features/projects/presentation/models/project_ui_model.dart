import 'package:equatable/equatable.dart';
import '../../domain/entities/project.dart';

/// UI model wrapping Project domain entity with unwrapped primitives
class ProjectUiModel extends Equatable {
  final Project project; // Composition pattern

  // Unwrapped primitives for easy UI access
  final String id;
  final String name;
  final String description;
  final String? coverUrl;
  final String? coverLocalPath;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  final int collaboratorCount;

  const ProjectUiModel({
    required this.project,
    required this.id,
    required this.name,
    required this.description,
    this.coverUrl,
    this.coverLocalPath,
    required this.createdAt,
    this.updatedAt,
    required this.isDeleted,
    required this.collaboratorCount,
  });

  factory ProjectUiModel.fromDomain(Project project) {
    return ProjectUiModel(
      project: project,
      id: project.id.value,
      name: project.name.value.getOrElse(() => ''),
      description: project.description.value.getOrElse(() => ''),
      coverUrl: project.coverUrl,
      coverLocalPath: project.coverLocalPath,
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
      isDeleted: project.isDeleted,
      collaboratorCount: project.collaborators.length,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    coverUrl,
    coverLocalPath,
    createdAt,
    updatedAt,
    isDeleted,
    collaboratorCount,
  ];
}
