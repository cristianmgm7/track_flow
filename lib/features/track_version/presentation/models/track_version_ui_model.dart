import 'package:equatable/equatable.dart';
import '../../domain/entities/track_version.dart';

/// UI model wrapping TrackVersion domain entity with unwrapped primitives
class TrackVersionUiModel extends Equatable {
  final TrackVersion version;

  // Unwrapped primitives
  final String id;
  final String trackId;
  final int versionNumber;
  final String? label;
  final String? fileLocalPath;
  final String? fileRemoteUrl;
  final int? durationMs;
  final String status;
  final DateTime createdAt;
  final String createdBy;

  // UI-specific computed fields
  final String displayLabel;
  final String formattedDuration;
  final bool hasLocalFile;

  const TrackVersionUiModel({
    required this.version,
    required this.id,
    required this.trackId,
    required this.versionNumber,
    this.label,
    this.fileLocalPath,
    this.fileRemoteUrl,
    this.durationMs,
    required this.status,
    required this.createdAt,
    required this.createdBy,
    required this.displayLabel,
    required this.formattedDuration,
    required this.hasLocalFile,
  });

  factory TrackVersionUiModel.fromDomain(TrackVersion version) {
    return TrackVersionUiModel(
      version: version,
      id: version.id.value,
      trackId: version.trackId.value,
      versionNumber: version.versionNumber,
      label: version.label,
      fileLocalPath: version.fileLocalPath,
      fileRemoteUrl: version.fileRemoteUrl,
      durationMs: version.durationMs,
      status: version.status.toString(),
      createdAt: version.createdAt,
      createdBy: version.createdBy.value,
      displayLabel: version.label ?? 'Version ${version.versionNumber}',
      formattedDuration: version.durationMs != null
          ? _formatDuration(Duration(milliseconds: version.durationMs!))
          : '--:--',
      hasLocalFile: version.fileLocalPath != null,
    );
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
        id,
        trackId,
        versionNumber,
        label,
        fileLocalPath,
        fileRemoteUrl,
        durationMs,
        status,
        createdAt,
        createdBy,
        displayLabel,
        formattedDuration,
        hasLocalFile,
      ];
}

