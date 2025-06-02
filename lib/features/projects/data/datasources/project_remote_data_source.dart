import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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

  Future<Either<Failure, List<Project>>> getAllProjects();

  Future<Either<Failure, Project>> getProjectById(String id);

  Future<Either<Failure, Unit>> addCollaborator({
    required String projectId,
    required String userId,
  });
}

@LazySingleton(as: ProjectRemoteDataSource)
class ProjectsRemoteDatasSourceImpl implements ProjectRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProjectsRemoteDatasSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<Either<Failure, Project>> createProject(Project project) async {
    final dto = ProjectDTO.fromDomain(project);
    try {
      final docRef = await _firestore
          .collection(ProjectDTO.collection)
          .add(dto.toFirestore());
      final projectWithId = project.copyWith(
        id: ProjectId.fromUniqueString(docRef.id),
      );
      await docRef.update({'id': docRef.id});
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
  Future<Either<Failure, List<Project>>> getAllProjects() async {
    try {
      final querySnapshot =
          await _firestore.collection(ProjectDTO.collection).get();
      final projects =
          querySnapshot.docs
              .map((doc) => ProjectDTO.fromFirestore(doc).toDomain())
              .toList();
      return Right(projects);
    } on FirebaseException catch (e) {
      return Left(DatabaseFailure('Failed to fetch projects: \\${e.message}'));
    } catch (e) {
      return Left(UnexpectedFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Project>> getProjectById(String id) async {
    try {
      final doc =
          await _firestore.collection(ProjectDTO.collection).doc(id).get();
      if (!doc.exists) {
        return Left(DatabaseFailure('Project not found'));
      }
      final project = ProjectDTO.fromFirestore(doc).toDomain();
      return Right(project);
    } on FirebaseException catch (e) {
      return Left(DatabaseFailure('Failed to fetch project: ${e.message}'));
    } catch (e) {
      return Left(UnexpectedFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Unit>> addCollaborator({
    required String projectId,
    required String userId,
  }) async {
    try {
      final docRef = _firestore
          .collection(ProjectDTO.collection)
          .doc(projectId);
      await docRef.update({
        'collaborators': FieldValue.arrayUnion([userId]),
      });
      debugPrint('Collaborator added: $userId');
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
      return Left(DatabaseFailure('Failed to add collaborator: ${e.message}'));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'An unexpected error occurred while adding collaborator',
        ),
      );
    }
  }
}
