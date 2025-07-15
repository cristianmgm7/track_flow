import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import '../models/project_dto.dart';

/// Abstract class defining the contract for remote project operations.
abstract class ProjectRemoteDataSource {
  Future<Either<Failure, ProjectDTO>> createProject(ProjectDTO project);

  Future<Either<Failure, Unit>> updateProject(ProjectDTO project);

  Future<Either<Failure, Unit>> deleteProject(String projectId);

  Future<Either<Failure, ProjectDTO>> getProjectById(String projectId);

  Future<Either<Failure, List<ProjectDTO>>> getUserProjects(String userId);
}

@LazySingleton(as: ProjectRemoteDataSource)
class ProjectsRemoteDatasSourceImpl implements ProjectRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProjectsRemoteDatasSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<Either<Failure, ProjectDTO>> createProject(ProjectDTO project) async {
    try {
      // Generate a new document reference with a unique ID.
      final docRef = _firestore.collection(ProjectDTO.collection).doc();

      // Create a new project DTO that includes the generated ID.
      final projectWithId = project.copyWith(id: docRef.id);

      // Write the DTO to Firestore.
      await docRef.set(projectWithId.toFirestore());

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
  Future<Either<Failure, Unit>> updateProject(ProjectDTO project) async {
    try {
      await _firestore
          .collection(ProjectDTO.collection)
          .doc(project.id)
          .update(project.toFirestore());
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
      return Left(DatabaseFailure('Failed to update project: ${e.message}'));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'An unexpected error occurred while updating the project',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProject(String projectId) async {
    try {
      await _firestore
          .collection(ProjectDTO.collection)
          .doc(projectId)
          .delete();
      return Right(unit);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Left(
          AuthenticationFailure(
            'You don\'t have permission to delete this project',
          ),
        );
      }
      return Left(DatabaseFailure('Failed to delete project: ${e.message}'));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'An unexpected error occurred while deleting the project',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, ProjectDTO>> getProjectById(String projectId) async {
    try {
      final docSnapshot =
          await _firestore
              .collection(ProjectDTO.collection)
              .doc(projectId)
              .get();

      if (docSnapshot.exists) {
        final project = ProjectDTO.fromFirestore(docSnapshot);
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
  Future<Either<Failure, List<ProjectDTO>>> getUserProjects(
    String userId,
  ) async {
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

      final allProjects = <String, ProjectDTO>{};

      for (var doc in ownedProjectsSnapshot.docs) {
        final project = ProjectDTO.fromFirestore(doc);
        allProjects[project.id] = project;
      }

      for (var doc in collaboratorProjectsSnapshot.docs) {
        final project = ProjectDTO.fromFirestore(doc);
        allProjects[project.id] = project;
      }

      return Right(allProjects.values.toList());
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get user projects: $e'));
    }
  }
}
