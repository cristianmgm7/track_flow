import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import '../models/project_dto.dart';

/// Abstract class defining the contract for remote project operations.
abstract class ProjectRemoteDataSource {
  Future<Either<Failure, ProjectDTO>> createProject(ProjectDTO project);

  Future<Either<Failure, Unit>> updateProject(ProjectDTO project);

  Future<Either<Failure, Unit>> deleteProject(String projectId);

  Future<Either<Failure, ProjectDTO>> getProjectById(String projectId);

  Future<Either<Failure, List<ProjectDTO>>> getUserProjects(String userId);

  /// Get projects modified since a specific timestamp (for incremental sync)
  Future<Either<Failure, List<ProjectDTO>>> getUserProjectsModifiedSince(
    DateTime since,
    String userId,
  );
}

@LazySingleton(as: ProjectRemoteDataSource)
class ProjectsRemoteDatasSourceImpl implements ProjectRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProjectsRemoteDatasSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<Either<Failure, ProjectDTO>> createProject(ProjectDTO project) async {
    try {
      // Use the existing project ID to maintain consistency with offline storage
      final docRef = _firestore
          .collection(ProjectDTO.collection)
          .doc(project.id);

      // Write the DTO to Firestore with the original ID
      await docRef.set(project.toFirestore());

      return Right(project);
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
      AppLogger.network(
        'Getting projects for user: $userId',
        url: 'firestore://projects',
      );

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

      AppLogger.network('Executing Firestore queries for user projects');

      // Wait for both queries to complete
      final results = await Future.wait([
        ownedProjectsFuture,
        collaboratorProjectsFuture,
      ]);

      final ownedProjects = results[0];
      final collaboratorProjects = results[1];

      AppLogger.network('Found ${ownedProjects.docs.length} owned projects');
      AppLogger.network(
        'Found ${collaboratorProjects.docs.length} collaborator projects',
      );

      // Combine and deduplicate projects
      final allProjects = <ProjectDTO>[];
      final seenIds = <String>{};

      // Add owned projects
      for (final doc in ownedProjects.docs) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          allProjects.add(ProjectDTO.fromFirestore(doc));
        }
      }

      // Add collaborator projects
      for (final doc in collaboratorProjects.docs) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          allProjects.add(ProjectDTO.fromFirestore(doc));
        }
      }

      AppLogger.network('Total unique projects found: ${allProjects.length}');
      return Right(allProjects);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProjectDTO>>> getUserProjectsModifiedSince(
    DateTime since,
    String userId,
  ) async {
    try {
      AppLogger.network(
        'Getting projects modified since ${since.toIso8601String()} for user: $userId',
        url: 'firestore://projects',
      );

      // Query for owned projects modified since timestamp
      final ownedProjectsFuture =
          _firestore
              .collection(ProjectDTO.collection)
              .where('ownerId', isEqualTo: userId)
              .where('updatedAt', isGreaterThan: since)
              .get();

      // Query for collaborator projects (both modified and new)
      // Get all projects where user is collaborator, then filter locally
      final collaboratorProjectsFuture =
          _firestore
              .collection(ProjectDTO.collection)
              .where('collaboratorIds', arrayContains: userId)
              .get();

      AppLogger.network(
        'Executing incremental Firestore queries for user projects',
      );

      // Wait for both queries to complete
      final results = await Future.wait([
        ownedProjectsFuture,
        collaboratorProjectsFuture,
      ]);

      final ownedProjects = results[0];
      final allCollaboratorProjects = results[1];

      AppLogger.network(
        'Found ${ownedProjects.docs.length} modified owned projects',
      );
      AppLogger.network(
        'Found ${allCollaboratorProjects.docs.length} total collaborator projects',
      );

      // Filter collaborator projects locally (modified or new since timestamp)
      final relevantCollaboratorProjects =
          allCollaboratorProjects.docs.where((doc) {
            final data = doc.data();
            final updatedAt = data['updatedAt'];
            final createdAt = data['createdAt'];

            // Include if modified since timestamp OR created since timestamp
            return (updatedAt != null && updatedAt.toDate().isAfter(since)) ||
                (createdAt != null && createdAt.toDate().isAfter(since));
          }).toList();

      AppLogger.network(
        'Found ${relevantCollaboratorProjects.length} relevant collaborator projects',
      );

      // Combine and deduplicate projects
      final modifiedProjects = <ProjectDTO>[];
      final seenIds = <String>{};

      // Add owned projects
      for (final doc in ownedProjects.docs) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          modifiedProjects.add(ProjectDTO.fromFirestore(doc));
        }
      }

      // Add relevant collaborator projects
      for (final doc in relevantCollaboratorProjects) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          modifiedProjects.add(ProjectDTO.fromFirestore(doc));
        }
      }

      AppLogger.network('Total projects found: ${modifiedProjects.length}');
      return Right(modifiedProjects);
    } catch (e) {
      return Left(ServerFailure('Failed to get modified projects: $e'));
    }
  }
}
