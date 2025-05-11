/// Represents a music project entity in the application.
///
/// This is the core business entity that represents a music project.
/// It contains only the essential business rules and properties,
/// independent of any framework or external concerns.
class Project {
  const Project({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime createdAt;
  final String status;

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
