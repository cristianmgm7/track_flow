import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../models/project_dto.dart';

/// Implementation of [ProjectRepository] using Firestore as the data source.
class FirestoreProjectRepository implements ProjectRepository {
  final FirebaseFirestore _firestore;

  FirestoreProjectRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, Project>> createProject(Project project) async {
    try {
      final dto = ProjectDTO.fromEntity(project);
      final docRef = await _firestore
          .collection(ProjectDTO.collection)
          .add(dto.toFirestore());

      return Right(project.copyWith(id: docRef.id));
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Left(
          AuthenticationFailure(
            message: 'You don\'t have permission to create projects',
          ),
        );
      }
      return Left(
        DatabaseFailure(message: 'Failed to create project: ${e.message}'),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'An unexpected error occurred while creating the project',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Project>> updateProject(Project project) async {
    try {
      final dto = ProjectDTO.fromEntity(project);
      await _firestore
          .collection(ProjectDTO.collection)
          .doc(project.id)
          .update(dto.toFirestore());

      return Right(project);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Left(
          AuthenticationFailure(
            message: 'You don\'t have permission to update this project',
          ),
        );
      }
      if (e.code == 'not-found') {
        return Left(DatabaseFailure(message: 'Project not found'));
      }
      return Left(
        DatabaseFailure(message: 'Failed to update project: ${e.message}'),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'An unexpected error occurred while updating the project',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject(String projectId) async {
    try {
      await _firestore
          .collection(ProjectDTO.collection)
          .doc(projectId)
          .delete();
      return const Right(null);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Left(
          AuthenticationFailure(
            message: 'You don\'t have permission to delete this project',
          ),
        );
      }
      return Left(
        DatabaseFailure(message: 'Failed to delete project: ${e.message}'),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'An unexpected error occurred while deleting the project',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Project>> getProjectById(String projectId) async {
    try {
      final doc =
          await _firestore
              .collection(ProjectDTO.collection)
              .doc(projectId)
              .get();

      if (!doc.exists) {
        return Left(DatabaseFailure(message: 'Project not found'));
      }

      return Right(ProjectDTO.fromFirestore(doc).toEntity());
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Left(
          AuthenticationFailure(
            message: 'You don\'t have permission to access this project',
          ),
        );
      }
      return Left(
        DatabaseFailure(message: 'Failed to fetch project: ${e.message}'),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'An unexpected error occurred while fetching the project',
        ),
      );
    }
  }

  @override
  Either<Failure, Stream<List<Project>>> getUserProjects(String userId) {
    try {
      final stream = _firestore
          .collection(ProjectDTO.collection)
          .where(ProjectDTO.fieldUserId, isEqualTo: userId)
          .orderBy(ProjectDTO.fieldCreatedAt, descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => ProjectDTO.fromFirestore(doc).toEntity())
                    .toList(),
          );

      return Right(stream);
    } on FirebaseException catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Failed to setup projects stream: ${e.message}',
        ),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message:
              'An unexpected error occurred while setting up projects stream',
        ),
      );
    }
  }

  @override
  Either<Failure, Stream<List<Project>>> getUserProjectsByStatus(
    String userId,
    String status,
  ) {
    try {
      final stream = _firestore
          .collection(ProjectDTO.collection)
          .where(ProjectDTO.fieldUserId, isEqualTo: userId)
          .where(ProjectDTO.fieldStatus, isEqualTo: status)
          .orderBy(ProjectDTO.fieldCreatedAt, descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => ProjectDTO.fromFirestore(doc).toEntity())
                    .toList(),
          );

      return Right(stream);
    } on FirebaseException catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Failed to setup projects stream: ${e.message}',
        ),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message:
              'An unexpected error occurred while setting up projects stream',
        ),
      );
    }
  }
}
