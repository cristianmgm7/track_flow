class JoinProjectDto {
  final String projectId;
  final String userId;

  JoinProjectDto({
    required this.projectId,
    required this.userId,
  });
}

class LeaveProjectDto {
  final String projectId;
  final String userId;

  LeaveProjectDto({
    required this.projectId,
    required this.userId,
  });
}

class GetCollaboratorsDto {
  final String projectId;
  final List<String> collaboratorIds;

  GetCollaboratorsDto({
    required this.projectId,
    required this.collaboratorIds,
  });
}