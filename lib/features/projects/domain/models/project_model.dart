import 'package:dartz/dartz.dart';
import '../entities/project.dart';
import 'package:trackflow/core/error/failures.dart';

/// ProjectModel encapsulates all business logic and validation rules for Projects.
///
/// This model follows the Domain-Driven Design approach where complex business rules
/// and validations are separated from the pure entity.
class ProjectModel {
  final Project _project;

  const ProjectModel(this._project);

  // Getters to access entity properties
  String get id => _project.id;
  String get title => _project.title;
  String get description => _project.description;
  String get userId => _project.userId;
  String get status => _project.status;
  DateTime get createdAt => _project.createdAt;
  DateTime? get updatedAt => _project.updatedAt;

  /// Validates all business rules for a project
  Either<ValidationFailure, Project> validate() {
    // Only validate ID if it's not empty (for existing projects)
    if (id.isNotEmpty && id.isEmpty) {
      return Left(ValidationFailure('Project ID is invalid'));
    }

    if (title.isEmpty) {
      return Left(ValidationFailure('Project title cannot be empty'));
    }

    if (userId.isEmpty) {
      return Left(ValidationFailure('User ID cannot be empty'));
    }

    if (!Project.validStatuses.contains(status)) {
      return Left(ValidationFailure('Invalid project status: $status'));
    }

    return Right(_project);
  }

  /// Creates a copy of the project with updated fields
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
      updatedAt: updatedAt,
    );
  }

  /// Gets a user-friendly display status
  String getDisplayStatus() {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  /// Checks if the project can be edited based on its status
  bool canEdit() {
    return status != Project.statusFinished;
  }

  /// Checks if the project is active
  bool isActive() {
    return status == Project.statusInProgress;
  }

  /// Gets the project duration since creation
  Duration getDuration() {
    return DateTime.now().difference(createdAt);
  }

  /// Gets a formatted duration string
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

  /// Determines if the project needs attention based on business rules
  bool needsAttention() {
    if (status != Project.statusInProgress) return false;

    final duration = getDuration();
    if (duration.inDays > 30) return true; // Overdue threshold

    return false;
  }

  /// Gets the next logical status for the project
  String getNextStatus() {
    switch (status) {
      case Project.statusDraft:
        return Project.statusInProgress;
      case Project.statusInProgress:
        return Project.statusFinished;
      default:
        return status;
    }
  }

  /// Attempts to progress the project status
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

  /// Checks if the project can be assigned to a specific user
  bool canBeAssignedTo(String userId) {
    if (!canEdit()) return false;
    if (this.userId == userId) return true;

    // Add more complex assignment rules here
    return true;
  }

  /// Gets the estimated completion percentage
  double getCompletionPercentage() {
    switch (status) {
      case Project.statusDraft:
        return 0.0;
      case Project.statusInProgress:
        // Could be more complex based on tasks/milestones
        return 50.0;
      case Project.statusFinished:
        return 100.0;
      default:
        return 0.0;
    }
  }

  /// Converts the project to a map (for persistence)
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

  /// Creates a project from a map
  static Either<ValidationFailure, Project> fromMap(Map<String, dynamic> map) {
    try {
      final project = Project(
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

      return ProjectModel(project).validate();
    } catch (e) {
      return Left(ValidationFailure('Invalid project data: ${e.toString()}'));
    }
  }
}
