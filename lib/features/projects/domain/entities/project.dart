import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/playlist/domain/entities/playlist_id.dart';
import 'package:trackflow/features/projects/domain/entities/project_collaborator.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_permission.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_description.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_name.dart';
import 'package:trackflow/core/domain/aggregate_root.dart';
import 'package:trackflow/features/projects/domain/exceptions/project_exceptions.dart';
import 'package:trackflow/features/manage_collaborators/domain/exceptions/manage_collaborator_exception.dart'
    as manage_collab_exc;
import 'package:trackflow/features/playlist/domain/entities/playlist.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';

export 'package:trackflow/features/projects/domain/value_objects/project_name.dart';
export 'package:trackflow/features/projects/domain/value_objects/project_description.dart';

class Project extends AggregateRoot<ProjectId> {
  @override
  final ProjectId id;
  final UserId ownerId;
  final ProjectName name;
  final ProjectDescription description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<ProjectCollaborator> collaborators;
  final bool isDeleted;

  Project({
    required ProjectId id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    List<ProjectCollaborator>? collaborators,
    this.isDeleted = false,
  }) : id = id,
       collaborators = collaborators ?? [],
       super(id);

  Project copyWith({
    ProjectId? id,
    UserId? ownerId,
    ProjectName? name,
    ProjectDescription? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ProjectCollaborator>? collaborators,
    bool? isDeleted,
  }) {
    return Project(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      collaborators: collaborators ?? this.collaborators,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Project updateProject({
    required UserId requester,
    ProjectName? newName,
    ProjectDescription? newDescription,
  }) {
    final requesterCollaborator = collaborators.firstWhere(
      (collaborator) => collaborator.userId == requester,
      orElse: () => throw UserNotCollaboratorException(),
    );

    if (!requesterCollaborator.hasPermission(ProjectPermission.editProject)) {
      throw ProjectPermissionException();
    }

    return copyWith(
      name: newName ?? name,
      description: newDescription ?? description,
      updatedAt: DateTime.now(),
    );
  }

  Project deleteProject({required UserId requester}) {
    final requesterCollaborator = collaborators.firstWhere(
      (collaborator) => collaborator.userId == requester,
      orElse: () => throw ProjectNotFoundException(),
    );

    if (!requesterCollaborator.hasPermission(ProjectPermission.deleteProject)) {
      throw ProjectPermissionException();
    }

    return copyWith(updatedAt: DateTime.now(), isDeleted: true);
  }

  Project addCollaborator(ProjectCollaborator collaborator) {
    if (collaborators.any((c) => c.userId == collaborator.userId)) {
      throw const manage_collab_exc.CollaboratorAlreadyExistsException();
    }
    final updatedCollaborators = List<ProjectCollaborator>.from(collaborators)
      ..add(collaborator);
    return copyWith(
      collaborators: updatedCollaborators,
      updatedAt: DateTime.now(),
    );
  }

  Project removeCollaborator(UserId userId) {
    if (userId == ownerId) {
      throw Exception('Cannot remove the project owner');
    }
    if (!collaborators.any((collaborator) => collaborator.userId == userId)) {
      throw CollaboratorNotFoundException();
    }
    final updatedCollaborators = List<ProjectCollaborator>.from(collaborators)
      ..removeWhere((collaborator) => collaborator.userId == userId);

    return copyWith(
      collaborators: updatedCollaborators,
      updatedAt: DateTime.now(),
    );
  }

  Project updateCollaboratorRole(
    UserId requester,
    UserId userId,
    ProjectRole role,
  ) {
    // Validate that the requester has permission to update collaborator roles
    final requesterCollaborator = collaborators.firstWhere(
      (collaborator) => collaborator.userId == requester,
      orElse: () => throw UserNotCollaboratorException(),
    );

    if (!requesterCollaborator.hasPermission(
      ProjectPermission.updateCollaboratorRole,
    )) {
      throw ProjectPermissionException();
    }

    // Prevent users from changing their own role
    if (requester == userId) {
      throw Exception('Cannot change your own role');
    }

    // Find the collaborator to update
    final collaborator = collaborators.firstWhere(
      (collaborator) => collaborator.userId == userId,
      orElse: () => throw CollaboratorNotFoundException(),
    );

    // Create updated collaborator with new role
    final updatedCollaborator = ProjectCollaborator.rebuild(
      id: collaborator.id,
      userId: collaborator.userId,
      role: role,
      specificPermissions: collaborator.specificPermissions,
    );

    // Update the collaborators list
    final updatedCollaborators =
        List<ProjectCollaborator>.from(collaborators)
          ..removeWhere((collaborator) => collaborator.userId == userId)
          ..add(updatedCollaborator);

    return copyWith(
      collaborators: updatedCollaborators,
      updatedAt: DateTime.now(),
    );
  }
}

extension ProjectPlaylist on Project {
  Playlist toPlaylist(List<AudioTrack> tracks) {
    return Playlist(
      id: PlaylistId.fromUniqueString(id.value.toString()),
      name: name.value.getOrElse(() => 'Project Playlist'),
      trackIds: tracks.map((t) => t.id.value).toList(),
      playlistSource: PlaylistSource.project,
    );
  }
}
