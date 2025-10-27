import 'package:equatable/equatable.dart';
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

class ContactInfo extends Equatable {
  final String? phone;
  const ContactInfo({this.phone});
  @override
  List<Object?> get props => [phone];
}

class SocialLink extends Equatable {
  final String platform; // instagram, twitter, spotify, etc
  final String url;
  const SocialLink({required this.platform, required this.url});
  @override
  List<Object?> get props => [platform, url];
}

class UserProfile extends AggregateRoot<UserId> {
  final String name;
  final String email;
  final String avatarUrl; // remote URL (http/https) when disponible
  final String? avatarLocalPath; // local cache path (solo local)
  final DateTime createdAt;
  final DateTime? updatedAt;
  final CreativeRole? creativeRole;
  final ProjectRole? role;

  // Professional context
  final String? description;
  final String? location;
  final List<String>? roles;
  final List<String>? genres;
  final List<String>? skills;
  final String? availabilityStatus;

  // External links
  final List<SocialLink>? socialLinks;
  final String? websiteUrl;
  final String? linktreeUrl;

  // Contact (display only)
  final ContactInfo? contactInfo;

  // Meta
  final bool verified;

  const UserProfile({
    required UserId id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.avatarLocalPath,
    required this.createdAt,
    this.updatedAt,
    this.creativeRole,
    this.role,
    this.description,
    this.location,
    this.roles,
    this.genres,
    this.skills,
    this.availabilityStatus,
    this.socialLinks,
    this.websiteUrl,
    this.linktreeUrl,
    this.contactInfo,
    this.verified = false,
  }) : super(id);

  UserProfile copyWith({
    UserId? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? avatarLocalPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    CreativeRole? creativeRole,
    ProjectRole? role,
    String? description,
    String? location,
    List<String>? roles,
    List<String>? genres,
    List<String>? skills,
    String? availabilityStatus,
    List<SocialLink>? socialLinks,
    String? websiteUrl,
    String? linktreeUrl,
    ContactInfo? contactInfo,
    bool? verified,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarLocalPath: avatarLocalPath ?? this.avatarLocalPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      creativeRole: creativeRole ?? this.creativeRole,
      role: role ?? this.role,
      description: description ?? this.description,
      location: location ?? this.location,
      roles: roles ?? this.roles,
      genres: genres ?? this.genres,
      skills: skills ?? this.skills,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      socialLinks: socialLinks ?? this.socialLinks,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      linktreeUrl: linktreeUrl ?? this.linktreeUrl,
      contactInfo: contactInfo ?? this.contactInfo,
      verified: verified ?? this.verified,
    );
  }
}
