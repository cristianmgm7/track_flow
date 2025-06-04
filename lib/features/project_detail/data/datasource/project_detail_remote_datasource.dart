import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/features/project_detail/data/models/project_detail_dto.dart';

class ProjectDetailRemoteDataSource {
  final FirebaseFirestore firestore;

  ProjectDetailRemoteDataSource({required this.firestore});

  Future<Either<Failure, ProjectDetailDTO>> fetchProjectDetailById(
    ProjectId projectId,
  ) async {
    try {
      final doc =
          await firestore
              .collection(ProjectDetailDTO.collection)
              .doc(projectId.value)
              .get();
      if (doc.exists) {
        final projectDetailDTO = ProjectDetailDTO.fromJson(doc.data()!);
        return right(projectDetailDTO);
      } else {
        return left(UnexpectedFailure('Project not found'));
      }
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  Future<Either<Failure, Unit>> leaveProject({
    required ProjectId projectId,
    required UserId userId,
  }) async {
    try {
      final docRef = firestore
          .collection(ProjectDetailDTO.collection)
          .doc(projectId.value);
      await docRef.update({
        'collaborators': FieldValue.arrayRemove([userId.value]),
      });
      return right(unit);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }
}
