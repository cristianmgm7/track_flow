import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

abstract class ProjectDetailRemoteDataSource {
  Future<Either<Failure, Project>> getProjectById(ProjectId projectId);
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
}
