import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a music project in the application.
///
/// A project is the core entity that groups tasks, ideas, notes, and files
/// related to a specific music production.
class Project {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime createdAt;
  final String status;

  const Project({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.createdAt,
    required this.status,
  });

  /// Creates a Project instance from a Firestore document.
  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Project(
      id: doc.id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      description: data['description'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] as String,
    );
  }

  /// Converts the Project instance to a Map for Firestore storage.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }

  /// Creates a copy of this Project with the given fields replaced with new values.
  Project copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? createdAt,
    String? status,
  }) {
    return Project(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  /// Project status constants
  static const String statusDraft = 'draft';
  static const String statusInProgress = 'in_progress';
  static const String statusFinished = 'finished';

  /// List of valid project statuses
  static const List<String> validStatuses = [
    statusDraft,
    statusInProgress,
    statusFinished,
  ];
}
