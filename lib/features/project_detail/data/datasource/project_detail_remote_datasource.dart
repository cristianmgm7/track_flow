import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

abstract class ProjectDetailRemoteDataSource {
  Future<Either<Failure, Project>> fetchProjectDetails(ProjectId projectId);
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
  Future<Either<Failure, Project>> fetchProjectDetails(
    ProjectId projectId,
  ) async {
    try {
      final doc =
          await _firestore
              .collection(ProjectDTO.collection)
              .doc(projectId.value)
              .get();
      if (!doc.exists) {
        return left(DatabaseFailure('Project not found'));
      }
      final project = ProjectDTO.fromJson(doc.data()!).toDomain();
      return right(project);
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
