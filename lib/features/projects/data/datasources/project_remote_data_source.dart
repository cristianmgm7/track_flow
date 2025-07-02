import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import '../../domain/entities/project.dart';
import '../models/project_dto.dart';

/// Abstract class defining the contract for remote project operations.
abstract class ProjectRemoteDataSource {
  Future<Either<Failure, Project>> createProject(Project project);

  Future<Either<Failure, Unit>> updateProject(Project project);

  Future<Either<Failure, Unit>> deleteProject(UniqueId id);

  Future<Either<Failure, Project>> getProjectById(ProjectId projectId);

  Future<Either<Failure, List<Project>>> getUserProjects(String userId);
}

@LazySingleton(as: ProjectRemoteDataSource)
class ProjectsRemoteDatasSourceImpl implements ProjectRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProjectsRemoteDatasSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<Either<Failure, Project>> createProject(Project project) async {
    try {
      // Generate a new document reference with a unique ID.
      final docRef = _firestore.collection(ProjectDTO.collection).doc();

      // Create a new project object that includes the generated ID.
      final projectWithId = project.copyWith(
        id: ProjectId.fromUniqueString(docRef.id),
      );

      // Convert the final project object to a DTO and write it to Firestore.
      final dto = ProjectDTO.fromDomain(projectWithId);
      await docRef.set(dto.toFirestore());

      return Right(projectWithId);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Left(
          AuthenticationFailure(
            'You don\'t have permission to create projects',
          ),
        );
      }
      return Left(DatabaseFailure('Failed to create project: ${e.message}'));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'An unexpected error occurred while creating the project',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProject(Project project) async {
    try {
      final dto = ProjectDTO.fromDomain(project);
      await _firestore
          .collection(ProjectDTO.collection)
          .doc(project.id.value)
          .update(dto.toFirestore());
      return Right(unit);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Left(
          AuthenticationFailure(
            'You don\'t have permission to update this project',
          ),
        );
      }
      if (e.code == 'not-found') {
        return Left(DatabaseFailure('Project not found'));
      }
      return Left(DatabaseFailure('Failed to update project: \\${e.message}'));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'An unexpected error occurred while updating the project',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProject(UniqueId id) async {
    try {
      await _firestore.collection(ProjectDTO.collection).doc(id.value).delete();
      return Right(unit);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Left(
          AuthenticationFailure(
            'You don\'t have permission to delete this project',
          ),
        );
      }
      return Left(DatabaseFailure('Failed to delete project: \\${e.message}'));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'An unexpected error occurred while deleting the project',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Project>> getProjectById(ProjectId projectId) async {
    try {
      final docSnapshot = await _firestore
          .collection(ProjectDTO.collection)
          .doc(projectId.value)
          .get();
      
      if (docSnapshot.exists) {
        final project = ProjectDTO.fromFirestore(docSnapshot).toDomain();
        return Right(project);
      } else {
        return Left(DatabaseFailure('Project not found'));
      }
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Left(
          AuthenticationFailure(
            'You don\'t have permission to access this project',
          ),
        );
      }
      if (e.code == 'not-found') {
        return Left(DatabaseFailure('Project not found'));
      }
      return Left(DatabaseFailure('Failed to get project: ${e.message}'));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'An unexpected error occurred while getting the project',
        ),
      );
    }
  }

  /// Get all projects for a user.for offline first
  @override
  Future<Either<Failure, List<Project>>> getUserProjects(String userId) async {
    try {
      // Query for projects owned by the user
      final ownedProjectsFuture =
          _firestore
              .collection(ProjectDTO.collection)
              .where('ownerId', isEqualTo: userId)
              .get();

      // Query for projects where the user is a collaborator
      final collaboratorProjectsFuture =
          _firestore
              .collection(ProjectDTO.collection)
              .where('collaboratorIds', arrayContains: userId)
              .get();

      final results = await Future.wait([
        ownedProjectsFuture,
        collaboratorProjectsFuture,
      ]);

      final ownedProjectsSnapshot = results[0];
      final collaboratorProjectsSnapshot = results[1];

      final allProjects = <String, Project>{};

      for (var doc in ownedProjectsSnapshot.docs) {
        final project = ProjectDTO.fromFirestore(doc).toDomain();
        allProjects[project.id.value] = project;
      }

      for (var doc in collaboratorProjectsSnapshot.docs) {
        final project = ProjectDTO.fromFirestore(doc).toDomain();
        allProjects[project.id.value] = project;
      }

      return Right(allProjects.values.toList());
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get user projects: $e'));
    }
  }
}
