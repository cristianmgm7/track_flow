import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/entities/user_role.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class ManageCollaboratorsRemoteDataSource {
  Future<Either<Failure, List<UserProfile>>> getProjectCollaborators(
    ProjectId projectId,
    List<UserId> collaborators,
  );
  Future<Either<Failure, void>> addCollaboratorWithUserId(
    ProjectId projectId,
    UserId userId,
  );
  Future<Either<Failure, void>> removeCollaborator(
    ProjectId projectId,
    UserId userId,
  );
  Future<Either<Failure, void>> updateCollaboratorRole(
    ProjectId projectId,
    UserId userId,
    UserRole role,
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
  Future<Either<Failure, List<UserProfile>>> getProjectCollaborators(
    ProjectId projectId,
    List<UserId> collaborators,
  ) async {
    try {
      final ids = collaborators.map((e) => e.value).toList();

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
  Future<Either<Failure, void>> addCollaboratorWithUserId(
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
  Future<Either<Failure, void>> updateCollaboratorRole(
    ProjectId projectId,
    UserId userId,
    UserRole role,
  ) {
    // TODO: implement updateCollaboratorRole
    throw UnimplementedError();
  }
}
