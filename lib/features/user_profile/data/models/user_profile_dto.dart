import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class UserProfileDTO {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final CreativeRole creativeRole;

  UserProfileDTO({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.createdAt,
    this.updatedAt,
    required this.creativeRole,
  });

  static const String collection = 'user_profile';

  factory UserProfileDTO.fromDomain(UserProfile userProfile) {
    return UserProfileDTO(
      id: userProfile.id.value,
      name: userProfile.name,
      email: userProfile.email,
      avatarUrl: userProfile.avatarUrl,
      createdAt: userProfile.createdAt,
      updatedAt: userProfile.updatedAt,
      creativeRole: userProfile.creativeRole ?? CreativeRole.other,
    );
  }

  UserProfile toDomain() {
    return UserProfile(
      id: UserId.fromUniqueString(id),
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      creativeRole: creativeRole,
    );
  }

  factory UserProfileDTO.fromJson(Map<String, dynamic> json) {
    DateTime? parsedCreatedAt;
    if (json['createdAt'] is Timestamp) {
      parsedCreatedAt = (json['createdAt'] as Timestamp).toDate();
    } else if (json['createdAt'] is String) {
      parsedCreatedAt = DateTime.tryParse(json['createdAt'] as String);
    }

    DateTime? parsedUpdatedAt;
    if (json['updatedAt'] is Timestamp) {
      parsedUpdatedAt = (json['updatedAt'] as Timestamp).toDate();
    } else if (json['updatedAt'] is String) {
      parsedUpdatedAt = DateTime.tryParse(json['updatedAt'] as String);
    }

    return UserProfileDTO(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'No Name',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      createdAt: parsedCreatedAt ?? DateTime.now(),
      updatedAt: parsedUpdatedAt,
      creativeRole: _parseCreativeRole(json['creativeRole'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'creativeRole': creativeRole.name,
    };
  }

  UserProfileDTO copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    CreativeRole? creativeRole,
  }) {
    return UserProfileDTO(
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

CreativeRole _parseCreativeRole(String? roleName) {
  if (roleName == null) {
    return CreativeRole.other;
  }
  try {
    return CreativeRole.values.byName(roleName);
  } catch (e) {
    return CreativeRole.other;
  }
}
