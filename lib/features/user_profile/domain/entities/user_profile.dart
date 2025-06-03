import 'package:trackflow/core/entities/unique_id.dart';

enum CreativeRole {
  producer,
  composer,
  mixingEngineer,
  masteringEngineer,
  vocalist,
  instrumentalist,
  other,
}

class UserProfile {
  final UserId id;
  final String name;
  final String email;
  final String avatarUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final CreativeRole? creativeRole;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.createdAt,
    this.updatedAt,
    this.creativeRole,
  });

  UserProfile copyWith({
    UserId? id,
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    CreativeRole? creativeRole,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      creativeRole: creativeRole ?? this.creativeRole,
    );
  }
}
