import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class ManageCollaboratorsRemoteDataSource {
  Future<Either<Failure, void>> selfJoinProjectWithProjectId({
    required ProjectId projectId,
    required UserId userId,
  });

  Future<Either<Failure, Project>> updateProject(Project project);
  Future<Either<Failure, List<UserProfile>>> getProjectCollaborators(
    Project project,
  );

  Future<Either<Failure, Unit>> leaveProject({
    required ProjectId projectId,
    required UserId userId,
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
  Future<Either<Failure, void>> selfJoinProjectWithProjectId({
    required ProjectId projectId,
    required UserId userId,
  }) async {
    try {
      final docRef = firestore.collection(ProjectDTO.collection).doc(projectId.value);
      await docRef.update({
        'collaborators': FieldValue.arrayUnion([userId.value]),
      });
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
  Future<Either<Failure, Project>> updateProject(Project project) async {
    try {
      final projectDto = ProjectDTO.fromDomain(project);
      await firestore
          .collection(ProjectDTO.collection)
          .doc(project.id.value)
          .update(projectDto.toJson());
      return right(project);
    } on FirebaseException catch (e) {
      return left(DatabaseFailure('Failed to update project: ${e.message}'));
    } catch (e) {
      return left(UnexpectedFailure('Unexpected error updating project'));
    }
  }

  @override
  Future<Either<Failure, List<UserProfile>>> getProjectCollaborators(
    Project project,
  ) async {
    try {
      final ids = project.collaborators.map((e) => e.userId.value).toList();

      final snapshot =
          await firestore
              .collection(UserProfileDTO.collection)
              .where(FieldPath.documentId, whereIn: ids)
              .get();

      final userProfiles =
          snapshot.docs
              .map((doc) => UserProfileDTO.fromJson(doc.data()).toDomain())
              .toList();

      return right(userProfiles);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> leaveProject({
    required ProjectId projectId,
    required UserId userId,
  }) async {
    try {
      await firestore
          .collection(ProjectDTO.collection)
          .doc(projectId.value)
          .update({
            'collaborators': FieldValue.arrayRemove([userId.value]),
          });
      return right(unit);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }
}
