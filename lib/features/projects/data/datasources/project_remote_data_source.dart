import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_dto.dart';

/// Abstract class defining the contract for remote project operations.
abstract class ProjectRemoteDataSource {
  /// Creates a new project in the remote database.
  Future<String> createProject(ProjectDTO project);

  /// Updates an existing project in the remote database.
  Future<void> updateProject(String id, ProjectDTO project);

  /// Deletes a project from the remote database.
  Future<void> deleteProject(String id);

  /// Gets a project by its ID from the remote database.
  Future<ProjectDTO?> getProject(String id);

  /// Gets all projects for a specific user from the remote database.
  Stream<List<ProjectDTO>> getUserProjects(String userId);

  /// Gets all projects for a specific user with a given status from the remote database.
  Stream<List<ProjectDTO>> getUserProjectsByStatus(
    String userId,
    String status,
  );
}

/// Implementation of [ProjectRemoteDataSource] using Firestore.
class FirestoreProjectRemoteDataSource implements ProjectRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreProjectRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String> createProject(ProjectDTO project) async {
    final docRef = await _firestore
        .collection(ProjectDTO.collection)
        .add(project.toFirestore());
    return docRef.id;
  }

  @override
  Future<void> updateProject(String id, ProjectDTO project) async {
    await _firestore
        .collection(ProjectDTO.collection)
        .doc(id)
        .update(project.toFirestore());
  }

  @override
  Future<void> deleteProject(String id) async {
    await _firestore.collection(ProjectDTO.collection).doc(id).delete();
  }

  @override
  Future<ProjectDTO?> getProject(String id) async {
    final doc =
        await _firestore.collection(ProjectDTO.collection).doc(id).get();
    if (!doc.exists) return null;
    return ProjectDTO.fromFirestore(doc);
  }

  @override
  Stream<List<ProjectDTO>> getUserProjects(String userId) {
    return _firestore
        .collection(ProjectDTO.collection)
        .where(ProjectDTO.fieldUserId, isEqualTo: userId)
        .orderBy(ProjectDTO.fieldCreatedAt, descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ProjectDTO.fromFirestore(doc))
                  .toList(),
        );
  }

  @override
  Stream<List<ProjectDTO>> getUserProjectsByStatus(
    String userId,
    String status,
  ) {
    return _firestore
        .collection(ProjectDTO.collection)
        .where(ProjectDTO.fieldUserId, isEqualTo: userId)
        .where(ProjectDTO.fieldStatus, isEqualTo: status)
        .orderBy(ProjectDTO.fieldCreatedAt, descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ProjectDTO.fromFirestore(doc))
                  .toList(),
        );
  }
}
