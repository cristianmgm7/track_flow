import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart';

abstract class ManageCollaboratorsRemoteDataSource {
  Future<Either<Failure, void>> addCollaboratorWithId(
    ProjectId projectId,
    UserId userId,
  );
  Future<Either<Failure, void>> selfJoinProjectWithProjectId({
    required String projectId,
    required String userId,
  });
  Future<Either<Failure, void>> removeCollaborator(
    ProjectId projectId,
    UserId userId,
  );
  Future<Either<Failure, void>> updateCollaboratorRole(
    ProjectId projectId,
    UserId userId,
    ProjectRole role,
  );
}

@LazySingleton(as: ManageCollaboratorsRemoteDataSource)
class ManageCollaboratorsRemoteDataSourceImpl
    extends ManageCollaboratorsRemoteDataSource {
  final UserProfileRemoteDataSource userProfileRemoteDataSource;
  final FirebaseFirestore firestore;

  ManageCollaboratorsRemoteDataSourceImpl({
    required this.userProfileRemoteDataSource,
    required this.firestore,
  });

  @override
  Future<Either<Failure, void>> addCollaboratorWithId(
    ProjectId projectId,
    UserId collaboratorId,
  ) async {
    try {
      final projectRef = firestore
          .collection(ProjectDTO.collection)
          .doc(projectId.value);

      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(projectRef);
        if (!snapshot.exists) {
          throw Exception("Project not found");
        }

        final projectDTO = ProjectDTO.fromFirestore(snapshot);
        final updatedCollaborators = [
          ...projectDTO.collaborators,
          collaboratorId.value,
        ];

        final updatedProjectDTO = projectDTO.copyWith(
          collaborators: updatedCollaborators,
        );

        transaction.update(projectRef, updatedProjectDTO.toFirestore());
      });

      return right(null);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeCollaborator(
    ProjectId projectId,
    UserId collaboratorId,
  ) async {
    try {
      final projectRef = firestore
          .collection(ProjectDTO.collection)
          .doc(projectId.value);

      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(projectRef);
        if (!snapshot.exists) {
          throw Exception("Project not found");
        }

        final projectDTO = ProjectDTO.fromFirestore(snapshot);
        final updatedCollaborators =
            projectDTO.collaborators
                .where((id) => id != collaboratorId.value)
                .toList();

        final updatedProjectDTO = projectDTO.copyWith(
          collaborators: updatedCollaborators,
        );

        transaction.update(projectRef, updatedProjectDTO.toFirestore());
      });

      return right(null);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> selfJoinProjectWithProjectId({
    required String projectId,
    required String userId,
  }) async {
    try {
      final docRef = firestore.collection(ProjectDTO.collection).doc(projectId);
      await docRef.update({
        'collaborators': FieldValue.arrayUnion([userId]),
      });
      debugPrint('Collaborator added: $userId');
      return right(null);
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

  @override
  Future<Either<Failure, void>> updateCollaboratorRole(
    ProjectId projectId,
    UserId userId,
    ProjectRole role,
  ) async {
    try {
      final projectRef = firestore
          .collection(ProjectDTO.collection)
          .doc(projectId.value);

      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(projectRef);
        if (!snapshot.exists) {
          throw Exception("Project not found");
        }

        final projectDTO = ProjectDTO.fromFirestore(snapshot);
        final updatedCollaborators =
            projectDTO.collaborators.map((collaborator) {
              if (collaborator == userId.value) {
                return collaborator;
              }
              return collaborator;
            }).toList();

        final updatedProjectDTO = projectDTO.copyWith(
          collaborators: updatedCollaborators,
        );

        transaction.update(projectRef, updatedProjectDTO.toFirestore());
      });

      return right(null);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }
}
