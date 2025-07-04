class MagicLinkRequestDto {
  final String projectId;
  final String userId;

  MagicLinkRequestDto({
    required this.projectId,
    required this.userId,
  });
}

class MagicLinkValidationDto {
  final String linkId;

  MagicLinkValidationDto({
    required this.linkId,
  });
}

class MagicLinkStatusDto {
  final String linkId;

  MagicLinkStatusDto({
    required this.linkId,
  });
}