import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:equatable/equatable.dart';

enum CreativeRole {
  producer,
  composer,
  mixingEngineer,
  masteringEngineer,
  vocalist,
  instrumentalist,
  other,
}

class UserProfile extends Equatable {
  final UserId id;
  final String name;
  final String email;
  final String avatarUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final CreativeRole? creativeRole;
  final ProjectRole? role;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.createdAt,
    this.updatedAt,
    this.creativeRole,
    this.role,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    avatarUrl,
    createdAt,
    updatedAt,
    creativeRole,
    role,
  ];

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
