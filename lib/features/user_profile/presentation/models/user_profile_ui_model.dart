import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

/// UI model wrapping UserProfile domain entity with unwrapped primitives
class UserProfileUiModel extends Equatable {
  final UserProfile profile; // Composition pattern

  // Unwrapped primitives
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String? avatarLocalPath;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? creativeRole;
  final String? projectRole;

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

  // Contact
  final ContactInfo? contactInfo;

  // Meta
  final bool verified;

  // UI-specific computed fields
  final String displayName;
  final String initials;

  const UserProfileUiModel({
    required this.profile,
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.avatarLocalPath,
    required this.createdAt,
    this.updatedAt,
    this.creativeRole,
    this.projectRole,
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
    required this.displayName,
    required this.initials,
  });

  factory UserProfileUiModel.fromDomain(UserProfile profile) {
    final name = profile.name;
    return UserProfileUiModel(
      profile: profile,
      id: profile.id.value,
      name: name,
      email: profile.email,
      avatarUrl: profile.avatarUrl,
      avatarLocalPath: profile.avatarLocalPath,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
      creativeRole: profile.creativeRole?.toString(),
      projectRole: profile.role?.toString(),
      description: profile.description,
      location: profile.location,
      roles: profile.roles,
      genres: profile.genres,
      skills: profile.skills,
      availabilityStatus: profile.availabilityStatus,
      socialLinks: profile.socialLinks,
      websiteUrl: profile.websiteUrl,
      linktreeUrl: profile.linktreeUrl,
      contactInfo: profile.contactInfo,
      verified: profile.verified,
      displayName: name.isNotEmpty ? name : profile.email.split('@').first,
      initials: _getInitials(name),
    );
  }

  static String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    avatarUrl,
    avatarLocalPath,
    createdAt,
    updatedAt,
    creativeRole,
    projectRole,
    description,
    location,
    roles,
    genres,
    skills,
    availabilityStatus,
    socialLinks,
    websiteUrl,
    linktreeUrl,
    contactInfo,
    verified,
    displayName,
    initials,
  ];
}
