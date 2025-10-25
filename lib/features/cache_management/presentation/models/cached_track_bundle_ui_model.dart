import 'package:equatable/equatable.dart';
import '../../domain/entities/cached_track_bundle.dart';
import '../../../audio_track/presentation/models/audio_track_ui_model.dart';
import '../../../track_version/presentation/models/track_version_ui_model.dart';
import '../../../user_profile/presentation/models/user_profile_ui_model.dart';

/// UI model wrapping CachedTrackBundle with UI-friendly data
class CachedTrackBundleUiModel extends Equatable {
  final CachedTrackBundle bundle;

  // Unwrapped UI models and primitives
  final String trackId;
  final String versionId;
  final AudioTrackUiModel? track;
  final TrackVersionUiModel? version;
  final UserProfileUiModel? uploader;
  final String? projectName;
  final int? fileSizeBytes;
  final DateTime? cachedAt;

  // UI-specific computed fields
  final String formattedSize;
  final String displayName;
  final bool isDownloading;

  const CachedTrackBundleUiModel({
    required this.bundle,
    required this.trackId,
    required this.versionId,
    this.track,
    this.version,
    this.uploader,
    this.projectName,
    this.fileSizeBytes,
    this.cachedAt,
    required this.formattedSize,
    required this.displayName,
    required this.isDownloading,
  });

  factory CachedTrackBundleUiModel.fromDomain(CachedTrackBundle bundle) {
    return CachedTrackBundleUiModel(
      bundle: bundle,
      trackId: bundle.trackId,
      versionId: bundle.versionId,
      track: bundle.track != null 
        ? AudioTrackUiModel.fromDomain(bundle.track!)
        : null,
      version: bundle.version != null
        ? TrackVersionUiModel.fromDomain(bundle.version!)
        : null,
      uploader: bundle.uploader != null
        ? UserProfileUiModel.fromDomain(bundle.uploader!)
        : null,
      projectName: bundle.projectName,
      fileSizeBytes: bundle.cached.fileSizeBytes,
      cachedAt: bundle.cached.cachedAt,
      formattedSize: _formatBytes(bundle.cached.fileSizeBytes),
      displayName: _computeDisplayName(bundle),
      isDownloading: bundle.activeDownload != null,
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB';
  }

  static String _computeDisplayName(CachedTrackBundle bundle) {
    // Try track name first
    if (bundle.track != null) {
      return bundle.track!.name;
    }
    // Fall back to version label
    if (bundle.version != null && bundle.version!.label != null) {
      return bundle.version!.label!;
    }
    // Last resort: version ID
    return 'Version ${bundle.versionId}';
  }

  @override
  List<Object?> get props => [
    trackId,
    versionId,
    track,
    version,
    uploader,
    projectName,
    fileSizeBytes,
    cachedAt,
    formattedSize,
    displayName,
    isDownloading,
  ];
}

