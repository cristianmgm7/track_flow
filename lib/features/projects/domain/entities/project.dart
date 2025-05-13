/// Represents a music project entity in the application.
///
/// This is the core business entity that represents a music project.
/// It contains only the essential business rules and properties,
/// independent of any framework or external concerns.
library;

import 'package:equatable/equatable.dart';

class Project extends Equatable {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

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

  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    userId,
    status,
    createdAt,
    updatedAt,
  ];

  /// Creates a copy of this Project with the given fields replaced with new values.
  Project copyWith({
    String? id,
    String? title,
    String? description,
    String? userId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      userId: map['userId'] as String,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt:
          map['updatedAt'] != null
              ? DateTime.parse(map['updatedAt'] as String)
              : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(id, userId, title, description, createdAt, status);
  }
}
