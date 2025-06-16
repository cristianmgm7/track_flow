import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class ProjectDetailRemoteDataSource {
  Future<Either<Failure, Project>> getProjectById(ProjectId projectId);

  Future<Either<Failure, List<UserProfile>>> getProjectCollaborators(
    Project project,
  );

  Future<Either<Failure, Unit>> leaveProject({
    required ProjectId projectId,
    required UserId userId,
  });
}

@LazySingleton(as: ProjectDetailRemoteDataSource)
class ProjectDetailRemoteDatasourceImpl
    implements ProjectDetailRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProjectDetailRemoteDatasourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<Either<Failure, Project>> getProjectById(ProjectId projectId) async {
    return await _firestore
        .collection(ProjectDTO.collection)
        .doc(projectId.value)
        .get()
        .then((value) {
          if (value.exists) {
            return right(ProjectDTO.fromFirestore(value).toDomain());
          }
          return left(DatabaseFailure('Project not found'));
        });
  }

  @override
  Future<Either<Failure, List<UserProfile>>> getProjectCollaborators(
    Project project,
  ) async {
    try {
      final ids = project.collaborators.map((e) => e.userId.value).toList();

      final snapshot =
          await _firestore
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
      await _firestore
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
