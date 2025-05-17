import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import '../../domain/entities/project.dart';
import '../models/project_dto.dart';

/// Abstract class defining the contract for remote project operations.
abstract class ProjectRemoteDataSource {
  /// Creates a new project in the remote database.
  Future<Either<Failure, Unit>> createProject(Project project);

  /// Updates an existing project in the remote database.
  Future<Either<Failure, Unit>> updateProject(Project project);

  /// Deletes a project from the remote database.
  Future<Either<Failure, Unit>> deleteProject(UniqueId id);
}

/// Implementation of [ProjectRemoteDataSource] using Firestore.
class FirestoreProjectDataSource implements ProjectRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreProjectDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, Unit>> createProject(Project project) async {
    try {
      final dto = ProjectDTO.fromDomain(project);
      final docRef = await _firestore
          .collection(ProjectDTO.collection)
          .add(dto.toFirestore());
      // Optionally update the project with the new id if needed
      // final createdProject = project.copyWith(id: UniqueId.fromUniqueString(docRef.id));
      return Right(unit);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Left(
          AuthenticationFailure(
            'You don\'t have permission to create projects',
          ),
        );
      }
      return Left(DatabaseFailure('Failed to create project: \\${e.message}'));
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
}
