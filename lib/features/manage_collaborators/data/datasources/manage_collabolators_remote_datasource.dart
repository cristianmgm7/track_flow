import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart';

abstract class ManageCollaboratorsRemoteDataSource {
  Future<Either<Failure, void>> selfJoinProjectWithProjectId({
    required String projectId,
    required String userId,
  });

  Future<Either<Failure, Project>> updateProject(Project project);
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
    required String projectId,
    required String userId,
  }) async {
    try {
      final docRef = firestore.collection(ProjectDTO.collection).doc(projectId);
      await docRef.update({
        'collaborators': FieldValue.arrayUnion([userId]),
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
}
