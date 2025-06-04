import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/entities/user_role.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class ManageCollaboratorsRemoteDataSource {
  Future<Either<Failure, List<UserProfile>>> getProjectCollaborators(
    ProjectId projectId,
    List<UserId> collaborators,
  );
  Future<Either<Failure, void>> addCollaborator(
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
  Future<Either<Failure, void>> addCollaborator(
    ProjectId projectId,
    UserId userId,
  ) {
    // TODO: implement addCollaborator
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> removeCollaborator(
    ProjectId projectId,
    UserId userId,
  ) {
    // TODO: implement removeCollaborator
    throw UnimplementedError();
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
