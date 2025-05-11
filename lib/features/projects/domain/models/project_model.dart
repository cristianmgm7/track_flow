import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/project.dart';

/// A model class that extends the Project entity with Firestore-specific functionality.
///
/// This class adds the ability to convert to/from Firestore documents
/// while keeping the core entity clean and framework-independent.
class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.description,
    required super.createdAt,
    required super.status,
    super.updatedAt,
  });

  /// Creates a ProjectModel instance from a Firestore document.
  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectModel(
      id: doc.id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      description: (data['description'] as String?) ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] as String,
    );
  }

  /// Converts the ProjectModel instance to a Map for Firestore storage.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }

  /// Creates a copy of this ProjectModel with the given fields replaced with new values.
  @override
  ProjectModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? createdAt,
    String? status,
    DateTime? updatedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      updatedAt: updatedAt,
    );
  }
}
