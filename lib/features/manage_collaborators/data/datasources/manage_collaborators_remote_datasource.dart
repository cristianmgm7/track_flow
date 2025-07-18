import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/manage_collaborators/data/models/collaborator_operation_dto.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';

abstract class ManageCollaboratorsRemoteDataSource {
  Future<Either<Failure, Unit>> selfJoinProjectWithProjectId(
    JoinProjectDto joinRequest,
  );

  Future<Either<Failure, ProjectDTO>> updateProject(ProjectDTO project);

  Future<Either<Failure, List<UserProfileDTO>>> getProjectCollaborators(
    GetCollaboratorsDto request,
  );

  Future<Either<Failure, Unit>> leaveProject(LeaveProjectDto leaveRequest);

  Future<Either<Failure, Unit>> updateCollaboratorRole({
    required String projectId,
    required String userId,
    required String newRole,
  });
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
  Future<Either<Failure, Unit>> selfJoinProjectWithProjectId(
    JoinProjectDto joinRequest,
  ) async {
    try {
      final docRef = firestore
          .collection(ProjectDTO.collection)
          .doc(joinRequest.projectId);
      await docRef.update({
        'collaborators': FieldValue.arrayUnion([joinRequest.userId]),
      });
      return right(unit);
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
  Future<Either<Failure, ProjectDTO>> updateProject(ProjectDTO project) async {
    try {
      await firestore
          .collection(ProjectDTO.collection)
          .doc(project.id)
          .update(project.toJson());
      return right(project);
    } on FirebaseException catch (e) {
      return left(DatabaseFailure('Failed to update project: ${e.message}'));
    } catch (e) {
      return left(UnexpectedFailure('Unexpected error updating project'));
    }
  }

  @override
  Future<Either<Failure, List<UserProfileDTO>>> getProjectCollaborators(
    GetCollaboratorsDto request,
  ) async {
    try {
      final snapshot =
          await firestore
              .collection(UserProfileDTO.collection)
              .where(FieldPath.documentId, whereIn: request.collaboratorIds)
              .get();

      final userProfiles =
          snapshot.docs
              .map((doc) => UserProfileDTO.fromJson(doc.data()))
              .toList();

      return right(userProfiles);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> leaveProject(
    LeaveProjectDto leaveRequest,
  ) async {
    try {
      await firestore
          .collection(ProjectDTO.collection)
          .doc(leaveRequest.projectId)
          .update({
            'collaborators': FieldValue.arrayRemove([leaveRequest.userId]),
          });
      return right(unit);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateCollaboratorRole({
    required String projectId,
    required String userId,
    required String newRole,
  }) async {
    try {
      final docRef = firestore.collection(ProjectDTO.collection).doc(projectId);
      await docRef.update({'collaboratorsRoles.$userId': newRole});
      return right(unit);
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
      return Left(
        DatabaseFailure('Failed to update collaborator role: ${e.message}'),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'An unexpected error occurred while updating collaborator role',
        ),
      );
    }
  }
}
