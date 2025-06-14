import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class ProjectDetailRemoteDataSource {
  Future<Either<Failure, List<UserProfile>>> getProjectCollaborators(
    ProjectId projectId,
    List<UserId> collaborators,
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
  Future<Either<Failure, List<UserProfile>>> getProjectCollaborators(
    ProjectId projectId,
    List<UserId> collaborators,
  ) async {
    try {
      final ids = collaborators.map((e) => e.value).toList();

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
