import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackflow/features/invitations/domain/entities/project_invitation.dart';
import 'package:trackflow/features/invitations/domain/entities/invitation_id.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';

/// Data Transfer Object for ProjectInvitation
/// Used for serialization/deserialization between domain and data layers
class InvitationDto {
  final String id;
  final String projectId;
  final String invitedByUserId;
  final String? invitedUserId; // For existing users
  final String invitedEmail;
  final String proposedRole;
  final String? message;
  final String status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? respondedAt;
  final String? responseMessage;

  // Sync metadata fields for offline-first functionality
  final int version;
  final DateTime? lastModified;

  const InvitationDto({
    required this.id,
    required this.projectId,
    required this.invitedByUserId,
    this.invitedUserId,
    required this.invitedEmail,
    required this.proposedRole,
    this.message,
    required this.status,
    required this.createdAt,
    this.expiresAt,
    this.respondedAt,
    this.responseMessage,
    // Sync metadata
    this.version = 1,
    this.lastModified,
  });

  static const String collection = 'project_invitations';

  /// Convert domain entity to DTO
  factory InvitationDto.fromDomain(ProjectInvitation invitation) {
    return InvitationDto(
      id: invitation.id.value,
      projectId: invitation.projectId.value,
      invitedByUserId: invitation.invitedByUserId.value,
      invitedUserId: invitation.invitedUserId?.value,
      invitedEmail: invitation.invitedEmail,
      proposedRole: invitation.proposedRole.toShortString(),
      message: invitation.message,
      status: invitation.status.name,
      createdAt: invitation.createdAt,
      expiresAt: invitation.expiresAt,
      // Sync metadata
      version: 1, // Initial version for new invitations
      lastModified: invitation.createdAt,
    );
  }

  /// Convert DTO to domain entity
  ProjectInvitation toDomain() {
    return ProjectInvitation(
      id: InvitationId.fromUniqueString(id),
      projectId: ProjectId.fromUniqueString(projectId),
      invitedByUserId: UserId.fromUniqueString(invitedByUserId),
      invitedUserId:
          invitedUserId != null
              ? UserId.fromUniqueString(invitedUserId!)
              : null,
      invitedEmail: invitedEmail,
      proposedRole: ProjectRole.fromString(proposedRole),
      message: message,
      createdAt: createdAt,
      expiresAt:
          expiresAt ?? createdAt.add(const Duration(days: 7)), // Default 7 days
      status: InvitationStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => InvitationStatus.pending,
      ),
    );
  }

  /// Create from Firestore JSON
  factory InvitationDto.fromJson(Map<String, dynamic> json) {
    DateTime? parsedCreatedAt;
    if (json['createdAt'] is Timestamp) {
      parsedCreatedAt = (json['createdAt'] as Timestamp).toDate();
    } else if (json['createdAt'] is String) {
      parsedCreatedAt = DateTime.tryParse(json['createdAt'] as String);
    }

    DateTime? parsedExpiresAt;
    if (json['expiresAt'] is Timestamp) {
      parsedExpiresAt = (json['expiresAt'] as Timestamp).toDate();
    } else if (json['expiresAt'] is String) {
      parsedExpiresAt = DateTime.tryParse(json['expiresAt'] as String);
    }

    DateTime? parsedRespondedAt;
    if (json['respondedAt'] is Timestamp) {
      parsedRespondedAt = (json['respondedAt'] as Timestamp).toDate();
    } else if (json['respondedAt'] is String) {
      parsedRespondedAt = DateTime.tryParse(json['respondedAt'] as String);
    }

    DateTime? parsedLastModified;
    if (json['lastModified'] is Timestamp) {
      parsedLastModified = (json['lastModified'] as Timestamp).toDate();
    } else if (json['lastModified'] is String) {
      parsedLastModified = DateTime.tryParse(json['lastModified'] as String);
    }

    return InvitationDto(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      invitedByUserId: json['invitedByUserId'] as String? ?? '',
      invitedUserId: json['invitedUserId'] as String?,
      invitedEmail: json['invitedEmail'] as String? ?? '',
      proposedRole: json['proposedRole'] as String? ?? 'viewer',
      message: json['message'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: parsedCreatedAt ?? DateTime.now(),
      expiresAt: parsedExpiresAt,
      respondedAt: parsedRespondedAt,
      responseMessage: json['responseMessage'] as String?,
      // Sync metadata
      version: json['version'] as int? ?? 1,
      lastModified: parsedLastModified,
    );
  }

  /// Convert to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'invitedByUserId': invitedByUserId,
      'invitedUserId': invitedUserId,
      'invitedEmail': invitedEmail,
      'proposedRole': proposedRole,
      'message': message,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
      'responseMessage': responseMessage,
      // Sync metadata
      'version': version,
      'lastModified': lastModified?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  InvitationDto copyWith({
    String? id,
    String? projectId,
    String? invitedByUserId,
    String? invitedUserId,
    String? invitedEmail,
    String? proposedRole,
    String? message,
    String? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? respondedAt,
    String? responseMessage,
    int? version,
    DateTime? lastModified,
  }) {
    return InvitationDto(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      invitedByUserId: invitedByUserId ?? this.invitedByUserId,
      invitedUserId: invitedUserId ?? this.invitedUserId,
      invitedEmail: invitedEmail ?? this.invitedEmail,
      proposedRole: proposedRole ?? this.proposedRole,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      respondedAt: respondedAt ?? this.respondedAt,
      responseMessage: responseMessage ?? this.responseMessage,
      version: version ?? this.version,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvitationDto &&
        other.id == id &&
        other.projectId == projectId &&
        other.invitedByUserId == invitedByUserId &&
        other.invitedUserId == invitedUserId &&
        other.invitedEmail == invitedEmail &&
        other.proposedRole == proposedRole &&
        other.message == message &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.expiresAt == expiresAt &&
        other.respondedAt == respondedAt &&
        other.responseMessage == responseMessage &&
        other.version == version &&
        other.lastModified == lastModified;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      projectId,
      invitedByUserId,
      invitedUserId,
      invitedEmail,
      proposedRole,
      message,
      status,
      createdAt,
      expiresAt,
      respondedAt,
      responseMessage,
      version,
      lastModified,
    );
  }

  @override
  String toString() {
    return 'InvitationDto(id: $id, projectId: $projectId, invitedEmail: $invitedEmail, status: $status)';
  }
}
