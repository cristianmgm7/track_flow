/// Represents a project entity in the application.
///
/// This is the core business entity that represents a project.
/// It contains only essential properties and value objects.
library;

import 'package:equatable/equatable.dart';
import 'package:trackflow/features/projects/domain/entities/project_status.dart';
import 'package:trackflow/core/entities/user_id.dart';
import 'package:trackflow/features/projects/domain/entities/project_id.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';

/// Pure entity class that represents a project in the domain
class Project extends Equatable {
  final ProjectId id;
  final String title;
  final String description;
  final UserId userId;
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
    ProjectId? id,
    String? title,
    String? description,
    UserId? userId,
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

  Either<ValidationFailure, Project> validate() {
    if (title.isEmpty) {
      return Left(ValidationFailure('Project title cannot be empty'));
    }
    if (status.value.isLeft()) {
      return Left(ValidationFailure('Invalid project status'));
    }
    return Right(this);
  }

  String get statusValue => status.value.fold((f) => '', (s) => s);

  bool canEdit() {
    return statusValue != ProjectStatus.finished;
  }

  bool isActive() {
    return statusValue == ProjectStatus.inProgress;
  }

  Duration getDuration() {
    return DateTime.now().difference(createdAt);
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

  bool canBeAssignedTo(UserId userId) {
    if (!canEdit()) return false;
    if (this.userId == userId) return true;
    // Add more complex assignment rules here
    return true;
  }
}
