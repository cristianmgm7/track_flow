import 'package:trackflow/core/domain/aggregate_root.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';

enum CreativeRole {
  producer,
  composer,
  mixingEngineer,
  masteringEngineer,
  vocalist,
  instrumentalist,
  other,
}

class UserProfile extends AggregateRoot<UserId> {
  final String name;
  final String email;
  final String avatarUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final CreativeRole? creativeRole;
  final ProjectRole? role;

  const UserProfile({
    required UserId id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.createdAt,
    this.updatedAt,
    this.creativeRole,
    this.role,
  }) : super(id);


  UserProfile copyWith({
    UserId? id,
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    CreativeRole? creativeRole,
    ProjectRole? role,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      creativeRole: creativeRole ?? this.creativeRole,
      role: role ?? this.role,
    );
  }
}
