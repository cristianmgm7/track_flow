/// Represents a project entity in the application.
///
/// This is the core business entity that represents a project.
/// It contains only essential properties and value objects.
library;

import 'package:equatable/equatable.dart';

/// Pure entity class that represents a project in the domain
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

  /// Creates a copy of this Project with the given fields replaced with the new values.
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
}
