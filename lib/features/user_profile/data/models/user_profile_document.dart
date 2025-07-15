import 'package:isar/isar.dart';
import 'package:trackflow/features/projects/data/models/project_document.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

part 'user_profile_document.g.dart';

@collection
class UserProfileDocument {
  Id get isarId => fastHash(id);

  @Index(unique: true)
  late String id;

  late String name;

  @Index(unique: true)
  late String email;

  late String avatarUrl;
  late DateTime createdAt;
  DateTime? updatedAt;

  @Enumerated(EnumType.name)
  late CreativeRole creativeRole;

  UserProfileDocument();

  factory UserProfileDocument.fromDTO(UserProfileDTO dto) {
    return UserProfileDocument()
      ..id = dto.id
      ..name = dto.name
      ..email = dto.email
      ..avatarUrl = dto.avatarUrl
      ..createdAt = dto.createdAt
      ..updatedAt = dto.updatedAt
      ..creativeRole = dto.creativeRole;
  }

  UserProfileDTO toDTO() {
    return UserProfileDTO(
      id: id,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      creativeRole: creativeRole,
    );
  }
}
