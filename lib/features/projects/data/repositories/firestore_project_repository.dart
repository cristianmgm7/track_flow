import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/project.dart';
import '../../domain/repositories/project_repository.dart';

/// Implementation of [ProjectRepository] using Firestore as the data source.
class FirestoreProjectRepository implements ProjectRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'projects';

  FirestoreProjectRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Project> createProject(Project project) async {
    final docRef = await _firestore
        .collection(_collection)
        .add(project.toFirestore());
    return project.copyWith(id: docRef.id);
  }

  @override
  Future<void> updateProject(Project project) async {
    await _firestore
        .collection(_collection)
        .doc(project.id)
        .update(project.toFirestore());
  }

  @override
  Future<void> deleteProject(String projectId) async {
    await _firestore.collection(_collection).doc(projectId).delete();
  }

  @override
  Future<Project?> getProject(String projectId) async {
    final doc = await _firestore.collection(_collection).doc(projectId).get();
    if (!doc.exists) return null;
    return Project.fromFirestore(doc);
  }

  @override
  Stream<List<Project>> getUserProjects(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Project.fromFirestore(doc)).toList(),
        );
  }

  @override
  Stream<List<Project>> getUserProjectsByStatus(String userId, String status) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Project.fromFirestore(doc)).toList(),
        );
  }
}
