import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../models/project_dto.dart';

/// Implementation of [ProjectRepository] using Firestore as the data source.
class FirestoreProjectRepository implements ProjectRepository {
  final FirebaseFirestore _firestore;

  FirestoreProjectRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Project> createProject(Project project) async {
    final dto = ProjectDTO.fromEntity(project);
    final docRef = await _firestore
        .collection(ProjectDTO.collection)
        .add(dto.toFirestore());

    return project.copyWith(id: docRef.id);
  }

  @override
  Future<void> updateProject(Project project) async {
    final dto = ProjectDTO.fromEntity(project);
    await _firestore
        .collection(ProjectDTO.collection)
        .doc(project.id)
        .update(dto.toFirestore());
  }

  @override
  Future<void> deleteProject(String projectId) async {
    await _firestore.collection(ProjectDTO.collection).doc(projectId).delete();
  }

  @override
  Future<Project?> getProject(String projectId) async {
    final doc =
        await _firestore.collection(ProjectDTO.collection).doc(projectId).get();
    if (!doc.exists) return null;

    return ProjectDTO.fromFirestore(doc).toEntity();
  }

  @override
  Stream<List<Project>> getUserProjects(String userId) {
    return _firestore
        .collection(ProjectDTO.collection)
        .where(ProjectDTO.fieldUserId, isEqualTo: userId)
        .orderBy(ProjectDTO.fieldCreatedAt, descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ProjectDTO.fromFirestore(doc).toEntity())
                  .toList(),
        );
  }

  @override
  Stream<List<Project>> getUserProjectsByStatus(String userId, String status) {
    return _firestore
        .collection(ProjectDTO.collection)
        .where(ProjectDTO.fieldUserId, isEqualTo: userId)
        .where(ProjectDTO.fieldStatus, isEqualTo: status)
        .orderBy(ProjectDTO.fieldCreatedAt, descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ProjectDTO.fromFirestore(doc).toEntity())
                  .toList(),
        );
  }
}
