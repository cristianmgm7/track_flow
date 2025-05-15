/// Represents a project entity in the application.
///
/// This is the core business entity that represents a project.
/// It contains only essential properties and value objects.
library;

import 'package:equatable/equatable.dart';
import 'package:trackflow/features/projects/domain/entities/project_status.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';

/// Pure entity class that represents a project in the domain
class Project extends Equatable {
  final String id;
  final String title;
  final String description;
  final String userId;
  final ProjectStatus status;
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
    ProjectStatus? status,
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
      'status': status.value.fold((f) => null, (s) => s),
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
      status: ProjectStatus(map['status'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt:
          map['updatedAt'] != null
              ? DateTime.parse(map['updatedAt'] as String)
              : null,
    );
  }

  Either<ValidationFailure, Project> validate() {
    if (id.isEmpty) {
      return Left(ValidationFailure('Project ID is invalid'));
    }
    if (title.isEmpty) {
      return Left(ValidationFailure('Project title cannot be empty'));
    }
    if (userId.isEmpty) {
      return Left(ValidationFailure('User ID cannot be empty'));
    }
    if (status.value.isLeft()) {
      return Left(ValidationFailure('Invalid project status'));
    }
    return Right(this);
  }

  String get statusValue => status.value.fold((f) => '', (s) => s);

  String getDisplayStatus() {
    return statusValue.replaceAll('_', ' ').toUpperCase();
  }

  bool canEdit() {
    return statusValue != ProjectStatus.finished;
  }

  bool isActive() {
    return statusValue == ProjectStatus.inProgress;
  }

  Duration getDuration() {
    return DateTime.now().difference(createdAt);
  }

  String getFormattedDuration() {
    final duration = getDuration();
    if (duration.inDays > 0) {
      return '${duration.inDays} days';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours';
    } else {
      return '${duration.inMinutes} minutes';
    }
  }

  bool needsAttention() {
    if (statusValue != ProjectStatus.inProgress) return false;
    final duration = getDuration();
    if (duration.inDays > 30) return true;
    return false;
  }

  ProjectStatus getNextStatus() {
    switch (statusValue) {
      case ProjectStatus.draft:
        return ProjectStatus(ProjectStatus.inProgress);
      case ProjectStatus.inProgress:
        return ProjectStatus(ProjectStatus.finished);
      default:
        return status;
    }
  }

  Either<ValidationFailure, Project> progressStatus() {
    if (!canEdit()) {
      return Left(ValidationFailure('Cannot modify a finished project'));
    }
    final newProject = copyWith(
      status: getNextStatus(),
      updatedAt: DateTime.now(),
    );
    return Right(newProject);
  }

  bool canBeAssignedTo(String userId) {
    if (!canEdit()) return false;
    if (this.userId == userId) return true;
    // Add more complex assignment rules here
    return true;
  }

  double getCompletionPercentage() {
    switch (statusValue) {
      case ProjectStatus.draft:
        return 0.0;
      case ProjectStatus.inProgress:
        return 50.0;
      case ProjectStatus.finished:
        return 100.0;
      default:
        return 0.0;
    }
  }
}
