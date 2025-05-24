// import 'package:dartz/dartz.dart';
// import 'package:trackflow/core/entities/unique_id.dart';
// import 'package:trackflow/core/error/failures.dart';
// import 'package:trackflow/features/projects/domain/entities/project.dart';
// import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';

// class InMemoryProjectRepository implements ProjectRepository {
//   final Map<String, Project> _projects;

//   InMemoryProjectRepository({required List<Project> initialProjects})
//     : _projects = {
//         for (var project in initialProjects) project.id.value: project,
//       };

//   @override
//   Future<Either<Failure, Unit>> createProject(Project project) async {
//     _projects[project.id.value] = project;
//     return Right(unit);
//   }

//   @override
//   Future<Either<Failure, Unit>> updateProject(Project project) async {
//     if (_projects.containsKey(project.id.value)) {
//       _projects[project.id.value] = project;
//       return Right(unit);
//     }
//     return Left(DatabaseFailure('Project not found'));
//   }

//   @override
//   Future<Either<Failure, Unit>> deleteProject(UniqueId id) async {
//     _projects.remove(id.value);
//     return Right(unit);
//   }

//   @override
//   Future<Either<Failure, Project>> getProjectById(UniqueId id) async {
//     final project = _projects[id.value];
//     if (project != null) {
//       return Right(project);
//     }
//     return Left(DatabaseFailure('Project not found'));
//   }

//   @override
//   Future<Either<Failure, List<Project>>> getAllProjects() async {
//     return Right(_projects.values.toList());
//   }
// }
